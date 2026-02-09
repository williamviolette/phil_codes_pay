"""
Translate of obj.m — core objective function.

Contains:
  - obj()             : main function (grid → VFI → simulation → moments)
  - _bellman_step()   : Numba-compiled fused max+argmax for VFI (the hot kernel)
  - _simulate_nb()    : Numba-compiled simulation loop
"""
import numpy as np
from numba import njit, prange

from .grid_int_full import grid_int_full
from .gen_curve_quad import gen_curve_quad, gen_curve_quad_scalar_nb


# =========================================================================
# Numba VFI kernel — fused max + argmax, no temporary N×N allocation
# =========================================================================

@njit(parallel=True, cache=True)
def _bellman_step(util, cont, penalty, tv, td):
    """
    For each column j (current state), find the row i (choice) that
    maximizes  util[i, j] - penalty[i, j] + cont[i].

    Fuses max + argmax into a single pass.  No N×N temporary.
    Parallelized across columns via prange.

    Parameters
    ----------
    util    : (N, N) float64, Fortran-contiguous preferred
    cont    : (N,)   float64, continuation value per choice
    penalty : (N, N) float64, penalty matrix (same layout as util)
    tv      : (N,)   float64, output — max values
    td      : (N,)   int64,   output — argmax indices (0-based)
    """
    N = util.shape[1]
    M = util.shape[0]
    for j in prange(N):
        best_val = -1.0e300
        best_idx = 0
        for i in range(M):
            val = util[i, j] - penalty[i, j] + cont[i]
            if val > best_val:
                best_val = val
                best_idx = i
        tv[j] = best_val
        td[j] = best_idx


@njit(parallel=True, cache=True)
def _bellman_step_nopen(util, cont, tv, td):
    """
    Same as _bellman_step but without penalty (saves memory access).
    bellman[i,j] = util[i,j] + cont[i]
    """
    N = util.shape[1]
    M = util.shape[0]
    for j in prange(N):
        best_val = -1.0e300
        best_idx = 0
        for i in range(M):
            val = util[i, j] + cont[i]
            if val > best_val:
                best_val = val
                best_idx = i
        tv[j] = best_val
        td[j] = best_idx


def obj(given, nA, sigA, Alb, Aub, nB, sigB, nD, s, int_size, refinement, X,
        precomputed_grid=None):
    """
    Evaluate the structural model at parameter vector `given`.

    Parameters
    ----------
    given : 1-D array of length >= 20
    precomputed_grid : optional tuple to skip grid construction on repeated calls

    Returns
    -------
    h_out    : (6,) simulated moments
    util_val : scalar welfare
    controls : (Tsim*Acc, 7) simulation controls
    nA, nB   : grid sizes
    A, B     : state-space matrices
    """
    # ---- Unpack parameters (0-based indexing) ----
    r_lend      = given[0]
    r_water     = given[1]
    r_high      = given[2]
    h_param     = given[3]
    theta       = given[4]
    untied      = given[5]
    alpha       = given[6]
    beta_up     = given[7]
    Y           = given[8]
    p1          = given[9]
    p2          = given[10]
    pd          = given[11]
    n           = given[12]
    curve       = given[13]
    fee         = given[14]
    vh          = given[15]
    prob_caught = given[16]
    prob_move   = given[17]
    Blb         = given[18]
    Tg          = int(given[19])

    n = int(n)

    prob = np.array([(1 - prob_caught), (1 - prob_caught),
                     prob_caught, prob_caught]) / 2.0

    # Build chain: 0-based income state for each draw
    cum = np.cumsum(prob)
    chain = np.searchsorted(cum, X[:, 0]).astype(np.int64)

    chaine = (X[:, 1] < prob_move).astype(np.int64)

    beta = 1.0 / (1.0 + beta_up)

    Y_high = Y * (1 + theta)
    Y_low  = Y * (1 - theta)

    # ---- Grid ----
    if precomputed_grid is not None:
        A, Aprime, B, Bprime, D, Dprime, nA, nB = precomputed_grid
    else:
        A, Aprime, B, Bprime, D, Dprime, nA, nB = \
            grid_int_full(nA, sigA, Alb, Aub, nB, sigB, Blb, nD,
                          int_size, refinement, untied)

    N = A.shape[0]

    # ---- Utility matrices (N x N) ----
    util1, util2, util3, util4 = \
        gen_curve_quad(A, B, D, Aprime, Bprime, Dprime,
                       r_high, r_lend, r_water, h_param, vh,
                       Y_high, Y_low, p1, p2, pd, alpha,
                       curve, untied, fee, compute_w=False)

    # gen_curve_quad already returns Fortran-contiguous arrays
    utils = (util1, util2, util3, util4)

    # ---- Initial value function (N x 4) ----
    ap_col = Aprime[:, 0]
    v = -100000.0 * (ap_col < 0)[:, None] * np.ones((1, 4))

    if r_water > 0.6:
        bp_col = Bprime[:, 0]
        v = v + (-100000.0 * (bp_col < 0)[:, None] * np.ones((1, 4)))
        # Re-apply penalties on utils (in-place on Fortran arrays)
        bp_zero = (Bprime == 0)
        bp_neg  = (Bprime < 0)
        for u in [util1, util2, util3, util4]:
            u[:] = u * bp_zero + (-100000.0) * bp_neg

    va = v.copy()

    T   = 30 + Tg
    Acc = s
    Tsim = int(n // Acc)

    # ---- Allocate VFI storage ----
    mDecis  = np.zeros((N, 4, T), dtype=np.int64)
    mV      = np.zeros((N, 4, T), dtype=np.float64)
    mDecisa = np.zeros((N, 4, T), dtype=np.int64)
    mVa     = np.zeros((N, 4, T), dtype=np.float64)

    # ---- Penalty matrices (Fortran-contiguous for Numba) ----
    M_move   = np.asfortranarray(10000.0 * (Bprime < 0).astype(np.float64))
    M_dl     = np.asfortranarray((10000.0 * (Bprime < B) * (Dprime == 1)).astype(np.float64))
    M_dl_end = np.asfortranarray((10000.0 * (Bprime < B)).astype(np.float64))
    M_dl_end_move = np.asfortranarray(M_dl_end + M_move)

    # Pre-allocate output buffers for _bellman_step
    tv_buf = np.empty(N, dtype=np.float64)
    td_buf = np.empty(N, dtype=np.int64)

    # ---- Value Function Iteration ----
    for t_idx in range(T - 1, -1, -1):
        t_m = t_idx + 1   # MATLAB-equivalent 1-based t

        cont = beta * (v @ prob)

        if t_m == T:
            cont_a = beta * (va @ prob)
            for k in range(4):
                _bellman_step(utils[k], cont, M_dl_end, tv_buf, td_buf)
                mV[:, k, t_idx]     = tv_buf
                mDecis[:, k, t_idx] = td_buf

                _bellman_step(utils[k], cont_a, M_dl_end_move, tv_buf, td_buf)
                mVa[:, k, t_idx]     = tv_buf
                mDecisa[:, k, t_idx] = td_buf

        elif t_m < T and t_m > T - Tg:
            cont_a = beta * (va @ prob)
            for k in range(4):
                _bellman_step(utils[k], cont, M_dl, tv_buf, td_buf)
                mV[:, k, t_idx]     = tv_buf
                mDecis[:, k, t_idx] = td_buf

                _bellman_step(utils[k], cont_a, M_dl, tv_buf, td_buf)
                mVa[:, k, t_idx]     = tv_buf
                mDecisa[:, k, t_idx] = td_buf

        elif t_m == T - Tg:
            cont_mix = beta * ((1 - prob_move) * (v @ prob) +
                               prob_move * (va @ prob))
            for k in range(4):
                _bellman_step(utils[k], cont_mix, M_dl, tv_buf, td_buf)
                mV[:, k, t_idx]     = tv_buf
                mDecis[:, k, t_idx] = td_buf
        else:
            for k in range(4):
                _bellman_step_nopen(utils[k], cont, tv_buf, td_buf)
                mV[:, k, t_idx]     = tv_buf
                mDecis[:, k, t_idx] = td_buf

        v = mV[:, :, t_idx].copy()
        if t_m > T - Tg:
            va = mVa[:, :, t_idx].copy()

    # ---- Find initial state (A=0, B=0, D=0) — column-major first match ----
    mask = (B == 0) & (A == 0) & (D == 0)
    flat_idx = np.argmax(mask.ravel(order='F'))
    nrows = mask.shape[0]
    Im = flat_idx % nrows
    Jm = flat_idx // nrows

    # ---- Policy simulation (Numba) ----
    Aprime_vec = np.ascontiguousarray(Aprime[:, 0])
    Bprime_vec = np.ascontiguousarray(Bprime[:, 0])
    Dprime_vec = np.ascontiguousarray(Dprime[:, 0])

    controls = _simulate_nb(
        mDecis, mDecisa, chain, chaine,
        Aprime_vec, Bprime_vec, Dprime_vec,
        A[Im, Jm], B[Im, Jm], D[Im, Jm], Jm,
        Tsim, Acc, T, Tg,
        r_high, r_lend, r_water, h_param, vh,
        Y_high, Y_low, p1, p2, pd, alpha,
        curve, untied, fee
    )

    # ---- Compute moments ----
    tm = 12
    h_out = np.empty(6)
    h_out[0] = np.mean(controls[:, 0])
    h_out[1] = np.mean(-1.0 * controls[:, 2])
    h_out[2] = np.mean(controls[:, 3] == 1)

    prev_Bp = np.empty(len(controls))
    prev_Bp[0] = 0.0
    prev_Bp[1:] = controls[:-1, 2]
    prev_Dp = np.empty(len(controls))
    prev_Dp[0] = 0.0
    prev_Dp[1:] = controls[:-1, 3]

    cond_mask = (
        (prev_Bp < 0) &
        (controls[:, 4] >= 3) &
        (controls[:, 5] < Acc - tm) &
        (controls[:, 5] != 1) &
        (prev_Dp != 1)
    )
    h_out[3] = np.mean(controls[cond_mask, 3]) if np.any(cond_mask) else 0.0

    h_out[4] = np.mean(controls[:, 2] == 0)
    end_mask = controls[:, 5] == s
    h_out[5] = np.mean(np.abs(controls[end_mask, 2])) if np.any(end_mask) else 0.0

    # ---- Welfare ----
    util_val = prob @ mV[Jm, :, 0]

    return h_out, util_val, controls, nA, nB, A, B


# =========================================================================
# Numba-compiled simulation loop
# =========================================================================

@njit(cache=True)
def _simulate_nb(mDecis, mDecisa, chain, chaine,
                 Aprime_vec, Bprime_vec, Dprime_vec,
                 A_init, B_init, D_init, Jm_init,
                 Tsim, Acc, T, Tg,
                 r_high, r_lend, r_water, h_param, vh,
                 Y_high, Y_low, p1, p2, pd, alpha,
                 curve, untied, fee):
    """
    Markov-chain policy simulation.
    Loop variables use MATLAB 1-based conventions; array indices 0-based.
    """
    total_rows = Tsim * Acc
    controls = np.zeros((total_rows, 7))

    for jj in range(1, Tsim + 1):
        Athis = A_init
        Bthis = B_init
        Dthis = D_init
        Imark = Jm_init

        for ii in range(1, Acc + 1):
            II = (jj - 1) * Acc + ii
            II_idx = II - 1

            if ii < Acc - T + 1:
                Inext = mDecis[Imark, chain[II_idx], 0]
            else:
                ii_alt_m = ii - (Acc - T)
                ii_alt_idx = ii_alt_m - 1
                if ii > Acc - Tg and chaine[jj - 1] == 1:
                    Inext = mDecisa[Imark, chain[II_idx], ii_alt_idx]
                else:
                    Inext = mDecis[Imark, chain[II_idx], ii_alt_idx]

            Ap = Aprime_vec[Inext]
            Bp = Bprime_vec[Inext]
            Dp = Dprime_vec[Inext]
            Imark = Inext

            w1, w2, w3, w4 = gen_curve_quad_scalar_nb(
                Athis, Bthis, Dthis, Ap, Bp, Dp,
                r_high, r_lend, r_water, h_param, vh,
                Y_high, Y_low, p1, p2, pd, alpha,
                curve, untied, fee
            )

            ch = chain[II_idx]
            if ch == 0:
                cons = w1
            elif ch == 1:
                cons = w2
            elif ch == 2:
                cons = w3
            else:
                cons = w4

            controls[II_idx, 0] = cons
            controls[II_idx, 1] = Ap
            controls[II_idx, 2] = Bp
            controls[II_idx, 3] = Dp
            controls[II_idx, 4] = ch + 1
            controls[II_idx, 5] = ii
            controls[II_idx, 6] = chaine[jj - 1]

            Athis = Ap
            Bthis = Bp
            Dthis = Dp

    return controls
