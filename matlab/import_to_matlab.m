function [c_avg,c_std,bal_avg,bal_std,bal_corr,am1,am2,am3,am4,amar1,amar2,amar3,amar4,p1,p2] = import_to_matlab(folder,one_price)

 %%% import key stats
    c_avg     = csvread(strcat(folder,'c_avg.csv'));
    c_std     = csvread(strcat(folder,'c_std.csv'));
    bal_avg   = csvread(strcat(folder,'bal_avg.csv'));
    bal_std   = csvread(strcat(folder,'bal_std.csv'));
    bal_corr  = csvread(strcat(folder,'bal_corr.csv'));
    
    am1       = csvread(strcat(folder,'am1.csv')); %%% start with 1 not zero!!!!
    am2       = csvread(strcat(folder,'am2.csv'));
    am3       = csvread(strcat(folder,'am3.csv'));
    am4       = csvread(strcat(folder,'am4.csv'));

    amar1       = csvread(strcat(folder,'amar1.csv'));
    amar2       = csvread(strcat(folder,'amar2.csv'));
    amar3       = csvread(strcat(folder,'amar3.csv'));
    amar4       = csvread(strcat(folder,'amar4.csv'));

    if one_price==1
        p1        = csvread(strcat(folder,'p_avg.csv'));
        p2        = 0;
    else
        p1        = csvread(strcat(folder,'p_int.csv'));
        p2        = csvread(strcat(folder,'p_slope.csv'));
    end
%     prob_caught = csvread(strcat(folder,'prob_caught.csv'));
    % prob_caught = .05  %%% HAVE HIGH PROB OF GETTING CAUGHT


    prob_caught = csvread(strcat(folder,'prob_caught.csv'));
    
    y_avg       = csvread(strcat(folder,'y_avg.csv'));
    delinquency_cost = csvread(strcat(folder,'delinquency_cost.csv'));
    r_lend      = csvread(strcat(folder,'irate.csv'));
    r_lend      = ((1+r_lend)^(1/12)) - 1;
    dc_prob     = csvread(strcat(folder,'dc_per_month_account.csv'));