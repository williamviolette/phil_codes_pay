function [am_d4_sim,dc_time_sim,...
            inc_corr_sim,pay_corr_sim,...
            nbal_shr_sim] ...
             = fit_print(controls,p1,p2,y_avg,y_cv,s)
    

    cr = size(controls(:,5),1)/s;
    
    
    C_m         =     reshape(controls(:,1),[s,cr]);
    w_debt_m    = -1.*reshape(controls(:,3),[s,cr]);
    dd_m        =     reshape(controls(:,4),[s,cr]);
    state_m     =     reshape(controls(:,5),[s,cr]);
    ind_m       =     reshape(controls(:,6),[s,cr]);
    dd1= ( [zeros(1,cr); dd_m(1:end-1,:)] );
    wd4= ( [zeros(1,cr); w_debt_m(1:end-1,:)]>0 & ...
           [zeros(2,cr); w_debt_m(1:end-2,:)]>0 & ...
           [zeros(3,cr); w_debt_m(1:end-3,:)]>0 & ...
           [zeros(4,cr); w_debt_m(1:end-4,:)]>0  ) ;

    disp ' % disconnect if over 4 months delinquent when visited'
    am_d4_sim = mean(dd_m(state_m>=3 & wd4==1 & dd1==0 & ind_m<=s-12));
    
    disp ' DC time to reconnect '
    pre = [zeros(1,1); controls(1:end-1,4)];
    dc_time_sim=sum(controls(:,4)==1)/sum(pre==0 & controls(:,4)==1);

    disp ' Correlation between Payments and Income '
    inc = (controls(:,5)==1 | controls(:,5)==3).*(y_avg+y_cv*y_avg) + (controls(:,5)==2 | controls(:,5)==4).*(y_avg-y_cv*y_avg) ;
    c_pay = controls(:,1).*(p1+p2.*controls(:,1));
    bal_pre =[0;controls(1:end-1,3)];
    
    pay = controls(:,3)-bal_pre+c_pay;
    
    inc_corr_sim = corr(pay,inc);
    pay_corr_sim = corr(c_pay,inc);
    
    disp ' % of negative balances that are consecutive'
    nbal_shr_sim=sum( (controls(:,3)<0 & bal_pre<0))/sum(controls(:,3)<0 );
    


    
%     disp ' regression estimates of fit '
%     pay_pre = [0;pay(1:end-1,1)];
%     pay_ch = pay-pay_pre;
%     bal_ch = controls(:,3)-bal_pre;
%         
%     [r]=fitlm(inc_ch,pay_ch)
%     [r]=fitlm(inc_ch,c_ch)
% 
%     est_mom
%     data_moments
end

