#!/usr/bin/env python3
"""
Translate of dc_main_analysis_obj.m — main estimation script.

Usage:
    python -m matlab.py.dc_main_analysis_obj          (from repo root)
    python dc_main_analysis_obj.py                    (from matlab/py/)

Reproduces the MATLAB WBER-version estimation pipeline:
  1. Load data moments from CSV
  2. Run single obj() evaluation and display results
  3. (Optional) Run pattern-search estimation with bootstrap
"""
import sys
import os
import time
import numpy as np

# ---- Repo root detection ----
# Works from: command line, Spyder, Jupyter, interactive REPL.
# Override: set PHIL_CODES_PAY environment variable, or edit _MANUAL_ROOT below.
_MANUAL_ROOT = None   # e.g. '/Users/willviolette/.../phil_codes_pay'

def _find_repo_root():
    # 1. Manual override
    if _MANUAL_ROOT is not None:
        return _MANUAL_ROOT
    # 2. Environment variable
    env = os.environ.get('PHIL_CODES_PAY')
    if env and os.path.isdir(env):
        return env
    # 3. __file__ is available → go up two levels from matlab/py/
    try:
        here = os.path.dirname(os.path.abspath(__file__))
        candidate = os.path.abspath(os.path.join(here, '..', '..'))
        if os.path.isdir(os.path.join(candidate, 'moments')) or \
           os.path.isdir(os.path.join(candidate, 'matlab')):
            return candidate
    except NameError:
        pass
    # 4. Search upward from cwd
    d = os.path.abspath(os.getcwd())
    for _ in range(10):
        if os.path.isdir(os.path.join(d, 'moments')) or \
           os.path.isdir(os.path.join(d, 'matlab', 'py')):
            return d
        d = os.path.dirname(d)
    raise FileNotFoundError(
        "Cannot find repo root. Set _MANUAL_ROOT in this file, or set "
        "the PHIL_CODES_PAY environment variable to the repo path.")

_repo_root = _find_repo_root()
if _repo_root not in sys.path:
    sys.path.insert(0, _repo_root)

from matlab.py.import_data import import_to_matlab_t3
from matlab.py.obj import obj
from matlab.py.objopt import objopt
from matlab.py.grid_int_full import grid_int_full


def main():
    np.random.seed(1)

    # ---- Paths ----
    moments_folder = os.path.join(_repo_root, 'moments')
    tables_dir     = os.path.join(_repo_root, 'paper', 'tables_new')

    # ---- Flags ----
    real_data    = 1
    given_sim    = 1
    est_pattern  = 0
    results      = 1
    boot         = 1
    br           = 10      # bootstrap reps
    opt_method   = 'Nelder-Mead'  # 'Nelder-Mead' or 'Powell'

    int_size    = 1
    refinement  = 1
    one_price   = 0

    marginal_cost = 5
    ppinst        = 51

    s = 32 * 12            # account length = 384

    n  = 384 * 50 + 1      # 19201
    np.random.seed(1)
    X = np.random.rand(n - 1, 2)

    sigA = 0
    sigB = 0
    nD   = 2

    # What to estimate:  alpha(idx 6), pd(idx 11), pc(idx 16)  [0-based]
    option = [6, 11, 16]   # MATLAB [7, 12, 17] → Python 0-based
    lb = np.array([40.0,  10.0, 0.01])
    ub = np.array([80.0, 400.0, 0.99])

    option_moments     = [0, 1, 2]   # MATLAB [1,2,3] → 0-based
    option_moments_est = [0, 1, 2]

    # ---- Load data ----
    d = import_to_matlab_t3(moments_folder, one_price, 1)

    c_avg       = d['c_avg']
    bal_avg     = d['bal_avg']
    dc_shr      = d['dc_shr']
    am_d        = d['am_d']
    bal_0       = d['bal_0']
    bal_end     = d['bal_end']
    bal_0_end   = d['bal_0_end']
    y_avg       = d['y_avg']
    y_cv        = d['y_cv']
    p1          = d['p1']
    p2          = d['p2']
    prob_caught = d['prob_caught']
    Blb         = d['Blb']

    data_moments = np.array([c_avg, bal_avg, dc_shr, am_d, bal_0, bal_end])

    nA = 40
    nB = 40

    Alb = -2.0 * y_avg
    Aub =  2.0 * y_avg

    r_lend = 0.0047
    r_high = 0.0945

    # ---- Loop over sensitivity specifications ----
    for L in [0]:
        ver = 'b'
        if L == 1: ver = 'bhigh'
        if L == 2: ver = 'blow'
        if L == 3: ver = 'chigh'
        if L == 4: ver = 'clow'

        beta_set = 0.005
        if ver == 'bhigh': beta_set = 0.01
        if ver == 'blow':  beta_set = 0.0025

        # MATLAB pattern search estimates (warm-start)
        matlab_est = {'alpha': 54.001, 'pd': 319.56, 'pc': 0.22015}

        #                 0        1        2       3       4       5       6      7         8     9   10    11  12  13   14   15    16       17       18  19   20
        # given:      r_lend, r_water, r_high, hcost, inc_sh, untie, alpha, beta, Y,       p1,  p2,  pd,   n, curve,fee, vh,  pc,   pm,      Blb,  Tg,  sp
        given = np.array([
            0,    0,    r_high, 0,   y_cv,  0,    matlab_est['alpha'],   beta_set, y_avg, p1, p2,  matlab_est['pd'],  n, 1,   0,   0,  matlab_est['pc'], bal_0_end, Blb, 12, 0.8
        ], dtype=np.float64)

        if ver == 'bhigh':
            given = np.array([0,0,r_high,0,y_cv,0,54,  beta_set,y_avg,p1,p2,370,n,1,0,0,0.24,bal_0_end,Blb,12,0.8])
        if ver == 'blow':
            given = np.array([0,0,r_high,0,y_cv,0,54,  beta_set,y_avg,p1,p2,340,n,1,0,0,0.20,bal_0_end,Blb,12,0.8])
        if ver == 'chigh':
            given = np.array([0,0,r_high,0,y_cv,0,53.5,beta_set,y_avg,p1,p2,380,n,2,0,0,0.215,bal_0_end,Blb,12,0.8])
        if ver == 'clow':
            given = np.array([0,0,r_high,0,y_cv,0,54.5,beta_set,y_avg,p1,p2,310,n,0.5,0,0,0.23,bal_0_end,Blb,12,0.8])

        if real_data == 1:
            data = data_moments[option_moments]
        else:
            raise RuntimeError("real_data == 0 not supported")

        # ---- Single obj evaluation ----
        print(f"\n{'='*60}")
        print(f"Running obj() evaluation  [ver={ver}]")
        print(f"{'='*60}")

        t0 = time.time()
        est_mom, ucon, controls, nA_out, nB_out, A1, B1 = \
            obj(given, nA, sigA, Alb, Aub, nB, sigB, nD, s,
                int_size, refinement, X)
        elapsed = time.time() - t0
        print(f"obj() completed in {elapsed:.2f} seconds")

        print(f"\n A loan:         {np.sum(controls[:, 1] == controls[:, 1].min())}")
        print(f" A savings:      {np.sum(controls[:, 1] == controls[:, 1].max())}")
        print(f" B loan:         {np.sum(controls[:, 2] == controls[:, 2].min())}")
        pre_dc = controls[:, 5] < 300
        print(f" B loan (pre DC):{np.sum(controls[pre_dc, 2] == controls[pre_dc, 2].min())}")
        end_dc = controls[:, 5] == s
        if np.any(end_dc):
            print(f" B loan (last DC):{np.sum(controls[end_dc, 2] == controls[end_dc, 2].min()) / np.sum(end_dc):.4f}")
            print(f" B loan 0 (last DC):{np.sum(controls[end_dc, 2] == 0) / np.sum(end_dc):.4f}")
            print(f" B loan average:  {np.mean(controls[end_dc, 2]):.4f}")

        print(f"\n Sim:  {np.round(est_mom[option_moments_est], 3)}")
        print(f" Data: {np.round(data[option_moments], 3)}")

        # ---- Pattern search estimation ----
        if est_pattern == 1:
            from scipy.optimize import minimize

            # Pre-compute grid (doesn't change during optimization)
            precomputed = grid_int_full(
                nA, sigA, Alb, Aub, nB, sigB, Blb, nD,
                int_size, refinement, int(given[5]))

            weights = np.diag(1.0 / data ** 2)
            ag = given[option]

            def obj_fn(a1):
                fval, _, _ = objopt(
                    a1, given, data, option, option_moments_est, weights,
                    nA, sigA, Alb, Aub, nB, sigB, nD, s,
                    int_size, refinement, X, precomputed_grid=precomputed)
                return fval

            print(f"\n old obj: {obj_fn(ag):.6f}")
            print(f" {opt_method} search ...")

            t0 = time.time()
            if opt_method == 'Nelder-Mead':
                result = minimize(obj_fn, ag, method='Nelder-Mead',
                                  options={'maxfev': 400, 'maxiter': 200,
                                           'xatol': 0.5, 'fatol': 1e-5,
                                           'adaptive': True, 'disp': True})
            else:
                result = minimize(obj_fn, ag, method='Powell',
                                  bounds=list(zip(lb, ub)),
                                  options={'maxfev': 400, 'maxiter': 30, 'disp': True})
            elapsed = time.time() - t0
            res = np.clip(result.x, lb, ub)  # enforce bounds for Nelder-Mead
            fval = result.fun

            print(f"Iterations: {result.nit}")
            print(f"Function evaluations: {result.nfev}")
            print(f"Elapsed: {elapsed:.1f}s")

            _, _, est_mom_opt = objopt(
                res, given, data, option, option_moments_est, weights,
                nA, sigA, Alb, Aub, nB, sigB, nD, s,
                int_size, refinement, X, precomputed_grid=precomputed)

            print(f"\n   Data              Estimates")
            for i in range(len(data)):
                print(f"   {data[i]:8.3f}         {est_mom_opt[i]:8.3f}")
            print(" search done! :)")

            np.savetxt(os.path.join(moments_folder,
                       f'pattern_estimates_{ver}.csv'),
                       res[None, :], delimiter=',')

            # ---- Bootstrap ----
            if boot == 1:
                for i_boot in range(1, br + 1):
                    np.random.seed(i_boot)
                    X1 = np.random.rand(n - 1, 2)

                    c_avg_b   = np.loadtxt(os.path.join(moments_folder, f'c_avg_{i_boot}.csv'), delimiter=',')
                    bal_avg_b = np.loadtxt(os.path.join(moments_folder, f'bal_avg_{i_boot}.csv'), delimiter=',')
                    dc_shr_b  = np.loadtxt(os.path.join(moments_folder, f'dc_shr_{i_boot}.csv'), delimiter=',')

                    data_boot = np.array([c_avg_b, bal_avg_b, dc_shr_b])
                    data_b = data_boot[option_moments]
                    weights_b = np.diag(1.0 / data_b ** 2)

                    def obj_fn_b(a1, _d=data_b, _w=weights_b, _X=X1):
                        fval_b, _, _ = objopt(
                            a1, given, _d, option, option_moments_est, _w,
                            nA, sigA, Alb, Aub, nB, sigB, nD, s,
                            int_size, refinement, _X, precomputed_grid=precomputed)
                        return fval_b

                    print(f"\n Bootstrap rep {i_boot}")
                    t0 = time.time()
                    if opt_method == 'Nelder-Mead':
                        result_b = minimize(obj_fn_b, ag, method='Nelder-Mead',
                                            options={'maxfev': 400, 'maxiter': 200,
                                                     'xatol': 0.5, 'fatol': 1e-5,
                                                     'adaptive': True, 'disp': True})
                    else:
                        result_b = minimize(obj_fn_b, ag, method='Powell',
                                            bounds=list(zip(lb, ub)),
                                            options={'maxfev': 400, 'maxiter': 30, 'disp': True})
                    print(f"  Elapsed: {time.time()-t0:.1f}s")

                    np.savetxt(os.path.join(moments_folder,
                               f'pattern_estimates_{ver}_{i_boot}.csv'),
                               result_b.x[None, :], delimiter=',')

        # ---- Results summary ----
        if results == 1 and est_pattern == 1:
            rb = np.zeros((br, len(option_moments)))
            if boot == 1:
                for i in range(1, br + 1):
                    rb[i-1, :] = np.loadtxt(
                        os.path.join(moments_folder,
                                     f'pattern_estimates_{ver}_{i}.csv'),
                        delimiter=',')
            r = np.loadtxt(os.path.join(moments_folder,
                           f'pattern_estimates_{ver}.csv'), delimiter=',')
            print(f"\n Estimates: {r}")
            print(f" Bootstrap SE: {rb.std(axis=0)}")

    print("\nDone.")


if __name__ == '__main__':
    main()
