#!/usr/bin/env python3
"""
Robustness: re-estimate the model with a higher monthly discount rate
delta = 0.027 (beta_set = .027), then run all counterfactuals.

Outputs to tables_new/ with 'bhigh' suffix.

Usage:
    python -m matlab.py.dc_robustness_delta027          (from repo root)
    python dc_robustness_delta027.py                    (from matlab/py/)
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
from matlab.py.objopt import objopt
from matlab.py.grid_int_full import grid_int_full
from matlab.py.counterfactuals_new import (
    wnum, cost_calc, counterfactuals_print, find_revenue_neutral_price,
)


def main():
    np.random.seed(1)

    # ---- Paths ----
    moments_folder = os.path.join(_repo_root, 'moments')
    cd_dir = os.path.join(_repo_root, 'paper', 'tables_new', '')
    os.makedirs(cd_dir, exist_ok=True)
    print(f"Output directory: {cd_dir}")

    # ---- Flags ----
    est_pattern  = 1
    results      = 1
    boot         = 0
    given_sim    = 1
    br           = 10      # bootstrap reps
    opt_method   = 'Nelder-Mead'

    int_size    = 1
    refinement  = 1
    one_price   = 0

    marginal_cost = 5
    ppinst        = 51
    visit_price   = 200

    s = 32 * 12            # account length = 384

    n  = 384 * 50 + 1      # 19201
    np.random.seed(1)
    X = np.random.rand(n - 1, 2)

    sigA = 0
    sigB = 0
    nD   = 2

    # What to estimate:  alpha(idx 6), pd(idx 11), pc(idx 16)  [0-based]
    option = [6, 11, 16]
    lb = np.array([40.0,  10.0, 0.01])
    ub = np.array([80.0, 1000.0, 0.99])

    option_moments     = [0, 1, 2]
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

    # ---- HIGH DISCOUNT RATE: delta = 0.027 ---- ACTUALLY .024 -- https://www.econstor.eu/bitstream/10419/194617/1/discrate.pdf ; https://ideas.repec.org/a/kap/expeco/v25y2022i1d10.1007_s10683-021-09716-9.html 
    ver = 'bhigh'
    beta_set = 0.024

    print(f"\n{'='*60}")
    print(f"Robustness: delta = {beta_set}, ver = {ver}")
    print(f"{'='*60}")

    #                 0        1        2       3       4       5       6      7         8     9   10    11  12  13   14   15    16       17       18  19   20
    # given:      r_lend, r_water, r_high, hcost, inc_sh, untie, alpha, beta, Y,       p1,  p2,  pd,   n, curve,fee, vh,  pc,   pm,      Blb,  Tg,  sp
    given = np.array([
        0,    0,    r_high, 0,   y_cv,  0,    54,   beta_set, y_avg, p1, p2,  370,  n, 1,   0,   0,  0.24, bal_0_end, Blb, 12, 0.8
    ], dtype=np.float64)

    data = data_moments[option_moments]

    # ---- Single obj evaluation ----
    print(f"\nRunning obj() evaluation  [ver={ver}]")

    t0 = time.time()
    est_mom, ucon, controls, nA_out, nB_out, A1, B1 = \
        obj(given, nA, sigA, Alb, Aub, nB, sigB, nD, s,
            int_size, refinement, X)
    elapsed = time.time() - t0
    print(f"obj() completed in {elapsed:.2f} seconds")

    print(f"\n Sim:  {np.round(est_mom[option_moments_est], 3)}")
    print(f" Data: {np.round(data[option_moments], 3)}")

    # ================================================================
    # ESTIMATION
    # ================================================================
    if est_pattern == 1:
        from scipy.optimize import minimize

        # Pre-compute grid
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
        res = np.clip(result.x, lb, ub)
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

    # ================================================================
    # RESULTS: Print estimates and run counterfactuals
    # ================================================================
    if results == 1:
        # Reload data in case bootstrap overwrote variables
        d = import_to_matlab_t3(moments_folder, one_price, 1)
        bal_avg = d['bal_avg']
        p1     = d['p1']
        p2     = d['p2']

        rb = np.zeros((br, len(option_moments)))
        if boot == 1:
            for i in range(1, br + 1):
                rb[i-1, :] = np.loadtxt(
                    os.path.join(moments_folder,
                                 f'pattern_estimates_{ver}_{i}.csv'),
                    delimiter=',')
        r = np.loadtxt(os.path.join(moments_folder,
                       f'pattern_estimates_{ver}.csv'), delimiter=',')

        # ---- Print estimates ----
        wnum(cd_dir, f'est_alpha_{ver}.tex', r[0], '%5.1f')
        wnum(cd_dir, f'est_sd_alpha_{ver}.tex', np.std(rb[:, 0]), '%5.2f')
        wnum(cd_dir, f'est_fc_{ver}.tex', r[1], '%5.1f')
        wnum(cd_dir, f'est_sd_fc_{ver}.tex', np.std(rb[:, 1]), '%5.1f')
        wnum(cd_dir, f'est_pc_{ver}.tex', r[2], '%5.3f')
        wnum(cd_dir, f'est_sd_pc_{ver}.tex', np.std(rb[:, 2]), '%5.3f')
        wnum(cd_dir, f'est_pc_per_{ver}.tex', 100 * r[1], '%5.0f')

        print(f"\n Estimates: {r}")
        print(f" Bootstrap SE: {rb.std(axis=0)}")

        if given_sim == 1:
            r = given[option]

        # Set estimates into given
        given[option] = r

        # ==============================================================
        # RUN COUNTERFACTUALS
        # ==============================================================
        np.random.seed(1)
        X = np.random.rand(n - 1, 2)

        # ---- BASELINE ----
        print("\n--- BASELINE ---")
        t0 = time.time()
        est_mom, ucon, sim, _, _, _, _ = \
            obj(given, nA, sigA, Alb, Aub, nB, sigB, nD, s,
                int_size, refinement, X)
        print(f"  obj() completed in {time.time()-t0:.1f}s")

        rev_goal, lend_cost, delinquency_cost, visit_cost, wwr, _, _ = \
            cost_calc(sim, r_lend, visit_price, marginal_cost, p1, p2, s)

        # Utility derivative (for CV)
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

        # ==============================================================
        # 1. NO-LOAN (PREPAID METERING)
        # ==============================================================
        print("\n--- PREPAID METERING (no-loan) ---")
        res_nl = given.copy()
        res_nl[1] = 0.8  # r_water high → effectively no borrowing

        t0 = time.time()
        _, ucon_nl, sim_nl, _, _, _, _ = \
            obj(res_nl, nA, sigA, Alb, Aub, nB, sigB, nD, s,
                int_size, refinement, X)
        print(f"  obj() completed in {time.time()-t0:.1f}s")
        print(f"  Uncompensated CV: {(ucon - ucon_nl)/u_ch:.1f}")

        rev_goal_nl, lend_cost_nl, delinquency_cost_nl, visit_cost_nl, wwr_nl, _, _ = \
            cost_calc(sim_nl, r_lend, visit_price, marginal_cost, p1, p2, s)

        # Revenue-neutral price
        p1_nlcp = find_revenue_neutral_price(
            sim_nl, res_nl, rev_goal, wwr_nl, rev_goal_nl,
            p1, p2, marginal_cost)

        res_nlcp = res_nl.copy()
        res_nlcp[9] = p1_nlcp
        _, ucon_nlcp, sim_nlcp, _, _, _, _ = \
            obj(res_nlcp, nA, sigA, Alb, Aub, nB, sigB, nD, s,
                int_size, refinement, X)
        print(f"  Compensated CV: {(ucon - ucon_nlcp)/u_ch:.1f}")

        rev_goal_nlcp, lend_cost_nlcp, delinquency_cost_nlcp, visit_cost_nlcp, wwr_nlcp, _, _ = \
            cost_calc(sim_nlcp, r_lend, visit_price, marginal_cost, p1_nlcp, p2, s)

        counterfactuals_print(cd_dir, f'nl_{ver}', 0,
                              ucon, u_ch, ucon_nl, ucon_nlcp, sim_nl, sim_nlcp,
                              rev_goal, rev_goal_nlcp,
                              lend_cost_nlcp, delinquency_cost_nlcp, visit_cost_nlcp, wwr_nlcp,
                              s, res_nlcp, marginal_cost)

        # ==============================================================
        # 2. HALF-RATE ENFORCEMENT (50% less enforcement)
        # ==============================================================
        print("\n--- 50% LESS ENFORCEMENT ---")
        res_hf = given.copy()
        res_hf[16] = given[16] / 2  # half prob_caught

        t0 = time.time()
        _, ucon_hf, sim_hf, _, _, _, _ = \
            obj(res_hf, nA, sigA, Alb, Aub, nB, sigB, nD, s,
                int_size, refinement, X)
        print(f"  obj() completed in {time.time()-t0:.1f}s")
        print(f"  Uncompensated CV: {(ucon - ucon_hf)/u_ch:.1f}")

        rev_goal_hf, lend_cost_hf, delinquency_cost_hf, visit_cost_hf, wwr_hf, _, _ = \
            cost_calc(sim_hf, r_lend, visit_price, marginal_cost, p1, p2, s)

        # Revenue-neutral price with grid search
        p1_hft = find_revenue_neutral_price(
            sim_hf, res_hf, rev_goal, wwr_hf, rev_goal_hf,
            p1, p2, marginal_cost)

        Ogride = np.arange(-1, 0.25, 0.25)
        R_ov = np.zeros(len(Ogride))
        P_ov = np.zeros(len(Ogride))
        for i, offset in enumerate(Ogride):
            p1r = p1_hft + offset
            res_hfr = res_hf.copy()
            res_hfr[9] = p1r
            _, _, sim_hfr, _, _, _, _ = \
                obj(res_hfr, nA, sigA, Alb, Aub, nB, sigB, nD, s,
                    int_size, refinement, X)
            rev_goal_hfr, _, _, _, _, _, _ = \
                cost_calc(sim_hfr, r_lend, visit_price, marginal_cost, p1r, p2, s)
            R_ov[i] = rev_goal - rev_goal_hfr
            P_ov[i] = p1r

        best_idx = np.argmin(np.abs(R_ov))
        p1_hf = P_ov[best_idx]

        res_hfcp = res_hf.copy()
        res_hfcp[9] = p1_hf
        _, ucon_hfcp, sim_hfcp, _, _, _, _ = \
            obj(res_hfcp, nA, sigA, Alb, Aub, nB, sigB, nD, s,
                int_size, refinement, X)
        print(f"  Compensated CV: {(ucon - ucon_hfcp)/u_ch:.1f}")

        rev_goal_hfcp, lend_cost_hfcp, delinquency_cost_hfcp, visit_cost_hfcp, wwr_hfcp, _, _ = \
            cost_calc(sim_hfcp, r_lend, visit_price, marginal_cost, p1_hf, p2, s)

        counterfactuals_print(cd_dir, f'hf_{ver}', given[16] / 2,
                              ucon, u_ch, ucon_hf, ucon_hfcp, sim_hf, sim_hfcp,
                              rev_goal, rev_goal_hfcp,
                              lend_cost_hfcp, delinquency_cost_hfcp, visit_cost_hfcp, wwr_hfcp,
                              s, res_hfcp, marginal_cost)

        # ==============================================================
        # 3. LATE PENALTY
        # ==============================================================
        late_penalty = 0.1 * bal_avg  # ~123.5 PhP
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
        # 4. 4.9% INTEREST RATE ON UNPAID BILLS
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

        # ==============================================================
        # SUMMARY
        # ==============================================================
        print(f"\n{'='*60}")
        print(f"SUMMARY  (delta = {beta_set}, ver = {ver})")
        print(f"{'='*60}")
        print(f"{'Scenario':<25} {'Uncomp CV':>12} {'Comp CV':>12} {'Price p1':>10}")
        print(f"{'-'*60}")
        print(f"{'Baseline':<25} {'---':>12} {'---':>12} {p1:>10.1f}")
        print(f"{'Prepaid Metering':<25} {(ucon-ucon_nl)/u_ch:>12.0f} {(ucon-ucon_nlcp)/u_ch:>12.0f} {p1_nlcp:>10.1f}")
        print(f"{'50% Less Enforcement':<25} {(ucon-ucon_hf)/u_ch:>12.0f} {(ucon-ucon_hfcp)/u_ch:>12.0f} {p1_hf:>10.1f}")
        print(f"{'Late Penalty':<25} {(ucon-ucon_lp)/u_ch:>12.0f} {(ucon-ucon_lpcp)/u_ch:>12.0f} {p1_lp_final:>10.1f}")
        print(f"{'4.9% Interest Rate':<25} {(ucon-ucon_ir)/u_ch:>12.0f} {(ucon-ucon_ircp)/u_ch:>12.0f} {p1_ir_final:>10.1f}")
        print(f"\nResults written to: {cd_dir}")
        print("Done.")


if __name__ == '__main__':
    main()
