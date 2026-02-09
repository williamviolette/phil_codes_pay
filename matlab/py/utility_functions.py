"""
Symbolic utility/value/policy functions generated from MATLAB Symbolic Math Toolbox.
Translates: v_reg_quad.m, v_b_quad.m, w_reg_quad.m, w_b_quad.m, cut_quad.m

All functions work element-wise on both scalars and NumPy arrays.
Numba-compatible versions are provided for use in the simulation loop.
"""
import numpy as np
from numba import njit


# ---------- NumPy (vectorized) versions ----------

def v_reg_quad(L, alpha, p1, p2, y):
    """Regular regime value function."""
    t3 = p2 * 2.0
    t4 = t3 + 1.0
    t2 = alpha - (alpha - p1) / t4
    t5 = p1 ** 2
    return -L + y - t2 ** 2 / 2.0 + (t5 - alpha * p1 + p2 * (t5 - alpha ** 2)) / t4 ** 2


def v_b_quad(L, alpha, p1, p2, y):
    """Boundary regime value function."""
    t2 = alpha + (p1 - np.sqrt(L * p2 * -4.0 + p1 ** 2)) / (p2 * 2.0)
    return y - t2 ** 2 / 2.0


def w_reg_quad(alpha, p1, p2):
    """Regular regime policy (water consumption)."""
    return (alpha - p1) / (p2 * 2.0 + 1.0)


def w_b_quad(L, p1, p2):
    """Boundary regime policy (water consumption)."""
    return ((p1 - np.sqrt(L * p2 * -4.0 + p1 ** 2)) * (-1.0 / 2.0)) / p2


def cut_quad(alpha, p1, p2):
    """Cutoff point between regular and boundary regimes."""
    return -1.0 / (p2 * 2.0 + 1.0) ** 2 * (alpha - p1) * (p1 + alpha * p2 + p1 * p2)


# ---------- Numba (scalar) versions for simulation loop ----------

@njit(cache=True)
def v_reg_quad_nb(L, alpha, p1, p2, y):
    t3 = p2 * 2.0
    t4 = t3 + 1.0
    t2 = alpha - (alpha - p1) / t4
    t5 = p1 ** 2
    return -L + y - t2 ** 2 / 2.0 + (t5 - alpha * p1 + p2 * (t5 - alpha ** 2)) / t4 ** 2


@njit(cache=True)
def v_b_quad_nb(L, alpha, p1, p2, y):
    t2 = alpha + (p1 - np.sqrt(L * p2 * -4.0 + p1 ** 2)) / (p2 * 2.0)
    return y - t2 ** 2 / 2.0


@njit(cache=True)
def w_reg_quad_nb(alpha, p1, p2):
    return (alpha - p1) / (p2 * 2.0 + 1.0)


@njit(cache=True)
def w_b_quad_nb(L, p1, p2):
    return ((p1 - np.sqrt(L * p2 * -4.0 + p1 ** 2)) * (-1.0 / 2.0)) / p2


@njit(cache=True)
def cut_quad_nb(alpha, p1, p2):
    return -1.0 / (p2 * 2.0 + 1.0) ** 2 * (alpha - p1) * (p1 + alpha * p2 + p1 * p2)
