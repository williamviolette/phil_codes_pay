function [out] =counterfactuals_fixedcost(cd_dir,r,ver,given,option,ppinst,...
    r_lend,visit_price,marginal_cost,p1,p2,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X)


given(option) = r;

[~,ucon,sim]=obj(given,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);

disp ' PRE UTILITY DERIVATIVE '
[rev_goal,lend_cost,delinquency_cost,visit_cost,wwr]=cost_calc(sim,r_lend,visit_price,marginal_cost,p1,p2,s);

res_poor = given ;
res_poor(:,9) = given(:,9) - 100;
[~,u_poor,sim_poor] = obj(res_poor,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);

u_ch = (ucon-u_poor)/100;




disp ' UN-TIED '
    resu = given;
    resu(:,6)=1;
    [~,ucon_u,sim_u] = obj(resu,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'utility from untied'
    (ucon_u-ucon)/u_ch
   
    [rev_goal_u,lend_cost_u,delinquency_cost_u,visit_cost_u,wwr_u] = cost_calc(sim_u,r_lend,visit_price,marginal_cost,p1,p2,s);
    disp 'Pre-Post: Rev'
    rev_goal-rev_goal_u
    
    resu_c = resu;
    resu_c(:,15)=rev_goal - rev_goal_u ;
    [~,ucon_uc,sim_uc] =obj(resu_c,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'compensated utility from untied'
    (ucon_uc-ucon)/u_ch
    


disp ' NO-LOAN '

    res_nl = given;
    res_nl(:,2) = .8;
    [~,ucon_nl,sim_nl] =obj(res_nl,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'utility from no loan'
    (ucon_nl-ucon)/u_ch

    [rev_goal_nl,lend_cost_nl,delinquency_cost_nl,visit_cost_nl,wwr_nl] = cost_calc(sim_nl,r_lend,visit_price,marginal_cost,p1,p2,s);
    disp 'Pre-Post: Rev'
    rev_goal-rev_goal_nl
  
    res_nlc = res_nl;
    res_nlc(:,15) = rev_goal - rev_goal_nl;
    [~,ucon_nlc,sim_nlc] =obj(res_nlc,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'compensated utility from no loan'
    (ucon_nlc-ucon)/u_ch
    

    res_nlcp = res_nl;
    res_nlcp(:,15) = rev_goal - (rev_goal_nl-ppinst);
    [~,ucon_nlpp,sim_nlpp] =obj(res_nlcp,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'compensated utility from no loan'
    (ucon_nlpp-ucon)/u_ch
  

Ogride = (.01:.01:.05)' ;
Uov = zeros(size(Ogride,1),1);
Rov = zeros(size(Ogride,1),1);

for i=1:size(Ogride,1)
       
    disp ' Optimal Visit Rate'

    res_ov = given;
    res_ov(:,17) = Ogride(i);
    [~,u_ov,sim_ov] =obj(res_ov,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'utility from ovisit rate'
    (u_ov-ucon)/u_ch

    [rev_goal_ov,~,~,~,wwr_ov] = cost_calc(sim_ov,r_lend,visit_price,marginal_cost,p1,p2,s);

    disp ' how much cash to raise?'
    rev_goal-rev_goal_ov
    
%     inflator 
    res_ovc=res_ov;
    res_ovc(:,15) = rev_goal-rev_goal_ov;
    [~,u_ovc,sim_ovc] =obj(res_ovc,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    
    disp 'compensated utility from ovisit rate'
    (u_ovc-ucon)/u_ch
    
    Uov(i,1) = (u_ovc-ucon)/u_ch;
    Rov(i,1) = rev_goal-rev_goal_ov;

end


[~,maxO]=max(Uov);
Oopt = Ogride(maxO);


    disp ' Optimal Visit Rate'

    res_ov = given;
    res_ov(:,17) = Oopt;
    [~,ucon_ov,sim_ov] =obj(res_ov,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'utility from ovisit rate'
    (ucon_ov-ucon)/u_ch

    [rev_goal_ov,lend_cost_ov,delinquency_cost_ov,visit_cost_ov,wwr_ov] = cost_calc(sim_ov,r_lend,visit_price,marginal_cost,p1,p2,s);

    disp ' how much cash to raise?'
    rev_goal-rev_goal_ov
    
%     inflator 
    res_ovc=res_ov;
    res_ovc(:,15) = rev_goal-rev_goal_ov;
    [~,ucon_ovc,sim_ovc] =obj(res_ovc,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    
    disp 'compensated utility from ovisit rate'
    (ucon_ovc-ucon)/u_ch
    
    
h=counterfactuals_print(cd_dir,strcat('reg_',ver),res_poor(17),ucon,u_ch,ucon,ucon,sim,sim,rev_goal,rev_goal,lend_cost,delinquency_cost,visit_cost,wwr,s,given);
h=counterfactuals_print(cd_dir,strcat('ut_',ver),0,ucon,u_ch,ucon_u,ucon_uc,sim_u,sim_uc,rev_goal,rev_goal_u,lend_cost_u,delinquency_cost_u,visit_cost_u,wwr_u,s,given);
h=counterfactuals_print(cd_dir,strcat('nl_',ver),0,ucon,u_ch,ucon_nl,ucon_nlc,sim_nl,sim_nlc,rev_goal,rev_goal_nl,lend_cost_nl,delinquency_cost_nl,visit_cost_nl,wwr_nl,s,given);
h=counterfactuals_print(cd_dir,strcat('nlpp_',ver),0,ucon,u_ch,ucon_nl,ucon_nlpp,sim_nl,sim_nlpp,rev_goal,(rev_goal_nl-ppinst),lend_cost_nl,delinquency_cost_nl,visit_cost_nl,wwr_nl,s,given);
h=counterfactuals_print(cd_dir,strcat('opt_',ver),Oopt,ucon,u_ch,ucon_ov,ucon_ovc,sim_ov,sim_ovc,rev_goal,rev_goal_ov,lend_cost_ov,delinquency_cost_ov,visit_cost_ov,wwr_ov,s,given);


out=0;


%     syms p1s p2s as R
%      assume(p1s>0)
%      assume(p2s>0)
%      assume(as>0)
%      assume(R>0)
%      wse = (as-p1s)./(p2s.*2.0+1.0)
%  rr = wse*(p1s+p2s*wse)
%     
%  simplify(diff(rr,p1s))
 
 
 
%%% NEED TO FIND THE ACTUAL OPTIMUM!! 
    
    
