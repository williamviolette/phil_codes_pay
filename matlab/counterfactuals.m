function [out,out_ut] =counterfactuals(r,given,option,...
    r_lend,visit_price,marginal_cost,p1,p2,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement)


given(option) = r;

[~,ucon,sim]=obj(given,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);


disp ' PRE UTILITY DERIVATIVE '
[rev_goal,lend_cost,delinquency_cost,visit_cost,wwr]=cost_calc(sim,r_lend,visit_price,marginal_cost,p1,p2,s);

res_poor = given ;
res_poor(:,9) = given(:,9) - 100;
[~,u_poor,sim_poor] = obj(res_poor,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);

u_ch = (ucon-u_poor)/100;
   % DU  DUcomp                                                 new price
out = [ 0  0    rev_goal lend_cost delinquency_cost visit_cost wwr 0];

disp ' UN-TIED '
    resu = given;
    resu(:,6)=1;
    [~,uu_ut,simu] = obj(resu,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'utility from untied'
    (uu_ut-ucon)/u_ch
   
    [rev_goal_u,lend_cost_u,delinquency_cost_u,visit_cost_u,wwr_u] = cost_calc(simu,r_lend,visit_price,marginal_cost,p1,p2,s);
    disp 'Pre-Post: Rev'
    rev_goal-rev_goal_u
    
    resu_c = resu;
    resu_c(:,15)=rev_goal - rev_goal_u ;
    [~,uu_c,simu_c] =obj(resu_c,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'compensated utility from untied'
    (uu_c-ucon)/u_ch

    
    disp ' how much cash to raise?'
    rev_goal-rev_goal_u
    
    R =  rev_goal + (wwr_u-rev_goal_u);
    I = mean(simu(:,1)) - (given(7)-p1)./(p2.*2+1);  %%% how much extra water do you use?
    as = given(:,7);
    mc = marginal_cost;
    p2s = p2;
    p1_ov =  (I + as + mc + 2*I*p2s - 2*p2s*(4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2) + 2*mc*p2s - (4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2))/(2*(p2s + 1));
      
    
out_ut = [ (uu_ut-ucon)/u_ch  (uu_c-ucon)/u_ch  rev_goal_u lend_cost_u delinquency_cost_u visit_cost_u wwr_u (rev_goal - rev_goal_u) ];




disp ' NO-LOAN '

    res_nl = given;
    res_nl(:,2) = .8;
    [~,u_nl,sim_nl] =obj(res_nl,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'utility from no loan'
    (u_nl-ucon)/u_ch

    [rev_goal_nl,~,~,~,wwr_nl] = cost_calc(sim_nl,r_lend,visit_price,marginal_cost,p1,p2,s);
    disp 'Pre-Post: Rev'
    rev_goal-rev_goal_nl
  
    R = rev_goal;
    as =given(:,7);
    mc = marginal_cost;
    p2s = p2;
    p1s = p1;
    p1_new = (as + mc - 2*p2s*(as^2 - 2*as*mc + mc^2 - 4*R - 4*R*p2s)^(1/2) + 2*mc*p2s - (as^2 - 2*as*mc + mc^2 - 4*R - 4*R*p2s)^(1/2))/(2*(p2s + 1))

    res_nlc = res_nl;
    res_nl(:,10) = p1_new;
    [~,u_nlc,sim_nlc] =obj(res_nl,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'compensated utility from no loan'
    (u_nlc-ucon)/u_ch
    
    
    R = rev_goal+53;
    as =given(:,7);
    mc = marginal_cost;
    p2s = p2;
    p1s = p1;
    p1_new_pp = (as + mc - 2*p2s*(as^2 - 2*as*mc + mc^2 - 4*R - 4*R*p2s)^(1/2) + 2*mc*p2s - (as^2 - 2*as*mc + mc^2 - 4*R - 4*R*p2s)^(1/2))/(2*(p2s + 1))

    res_nlc = res_nl;
    res_nl(:,10) = p1_new_pp;
    [~,u_nlc_pp,sim_nlc_pp] =obj(res_nl,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'compensated utility from no loan PREPAID'
    (u_nlc_pp-ucon)/u_ch
    
    
    
out_nl = [ (uu_ut-ucon)/u_ch  (u_nlc-ucon)/u_ch rev_goal_u lend_cost_u delinquency_cost_u visit_cost_u wwr_u];

    
    
disp ' Optimal Visit Rate'

    res_ov = given;
    res_ov(:,17) = .1;
    [~,u_ov,sim_ov] =obj(res_ov,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'utility from ovisit rate'
    (u_ov-ucon)/u_ch

    [rev_goal_ov,~,~,~,wwr_ov] = cost_calc(sim_ov,r_lend,visit_price,marginal_cost,p1,p2,s);

    disp ' how much cash to raise?'
    rev_goal-rev_goal_ov
    
    inflator = mean(sim_ov(:,1)) - (given(7)-p1)./(p2.*2+1) ; %%% how much extra water do you use?
    
    R =  rev_goal + (wwr_ov-rev_goal_ov);
    I = inflator;
    as = given(:,7);
    mc = marginal_cost;
    p2s = p2;
    p1_ov =  (I + as + mc + 2*I*p2s - 2*p2s*(4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2) + 2*mc*p2s - (4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2))/(2*(p2s + 1));
  
    res_ovc = res_ov;
    res_ovc(:,10) = p1_ov;
    [~,u_ovc,sim_ovc] =obj(res_ovc,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'compensated utility from ovisit rate'
    (u_ovc-ucon)/u_ch
    
    [rev_goal_ovc,~,~,~,wwr_ovc] = cost_calc(sim_ovc,r_lend,visit_price,marginal_cost,p1_ov,p2,s);

    rev_goal-rev_goal_ovc
    
     

Ogride = (.02:.02:.12)' ;
Uov = zeros(size(Ogride,1),1);
Pov = zeros(size(Ogride,1),1);
Rov = zeros(size(Ogride,1),1);

Uova = zeros(size(Ogride,1),1);
Pova = zeros(size(Ogride,1),1);
Rova = zeros(size(Ogride,1),1);

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
    
    R =  rev_goal + (wwr_ov-rev_goal_ov);
    I = mean(sim_ov(:,1)) - (given(7)-p1)./(p2.*2+1) ; %%% how much extra water do you use?
    as = given(:,7);
    mc = marginal_cost;
    p2s = p2;
    p1_ov =  (I + as + mc + 2*I*p2s - 2*p2s*(4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2) + 2*mc*p2s - (4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2))/(2*(p2s + 1));
  
    res_ovc = res_ov;
    res_ovc(:,10) = p1_ov;
    [~,u_ovc,sim_ovc] =obj(res_ovc,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    
    [rev_goal_ovc,~,~,~,wwr_ovc] = cost_calc(sim_ovc,r_lend,visit_price,marginal_cost,p1_ov,p2,s);

    disp 'compensated utility from ovisit rate'
    (u_ovc-ucon)/u_ch
    
    p_ch = (rev_goal-rev_goal_ovc)/ (-(2*p1_ov - given(7) + 2*p1_ov*p2)/(2*p2 + 1)^2);
   
    p1_ova = p1_ov + (p_ch./2);
    
    res_ovca = res_ov;
    res_ovca(:,10) = p1_ova;
    [~,u_ovca,sim_ovca] =obj(res_ovca,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    
    [rev_goal_ovca,~,~,~,wwr_ovca] = cost_calc(sim_ovca,r_lend,visit_price,marginal_cost,p1_ova,p2,s);
    
    disp 'compensated utility from ovisit rate'
    (u_ovca-ucon)/u_ch
    
    Uov(i,1) = (u_ovc-ucon)/u_ch;
    Rov(i,1) = rev_goal-rev_goal_ovc;
    Pov(i,1) = p1_ov;
    
    Uova(i,1) = (u_ovca-ucon)/u_ch;
    Rova(i,1) = rev_goal-rev_goal_ovca;
    Pova(i,1) = p1_ova;
end





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
    
    
