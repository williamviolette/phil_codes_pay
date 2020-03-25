function [out] =counterfactuals_price(cd_dir,r,ver,given,option,ppinst,...
    r_lend,visit_price,marginal_cost,p1,p2,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X)


given(option) = r;

[~,ucon,sim]=obj(given,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);

disp ' PRE UTILITY DERIVATIVE '
[rev_goal,lend_cost,delinquency_cost,visit_cost,wwr]=cost_calc(sim,r_lend,visit_price,marginal_cost,p1,p2,s);

res_poor = given ;
res_poor(:,9) = given(:,9) - 100;
[~,u_poor,sim_poor] = obj(res_poor,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);

u_ch = (ucon-u_poor)/100;

   
disp ' NO-LOAN '
    res_nl = given;
    res_nl(:,2) = .8;
    [~,ucon_nl,sim_nl] =obj(res_nl,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'utility from no loan'
    (ucon_nl-ucon)/u_ch

    [rev_goal_nl,lend_cost_nl,delinquency_cost_nl,visit_cost_nl,wwr_nl] = cost_calc(sim_nl,r_lend,visit_price,marginal_cost,p1,p2,s);
    disp 'Pre-Post: Rev'
    rev_goal-rev_goal_nl

    R =  rev_goal + (wwr_nl-rev_goal_nl);
    I = mean(sim_nl(:,1)) - (given(7)-p1)./(p2.*2+1);  %%% how much extra water do you use?
    as = given(:,7);
    mc = marginal_cost;
    p2s = p2;
    p1_nlcp =  (I + as + mc + 2*I*p2s - 2*p2s*(4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2) + 2*mc*p2s - (4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2))/(2*(p2s + 1));
      
    res_nlcp = res_nl;
    res_nlcp(:,10) = p1_nlcp;
    [~,ucon_nlcp,sim_nlcp] =obj(res_nlcp,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'compensated price utility from no loan'
    (ucon_nlcp-ucon)/u_ch
    
    [rev_goal_nlcp,lend_cost_nlcp,delinquency_cost_nlcp,visit_cost_nlcp,wwr_nlcp] = cost_calc(sim_nlcp,r_lend,visit_price,marginal_cost,p1_nlcp,p2,s);
    disp 'Pre-Post: Rev'
    rev_goal-rev_goal_nlcp
    
    
disp ' HALF-RATE '
    res_hf = given;
    res_hf(:,17)=given(:,17)/2;
    [~,ucon_hf,sim_hf] = obj(res_hf,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'utility from half rate '
    (ucon_hf-ucon)/u_ch
   
    [rev_goal_hf,lend_cost_hf,delinquency_cost_hf,visit_cost_hf,wwr_hf] = cost_calc(sim_hf,r_lend,visit_price,marginal_cost,p1,p2,s);
    disp 'Pre-Post: Rev'
    rev_goal-rev_goal_hf
    
    R =  rev_goal + (wwr_hf-rev_goal_hf);
    I = mean(sim_hf(:,1)) - (given(7)-p1)./(p2.*2+1);  %%% how much extra water do you use?
    as = given(:,7);
    mc = marginal_cost;
    p2s = p2;
    p1_hf =  (I + as + mc + 2*I*p2s - 2*p2s*(4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2) + 2*mc*p2s - (4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2))/(2*(p2s + 1));
      
    res_hfcp = res_hf;
    res_hfcp(:,10) = p1_hf;
    [~,ucon_hfcp,sim_hfcp] =obj(res_hfcp,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'compensated utility price from half rate'
    (ucon_hfcp-ucon)/u_ch
    
    [rev_goal_hfcp,lend_cost_hfcp,delinquency_cost_hfcp,visit_cost_hfcp,wwr_hfcp] = cost_calc(sim_nlcp,r_lend,visit_price,marginal_cost,p1_hf,p2,s);
    disp 'Pre-Post: Rev'
    rev_goal-rev_goal_hfcp
 
h=counterfactuals_price_print(cd_dir,strcat('reg_',ver),res_poor(17),ucon,u_ch,ucon,ucon,sim,sim,rev_goal,rev_goal,lend_cost,delinquency_cost,visit_cost,wwr,s,given);
h=counterfactuals_price_print(cd_dir,strcat('nl_',ver),0,ucon,u_ch,ucon_nl,ucon_nlcp,sim_nl,sim_nlcp,rev_goal,rev_goal_nlcp,lend_cost_nlcp,delinquency_cost_nlcp,visit_cost_nlcp,wwr_nlcp,s,res_nlcp);
h=counterfactuals_price_print(cd_dir,strcat('hf_',ver),res_poor(17)/2,ucon,u_ch,ucon_hf,ucon_hfcp,sim_hf,sim_hfcp,rev_goal,rev_goal_hfcp,lend_cost_hfcp,delinquency_cost_hfcp,visit_cost_hfcp,wwr_hfcp,s,res_hfcp);


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
    
    
% Ogride = (10:1:50)' ;
% R_ov = zeros(size(Ogride,1),1);
% for i=1:size(Ogride,1)
%     p1r = Ogride(i);
%     w_tr = (given(7)-p1r)./(p2.*2+1);
%     r_tr = (p1r- marginal_cost  + p2*w_tr)*w_tr;
%     R_ov(i)=r_tr;
% end
% plot(Ogride,R_ov)





%     res_nlcp = res_nl;
%     res_nlcp(:,15) = rev_goal - (rev_goal_nl-ppinst);
%     [~,ucon_nlpp,sim_nlpp] =obj(res_nlcp,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
%     disp 'compensated utility from no loan pre-paid'
%     (ucon_nlpp-ucon)/u_ch
%     
%     R =  rev_goal + (wwr_nl-(rev_goal_nl-ppinst));
%     I = mean(sim_nl(:,1)) - (given(7)-p1)./(p2.*2+1);  %%% how much extra water do you use?
%     as = given(:,7);
%     mc = marginal_cost;
%     p2s = p2;
%     p1_new =  (I + as + mc + 2*I*p2s - 2*p2s*(4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2) + 2*mc*p2s - (4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2))/(2*(p2s + 1));
    
%     res_nlcpp = res_nl;
%     res_nlcpp(:,10) = p1_new;
%     [~,ucon_nlcpp,sim_nlcpp] =obj(res_nlcpp,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
%     disp 'compensated price utility from no loan pre-paid'
%     (ucon_nlcpp-ucon)/u_ch
%     
%     [rev_goal_nlcpp,lend_cost_nlcpp,delinquency_cost_nlcpp,visit_cost_nlcpp,wwr_nlcpp] = cost_calc(sim_nlcpp,r_lend,visit_price,marginal_cost,p1_new,p2,s);
%     disp 'Pre-Post: Rev'
%     rev_goal-rev_goal_nlcpp





% disp ' UN-TIED '
%     resu = given;
%     resu(:,6)=1;
%     [~,ucon_u,sim_u] = obj(resu,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
%     disp 'utility from untied'
%     (ucon_u-ucon)/u_ch
%    
%     [rev_goal_u,lend_cost_u,delinquency_cost_u,visit_cost_u,wwr_u] = cost_calc(sim_u,r_lend,visit_price,marginal_cost,p1,p2,s);
%     disp 'Pre-Post: Rev'
%     rev_goal-rev_goal_u
%     
%     resu_c = resu;
%     resu_c(:,15)=rev_goal - rev_goal_u ;
%     [~,ucon_uc,sim_uc] =obj(resu_c,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
%     disp 'compensated utility from untied'
%     (ucon_uc-ucon)/u_ch
%     
%     R =  rev_goal + (wwr_u-rev_goal_u);
%     I = mean(sim_u(:,1)) - (given(7)-p1)./(p2.*2+1);  %%% how much extra water do you use?
%     as = given(:,7);
%     mc = marginal_cost;
%     p2s = p2;
%     p1_ov =  (I + as + mc + 2*I*p2s - 2*p2s*(4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2) + 2*mc*p2s - (4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2))/(2*(p2s + 1));
      

%     res_nlc = res_nl;
%     res_nlc(:,15) = rev_goal - rev_goal_nl;
%     [~,ucon_nlc,sim_nlc] =obj(res_nlc,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
%     disp 'compensated utility from no loan'
%     (ucon_nlc-ucon)/u_ch
