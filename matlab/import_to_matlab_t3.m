function [c_avg,c_std,bal_avg,bal_med,bal_std,bal_corr,...
    dc_shr,...
    bal_0,bal_end,bal_0_end,...
    am_d, am_d4,...
    am1,am2,am3,am4,...
    amar1,amar2,amar3,amar4,...
    y_avg,y_cv,Aub,Alb,Blb,...
    p1,p2,prob_caught,...
    delinquency_cost,r_lend,dc_prob,r_high] ...
        = import_to_matlab_t3(folder,one_price,just_one)

 
if just_one==1
     %%% import key stats
    c_avg     = csvread(strcat(folder,'c_avg.csv'))  ;
    c_std     = csvread(strcat(folder,'c_std.csv')) ;
    bal_avg   = csvread(strcat(folder,'bal_avg.csv'));
    bal_med   = csvread(strcat(folder,'bal_med.csv'));
    bal_std   = csvread(strcat(folder,'bal_std.csv'));
    bal_corr  = csvread(strcat(folder,'bal_corr.csv'));
    
    bal_0   = csvread(strcat(folder,'bal_0.csv'));
    bal_end = csvread(strcat(folder,'bal_end.csv'));
    bal_0_end = csvread(strcat(folder,'bal_0_end.csv'));
    
    am_d       = csvread(strcat(folder,'tcd_share_rec.csv')); 
    am_d4      = csvread(strcat(folder,'tcd_share_rec_3.csv'));
   
    dc_shr = csvread(strcat(folder,'dc_shr.csv'));

    y_avg     = csvread(strcat(folder,'y_avg.csv')) ;
    y_cv      = csvread(strcat(folder,'y_cv.csv'));
        
    Aub = csvread(strcat(folder,'Ab.csv')); 

    Alb = -1.*Aub;
    Blb = -1.*csvread(strcat(folder,'Bb.csv'));
    
    prob_caught = csvread(strcat(folder,'prob_caught.csv'));
    delinquency_cost = csvread(strcat(folder,'delinquency_cost.csv'));
    
    r_high = csvread(strcat(folder,'irate.csv'));
    r_lend = csvread(strcat(folder,'save_rate.csv'));
%     r_lend      = csvread(strcat(folder,'irate.csv'));
%     r_lend      = ((1+r_lend)^(1/12)) - 1;
    dc_prob     = csvread(strcat(folder,'dc_per_month_account.csv'));
    
    if one_price==1
        p1        = csvread(strcat(folder,'p_avg.csv'));
        p2        = 0;
    else
        p1        = csvread(strcat(folder,'p_int.csv'));
        p2        = csvread(strcat(folder,'p_slope.csv'));
    end
      
        am1       = 1;
    am2       = 1;
    am3       = 1;
    am4       = 1;

    amar1     = 1;
    amar2     = 1;
    amar3     = 1;
    amar4     = 1;
    
else
      %%% import key stats
    c_avg     = [csvread(strcat(folder,'c_avg_t1.csv')) csvread(strcat(folder,'c_avg_t2.csv')) csvread(strcat(folder,'c_avg_t3.csv'))]  ;
    c_std     = [csvread(strcat(folder,'c_std_t1.csv')) csvread(strcat(folder,'c_std_t2.csv')) csvread(strcat(folder,'c_std_t3.csv'))]  ;
    bal_avg   = [csvread(strcat(folder,'bal_avg_t1.csv')) csvread(strcat(folder,'bal_avg_t2.csv')) csvread(strcat(folder,'bal_avg_t3.csv'))];
    bal_med   = [csvread(strcat(folder,'bal_med_t1.csv')) csvread(strcat(folder,'bal_med_t2.csv')) csvread(strcat(folder,'bal_med_t3.csv'))];
    bal_std   = [csvread(strcat(folder,'bal_std_t1.csv')) csvread(strcat(folder,'bal_std_t2.csv')) csvread(strcat(folder,'bal_std_t3.csv'))];
    bal_corr  = [csvread(strcat(folder,'bal_corr_t1.csv')) csvread(strcat(folder,'bal_corr_t2.csv')) csvread(strcat(folder,'bal_corr_t3.csv'))];
    

%     am_d       = [csvread(strcat(folder,'am_d_t1.csv')) csvread(strcat(folder,'am_d_t2.csv')) csvread(strcat(folder,'am_d_t3.csv'))]; 
%     am_d4       = [csvread(strcat(folder,'am_d4_t1.csv')) csvread(strcat(folder,'am_d4_t2.csv')) csvread(strcat(folder,'am_d4_t3.csv'))]; 

    am_d       = csvread(strcat(folder,'tcd_share_rec.csv')).*[ 1 1 1 ]; 
    am_d4      = csvread(strcat(folder,'tcd_share_rec_3.csv')).*[ 1 1 1 ];
    
    am1       = [csvread(strcat(folder,'am1_t1.csv')) csvread(strcat(folder,'am1_t2.csv')) csvread(strcat(folder,'am1_t3.csv'))]; %%% start with 1 not zero!!!!
    am2       = [csvread(strcat(folder,'am2_t1.csv')) csvread(strcat(folder,'am2_t2.csv')) csvread(strcat(folder,'am2_t3.csv'))];
    am3       = [csvread(strcat(folder,'am3_t1.csv')) csvread(strcat(folder,'am3_t2.csv')) csvread(strcat(folder,'am3_t3.csv'))];
    am4       = [csvread(strcat(folder,'am4_t1.csv')) csvread(strcat(folder,'am4_t2.csv')) csvread(strcat(folder,'am4_t3.csv'))];

    amar1     = [csvread(strcat(folder,'amar1_t1.csv')) csvread(strcat(folder,'amar1_t2.csv')) csvread(strcat(folder,'amar1_t3.csv'))];
    amar2     = [csvread(strcat(folder,'amar2_t1.csv')) csvread(strcat(folder,'amar2_t2.csv')) csvread(strcat(folder,'amar2_t3.csv'))];
    amar3     = [csvread(strcat(folder,'amar3_t1.csv')) csvread(strcat(folder,'amar3_t2.csv')) csvread(strcat(folder,'amar3_t3.csv'))];
    amar4     = [csvread(strcat(folder,'amar4_t1.csv')) csvread(strcat(folder,'amar4_t2.csv')) csvread(strcat(folder,'amar4_t3.csv'))];



    y_avg     = [csvread(strcat(folder,'y_avg_t1.csv'))  csvread(strcat(folder,'y_avg_t2.csv'))  csvread(strcat(folder,'y_avg_t3.csv'))];
%   y_cv      = [csvread(strcat(folder,'cv_adj_t1.csv')) csvread(strcat(folder,'cv_adj_t2.csv')) csvread(strcat(folder,'cv_adj_t3.csv'))];

    y_cv      = csvread(strcat(folder,'cv_single.csv'));

        
    Aub = [csvread(strcat(folder,'Ab_t1.csv'))  csvread(strcat(folder,'Ab_t2.csv'))  csvread(strcat(folder,'Ab_t3.csv'))]; 
    Aub = [Aub mean(Aub)];
    
    Alb = -1.*Aub;
    Blb = -1.*[csvread(strcat(folder,'Bb_t1.csv')) csvread(strcat(folder,'Bb_t2.csv')) csvread(strcat(folder,'Bb_t3.csv'))];
    Blb = [Blb mean(Blb)];
    
    prob_caught = csvread(strcat(folder,'prob_caught.csv'));


    delinquency_cost = csvread(strcat(folder,'delinquency_cost.csv'));
    
    r_high = csvread(strcat(folder,'irate.csv'));
    r_lend = csvread(strcat(folder,'save_rate.csv'));
%     r_lend      = csvread(strcat(folder,'irate.csv'));
%     r_lend      = ((1+r_lend)^(1/12)) - 1;
    dc_prob     = csvread(strcat(folder,'dc_per_month_account.csv'));
    
    if one_price==1
        p1        = csvread(strcat(folder,'p_avg.csv'));
        p2        = 0;
    else
        p1        = csvread(strcat(folder,'p_int.csv'));
        p2        = csvread(strcat(folder,'p_slope.csv'));
    end
    
    
    
end

    