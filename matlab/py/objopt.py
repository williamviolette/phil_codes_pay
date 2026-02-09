"""
Translate of objopt.m — optimization wrapper around obj().
"""
import numpy as np
from .obj import obj


def objopt(a, given, data, option, option_moments_est, weights,
           nA, sigA, Alb, Aub, nB, sigB, nD, s, int_size, refinement, X,
           precomputed_grid=None):
    """
    Objective function for the optimizer.

    Parameters
    ----------
    a      : 1-D array, parameter guess (values for given[option])
    given  : 1-D array, full parameter vector (modified in-place copy)
    data   : 1-D array, data moments
    option : list/array of indices into `given` to replace with `a`
    option_moments_est : list/array of moment indices to use
    weights : 2-D weight matrix
    precomputed_grid : optional cached grid tuple

    Returns
    -------
    fval    : scalar, weighted distance
    mom     : 1-D residual vector
    est_mom : 1-D estimated moments
    """
    g = given.copy()
    for i, idx in enumerate(option):
        g[idx] = a[i]

    est_mom_full, *_ = obj(g, nA, sigA, Alb, Aub, nB, sigB, nD, s,
                           int_size, refinement, X,
                           precomputed_grid=precomputed_grid)

    est_mom = est_mom_full[option_moments_est]
    mom = est_mom - data
    fval = mom @ weights @ mom

    return fval, mom, est_mom
