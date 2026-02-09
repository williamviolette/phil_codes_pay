"""
Translate of gen_curve_quad.m — generate utility matrices for 4 income/default states.

Three versions:
  - gen_curve_quad()           : fast Numba-parallel fused kernel for VFI (N×N matrices)
  - gen_curve_quad_numpy()     : pure NumPy fallback
  - gen_curve_quad_scalar_nb() : Numba scalar, for simulation loop
"""
import numpy as np
from numba import njit, prange

from .u_quad import u_quad, u_quad_scalar_nb
from .utility_functions import (
    v_reg_quad_nb, v_b_quad_nb, w_reg_quad_nb, w_b_quad_nb, cut_quad_nb,
)

BIG_NEG = -1000000.0


# =========================================================================
# Fast fused Numba kernel — processes each (i,j) element in one pass
# =========================================================================

@njit(parallel=True, cache=True)
def _gen_curve_quad_kernel(A, B, D, Aprime, Bprime, Dprime,
                           r_high, r_lend, r_water, h_param, vh,
                           Y_high, Y_low, p1, p2, pd, alpha,
                           curve, untied, fee,
                           util1, util2, util3, util4):
    """
    Fused element-wise kernel.  Writes directly into pre-allocated output
    matrices util1..util4 (Fortran-order).  No temporary N×N arrays.
    """
    Nr = A.shape[0]
    Nc = A.shape[1]
    L_cut = cut_quad_nb(alpha, p1, p2)

    for j in prange(Nc):
        for i in range(Nr):
            a  = A[i, j];      ap = Aprime[i, j]
            b  = B[i, j];      bp = Bprime[i, j]
            dv = D[i, j];      dp = Dprime[i, j]

            # Aprime_inc
            if ap <= 0.0:
                ap_inc = ap / (1.0 + r_high)
            else:
                ap_inc = ap / (1.0 + r_lend)

            if untied == 0:
                # Bprime_inc
                if r_water > 0.0:
                    bp_inc = (bp if bp >= b else b) / (1.0 + r_water)
                else:
                    bp_inc = bp if bp >= b else b

                cc = 1.0 if (dv == 0.0 and dp == 0.0) else 0.0
                cd = 1.0 if (dv == 0.0 and dp == 1.0) else 0.0
                dd = 1.0 if (dv == 1.0 and dp == 1.0) else 0.0

                # Lf_12
                bp_lt_b = 1.0 if bp < b else 0.0
                if r_water > 0.0:
                    Lf_12 = ((bp - b) / (1.0 + r_water)) * bp_lt_b * cc
                else:
                    Lf_12 = (bp - b) * bp_lt_b * cc

                cd_dd = cd + dd
                y_34f = (a - ap_inc + b) + (-bp_inc) * cd_dd - pd * cd_dd
                y_12f = y_34f + (-1.0 * bp_inc) * cc

                if h_param > 0.0:
                    bp_neg = 1.0 if bp < 0.0 else 0.0
                    y_34f -= bp_neg * h_param
                    y_12f -= bp_neg * h_param
                if vh > 0.0:
                    b_neg = 1.0 if b < 0.0 else 0.0
                    y_34f -= b_neg * (cc + cd) * vh
                if fee != 0.0:
                    y_34f -= fee
                    y_12f -= fee

                # ---- u_quad for debt=1 (Lf_12, income = Y_high / Y_low) ----
                y1 = Y_high + y_12f
                y2 = Y_low  + y_12f
                u1 = _u_quad_inline(Lf_12, 1, alpha, p1, p2, y1, L_cut)
                u2 = _u_quad_inline(Lf_12, 1, alpha, p1, p2, y2, L_cut)

                # ---- u_quad for debt=0 (L=0, income = Y_high / Y_low) ----
                y3 = Y_high + y_34f
                y4 = Y_low  + y_34f
                u3 = _u_quad_inline(0.0, 0, alpha, p1, p2, y3, L_cut)
                u4 = _u_quad_inline(0.0, 0, alpha, p1, p2, y4, L_cut)
            else:
                # untied path
                y_12f = (a - ap_inc + b - bp)
                if fee != 0.0:
                    y_12f -= fee
                y1 = Y_high + y_12f
                y2 = Y_low  + y_12f
                u1 = _u_quad_inline(0.0, 0, alpha, p1, p2, y1, L_cut)
                u2 = _u_quad_inline(0.0, 0, alpha, p1, p2, y2, L_cut)
                u3 = u1
                u4 = u2

            # Curvature transformation
            if curve == 1.0:
                if u1 > 0.0: u1 = np.log(u1)
                if u2 > 0.0: u2 = np.log(u2)
                if u3 > 0.0: u3 = np.log(u3)
                if u4 > 0.0: u4 = np.log(u4)
            else:
                inv_c = 1.0 - curve
                if u1 > 0.0: u1 = (u1 ** inv_c - 1.0) / inv_c
                if u2 > 0.0: u2 = (u2 ** inv_c - 1.0) / inv_c
                if u3 > 0.0: u3 = (u3 ** inv_c - 1.0) / inv_c
                if u4 > 0.0: u4 = (u4 ** inv_c - 1.0) / inv_c

            util1[i, j] = u1
            util2[i, j] = u2
            util3[i, j] = u3
            util4[i, j] = u4


@njit(cache=True)
def _u_quad_inline(L, debt, alpha, p1, p2, y, L_cut):
    """
    Inlined scalar u_quad (no w output needed for VFI).
    """
    if debt == 1:
        disc = L * p2 * (-4.0) + p1 ** 2
        if disc < 0.0:
            vb = BIG_NEG
        else:
            t2 = alpha + (p1 - np.sqrt(disc)) / (p2 * 2.0)
            vb = y - t2 ** 2 / 2.0
            if np.isinf(vb):
                vb = BIG_NEG

        # v_reg_quad
        t3 = p2 * 2.0
        t4 = t3 + 1.0
        t2r = alpha - (alpha - p1) / t4
        t5 = p1 ** 2
        vreg = -L + y - t2r ** 2 / 2.0 + (t5 - alpha * p1 + p2 * (t5 - alpha ** 2)) / t4 ** 2

        if L >= L_cut:
            util = vreg
        else:
            util = vb

        # Check w for feasibility
        if L >= L_cut:
            w = (alpha - p1) / (p2 * 2.0 + 1.0)
        else:
            if disc < 0.0:
                w = 0.0
            else:
                w = ((p1 - np.sqrt(disc)) * (-0.5)) / p2
    else:
        t3 = p2 * 2.0
        t4 = t3 + 1.0
        t2r = alpha - (alpha - p1) / t4
        t5 = p1 ** 2
        util = -L + y - t2r ** 2 / 2.0 + (t5 - alpha * p1 + p2 * (t5 - alpha ** 2)) / t4 ** 2
        w = (alpha - p1) / (p2 * 2.0 + 1.0)

    if y <= 0.0:
        util = BIG_NEG
    if w < 0.0:
        util = BIG_NEG

    return util


# =========================================================================
# Public API
# =========================================================================

def gen_curve_quad(A, B, D, Aprime, Bprime, Dprime,
                   r_high, r_lend, r_water, h, vh,
                   Y_high, Y_low, p1, p2, pd, alpha,
                   curve, untied, fee, compute_w=False):
    """
    Fast Numba-parallel version for matrix inputs.
    Returns Fortran-contiguous output matrices.
    """
    if compute_w:
        # Fallback to NumPy for the simulation-style call that needs w
        return _gen_curve_quad_numpy(
            A, B, D, Aprime, Bprime, Dprime,
            r_high, r_lend, r_water, h, vh,
            Y_high, Y_low, p1, p2, pd, alpha,
            curve, untied, fee, compute_w=True)

    N = A.shape[0]
    M = A.shape[1]
    util1 = np.empty((N, M), dtype=np.float64, order='F')
    util2 = np.empty((N, M), dtype=np.float64, order='F')
    util3 = np.empty((N, M), dtype=np.float64, order='F')
    util4 = np.empty((N, M), dtype=np.float64, order='F')

    _gen_curve_quad_kernel(
        np.asfortranarray(A), np.asfortranarray(B), np.asfortranarray(D),
        np.asfortranarray(Aprime), np.asfortranarray(Bprime), np.asfortranarray(Dprime),
        r_high, r_lend, r_water, h, vh,
        Y_high, Y_low, p1, p2, pd, alpha,
        float(curve), float(untied), float(fee),
        util1, util2, util3, util4)

    return util1, util2, util3, util4


def _gen_curve_quad_numpy(A, B, D, Aprime, Bprime, Dprime,
                          r_high, r_lend, r_water, h, vh,
                          Y_high, Y_low, p1, p2, pd, alpha,
                          curve, untied, fee, compute_w=False):
    """NumPy fallback (used only when compute_w=True)."""
    Aprime_inc = (Aprime / (1 + r_high)) * (Aprime <= 0) + \
                 (Aprime / (1 + r_lend)) * (Aprime > 0)

    if untied == 0:
        if r_water > 0:
            Bprime_inc = (Bprime * (Bprime >= B) + B * (Bprime < B)) / (1 + r_water)
        else:
            Bprime_inc = Bprime * (Bprime >= B) + B * (Bprime < B)

        cc = (D == 0) * (Dprime == 0)
        cd = (D == 0) * (Dprime == 1)
        dd = (D == 1) * (Dprime == 1)

        if r_water > 0:
            Lf_12 = ((Bprime - B) / (1 + r_water)) * (Bprime < B) * cc
        else:
            Lf_12 = (Bprime - B) * (Bprime < B) * cc

        y_34f = (A - Aprime_inc + B) + (-Bprime_inc) * (cd + dd) - pd * (cd + dd)
        y_12f = y_34f + (-1.0 * Bprime_inc) * cc

        if h > 0:
            y_34f = y_34f - (Bprime < 0) * h
            y_12f = y_12f - (Bprime < 0) * h
        if vh > 0:
            y_34f = y_34f - (B < 0) * (cc + cd) * vh
        if fee != 0:
            y_34f = y_34f - fee
            y_12f = y_12f - fee

        if compute_w:
            util1, w1 = u_quad(Lf_12, 1, alpha, p1, p2, Y_high + y_12f, 1, compute_w=True)
            util2, w2 = u_quad(Lf_12, 1, alpha, p1, p2, Y_low  + y_12f, 1, compute_w=True)
            util3, w3 = u_quad(0,     0, alpha, p1, p2, Y_high + y_34f, 1, compute_w=True)
            util4, w4 = u_quad(0,     0, alpha, p1, p2, Y_low  + y_34f, 1, compute_w=True)
        else:
            util1 = u_quad(Lf_12, 1, alpha, p1, p2, Y_high + y_12f, 1)
            util2 = u_quad(Lf_12, 1, alpha, p1, p2, Y_low  + y_12f, 1)
            util3 = u_quad(0,     0, alpha, p1, p2, Y_high + y_34f, 1)
            util4 = u_quad(0,     0, alpha, p1, p2, Y_low  + y_34f, 1)
    else:
        y_12f = (A - Aprime_inc + B - Bprime)
        if fee != 0:
            y_12f = y_12f - fee
        if compute_w:
            util1, w1 = u_quad(0, 0, alpha, p1, p2, Y_high + y_12f, 1, compute_w=True)
            util2, w2 = u_quad(0, 0, alpha, p1, p2, Y_low  + y_12f, 1, compute_w=True)
            util3, w3 = util1.copy(), w1.copy()
            util4, w4 = util2.copy(), w2.copy()
        else:
            util1 = u_quad(0, 0, alpha, p1, p2, Y_high + y_12f, 1)
            util2 = u_quad(0, 0, alpha, p1, p2, Y_low  + y_12f, 1)
            util3 = util1.copy()
            util4 = util2.copy()

    if curve == 1:
        for u in [util1, util2, util3, util4]:
            mask = u > 0
            u[mask] = np.log(u[mask])
    else:
        for u in [util1, util2, util3, util4]:
            mask = u > 0
            u[mask] = (u[mask] ** (1 - curve) - 1) / (1 - curve)

    if compute_w:
        return util1, util2, util3, util4, w1, w2, w3, w4
    return util1, util2, util3, util4


# =========================================================================
# Numba scalar version for simulation loop
# =========================================================================

@njit(cache=True)
def gen_curve_quad_scalar_nb(A, B, D, Aprime, Bprime, Dprime,
                             r_high, r_lend, r_water, h, vh,
                             Y_high, Y_low, p1, p2, pd, alpha,
                             curve, untied, fee):
    """
    Scalar version returning (w1, w2, w3, w4) for the simulation loop.
    """
    if Aprime <= 0:
        Aprime_inc = Aprime / (1 + r_high)
    else:
        Aprime_inc = Aprime / (1 + r_lend)

    if untied == 0:
        if r_water > 0:
            bp_inc = (Bprime if Bprime >= B else B) / (1 + r_water)
        else:
            bp_inc = Bprime if Bprime >= B else B

        cc = 1.0 if (D == 0 and Dprime == 0) else 0.0
        cd = 1.0 if (D == 0 and Dprime == 1) else 0.0
        dd = 1.0 if (D == 1 and Dprime == 1) else 0.0

        bp_lt_b = 1.0 if Bprime < B else 0.0
        if r_water > 0:
            Lf_12 = ((Bprime - B) / (1 + r_water)) * bp_lt_b * cc
        else:
            Lf_12 = (Bprime - B) * bp_lt_b * cc

        cd_dd = cd + dd
        y_34f = (A - Aprime_inc + B) + (-bp_inc) * cd_dd - pd * cd_dd
        y_12f = y_34f + (-1.0 * bp_inc) * cc

        if h > 0:
            bp_neg = 1.0 if Bprime < 0 else 0.0
            y_34f -= bp_neg * h
            y_12f -= bp_neg * h
        if vh > 0:
            b_neg = 1.0 if B < 0 else 0.0
            y_34f -= b_neg * (cc + cd) * vh
        if fee != 0:
            y_34f -= fee
            y_12f -= fee

        _, w1 = u_quad_scalar_nb(Lf_12, 1, alpha, p1, p2, Y_high + y_12f, 1)
        _, w2 = u_quad_scalar_nb(Lf_12, 1, alpha, p1, p2, Y_low  + y_12f, 1)
        _, w3 = u_quad_scalar_nb(0.0,   0, alpha, p1, p2, Y_high + y_34f, 1)
        _, w4 = u_quad_scalar_nb(0.0,   0, alpha, p1, p2, Y_low  + y_34f, 1)
    else:
        y_12f = (A - Aprime_inc + B - Bprime)
        if fee != 0:
            y_12f -= fee
        _, w1 = u_quad_scalar_nb(0.0, 0, alpha, p1, p2, Y_high + y_12f, 1)
        _, w2 = u_quad_scalar_nb(0.0, 0, alpha, p1, p2, Y_low  + y_12f, 1)
        w3 = w1
        w4 = w2

    return w1, w2, w3, w4
