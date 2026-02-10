#!/usr/bin/env python3
"""
Lambda sweep counterfactual: find the welfare-maximizing enforcement rate.

Replaces the old "50% Less Enforcement" counterfactual with a full sweep
over lambda (prob_caught), identifying the optimal enforcement rate under
revenue neutrality.

Usage:
    python -m matlab.py.counterfactuals_lambda_sweep        (from repo root)
    python counterfactuals_lambda_sweep.py                  (from matlab/py/)
"""
import sys
import os
import time
import numpy as np

# ---- Repo root detection (same as dc_main_analysis_obj.py) ----
_MANUAL_ROOT = None

def _find_repo_root():
    if _MANUAL_ROOT is not None:
        return _MANUAL_ROOT
    env = os.environ.get('PHIL_CODES_PAY')
    if env and os.path.isdir(env):
        return env
    try:
        here = os.path.dirname(os.path.abspath(__file__))
        candidate = os.path.abspath(os.path.join(here, '..', '..'))
        if os.path.isdir(os.path.join(candidate, 'moments')) or \
           os.path.isdir(os.path.join(candidate, 'matlab')):
            return candidate
    except NameError:
        pass
    d = os.path.abspath(os.getcwd())
    for _ in range(10):
        if os.path.isdir(os.path.join(d, 'moments')) or \
           os.path.isdir(os.path.join(d, 'matlab', 'py')):
            return d
        d = os.path.dirname(d)
    raise FileNotFoundError(
        "Cannot find repo root. Set _MANUAL_ROOT or PHIL_CODES_PAY env var.")

_repo_root = _find_repo_root()
if _repo_root not in sys.path:
    sys.path.insert(0, _repo_root)

from matlab.py.import_data import import_to_matlab_t3
from matlab.py.obj import obj


# =========================================================================
# cost_calc — translated from matlab/cost_calc.m
# =========================================================================

def cost_calc(controls, r_lend, visit_price, marginal_cost, p1, p2, s):
    """
    Compute utility cost components from simulation output.

    Returns: (rev_goal, lend_cost, delinquency_cost, visit_cost, wwr)
    """
    lend_cost = np.mean(np.abs(controls[:, 2])) * r_lend

    end_mask = controls[:, 5] == s
    delinquency_cost = np.mean(np.abs(controls[end_mask, 2])) / s if np.any(end_mask) else 0.0

    # Visit cost: fraction of periods where previous balance < 0 and account age > 2
    prev_B = np.empty(len(controls))
    prev_B[0] = 0.0
    prev_B[1:] = controls[:-1, 2]
    visit_mask = (prev_B < 0) & (controls[:, 4] > 2)
    visit_cost = visit_price * np.sum(visit_mask) / len(controls)

    wwr = np.mean((p1 - marginal_cost + p2 * controls[:, 0]) * controls[:, 0])

    rev_goal = wwr - (lend_cost + delinquency_cost + visit_cost)

    return rev_goal, lend_cost, delinquency_cost, visit_cost, wwr


# =========================================================================
# Revenue-neutral price formula (analytical first approximation)
# =========================================================================

def revenue_neutral_price(rev_goal_target, wwr_cf, rev_goal_cf,
                          mean_water_cf, alpha, p1_base, p2, marginal_cost):
    """
    Solve for the marginal price p1 that makes the utility break even,
    accounting for the change in water consumption.

    Uses the closed-form quadratic solution from the MATLAB code.
    """
    R = rev_goal_target + (wwr_cf - rev_goal_cf)
    I = mean_water_cf - (alpha - p1_base) / (p2 * 2 + 1)
    a = alpha
    mc = marginal_cost

    discriminant = (4*I**2*p2**2 + 4*I**2*p2 + I**2
                    + 4*I*a*p2 + 2*I*a
                    - 4*I*mc*p2 - 2*I*mc
                    + a**2 - 2*a*mc + mc**2
                    - 4*R*p2 - 4*R)

    if discriminant < 0:
        return None

    sqrt_d = np.sqrt(discriminant)
    p1_new = (I + a + mc + 2*I*p2 - 2*p2*sqrt_d + 2*mc*p2 - sqrt_d) / (2*(p2 + 1))

    return p1_new


# =========================================================================
# wnum — write a single number to a .tex file (same as matlab/wnum.m)
# =========================================================================

def wnum(tables_dir, name, num, fmt):
    """Write a formatted number to a .tex file."""
    path = os.path.join(tables_dir, name)
    with open(path, 'w') as f:
        f.write(fmt % num + '\n')


# =========================================================================
# Print results — translated from counterfactuals_price_print.m
# =========================================================================

def counterfactuals_price_print(tables_dir, tag, vr, ucon, u_ch,
                                ucon_u, ucon_uc, sim_u, sim_uc,
                                rev_goal, rev_goal_u,
                                lend_cost_u, delinquency_cost_u,
                                visit_cost_u, wwr_u, s, given):
    """Write all counterfactual output .tex files for a given tag."""
    wnum(tables_dir, f'cv_{tag}.tex', (ucon - ucon_u) / u_ch, '%5.0f')
    wnum(tables_dir, f'cv_comp_{tag}.tex', (ucon - ucon_uc) / u_ch, '%5.0f')
    wnum(tables_dir, f'rev_goal_{tag}.tex', rev_goal_u, '%5.0f')
    wnum(tables_dir, f'p1_{tag}.tex', given[9], '%5.1f')
    wnum(tables_dir, f'vrate_{tag}.tex', vr, '%5.2f')

    end_mask = sim_uc[:, 5] == s
    wnum(tables_dir, f'debt_end_{tag}.tex',
         np.mean(np.abs(sim_uc[end_mask, 2])) if np.any(end_mask) else 0, '%5.0f')
    wnum(tables_dir, f'debt_{tag}.tex', np.mean(np.abs(sim_uc[:, 2])), '%5.0f')
    wnum(tables_dir, f'cons_{tag}.tex', np.mean(sim_uc[:, 0]), '%5.1f')
    wnum(tables_dir, f'cons_val_{tag}.tex',
         np.mean(sim_uc[:, 0] * (given[9] + given[10] * sim_uc[:, 0])), '%5.0f')

    wnum(tables_dir, f'lend_cost_{tag}.tex', lend_cost_u, '%5.0f')
    wnum(tables_dir, f'lend_cost_sum_{tag}.tex', lend_cost_u + delinquency_cost_u, '%5.0f')
    wnum(tables_dir, f'del_cost_{tag}.tex', delinquency_cost_u, '%5.0f')
    wnum(tables_dir, f'visit_cost_{tag}.tex', visit_cost_u, '%5.0f')
    wnum(tables_dir, f'wwr_{tag}.tex', wwr_u, '%5.0f')
    wnum(tables_dir, f'mc_cost_{tag}.tex', np.mean(sim_uc[:, 0]) * 5, '%5.0f')

    borrow = np.abs(sim_uc[:, 1] * (sim_uc[:, 1] < 0))
    wnum(tables_dir, f'Aborr_abs_{tag}.tex', np.mean(borrow), '%5.0f')

    if np.any(end_mask):
        bmax = np.sum(sim_uc[end_mask, 2] == np.min(sim_uc[end_mask, 2])) / np.sum(end_mask)
        wnum(tables_dir, f'b_max_end_{tag}.tex', 100 * bmax, '%5.0f')


# =========================================================================
# Lambda sweep: evaluate welfare at each enforcement rate
# =========================================================================

def run_lambda_sweep(given, lambda_grid, rev_goal_baseline, ucon_baseline, u_ch,
                     r_lend_cost, visit_price, marginal_cost, p1_base, p2,
                     nA, sigA, Alb, Aub, nB, sigB, nD, s, int_size, refinement, X):
    """
    Sweep over lambda values. For each:
      1. Run model at new lambda (with baseline price)
      2. Compute revenue-neutral price
      3. Re-run model at revenue-neutral price
      4. Compute compensating variation

    Returns arrays of (cv, lambda, p1_new) and full results for the optimum.
    """
    n_grid = len(lambda_grid)
    cv_arr = np.full(n_grid, np.nan)
    p1_arr = np.full(n_grid, np.nan)
    rev_arr = np.full(n_grid, np.nan)

    alpha = given[6]

    for i, lam in enumerate(lambda_grid):
        t0 = time.time()
        print(f"\n--- Lambda = {lam:.3f} ({i+1}/{n_grid}) ---")

        # Step 1: run model at this lambda with baseline price
        given_cf = given.copy()
        given_cf[16] = lam
        _, ucon_cf, sim_cf, _, _, _, _ = obj(
            given_cf, nA, sigA, Alb, Aub, nB, sigB, nD, s, int_size, refinement, X)

        rev_goal_cf, _, _, _, wwr_cf = cost_calc(
            sim_cf, r_lend_cost, visit_price, marginal_cost, p1_base, p2, s)

        # Step 2: compute revenue-neutral price (analytical)
        p1_new = revenue_neutral_price(
            rev_goal_baseline, wwr_cf, rev_goal_cf,
            np.mean(sim_cf[:, 0]), alpha, p1_base, p2, marginal_cost)

        if p1_new is None or p1_new < 0:
            print(f"  Skipping: no valid revenue-neutral price")
            continue

        # Step 3: grid search to refine price (same approach as MATLAB)
        offsets = np.arange(-1.0, 0.0, 0.25)
        best_rev_gap = np.inf
        best_p1 = p1_new

        for offset in offsets:
            p1_try = p1_new + offset
            given_try = given_cf.copy()
            given_try[9] = p1_try
            _, _, sim_try, _, _, _, _ = obj(
                given_try, nA, sigA, Alb, Aub, nB, sigB, nD, s, int_size, refinement, X)
            rev_try, _, _, _, _ = cost_calc(
                sim_try, r_lend_cost, visit_price, marginal_cost, p1_try, p2, s)
            gap = abs(rev_goal_baseline - rev_try)
            if gap < best_rev_gap:
                best_rev_gap = gap
                best_p1 = p1_try

        # Step 4: final run at revenue-neutral price
        given_final = given_cf.copy()
        given_final[9] = best_p1
        _, ucon_final, sim_final, _, _, _, _ = obj(
            given_final, nA, sigA, Alb, Aub, nB, sigB, nD, s, int_size, refinement, X)

        rev_final, lend_final, del_final, visit_final, wwr_final = cost_calc(
            sim_final, r_lend_cost, visit_price, marginal_cost, best_p1, p2, s)

        cv = (ucon_baseline - ucon_final) / u_ch
        cv_arr[i] = cv
        p1_arr[i] = best_p1
        rev_arr[i] = rev_goal_baseline - rev_final

        elapsed = time.time() - t0
        print(f"  CV = {cv:.1f} PhP, p1 = {best_p1:.2f}, rev gap = {rev_arr[i]:.1f}, "
              f"({elapsed:.1f}s)")

    return cv_arr, p1_arr, rev_arr


# =========================================================================
# Main
# =========================================================================

def main():
    np.random.seed(1)

    # ---- Paths ----
    moments_folder = os.path.join(_repo_root, 'moments')
    tables_dir     = os.path.join(_repo_root, 'paper', 'tables')

    # ---- Parameters (same as dc_main_analysis_obj.py) ----
    int_size   = 1
    refinement = 1
    one_price  = 0
    marginal_cost = 5
    s = 32 * 12  # 384

    n = 384 * 50 + 1
    np.random.seed(1)
    X = np.random.rand(n - 1, 2)

    sigA = 0
    sigB = 0
    nD   = 2
    nA   = 40
    nB   = 40

    visit_price = 200

    # ---- Load data ----
    d = import_to_matlab_t3(moments_folder, one_price, 1)
    y_avg = d['y_avg']
    y_cv  = d['y_cv']
    p1    = d['p1']
    p2    = d['p2']
    bal_0_end = d['bal_0_end']
    Blb   = d['Blb']

    Alb = -2.0 * y_avg
    Aub =  2.0 * y_avg

    r_lend = 0.0047
    r_high = 0.0945

    # ---- Loop over specifications (baseline + robustness) ----
    specs = [
        (0, 'b',      0.005, dict(alpha=54.001, pd=319.56,  pc=0.22015)),
        (1, 'bhigh',  0.01,  dict(alpha=54,     pd=370,     pc=0.24)),
        (2, 'blow',   0.0025,dict(alpha=54,     pd=340,     pc=0.20)),
        (3, 'chigh',  0.005, dict(alpha=53.5,   pd=380,     pc=0.215)),
        (4, 'clow',   0.005, dict(alpha=54.5,   pd=310,     pc=0.23)),
    ]

    for L, ver, beta_set, est in specs:
        print(f"\n{'='*60}")
        print(f"  Specification: {ver}  (L={L})")
        print(f"{'='*60}")

        given = np.array([
            0, 0, r_high, 0, y_cv, 0,
            est['alpha'], beta_set, y_avg, p1, p2, est['pd'],
            n, 1, 0, 0, est['pc'], bal_0_end, Blb, 12, 0.8
        ], dtype=np.float64)

        if ver == 'bhigh':
            given = np.array([0,0,r_high,0,y_cv,0,54,beta_set,y_avg,p1,p2,370,n,1,0,0,0.24,bal_0_end,Blb,12,0.8])
        elif ver == 'blow':
            given = np.array([0,0,r_high,0,y_cv,0,54,beta_set,y_avg,p1,p2,340,n,1,0,0,0.20,bal_0_end,Blb,12,0.8])
        elif ver == 'chigh':
            given = np.array([0,0,r_high,0,y_cv,0,53.5,beta_set,y_avg,p1,p2,380,n,2,0,0,0.215,bal_0_end,Blb,12,0.8])
        elif ver == 'clow':
            given = np.array([0,0,r_high,0,y_cv,0,54.5,beta_set,y_avg,p1,p2,310,n,0.5,0,0,0.23,bal_0_end,Blb,12,0.8])

        # ---- Baseline ----
        print("Running baseline...")
        _, ucon_base, sim_base, _, _, _, _ = obj(
            given, nA, sigA, Alb, Aub, nB, sigB, nD, s, int_size, refinement, X)

        rev_goal_base, lend_base, del_base, visit_base, wwr_base = cost_calc(
            sim_base, r_lend, visit_price, marginal_cost, p1, p2, s)

        # Marginal utility of income
        given_poor = given.copy()
        given_poor[8] = given[8] - 100
        _, u_poor, _ , _, _, _, _ = obj(
            given_poor, nA, sigA, Alb, Aub, nB, sigB, nD, s, int_size, refinement, X)
        u_ch = (ucon_base - u_poor) / 100

        print(f"Baseline: ucon={ucon_base:.4f}, rev_goal={rev_goal_base:.1f}, u_ch={u_ch:.6f}")

        # ---- Lambda sweep ----
        lambda_grid = np.arange(0.02, 0.42, 0.02)

        cv_arr, p1_arr, rev_arr = run_lambda_sweep(
            given, lambda_grid, rev_goal_base, ucon_base, u_ch,
            r_lend, visit_price, marginal_cost, p1, p2,
            nA, sigA, Alb, Aub, nB, sigB, nD, s, int_size, refinement, X)

        # ---- Find optimum (most negative CV = largest welfare gain) ----
        valid = ~np.isnan(cv_arr)
        if not np.any(valid):
            print(f"WARNING: No valid lambda values for spec {ver}")
            continue

        opt_idx = np.nanargmin(cv_arr)
        lambda_opt = lambda_grid[opt_idx]
        cv_opt = cv_arr[opt_idx]
        p1_opt = p1_arr[opt_idx]

        print(f"\n{'='*60}")
        print(f"  OPTIMAL: lambda* = {lambda_opt:.3f}, CV = {cv_opt:.0f} PhP, p1 = {p1_opt:.2f}")
        print(f"{'='*60}")

        # ---- Save sweep results to CSV ----
        sweep_out = np.column_stack([lambda_grid, cv_arr, p1_arr, rev_arr])
        np.savetxt(os.path.join(moments_folder, f'lambda_sweep_{ver}.csv'),
                   sweep_out, delimiter=',',
                   header='lambda,cv,p1,rev_gap', comments='')

        # ---- Final run at optimal lambda for table output ----
        given_opt = given.copy()
        given_opt[16] = lambda_opt
        _, ucon_opt_raw, sim_opt_raw, _, _, _, _ = obj(
            given_opt, nA, sigA, Alb, Aub, nB, sigB, nD, s, int_size, refinement, X)

        given_opt_price = given_opt.copy()
        given_opt_price[9] = p1_opt
        _, ucon_opt, sim_opt, _, _, _, _ = obj(
            given_opt_price, nA, sigA, Alb, Aub, nB, sigB, nD, s, int_size, refinement, X)

        rev_opt, lend_opt, del_opt, visit_opt, wwr_opt = cost_calc(
            sim_opt, r_lend, visit_price, marginal_cost, p1_opt, p2, s)

        # ---- Write table files (using hf_ tag to replace old half-rate) ----
        tag = f'hf_{ver}'
        counterfactuals_price_print(
            tables_dir, tag, lambda_opt,
            ucon_base, u_ch,
            ucon_opt_raw, ucon_opt,
            sim_opt_raw, sim_opt,
            rev_goal_base, rev_opt,
            lend_opt, del_opt, visit_opt, wwr_opt,
            s, given_opt_price)

        print(f"\nTable files written for tag '{tag}'")

    print("\nDone.")


if __name__ == '__main__':
    main()
