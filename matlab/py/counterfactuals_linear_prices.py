#!/usr/bin/env python3
"""
Robustness check: re-run all Table 6 counterfactuals under linear prices
(p1 = 27.8, p2 ≈ 0).

Produces the same five columns as Table 6:
  (1) Current  (2) Prepaid Metering  (3) 50% Less Enforcement
  (4) Late Penalty  (5) 4.9% Interest Rate

All results saved to paper/tables_new/ with suffix 'linp_b'.

Usage:
    python -m matlab.py.counterfactuals_linear_prices   (from repo root)
    python counterfactuals_linear_prices.py              (from matlab/py/)
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


# ===========================================================================
# Main
# ===========================================================================
def main():
    np.random.seed(1)

    # ---- Paths ----
    moments_folder = os.path.join(_repo_root, 'moments')
    cd_dir = os.path.join(_repo_root, 'paper', 'tables_new', '')
    os.makedirs(cd_dir, exist_ok=True)
    print(f"Output directory: {cd_dir}")

    # ---- Model configuration ----
    int_size    = 1
    refinement  = 1
    marginal_cost = 5
    visit_price   = 200

    s = 32 * 12            # 384
    n = 384 * 50 + 1       # 19201

    np.random.seed(1)
    X = np.random.rand(n - 1, 2)

    sigA = 0; sigB = 0; nD = 2; nA = 40; nB = 40

    # ---- Load data ----
    d = import_to_matlab_t3(moments_folder, 0, 1)
    y_avg     = d['y_avg']
    y_cv      = d['y_cv']
    bal_0_end = d['bal_0_end']
    Blb       = d['Blb']

    Alb = -2.0 * y_avg
    Aub =  2.0 * y_avg

    r_lend = 0.0047
    r_high = 0.0945

    # ---- Linear prices: keep original p1, set p2 ≈ 0 ----
    # Use small epsilon for p2 to avoid division-by-zero in boundary regime
    p1 = d['p1']       # original from data (17.566)
    p2 = 0.001

    # ---- Old parameter estimates ----
    alpha_est = 54.0
    pd_est    = 325.0
    pc_est    = 0.220
    beta_set  = 0.005
    ver       = 'linp_b'

    given = np.array([
        0, 0, r_high, 0, y_cv, 0, alpha_est, beta_set, y_avg,
        p1, p2, pd_est, n, 1, 0, 0, pc_est, bal_0_end, Blb, 12, 0.8
    ], dtype=np.float64)

    print(f"\n{'='*60}")
    print(f"Linear Prices Robustness Check")
    print(f"  p1 = {p1}, p2 = {p2}")
    print(f"  alpha = {alpha_est}, f = {pd_est}, lambda = {pc_est}")
    print(f"{'='*60}")

    # ==================================================================
    # (1) BASELINE
    # ==================================================================
    print("\n--- (1) BASELINE ---")
    t0 = time.time()
    est_mom, ucon, sim, _, _, _, _ = \
        obj(given, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    print(f"  obj() completed in {time.time()-t0:.1f}s")

    rev_goal, lend_cost, delinquency_cost, visit_cost, wwr, _, _ = \
        cost_calc(sim, r_lend, visit_price, marginal_cost, p1, p2, s)
    print(f"  rev_goal={rev_goal:.1f}, wwr={wwr:.1f}")

    # Utility derivative for CV
    res_poor = given.copy()
    res_poor[8] = given[8] - 100
    _, u_poor, _, _, _, _, _ = \
        obj(res_poor, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    u_ch = (ucon - u_poor) / 100.0
    print(f"  u_ch = {u_ch:.6f}")

    # Print baseline
    counterfactuals_print(cd_dir, f'reg_{ver}', given[16],
                          ucon, u_ch, ucon, ucon, sim, sim,
                          rev_goal, rev_goal,
                          lend_cost, delinquency_cost, visit_cost, wwr,
                          s, given, marginal_cost)

    # ==================================================================
    # (2) PREPAID METERING  (untied = 1)
    # ==================================================================
    print("\n--- (2) PREPAID METERING ---")
    res_nl = given.copy()
    res_nl[5] = 1   # untied = 1

    t0 = time.time()
    _, ucon_nl, sim_nl, _, _, _, _ = \
        obj(res_nl, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    print(f"  obj() completed in {time.time()-t0:.1f}s")

    rev_goal_nl, lend_cost_nl, delinquency_cost_nl, visit_cost_nl, wwr_nl, _, _ = \
        cost_calc(sim_nl, r_lend, visit_price, marginal_cost, p1, p2, s)

    # Revenue-neutral price — wider grid for prepaid (costs drop a lot)
    p1_nl = find_revenue_neutral_price(
        sim_nl, res_nl, rev_goal, wwr_nl, rev_goal_nl,
        p1, p2, marginal_cost)

    # Use absolute grid for prepaid: search p1 from marginal_cost+1 to alpha-1
    p1_grid_nl = np.arange(marginal_cost + 1, alpha_est - 1, 0.5)
    R_ov = np.zeros(len(p1_grid_nl)); P_ov = p1_grid_nl.copy()
    for i, p1r in enumerate(p1_grid_nl):
        res_nlr = res_nl.copy(); res_nlr[9] = p1r
        _, _, sim_nlr, _, _, _, _ = \
            obj(res_nlr, nA, sigA, Alb, Aub, nB, sigB, nD, s,
                int_size, refinement, X)
        rev_goal_nlr, _, _, _, _, _, _ = \
            cost_calc(sim_nlr, r_lend, visit_price, marginal_cost, p1r, p2, s)
        R_ov[i] = rev_goal - rev_goal_nlr
        print(f"    p1={p1r:.2f}, rev_gap={R_ov[i]:.1f}")
    p1_nl_final = P_ov[np.argmin(np.abs(R_ov))]
    print(f"  Best p1 = {p1_nl_final:.2f}")

    res_nlc = res_nl.copy(); res_nlc[9] = p1_nl_final
    _, ucon_nlc, sim_nlc, _, _, _, _ = \
        obj(res_nlc, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    rev_goal_nlc, lend_cost_nlc, delinquency_cost_nlc, visit_cost_nlc, wwr_nlc, _, _ = \
        cost_calc(sim_nlc, r_lend, visit_price, marginal_cost, p1_nl_final, p2, s)

    counterfactuals_print(cd_dir, f'nl_{ver}', given[16],
                          ucon, u_ch, ucon_nl, ucon_nlc, sim_nl, sim_nlc,
                          rev_goal, rev_goal_nlc,
                          lend_cost_nlc, delinquency_cost_nlc, visit_cost_nlc, wwr_nlc,
                          s, res_nlc, marginal_cost)

    # ==================================================================
    # (3) 50% LESS ENFORCEMENT  (pc / 2)
    # ==================================================================
    print("\n--- (3) 50% LESS ENFORCEMENT ---")
    res_hf = given.copy()
    res_hf[16] = pc_est / 2.0

    t0 = time.time()
    _, ucon_hf, sim_hf, _, _, _, _ = \
        obj(res_hf, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    print(f"  obj() completed in {time.time()-t0:.1f}s")

    rev_goal_hf, lend_cost_hf, delinquency_cost_hf, visit_cost_hf, wwr_hf, _, _ = \
        cost_calc(sim_hf, r_lend, visit_price, marginal_cost, p1, p2, s)

    p1_hf = find_revenue_neutral_price(
        sim_hf, res_hf, rev_goal, wwr_hf, rev_goal_hf,
        p1, p2, marginal_cost)

    Ogride = np.arange(-1, 0.25, 0.25)
    R_ov = np.zeros(len(Ogride)); P_ov = np.zeros(len(Ogride))
    for i, offset in enumerate(Ogride):
        p1r = p1_hf + offset
        res_hfr = res_hf.copy(); res_hfr[9] = p1r
        _, _, sim_hfr, _, _, _, _ = \
            obj(res_hfr, nA, sigA, Alb, Aub, nB, sigB, nD, s,
                int_size, refinement, X)
        rev_goal_hfr, _, _, _, _, _, _ = \
            cost_calc(sim_hfr, r_lend, visit_price, marginal_cost, p1r, p2, s)
        R_ov[i] = rev_goal - rev_goal_hfr; P_ov[i] = p1r
        print(f"    p1={p1r:.2f}, rev_gap={R_ov[i]:.1f}")
    p1_hf_final = P_ov[np.argmin(np.abs(R_ov))]
    print(f"  Best p1 = {p1_hf_final:.2f}")

    res_hfc = res_hf.copy(); res_hfc[9] = p1_hf_final
    _, ucon_hfc, sim_hfc, _, _, _, _ = \
        obj(res_hfc, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    rev_goal_hfc, lend_cost_hfc, delinquency_cost_hfc, visit_cost_hfc, wwr_hfc, _, _ = \
        cost_calc(sim_hfc, r_lend, visit_price, marginal_cost, p1_hf_final, p2, s)

    counterfactuals_print(cd_dir, f'hf_{ver}', given[16],
                          ucon, u_ch, ucon_hf, ucon_hfc, sim_hf, sim_hfc,
                          rev_goal, rev_goal_hfc,
                          lend_cost_hfc, delinquency_cost_hfc, visit_cost_hfc, wwr_hfc,
                          s, res_hfc, marginal_cost)

    # ==================================================================
    # (4) LATE PENALTY
    # ==================================================================
    late_penalty = 0.1 * 1235.0
    print(f"\n--- (4) LATE PENALTY (fee = {late_penalty:.1f}) ---")

    res_lp = given.copy()
    res_lp[3] = late_penalty

    t0 = time.time()
    _, ucon_lp, sim_lp, _, _, _, _ = \
        obj(res_lp, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    print(f"  obj() completed in {time.time()-t0:.1f}s")

    rev_goal_lp, lend_cost_lp, delinquency_cost_lp, visit_cost_lp, wwr_lp, \
        penalty_rev_lp, _ = \
        cost_calc(sim_lp, r_lend, visit_price, marginal_cost, p1, p2, s,
                  h_param=late_penalty)

    p1_lp = find_revenue_neutral_price(
        sim_lp, res_lp, rev_goal, wwr_lp, rev_goal_lp,
        p1, p2, marginal_cost)

    Ogride = np.arange(-1, 0.25, 0.25)
    R_ov = np.zeros(len(Ogride)); P_ov = np.zeros(len(Ogride))
    for i, offset in enumerate(Ogride):
        p1r = p1_lp + offset
        res_lpr = res_lp.copy(); res_lpr[9] = p1r
        _, _, sim_lpr, _, _, _, _ = \
            obj(res_lpr, nA, sigA, Alb, Aub, nB, sigB, nD, s,
                int_size, refinement, X)
        rev_goal_lpr, _, _, _, _, _, _ = \
            cost_calc(sim_lpr, r_lend, visit_price, marginal_cost, p1r, p2, s,
                      h_param=late_penalty)
        R_ov[i] = rev_goal - rev_goal_lpr; P_ov[i] = p1r
        print(f"    p1={p1r:.2f}, rev_gap={R_ov[i]:.1f}")
    p1_lp_final = P_ov[np.argmin(np.abs(R_ov))]
    print(f"  Best p1 = {p1_lp_final:.2f}")

    res_lpc = res_lp.copy(); res_lpc[9] = p1_lp_final
    _, ucon_lpc, sim_lpc, _, _, _, _ = \
        obj(res_lpc, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    rev_goal_lpc, lend_cost_lpc, delinquency_cost_lpc, visit_cost_lpc, wwr_lpc, \
        penalty_rev_lpc, _ = \
        cost_calc(sim_lpc, r_lend, visit_price, marginal_cost, p1_lp_final, p2, s,
                  h_param=late_penalty)

    counterfactuals_print(cd_dir, f'lp_{ver}', given[16],
                          ucon, u_ch, ucon_lp, ucon_lpc, sim_lp, sim_lpc,
                          rev_goal, rev_goal_lpc,
                          lend_cost_lpc, delinquency_cost_lpc, visit_cost_lpc, wwr_lpc,
                          s, res_lpc, marginal_cost,
                          penalty_rev=penalty_rev_lpc)

    # ==================================================================
    # (5) 4.9% INTEREST RATE
    # ==================================================================
    ir_rate = 0.049
    print(f"\n--- (5) 4.9% INTEREST RATE ---")

    res_ir = given.copy()
    res_ir[1] = ir_rate

    t0 = time.time()
    _, ucon_ir, sim_ir, _, _, _, _ = \
        obj(res_ir, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    print(f"  obj() completed in {time.time()-t0:.1f}s")

    rev_goal_ir, lend_cost_ir, delinquency_cost_ir, visit_cost_ir, wwr_ir, \
        _, interest_rev_ir = \
        cost_calc(sim_ir, r_lend, visit_price, marginal_cost, p1, p2, s,
                  r_water=ir_rate)

    p1_ir = find_revenue_neutral_price(
        sim_ir, res_ir, rev_goal, wwr_ir, rev_goal_ir,
        p1, p2, marginal_cost)

    Ogride = np.arange(-1, 0.25, 0.25)
    R_ov = np.zeros(len(Ogride)); P_ov = np.zeros(len(Ogride))
    for i, offset in enumerate(Ogride):
        p1r = p1_ir + offset
        res_irr = res_ir.copy(); res_irr[9] = p1r
        _, _, sim_irr, _, _, _, _ = \
            obj(res_irr, nA, sigA, Alb, Aub, nB, sigB, nD, s,
                int_size, refinement, X)
        rev_goal_irr, _, _, _, _, _, _ = \
            cost_calc(sim_irr, r_lend, visit_price, marginal_cost, p1r, p2, s,
                      r_water=ir_rate)
        R_ov[i] = rev_goal - rev_goal_irr; P_ov[i] = p1r
        print(f"    p1={p1r:.2f}, rev_gap={R_ov[i]:.1f}")
    p1_ir_final = P_ov[np.argmin(np.abs(R_ov))]
    print(f"  Best p1 = {p1_ir_final:.2f}")

    res_irc = res_ir.copy(); res_irc[9] = p1_ir_final
    _, ucon_irc, sim_irc, _, _, _, _ = \
        obj(res_irc, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    rev_goal_irc, lend_cost_irc, delinquency_cost_irc, visit_cost_irc, wwr_irc, \
        _, interest_rev_irc = \
        cost_calc(sim_irc, r_lend, visit_price, marginal_cost, p1_ir_final, p2, s,
                  r_water=ir_rate)

    counterfactuals_print(cd_dir, f'ir_{ver}', given[16],
                          ucon, u_ch, ucon_ir, ucon_irc, sim_ir, sim_irc,
                          rev_goal, rev_goal_irc,
                          lend_cost_irc, delinquency_cost_irc, visit_cost_irc, wwr_irc,
                          s, res_irc, marginal_cost,
                          interest_rev=interest_rev_irc)

    # ==================================================================
    # SUMMARY
    # ==================================================================
    print(f"\n{'='*60}")
    print(f"SUMMARY  (Linear Prices: p1={p1}, p2={p2})")
    print(f"{'='*60}")
    print(f"{'Scenario':<25} {'Uncomp CV':>12} {'Comp CV':>12} {'Price p1':>10}")
    print(f"{'-'*60}")
    print(f"{'Baseline':<25} {'---':>12} {'---':>12} {p1:>10.1f}")
    print(f"{'Prepaid Metering':<25} {(ucon-ucon_nl)/u_ch:>12.0f} {(ucon-ucon_nlc)/u_ch:>12.0f} {p1_nl_final:>10.1f}")
    print(f"{'50% Less Enforcement':<25} {(ucon-ucon_hf)/u_ch:>12.0f} {(ucon-ucon_hfc)/u_ch:>12.0f} {p1_hf_final:>10.1f}")
    print(f"{'Late Penalty':<25} {(ucon-ucon_lp)/u_ch:>12.0f} {(ucon-ucon_lpc)/u_ch:>12.0f} {p1_lp_final:>10.1f}")
    print(f"{'4.9% Interest':<25} {(ucon-ucon_ir)/u_ch:>12.0f} {(ucon-ucon_irc)/u_ch:>12.0f} {p1_ir_final:>10.1f}")
    print(f"\nResults written to: {cd_dir}")
    print("Done.")


if __name__ == '__main__':
    main()
