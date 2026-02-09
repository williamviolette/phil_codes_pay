"""
Translate of import_to_matlab_t3.m — load moment data from CSV files.
"""
import os
import numpy as np


def import_to_matlab_t3(folder, one_price, just_one):
    """
    Read moment CSV files from `folder`.

    Parameters
    ----------
    folder    : str, path to the moments directory
    one_price : int (0 or 1)
    just_one  : int (1 = single cross-section, else 3-period panel)

    Returns
    -------
    dict with all moment data (keys match MATLAB variable names)
    """
    def rd(name):
        return np.loadtxt(os.path.join(folder, name), delimiter=',', ndmin=0).item()

    def rd_arr(name):
        return np.loadtxt(os.path.join(folder, name), delimiter=',', ndmin=1)

    if just_one == 1:
        c_avg    = rd('c_avg.csv')
        c_std    = rd('c_std.csv')
        bal_avg  = rd('bal_avg.csv')
        bal_med  = rd('bal_med.csv')
        bal_std  = rd('bal_std.csv')
        bal_corr = rd('bal_corr.csv')

        bal_0     = rd('bal_0.csv')
        bal_end   = rd('bal_end.csv')
        bal_0_end = rd('bal_0_end.csv')

        am_d  = rd('tcd_share_rec.csv')
        am_d4 = rd('tcd_share_rec_3.csv')

        dc_shr = rd('dc_shr.csv')

        y_avg = rd('y_avg.csv')
        y_cv  = rd('y_cv.csv')

        Aub = rd('Ab.csv')
        Alb = -1.0 * Aub
        Blb = -1.0 * rd('Bb.csv')

        prob_caught = rd('prob_caught.csv')
        delinquency_cost = rd('delinquency_cost.csv')

        r_lend  = rd('save_rate.csv')
        dc_prob = rd('dc_per_month_account.csv')

        if one_price == 1:
            p1 = rd('p_avg.csv')
            p2 = 0.0
        else:
            p1 = rd('p_int.csv')
            p2 = rd('p_slope.csv')

        am1 = am2 = am3 = am4 = 1.0
        amar1 = amar2 = amar3 = amar4 = 1.0

    else:
        raise NotImplementedError("just_one != 1 (panel mode) not yet implemented")

    return dict(
        c_avg=c_avg, c_std=c_std,
        bal_avg=bal_avg, bal_med=bal_med, bal_std=bal_std, bal_corr=bal_corr,
        dc_shr=dc_shr,
        bal_0=bal_0, bal_end=bal_end, bal_0_end=bal_0_end,
        am_d=am_d, am_d4=am_d4,
        am1=am1, am2=am2, am3=am3, am4=am4,
        amar1=amar1, amar2=amar2, amar3=amar3, amar4=amar4,
        y_avg=y_avg, y_cv=y_cv, Aub=Aub, Alb=Alb, Blb=Blb,
        p1=p1, p2=p2, prob_caught=prob_caught,
        delinquency_cost=delinquency_cost, r_lend=r_lend, dc_prob=dc_prob,
    )
