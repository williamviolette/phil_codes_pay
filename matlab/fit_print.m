function h = fit_print(cd_dir,r,ver,given,option,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X)


    given(option) = r;
    [outmom,~,controls]=obj(given,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);


    wnum(cd_dir,strcat('fit_usage_',ver,'.tex'),outmom(1),'%5.1f')
    wnum(cd_dir,strcat('fit_bal_',ver,'.tex'),outmom(2),'%5.0f')
    wnum(cd_dir,strcat('fit_dc_',ver,'.tex'),outmom(3),'%5.4f')
    
    disp ' DC time to reconnect '
    pre = [zeros(1,1); controls(1:end-1,4)];
    dc_time_sim=sum(controls(:,4)==1)/sum(pre==0 & controls(:,4)==1);

    wnum(cd_dir,strcat('fit_months_to_rec_',ver,'.tex'),dc_time_sim,'%5.1f')
    
    
    disp ' Correlation between Payments and Income '
    inc = (controls(:,5)==1 | controls(:,5)==3).*(y_avg+y_cv*y_avg) + (controls(:,5)==2 | controls(:,5)==4).*(y_avg-y_cv*y_avg) ;
    c_pay = controls(:,1).*(p1+p2.*controls(:,1));
    bal_pre =[0;controls(1:end-1,3)];
    
    pay = controls(:,3)-bal_pre+c_pay;
    
    pay_corr_sim = corr(pay(controls(:,6)>1 & controls(:,6)<s),inc(controls(:,6)>1 & controls(:,6)<s));
    use_corr_sim = corr(c_pay(controls(:,6)>1 & controls(:,6)<s),inc(controls(:,6)>1 & controls(:,6)<s));
    
    wnum(cd_dir,strcat('fit_pay_corr_',ver,'.tex'),pay_corr_sim,'%5.2f')
    wnum(cd_dir,strcat('fit_use_corr_',ver,'.tex'),use_corr_sim,'%5.2f')

    
h=1;