function h = fit_print(cd_dir,r,ver,given,option,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X)


    given(option) = r;
    [outmom,~,controls]=obj(given,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);


    disp ' DC time to reconnect '
    pre = [zeros(1,1); controls(1:end-1,4)];
    pre1 = pre(controls(:,6)<=s-12 & controls(:,6)>2,:);
    dc_time_sim=sum(controls(controls(:,6)<=s-12 & controls(:,6)>2,4)==1)/sum(pre1==0 & controls(controls(:,6)<=s-12 & controls(:,6)>2,4)==1);

    wnum(cd_dir,strcat('fit_months_to_rec_',ver,'.tex'),dc_time_sim,'%5.1f')
   
    disp ' Correlation between Payments and Income '
    inc = (controls(:,5)==1 | controls(:,5)==3).*(y_avg+y_cv*y_avg) + (controls(:,5)==2 | controls(:,5)==4).*(y_avg-y_cv*y_avg) ;
    c_pay = controls(:,1).*(p1+p2.*controls(:,1));
    bal_pre =[0;controls(1:end-1,3)];
    
    pay = controls(:,3)-bal_pre+c_pay;
    
v = controls(controls(:,6)<=s-12 ,4);
n      = length(v);
len    = zeros(1,n);         % length of each 1-string
k1     = 0;                  % count of 1-strings
inOnes = false;
s1      = 0;
for k = 1:n
  if v(k)                    % not in 1-string
    s1       = s1 + 1;         % increase the counter
    inOnes  = true;
  elseif inOnes              % leave the ones block
    k1      = k1 + 1;
    len(k1) = s1;
    s1       = 0;             % reset the counter
    inOnes  = false;
 end
end
len = len(1:k1);

    
     wnum(cd_dir,strcat('table_c_mean_',ver,'.tex'),mean(controls(:,1)),'%5.0f')
     wnum(cd_dir,strcat('table_c_sd_',ver,'.tex'),std(controls(:,1)),'%5.0f')
     
     wnum(cd_dir,strcat('table_bill_mean_',ver,'.tex'),mean(c_pay),'%5.0f')
     wnum(cd_dir,strcat('table_bill_sd_',ver,'.tex'),std(c_pay),'%5.0f')
     
     wnum(cd_dir,strcat('table_bal_mean_',ver,'.tex'),mean(abs(controls(:,3))),'%5.0f')
     wnum(cd_dir,strcat('table_bal_sd_',ver,'.tex'),std(abs(controls(:,3))),'%5.0f')
     
     wnum(cd_dir,strcat('table_pays_mean_',ver,'.tex'),mean(pay(pay>1)),'%5.0f')
     wnum(cd_dir,strcat('table_pays_sd_',ver,'.tex'),std(pay(pay>1)),'%5.0f')
     
     wnum(cd_dir,strcat('table_p0_mean_',ver,'.tex'),mean(pay>10),'%5.3f')
     wnum(cd_dir,strcat('table_p0_sd_',ver,'.tex'),std(pay>10),'%5.3f')
     
     wnum(cd_dir,strcat('table_shr_dc_mean_',ver,'.tex'),mean(controls(:,4)==1),'%5.3f')
     wnum(cd_dir,strcat('table_shr_dc_sd_',ver,'.tex'),std(controls(:,4)==1),'%5.3f')
     
     wnum(cd_dir,strcat('table_t_rec_mean_',ver,'.tex'),mean(len),'%5.1f')
     wnum(cd_dir,strcat('table_t_rec_sd_',ver,'.tex'),std(len),'%5.1f')
     
     wnum(cd_dir,strcat('table_bal_end_mean_',ver,'.tex'),mean(abs(controls(controls(:,6)==s,3))),'%5.0f')
     wnum(cd_dir,strcat('table_bal_end_sd_',ver,'.tex'),std(abs(controls(controls(:,6)==s,3))),'%5.0f')
    
     
     
    pay_corr_sim = corr(pay(controls(:,6)>1 & controls(:,6)<s),inc(controls(:,6)>1 & controls(:,6)<s))
    use_corr_sim = corr(c_pay(controls(:,6)>1 & controls(:,6)<s),inc(controls(:,6)>1 & controls(:,6)<s))
    
    wnum(cd_dir,strcat('fit_pay_corr_',ver,'.tex'),pay_corr_sim,'%5.2f')
    wnum(cd_dir,strcat('fit_use_corr_',ver,'.tex'),use_corr_sim,'%5.2f')

    
h=1;