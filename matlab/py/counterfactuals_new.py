#!/usr/bin/env python3
"""
New counterfactual computation script.

Runs two counterfactual policies using previously estimated parameters:
  (a) Late Penalty: 10% of avg unpaid balance fee when B_{t+1} < 0
      -> extra fee of (0.1 * 1235) * 1{B_{t+1} < 0}
  (b) Interest Rate: 4.9% monthly interest on unpaid bills
      -> B_{t+1} becomes B_{t+1} / (1 + 0.049)

Uses old parameter estimates: alpha = 54.0, f = 325.0, lambda = 0.220

Usage:
    python -m matlab.py.counterfactuals_new          (from repo root)
    python counterfactuals_new.py                    (from matlab/py/)
"""
import sys
import os
import time
import numpy as np

# ---- Repo root detection (same pattern as dc_main_analysis_obj.py) ----
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


# ---------------------------------------------------------------------------
# Helper: write a single formatted number to a .tex file (like wnum.m)
# ---------------------------------------------------------------------------
def wnum(directory, name, num, fmt='%5.0f'):
    """Write a formatted number to a .tex file."""
    os.makedirs(directory, exist_ok=True)
    with open(os.path.join(directory, name), 'w') as f:
        if isinstance(fmt, str) and 'f' in fmt:
            # parse precision from format string
            f.write((fmt % num).strip() + '\n')
        else:
            f.write((fmt % num).strip() + '\n')


# ---------------------------------------------------------------------------
# cost_calc: translate of cost_calc.m
# ---------------------------------------------------------------------------
def cost_calc(controls, r_lend, visit_price, marginal_cost, p1, p2, s,
              h_param=0.0, r_water=0.0):
    """
    Calculate revenue goal and cost components.

    Parameters
    ----------
    controls : (N, 7) array — simulation output from obj()
        col 0: consumption (w)
        col 1: A' (standard asset)
        col 2: B' (water bill balance, negative = debt)
        col 3: D' (delinquency indicator)
        col 4: income state (1-based)
        col 5: time period within account
        col 6: exit indicator
    r_lend       : float, lending interest rate
    visit_price  : float, cost per delinquency visit
    marginal_cost: float, marginal pumping cost per m3
    p1           : float, constant part of marginal price
    p2           : float, slope of marginal price
    s            : int,   account length (384)
    h_param      : float, late penalty fee when B_{t+1} < 0 (revenue to utility)
    r_water      : float, monthly interest rate on unpaid water bills (revenue to utility)

    Returns
    -------
    rev_goal, lend_cost, delinquency_cost, visit_cost, wwr, penalty_rev, interest_rev
    """
    # Lending cost: opportunity cost of carrying debt
    lend_cost = np.mean(np.abs(controls[:, 2])) * r_lend

    # Delinquency cost: lost revenue from unpaid bills at end of account
    end_mask = controls[:, 5] == s
    if np.any(end_mask):
        delinquency_cost = np.mean(np.abs(controls[end_mask, 2])) / s
    else:
        delinquency_cost = 0.0

    # Visit cost: cost of visiting delinquent households
    n_rows = controls.shape[0]
    prev_B = np.empty(n_rows)
    prev_B[0] = 0.0
    prev_B[1:] = controls[:-1, 2]
    delinquent_visited = np.sum((prev_B < 0) & (controls[:, 4] > 2))
    visit_cost = visit_price * (delinquent_visited / n_rows)

    # Late penalty revenue: utility collects h_param each month B_{t+1} < 0
    penalty_rev = h_param * np.mean(controls[:, 2] < 0) if h_param > 0 else 0.0

    # Interest revenue: utility collects interest on unpaid bills
    # Consistent with budget constraint: B_{t+1}/(1+r_water), so the
    # interest paid = |B_{t+1}| * r_water/(1+r_water)
    if r_water > 0:
        interest_rev = (r_water / (1.0 + r_water)) * \
            np.mean(np.abs(controls[:, 2]) * (controls[:, 2] < 0))
    else:
        interest_rev = 0.0

    # Water revenue net of marginal cost
    wwr = np.mean((p1 - marginal_cost + p2 * controls[:, 0]) * controls[:, 0])

    rev_goal = wwr + penalty_rev + interest_rev - (lend_cost + delinquency_cost + visit_cost)

    return rev_goal, lend_cost, delinquency_cost, visit_cost, wwr, penalty_rev, interest_rev


# ---------------------------------------------------------------------------
# counterfactuals_print: write all result .tex files for a scenario
# ---------------------------------------------------------------------------
def counterfactuals_print(cd_dir, tag, vr, ucon, u_ch,
                          ucon_u, ucon_uc, sim_u, sim_uc,
                          rev_goal, rev_goal_u,
                          lend_cost_u, delinquency_cost_u, visit_cost_u, wwr_u,
                          s, given, marginal_cost=5.0,
                          penalty_rev=0.0, interest_rev=0.0):
    """Write counterfactual results to .tex files (mirrors MATLAB print functions)."""
    # Welfare
    wnum(cd_dir, f'cv_{tag}.tex',      (ucon - ucon_u) / u_ch, '%5.0f')
    wnum(cd_dir, f'cv_comp_{tag}.tex',  (ucon - ucon_uc) / u_ch, '%5.0f')

    # Costs and revenue
    wnum(cd_dir, f'rev_goal_{tag}.tex',  rev_goal_u, '%5.0f')
    wnum(cd_dir, f'p1_{tag}.tex',        given[9], '%5.1f')
    wnum(cd_dir, f'vrate_{tag}.tex',     vr, '%5.2f')

    # Debt
    end_mask = sim_uc[:, 5] == s
    if np.any(end_mask):
        debt_end = np.mean(np.abs(sim_uc[end_mask, 2]))
    else:
        debt_end = 0.0
    wnum(cd_dir, f'debt_end_{tag}.tex', debt_end, '%5.0f')
    wnum(cd_dir, f'debt_{tag}.tex',     np.mean(np.abs(sim_uc[:, 2])), '%5.0f')

    # Consumption
    wnum(cd_dir, f'cons_{tag}.tex',     np.mean(sim_uc[:, 0]), '%5.1f')
    wnum(cd_dir, f'cons_val_{tag}.tex',
         np.mean(sim_uc[:, 0] * (given[9] + given[10] * sim_uc[:, 0])), '%5.0f')

    # Cost components
    wnum(cd_dir, f'lend_cost_{tag}.tex',     lend_cost_u, '%5.0f')
    wnum(cd_dir, f'del_cost_{tag}.tex',      delinquency_cost_u, '%5.0f')
    wnum(cd_dir, f'lend_cost_sum_{tag}.tex', lend_cost_u + delinquency_cost_u, '%5.0f')
    wnum(cd_dir, f'visit_cost_{tag}.tex',    visit_cost_u, '%5.0f')
    wnum(cd_dir, f'wwr_{tag}.tex',           wwr_u, '%5.0f')
    wnum(cd_dir, f'mc_cost_{tag}.tex',       np.mean(sim_uc[:, 0]) * marginal_cost, '%5.0f')

    # Policy revenue
    wnum(cd_dir, f'penalty_rev_{tag}.tex', penalty_rev, '%5.0f')
    wnum(cd_dir, f'interest_rev_{tag}.tex', interest_rev, '%5.0f')

    # Standard borrowing
    borrow = np.abs(sim_uc[:, 1] * (sim_uc[:, 1] < 0))
    wnum(cd_dir, f'Aborr_abs_{tag}.tex', np.mean(borrow), '%5.0f')

    # Fraction at max borrowing at end
    if np.any(end_mask):
        bmax = np.sum(sim_uc[end_mask, 2] == np.min(sim_uc[end_mask, 2])) / np.sum(end_mask)
    else:
        bmax = 0.0
    wnum(cd_dir, f'b_max_end_{tag}.tex', 100 * bmax, '%5.0f')


# ---------------------------------------------------------------------------
# Revenue-neutral price solver (closed-form from counterfactuals_price.m)
# ---------------------------------------------------------------------------
def find_revenue_neutral_price(sim_cf, given, rev_goal_baseline, wwr_cf, rev_goal_cf,
                               p1, p2, marginal_cost):
    """
    Find the revenue-neutral marginal price p1_new such that
    revenue under counterfactual = baseline fixed costs.

    Uses the closed-form solution from counterfactuals_price.m.
    """
    alpha = given[6]

    # Required revenue = baseline fixed costs + change in non-water costs
    R = rev_goal_baseline + (wwr_cf - rev_goal_cf)

    # Consumption shift: difference between counterfactual consumption
    # and what consumption would be at baseline prices
    I = np.mean(sim_cf[:, 0]) - (alpha - p1) / (p2 * 2.0 + 1.0)

    a_s = alpha
    mc = marginal_cost
    p2s = p2

    # Closed-form solution from MATLAB
    disc = (4*I**2*p2s**2 + 4*I**2*p2s + I**2
            + 4*I*a_s*p2s + 2*I*a_s
            - 4*I*mc*p2s - 2*I*mc
            + a_s**2 - 2*a_s*mc + mc**2
            - 4*R*p2s - 4*R)

    if disc < 0:
        print(f"  WARNING: discriminant negative ({disc:.2f}), using grid search")
        return _grid_search_price(given, rev_goal_baseline, p1, p2, marginal_cost)

    sqrt_disc = np.sqrt(disc)
    p1_new = (I + a_s + mc + 2*I*p2s
              - 2*p2s*sqrt_disc + 2*mc*p2s
              - sqrt_disc) / (2*(p2s + 1))

    return p1_new


def _grid_search_price(given, rev_goal_target, p1_base, p2, marginal_cost):
    """Fallback grid search for revenue-neutral price."""
    alpha = given[6]
    best_p1 = p1_base
    best_err = np.inf
    for p1_try in np.arange(p1_base - 5, p1_base + 5, 0.1):
        w_try = (alpha - p1_try) / (p2 * 2.0 + 1.0)
        if w_try <= 0:
            continue
        rev_try = (p1_try - marginal_cost + p2 * w_try) * w_try
        err = abs(rev_try - rev_goal_target)
        if err < best_err:
            best_err = err
            best_p1 = p1_try
    return best_p1


# ===========================================================================
# Main counterfactual computation
# ===========================================================================
def main():
    np.random.seed(1)

    # ---- Paths ----
    moments_folder = os.path.join(_repo_root, 'moments')

    # Output directory — local development path or repo-relative fallback
    local_tables_dir = '/Users/willviolette/Library/CloudStorage/Dropbox/Mac/Documents/GitHub/phil_codes_pay/paper/tables_new/'
    if os.path.isdir(os.path.dirname(local_tables_dir.rstrip('/'))):
        cd_dir = local_tables_dir
    else:
        cd_dir = os.path.join(_repo_root, 'paper', 'tables_new', '')

    os.makedirs(cd_dir, exist_ok=True)
    print(f"Output directory: {cd_dir}")

    # ---- Model configuration (same as dc_main_analysis_obj.py) ----
    int_size    = 1
    refinement  = 1
    marginal_cost = 5
    visit_price   = 200
    ppinst        = 51

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
    d = import_to_matlab_t3(moments_folder, 0, 1)
    y_avg       = d['y_avg']
    y_cv        = d['y_cv']
    p1          = d['p1']
    p2          = d['p2']
    bal_0_end   = d['bal_0_end']
    Blb         = d['Blb']

    Alb = -2.0 * y_avg
    Aub =  2.0 * y_avg

    r_lend = 0.0047
    r_high = 0.0945

    beta_set = 0.005
    ver = 'b'

    # ---- Old parameter estimates (as specified) ----
    alpha_est  = 54.0
    pd_est     = 325.0
    pc_est     = 0.220

    #                 0        1        2       3       4       5       6      7         8     9   10    11  12  13   14   15    16       17       18  19   20
    # given:      r_lend, r_water, r_high, hcost, inc_sh, untie, alpha, beta, Y,       p1,  p2,  pd,   n, curve,fee, vh,  pc,   pm,      Blb,  Tg,  sp
    given = np.array([
        0,    0,    r_high, 0,   y_cv,  0,    alpha_est,   beta_set, y_avg, p1, p2,  pd_est,  n, 1,   0,   0,  pc_est, bal_0_end, Blb, 12, 0.8
    ], dtype=np.float64)

    option = [6, 11, 16]   # alpha, pd, pc indices

    print(f"\n{'='*60}")
    print(f"New Counterfactual Computation")
    print(f"  alpha = {alpha_est}, f = {pd_est}, lambda = {pc_est}")
    print(f"  ver = {ver}")
    print(f"{'='*60}")

    # ==================================================================
    # BASELINE
    # ==================================================================
    print("\n--- BASELINE ---")
    t0 = time.time()
    est_mom, ucon, sim, _, _, _, _ = \
        obj(given, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    print(f"  obj() completed in {time.time()-t0:.1f}s")
    print(f"  Moments: {np.round(est_mom[:3], 3)}")

    rev_goal, lend_cost, delinquency_cost, visit_cost, wwr, _, _ = \
        cost_calc(sim, r_lend, visit_price, marginal_cost, p1, p2, s)
    print(f"  rev_goal={rev_goal:.1f}, lend={lend_cost:.1f}, "
          f"delinq={delinquency_cost:.1f}, visit={visit_cost:.1f}, wwr={wwr:.1f}")

    # ---- Utility derivative (for CV calculation) ----
    res_poor = given.copy()
    res_poor[8] = given[8] - 100  # reduce income by 100 PhP
    _, u_poor, _, _, _, _, _ = \
        obj(res_poor, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    u_ch = (ucon - u_poor) / 100.0
    print(f"  u_ch (utility per PhP) = {u_ch:.6f}")

    # ---- Print baseline results ----
    counterfactuals_print(cd_dir, f'reg_{ver}', given[16],
                          ucon, u_ch, ucon, ucon, sim, sim,
                          rev_goal, rev_goal,
                          lend_cost, delinquency_cost, visit_cost, wwr,
                          s, given, marginal_cost)

    # ==================================================================
    # COUNTERFACTUAL (a): LATE PENALTY
    # 10% of average unpaid balance = 0.1 * 1235 = 123.5 PhP
    # Applied as fee when B_{t+1} < 0 (uses h_param = given[3])
    # ==================================================================
    late_penalty = 0.1 * 1235.0   # = 123.5 PhP
    print(f"\n--- LATE PENALTY (fee = {late_penalty:.1f} PhP when B_{{t+1}} < 0) ---")

    res_lp = given.copy()
    res_lp[3] = late_penalty   # h_param: cost when Bprime < 0

    t0 = time.time()
    _, ucon_lp, sim_lp, _, _, _, _ = \
        obj(res_lp, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    print(f"  obj() completed in {time.time()-t0:.1f}s")
    print(f"  Uncompensated CV: {(ucon - ucon_lp)/u_ch:.1f} PhP")

    rev_goal_lp, lend_cost_lp, delinquency_cost_lp, visit_cost_lp, wwr_lp, \
        penalty_rev_lp, _ = \
        cost_calc(sim_lp, r_lend, visit_price, marginal_cost, p1, p2, s,
                  h_param=late_penalty)
    print(f"  rev_goal={rev_goal_lp:.1f}, penalty_rev={penalty_rev_lp:.1f}, "
          f"delta_rev={rev_goal - rev_goal_lp:.1f}")

    # Revenue-neutral price adjustment
    p1_lp = find_revenue_neutral_price(
        sim_lp, res_lp, rev_goal, wwr_lp, rev_goal_lp,
        p1, p2, marginal_cost)
    print(f"  Revenue-neutral p1 = {p1_lp:.2f} (baseline p1 = {p1:.1f})")

    # Grid search refinement around closed-form solution
    Ogride = np.arange(-1, 0.25, 0.25)
    R_ov = np.zeros(len(Ogride))
    P_ov = np.zeros(len(Ogride))
    for i, offset in enumerate(Ogride):
        p1r = p1_lp + offset
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
        print(f"    p1={p1r:.2f}, rev_gap={R_ov[i]:.1f}")

    best_idx = np.argmin(np.abs(R_ov))
    p1_lp_final = P_ov[best_idx]
    print(f"  Best revenue-neutral p1 = {p1_lp_final:.2f}")

    # Run compensated simulation
    res_lpc = res_lp.copy()
    res_lpc[9] = p1_lp_final
    _, ucon_lpc, sim_lpc, _, _, _, _ = \
        obj(res_lpc, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    rev_goal_lpc, lend_cost_lpc, delinquency_cost_lpc, visit_cost_lpc, wwr_lpc, \
        penalty_rev_lpc, _ = \
        cost_calc(sim_lpc, r_lend, visit_price, marginal_cost, p1_lp_final, p2, s,
                  h_param=late_penalty)

    print(f"  Compensated CV: {(ucon - ucon_lpc)/u_ch:.1f} PhP")
    print(f"  Rev gap after compensation: {rev_goal - rev_goal_lpc:.1f}")

    # Print late penalty results
    counterfactuals_print(cd_dir, f'lp_{ver}', given[16],
                          ucon, u_ch, ucon_lp, ucon_lpc, sim_lp, sim_lpc,
                          rev_goal, rev_goal_lpc,
                          lend_cost_lpc, delinquency_cost_lpc, visit_cost_lpc, wwr_lpc,
                          s, res_lpc, marginal_cost,
                          penalty_rev=penalty_rev_lpc)

    # ==================================================================
    # COUNTERFACTUAL (b): INTEREST RATE ON UNPAID BILLS
    # 4.9% monthly interest rate -> B_{t+1} / (1 + 0.049)
    # Uses r_water = given[1]
    # ==================================================================
    ir_rate = 0.049
    print(f"\n--- INTEREST RATE ({ir_rate*100:.1f}% monthly on unpaid bills) ---")

    res_ir = given.copy()
    res_ir[1] = ir_rate   # r_water: interest rate on water bill debt

    t0 = time.time()
    _, ucon_ir, sim_ir, _, _, _, _ = \
        obj(res_ir, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    print(f"  obj() completed in {time.time()-t0:.1f}s")
    print(f"  Uncompensated CV: {(ucon - ucon_ir)/u_ch:.1f} PhP")

    rev_goal_ir, lend_cost_ir, delinquency_cost_ir, visit_cost_ir, wwr_ir, \
        _, interest_rev_ir = \
        cost_calc(sim_ir, r_lend, visit_price, marginal_cost, p1, p2, s,
                  r_water=ir_rate)
    print(f"  rev_goal={rev_goal_ir:.1f}, interest_rev={interest_rev_ir:.1f}, "
          f"delta_rev={rev_goal - rev_goal_ir:.1f}")

    # Revenue-neutral price adjustment
    p1_ir = find_revenue_neutral_price(
        sim_ir, res_ir, rev_goal, wwr_ir, rev_goal_ir,
        p1, p2, marginal_cost)
    print(f"  Revenue-neutral p1 = {p1_ir:.2f} (baseline p1 = {p1:.1f})")

    # Grid search refinement
    Ogride = np.arange(-1, 0.25, 0.25)
    R_ov = np.zeros(len(Ogride))
    P_ov = np.zeros(len(Ogride))
    for i, offset in enumerate(Ogride):
        p1r = p1_ir + offset
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
        print(f"    p1={p1r:.2f}, rev_gap={R_ov[i]:.1f}")

    best_idx = np.argmin(np.abs(R_ov))
    p1_ir_final = P_ov[best_idx]
    print(f"  Best revenue-neutral p1 = {p1_ir_final:.2f}")

    # Run compensated simulation
    res_irc = res_ir.copy()
    res_irc[9] = p1_ir_final
    _, ucon_irc, sim_irc, _, _, _, _ = \
        obj(res_irc, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    rev_goal_irc, lend_cost_irc, delinquency_cost_irc, visit_cost_irc, wwr_irc, \
        _, interest_rev_irc = \
        cost_calc(sim_irc, r_lend, visit_price, marginal_cost, p1_ir_final, p2, s,
                  r_water=ir_rate)

    print(f"  Compensated CV: {(ucon - ucon_irc)/u_ch:.1f} PhP")
    print(f"  Rev gap after compensation: {rev_goal - rev_goal_irc:.1f}")

    # Print interest rate results
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
    print(f"SUMMARY")
    print(f"{'='*60}")
    print(f"{'Scenario':<25} {'Uncomp CV':>12} {'Comp CV':>12} {'Price p1':>10}")
    print(f"{'-'*60}")
    print(f"{'Baseline':<25} {'---':>12} {'---':>12} {p1:>10.1f}")
    print(f"{'Late Penalty':<25} {(ucon-ucon_lp)/u_ch:>12.0f} {(ucon-ucon_lpc)/u_ch:>12.0f} {p1_lp_final:>10.1f}")
    print(f"{'4.9% Interest Rate':<25} {(ucon-ucon_ir)/u_ch:>12.0f} {(ucon-ucon_irc)/u_ch:>12.0f} {p1_ir_final:>10.1f}")
    print(f"\nResults written to: {cd_dir}")
    print("Done.")


if __name__ == '__main__':
    main()
