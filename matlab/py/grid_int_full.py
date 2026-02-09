"""
Translate of grid_int_full.m and refine_no_arbitrage.m

Builds the full (A, Aprime, B, Bprime, D, Dprime) state-space matrices.

Matrix layout (matching MATLAB exactly):
  - Rows    = choice / next-period state
  - Columns = current state
  So  Aprime[i, j] = next-period asset for choice i  (varies by row)
      A[i, j]      = current asset for state j        (varies by col)
"""
import numpy as np


def grid_int_full(nA, sigA, Alb, Aub, nB, sigB, Blb, nD,
                  int_size, refinement, untied):
    """
    Returns
    -------
    A, Aprime, B, Bprime, D, Dprime : 2-D ndarray (N x N)
    nA, nB : int  (grid sizes, may include inserted zero point)
    """
    # --- Build 1-D grids ---
    if sigA > 0:
        raise NotImplementedError("grid_id not implemented (sigA > 0)")
    else:
        Agrid = np.arange(nA, dtype=np.float64) / (nA - 1) * (Aub - Alb) + Alb
        Bgrid = np.arange(nB, dtype=np.float64) / (nB - 1) * (0 - Blb) + Blb

    # Interpolation (int_size > 1 not used in the WBER version)
    if int_size > 1:
        raise NotImplementedError("l_int interpolation not implemented (int_size > 1)")

    # Insert zero into Agrid if not already present
    if not np.any(Agrid == 0):
        mid = len(Agrid) // 2
        Agrid = np.concatenate([Agrid[:mid], [0.0], Agrid[mid:]])

    nA_temp = len(Agrid)
    nB_temp = len(Bgrid)

    # --- 2-D asset grids ---
    # MATLAB: Aprime_r = repmat(Agrid, 1, nA_temp)       -> each col = Agrid  (choice varies by row)
    #         A_r      = repmat(Agrid, 1, nA_temp)'       -> each row = Agrid  (state varies by col)
    Aprime_r = np.tile(Agrid[:, None], (1, nA_temp))     # nA_temp x nA_temp
    A_r      = np.tile(Agrid[None, :], (nA_temp, 1))     # nA_temp x nA_temp

    # --- 2-D balance grids ---
    Bprime_r = np.tile(Bgrid[:, None], (1, nB_temp))     # nB_temp x nB_temp
    B_r      = np.tile(Bgrid[None, :], (nB_temp, 1))     # nB_temp x nB_temp

    # --- Combine A and B via Kronecker-style expansion ---
    # MATLAB: A_r1      = repelem(A_r,      nB_temp, nB_temp)
    #         Aprime_r1 = repelem(Aprime_r,  nB_temp, nB_temp)
    #         B_r1      = repmat(B_r,        nA_temp, nA_temp)
    #         Bprime_r1 = repmat(Bprime_r,   nA_temp, nA_temp)
    A_r1      = np.repeat(np.repeat(A_r,      nB_temp, axis=0), nB_temp, axis=1)
    Aprime_r1 = np.repeat(np.repeat(Aprime_r, nB_temp, axis=0), nB_temp, axis=1)
    B_r1      = np.tile(B_r, (nA_temp, nA_temp))
    Bprime_r1 = np.tile(Bprime_r, (nA_temp, nA_temp))

    # --- Add default dimension (D = 0 or 1) ---
    # MATLAB: A = repmat(A_r1, nD, nD)  etc.
    A      = np.tile(A_r1, (nD, nD))
    B      = np.tile(B_r1, (nD, nD))
    Aprime = np.tile(Aprime_r1, (nD, nD))
    Bprime = np.tile(Bprime_r1, (nD, nD))

    sz = A_r1.shape[0]   # = nA_temp * nB_temp
    # MATLAB: D = [zeros(sz*nD, sz)  ones(sz*nD, sz)]
    D = np.concatenate([np.zeros((sz * nD, sz)),
                        np.ones((sz * nD, sz))], axis=1)
    Dprime = D.T.copy()

    # --- Refinement ---
    if refinement == 1:
        A, Aprime, B, Bprime, D, Dprime = \
            refine_no_arbitrage(A, Aprime, B, Bprime, D, Dprime, untied)

    nA_out = nA_temp
    nB_out = nB_temp
    return A, Aprime, B, Bprime, D, Dprime, nA_out, nB_out


def refine_no_arbitrage(A, Aprime, B, Bprime, D, Dprime, untied):
    """
    Remove economically infeasible (arbitrage) states from the grid.

    MATLAB's find(max(test)) on a matrix returns column indices where any row
    in that column satisfies the condition.  We replicate this exactly.
    """
    if untied == 1:
        test = (D == 1)
        test1 = ~test                           # == (test == 0)
        # MATLAB: find(max(test1))  — columns where at least one True row
        arbitrage = np.where(test1.max(axis=0))[0]
        A      = A[np.ix_(arbitrage, arbitrage)]
        Aprime = Aprime[np.ix_(arbitrage, arbitrage)]
        B      = B[np.ix_(arbitrage, arbitrage)]
        Bprime = Bprime[np.ix_(arbitrage, arbitrage)]
        D      = D[np.ix_(arbitrage, arbitrage)]
        Dprime = Dprime[np.ix_(arbitrage, arbitrage)]

    # Remove columns/rows where D==1 and B==0  (dc with no balance)
    keep = ((B != 0) & (D == 1)) | (D == 0)
    dc_with_no_bal = np.where(keep.max(axis=0))[0]

    A      = A[np.ix_(dc_with_no_bal, dc_with_no_bal)]
    Aprime = Aprime[np.ix_(dc_with_no_bal, dc_with_no_bal)]
    B      = B[np.ix_(dc_with_no_bal, dc_with_no_bal)]
    Bprime = Bprime[np.ix_(dc_with_no_bal, dc_with_no_bal)]
    D      = D[np.ix_(dc_with_no_bal, dc_with_no_bal)]
    Dprime = Dprime[np.ix_(dc_with_no_bal, dc_with_no_bal)]

    return A, Aprime, B, Bprime, D, Dprime
