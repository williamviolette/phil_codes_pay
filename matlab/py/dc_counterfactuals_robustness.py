#!/usr/bin/env python3
"""
Run Late Penalty and 4.9% Interest Rate counterfactuals for the
remaining robustness variants: blow, chigh, clow.

Reads previously estimated parameters (alpha, pd, pc) from the
tables/ .tex files, plugs them into the given vector with the
appropriate beta_set and curve for each variant, and runs the
LP and IR counterfactuals.

Outputs to tables_new/ with blow/chigh/clow suffixes.

Usage:
    python -m matlab.py.dc_counterfactuals_robustness    (from repo root)
    python dc_counterfactuals_robustness.py              (from matlab/py/)
"""
import sys
import os
import time
import numpy as np

# ---- Repo root detection ----
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
from matlab.py.counterfactuals_new import (
    wnum, cost_calc, counterfactuals_print, find_revenue_neutral_price,
)


def read_tex_number(path):
    """Read a single number from a .tex file."""
    with open(path, 'r') as f:
        return float(f.read().strip())


def run_lp_ir_counterfactuals(ver, given, nA, sigA, Alb, Aub, nB, sigB, nD,
                               s, int_size, refinement, X,
                               r_lend, visit_price, marginal_cost, p1, p2,
                               bal_avg, cd_dir):
    """Run Late Penalty and 4.9% Interest counterfactuals for a given variant."""

    print(f"\n{'='*60}")
    print(f"Running LP & IR counterfactuals for ver={ver}")
    print(f"  alpha={given[6]:.1f}, pd={given[11]:.1f}, pc={given[16]:.3f}")
    print(f"  beta_set={given[7]:.4f}, curve={given[13]:.1f}")
    print(f"{'='*60}")

    # ---- BASELINE ----
    print("\n--- BASELINE ---")
    t0 = time.time()
    _, ucon, sim, _, _, _, _ = \
        obj(given, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    print(f"  obj() completed in {time.time()-t0:.1f}s")

    rev_goal, lend_cost, delinquency_cost, visit_cost, wwr, _, _ = \
        cost_calc(sim, r_lend, visit_price, marginal_cost, p1, p2, s)
    print(f"  rev_goal={rev_goal:.1f}")

    # Utility derivative (for CV)
    res_poor = given.copy()
    res_poor[8] = given[8] - 100
    _, u_poor, _, _, _, _, _ = \
        obj(res_poor, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    u_ch = (ucon - u_poor) / 100.0
    print(f"  u_ch = {u_ch:.6f}")

    # ==============================================================
    # LATE PENALTY
    # ==============================================================
    late_penalty = 0.1 * bal_avg
    print(f"\n--- LATE PENALTY (fee = {late_penalty:.1f} PhP) ---")

    res_lp = given.copy()
    res_lp[3] = late_penalty  # hasscost

    t0 = time.time()
    _, ucon_lp, sim_lp, _, _, _, _ = \
        obj(res_lp, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    print(f"  obj() completed in {time.time()-t0:.1f}s")
    print(f"  Uncompensated CV: {(ucon - ucon_lp)/u_ch:.1f}")

    rev_goal_lp, lend_cost_lp, delinquency_cost_lp, visit_cost_lp, wwr_lp, \
        penalty_rev_lp, _ = \
        cost_calc(sim_lp, r_lend, visit_price, marginal_cost, p1, p2, s,
                  h_param=late_penalty)

    # Revenue-neutral price with grid search
    p1_lpt = find_revenue_neutral_price(
        sim_lp, res_lp, rev_goal, wwr_lp, rev_goal_lp,
        p1, p2, marginal_cost)

    Ogride = np.arange(-1, 0.25, 0.25)
    R_ov = np.zeros(len(Ogride))
    P_ov = np.zeros(len(Ogride))
    for i, offset in enumerate(Ogride):
        p1r = p1_lpt + offset
        res_lpr = res_lp.copy()
        res_lpr[9] = p1r
        _, _, sim_lpr, _, _, _, _ = \
            obj(res_lpr, nA, sigA, Alb, Aub, nB, sigB, nD, s,
                int_size, refinement, X)
        rev_goal_lpr, _, _, _, _, _, _ = \
            cost_calc(sim_lpr, r_lend, visit_price, marginal_cost, p1r, p2, s,
                      h_param=late_penalty)
        R_ov[i] = rev_goal - rev_goal_lpr
        P_ov[i] = p1r

    best_idx = np.argmin(np.abs(R_ov))
    p1_lp_final = P_ov[best_idx]

    res_lpcp = res_lp.copy()
    res_lpcp[9] = p1_lp_final
    _, ucon_lpcp, sim_lpcp, _, _, _, _ = \
        obj(res_lpcp, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    print(f"  Compensated CV: {(ucon - ucon_lpcp)/u_ch:.1f}")

    rev_goal_lpcp, lend_cost_lpcp, delinquency_cost_lpcp, visit_cost_lpcp, wwr_lpcp, \
        penalty_rev_lpcp, _ = \
        cost_calc(sim_lpcp, r_lend, visit_price, marginal_cost, p1_lp_final, p2, s,
                  h_param=late_penalty)

    counterfactuals_print(cd_dir, f'lp_{ver}', given[16],
                          ucon, u_ch, ucon_lp, ucon_lpcp, sim_lp, sim_lpcp,
                          rev_goal, rev_goal_lpcp,
                          lend_cost_lpcp, delinquency_cost_lpcp, visit_cost_lpcp, wwr_lpcp,
                          s, res_lpcp, marginal_cost,
                          penalty_rev=penalty_rev_lpcp)

    # ==============================================================
    # 4.9% INTEREST RATE ON UNPAID BILLS
    # ==============================================================
    ir_rate = 0.049
    print(f"\n--- 4.9% INTEREST RATE ---")

    res_ir = given.copy()
    res_ir[1] = ir_rate  # r_water

    t0 = time.time()
    _, ucon_ir, sim_ir, _, _, _, _ = \
        obj(res_ir, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    print(f"  obj() completed in {time.time()-t0:.1f}s")
    print(f"  Uncompensated CV: {(ucon - ucon_ir)/u_ch:.1f}")

    rev_goal_ir, lend_cost_ir, delinquency_cost_ir, visit_cost_ir, wwr_ir, \
        _, interest_rev_ir = \
        cost_calc(sim_ir, r_lend, visit_price, marginal_cost, p1, p2, s,
                  r_water=ir_rate)

    # Revenue-neutral price with grid search
    p1_irt = find_revenue_neutral_price(
        sim_ir, res_ir, rev_goal, wwr_ir, rev_goal_ir,
        p1, p2, marginal_cost)

    Ogride = np.arange(-1, 0.25, 0.25)
    R_ov = np.zeros(len(Ogride))
    P_ov = np.zeros(len(Ogride))
    for i, offset in enumerate(Ogride):
        p1r = p1_irt + offset
        res_irr = res_ir.copy()
        res_irr[9] = p1r
        _, _, sim_irr, _, _, _, _ = \
            obj(res_irr, nA, sigA, Alb, Aub, nB, sigB, nD, s,
                int_size, refinement, X)
        rev_goal_irr, _, _, _, _, _, _ = \
            cost_calc(sim_irr, r_lend, visit_price, marginal_cost, p1r, p2, s,
                      r_water=ir_rate)
        R_ov[i] = rev_goal - rev_goal_irr
        P_ov[i] = p1r

    best_idx = np.argmin(np.abs(R_ov))
    p1_ir_final = P_ov[best_idx]

    res_ircp = res_ir.copy()
    res_ircp[9] = p1_ir_final
    _, ucon_ircp, sim_ircp, _, _, _, _ = \
        obj(res_ircp, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    print(f"  Compensated CV: {(ucon - ucon_ircp)/u_ch:.1f}")

    rev_goal_ircp, lend_cost_ircp, delinquency_cost_ircp, visit_cost_ircp, wwr_ircp, \
        _, interest_rev_ircp = \
        cost_calc(sim_ircp, r_lend, visit_price, marginal_cost, p1_ir_final, p2, s,
                  r_water=ir_rate)

    counterfactuals_print(cd_dir, f'ir_{ver}', given[16],
                          ucon, u_ch, ucon_ir, ucon_ircp, sim_ir, sim_ircp,
                          rev_goal, rev_goal_ircp,
                          lend_cost_ircp, delinquency_cost_ircp, visit_cost_ircp, wwr_ircp,
                          s, res_ircp, marginal_cost,
                          interest_rev=interest_rev_ircp)

    # Summary
    print(f"\n  SUMMARY for {ver}:")
    print(f"    Late Penalty  CV: {(ucon - ucon_lpcp)/u_ch:.0f} PhP")
    print(f"    4.9% Interest CV: {(ucon - ucon_ircp)/u_ch:.0f} PhP")

    return (ucon - ucon_lpcp) / u_ch, (ucon - ucon_ircp) / u_ch


def main():
    np.random.seed(1)

    # ---- Paths ----
    moments_folder = os.path.join(_repo_root, 'moments')
    tables_dir     = os.path.join(_repo_root, 'paper', 'tables')
    cd_dir         = os.path.join(_repo_root, 'paper', 'tables_new', '')
    os.makedirs(cd_dir, exist_ok=True)
    print(f"Reading estimates from: {tables_dir}")
    print(f"Output directory: {cd_dir}")

    # ---- Model configuration ----
    int_size    = 1
    refinement  = 1
    one_price   = 0
    marginal_cost = 5
    visit_price   = 200

    s = 32 * 12            # account length = 384
    n = 384 * 50 + 1       # 19201

    np.random.seed(1)
    X = np.random.rand(n - 1, 2)

    sigA = 0
    sigB = 0
    nD   = 2
    nA   = 40
    nB   = 40

    # ---- Load data ----
    d = import_to_matlab_t3(moments_folder, one_price, 1)
    y_avg       = d['y_avg']
    y_cv        = d['y_cv']
    p1          = d['p1']
    p2          = d['p2']
    bal_avg     = d['bal_avg']
    bal_0_end   = d['bal_0_end']
    Blb         = d['Blb']

    Alb = -2.0 * y_avg
    Aub =  2.0 * y_avg

    r_lend = 0.0047
    r_high = 0.0945

    # ---- Variant configurations ----
    # Each variant: (ver, beta_set, curve)
    # Estimates (alpha, pd, pc) are read from tables/ .tex files
    variants = [
        ('blow',  0.0025, 1.0),
        ('chigh', 0.005,  2.0),
        ('clow',  0.005,  0.5),
    ]

    for ver, beta_set, curve in variants:
        # Read estimates from tables/ .tex files
        alpha_est = read_tex_number(os.path.join(tables_dir, f'est_alpha_{ver}.tex'))
        pd_est    = read_tex_number(os.path.join(tables_dir, f'est_fc_{ver}.tex'))
        pc_est    = read_tex_number(os.path.join(tables_dir, f'est_pc_{ver}.tex'))

        print(f"\nLoaded estimates for {ver}: alpha={alpha_est}, pd={pd_est}, pc={pc_est}")

        #                 0        1        2       3       4       5       6      7         8     9   10    11  12  13     14   15    16       17       18  19   20
        # given:      r_lend, r_water, r_high, hcost, inc_sh, untie, alpha, beta, Y,       p1,  p2,  pd,   n, curve, fee, vh,  pc,   pm,      Blb,  Tg,  sp
        given = np.array([
            0, 0, r_high, 0, y_cv, 0, alpha_est, beta_set, y_avg, p1, p2, pd_est, n, curve, 0, 0, pc_est, bal_0_end, Blb, 12, 0.8
        ], dtype=np.float64)

        run_lp_ir_counterfactuals(
            ver, given, nA, sigA, Alb, Aub, nB, sigB, nD,
            s, int_size, refinement, X,
            r_lend, visit_price, marginal_cost, p1, p2,
            bal_avg, cd_dir)

    print(f"\n{'='*60}")
    print("All variants complete. Results written to tables_new/")
    print(f"{'='*60}")


if __name__ == '__main__':
    main()
