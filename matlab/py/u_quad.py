"""
Translate of u_quad.m — utility function with regular/boundary regime switching.

Two versions:
  - u_quad()          : NumPy vectorized, for matrix-level VFI calls
  - u_quad_scalar_nb(): Numba scalar, for simulation loop
"""
import numpy as np
from numba import njit

from .utility_functions import (
    v_reg_quad, v_b_quad, w_reg_quad, w_b_quad, cut_quad,
    v_reg_quad_nb, v_b_quad_nb, w_reg_quad_nb, w_b_quad_nb, cut_quad_nb,
)

BIG_NEG = -1000000.0


def u_quad(L, debt, alpha, p1, p2, y, lam, compute_w=False):
    """
    Vectorized utility function.

    Parameters
    ----------
    L, y   : array_like  (can be matrices)
    debt   : int (0 or 1)
    alpha, p1, p2, lam : float scalars
    compute_w : bool — if True, also return water-consumption policy w

    Returns
    -------
    util       : ndarray same shape as L / y
    w          : ndarray (only if compute_w is True)
    """
    if debt == 1:
        L_cut = cut_quad(alpha, p1, p2)

        vb = v_b_quad(L, alpha, p1, p2, y)
        vb = np.where(np.isinf(vb), BIG_NEG, vb)
        vb = np.where(np.iscomplex(vb) if np.iscomplexobj(vb) else False, BIG_NEG, vb)
        # Handle complex from sqrt of negative: check the discriminant
        disc = L * p2 * -4.0 + p1 ** 2
        vb = np.where(disc < 0, BIG_NEG, vb)

        vreg = v_reg_quad(L, alpha, p1, p2, y)

        mask_reg = L >= L_cut
        util = np.where(mask_reg, vreg, vb)
        # Guard complex in util (from vreg side too, though unlikely)
        util = np.real(util) if np.iscomplexobj(util) else util

        if compute_w:
            w_r = w_reg_quad(alpha, p1, p2)
            w_bv = w_b_quad(L, p1, p2)
            # guard complex in w_b
            w_bv = np.where(disc < 0, 0.0, w_bv)
            w = np.where(mask_reg, w_r, w_bv)
    else:
        util = v_reg_quad(L, alpha, p1, p2, y)
        util = np.real(util) if np.iscomplexobj(util) else util
        if compute_w:
            w = np.full_like(y, w_reg_quad(alpha, p1, p2)) if np.ndim(y) > 0 else w_reg_quad(alpha, p1, p2)

    # Penalize infeasible states
    util = np.where(y <= 0, BIG_NEG, util)

    if compute_w:
        util = np.where(w < 0, BIG_NEG, util)

    if lam != 0 and lam != 1:
        util = util * lam

    if compute_w:
        return util, w
    return util


# ---------- Numba scalar version for simulation ----------

@njit(cache=True)
def u_quad_scalar_nb(L, debt, alpha, p1, p2, y, lam):
    """
    Scalar utility function returning (util, w).
    Used inside the Numba-compiled simulation loop.
    """
    if debt == 1:
        L_cut = cut_quad_nb(alpha, p1, p2)

        disc = L * p2 * -4.0 + p1 ** 2
        if disc < 0:
            vb = BIG_NEG
        else:
            vb = v_b_quad_nb(L, alpha, p1, p2, y)
            if np.isinf(vb):
                vb = BIG_NEG

        if L >= L_cut:
            util = v_reg_quad_nb(L, alpha, p1, p2, y)
            w = w_reg_quad_nb(alpha, p1, p2)
        else:
            util = vb
            if disc < 0:
                w = 0.0
            else:
                w = w_b_quad_nb(L, p1, p2)
    else:
        util = v_reg_quad_nb(L, alpha, p1, p2, y)
        w = w_reg_quad_nb(alpha, p1, p2)

    if y <= 0:
        util = BIG_NEG
    if w < 0:
        util = BIG_NEG

    if lam != 0.0 and lam != 1.0:
        util = util * lam

    return util, w
