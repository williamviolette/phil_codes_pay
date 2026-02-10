
%%% dc_robustness_delta027.m
%%% Robustness: re-estimate the model with a higher monthly discount rate
%%% delta = 0.027 (beta_set = .027), then run all counterfactuals.
%%% Outputs to tables_new/ with 'bhigh' suffix.

clear;
cd "/Users/willviolette/Library/CloudStorage/Dropbox/Mac/Documents/GitHub/phil_codes_pay/matlab";
octave_setup;
rng(1)

folder ='/Users/willviolette/Library/CloudStorage/Dropbox/Mac/Documents/GitHub/phil_codes_pay/moments/';
cd_dir ='/Users/willviolette/Library/CloudStorage/Dropbox/Mac/Documents/GitHub/phil_codes_pay/paper/tables_new/';


real_data      = 1    ;
given_sim      = 1    ;

est_pattern    = 1    ;
results        = 1    ;
boot           = 1    ;
br             = 10   ; % reps

int_size = 1; % number of interpolations
refinement      = 1 ; % refine the number of stuff
one_price       = 0 ;

marginal_cost = 5;
ppinst = 51;

s=32*12; % sets account length

mult_set = [  1  ];

n  = 384*50 +1 ;
rng(1);
X=rand(n-1,2);
sigA = 0;
sigB = 0;
nD   = 2;



  %  alpha pd pc
option = [ 7 12 17 ];   %%% what to estimate
lb = [ 40 10  .01 ];
ub = [ 80 400 .99 ];

option_moments       = [ 1 2 3  ];  %%% moments to use!
option_moments_est   = [ 1 2 3  ];

inc_t=1;

    visit_price = 200;
    erate = 45;
    popadj = 2.4*12;

[c_avg,c_std,bal_avg,bal_med,bal_std,bal_corr,...
    dc_shr,...
    bal_0,bal_end,bal_0_end,...
    am_d, am_d4,...
    am1,am2,am3,am4,...
    amar1,amar2,amar3,amar4,...
    y_avg,y_cv,Aub,Alb,Blb,...
    p1,p2,prob_caught,...
    delinquency_cost,r_lend,dc_prob] ...
        = import_to_matlab_t3(folder,one_price,1);

data_moments = [ c_avg; bal_avg; dc_shr; am_d; bal_0; bal_end ] ;

format long g

    nA = 40
    nB = 40

Alb = -2.*y_avg ;
Aub =  2.*y_avg ;

%%% annual rate of 5.75%, which implies a monthly interest rate of .0047
r_lend     = .0047 ;
r_high     = .0945 ;


ver = 'bhigh';

%%% HIGH DISCOUNT RATE: delta = 0.027
beta_set   = .027

    %             1       2        3         4         5       6      7     8         9      10  11   12   13  14     15    16     17     18      19    20  21
    % given :  r_lend , r_water, r_high, hasscost, inc shock, untie, alpha, beta_up , Y   ,  p1, p2 , pd,  n, curve, fee,  vhass   pc     pm      Blb   Tg  sp
given =        [   0     0       r_high      0        y_cv      0      54   beta_set  y_avg  p1  p2   370  n    1     0     0    .24   bal_0_end  Blb   12  .8 ];


if real_data == 1
            data = data_moments(option_moments,:); % need to transpose here
else
            data = h(option_moments,:);
end

tic
[est_mom,ucon,controls,~,~,A1,B1]=obj(given,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
toc

disp ' Sim '
round(est_mom(option_moments_est),3)
disp ' Data '
round(data(option_moments),3)



if est_pattern==1
        options = optimoptions('patternsearch','Display','iter','MaxFunctionEvaluations',200,'MaxIterations',30,'InitialMeshSize',1,'UseParallel',true);
        weights =  eye(size(data,1))./(data.^2) ;   % normalize moments to be between zero and one (matters quite a bit)
        ag = given(option);
        obj_run = @(a1)objopt(a1,given,data,option,option_moments_est,weights,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
                    disp ' old obj: '
                    obj_run(ag)
                    disp ' '
                    disp 'pattern search ... '
                    tic
                    [res,fval,~,Output] = patternsearch(obj_run,ag,[],[],[],[],lb,ub,[],options)
                    fprintf('The number of iterations was : %d\n', Output.iterations);
                    fprintf('The number of function evaluations was : %d\n', Output.funccount);
                    toc
                    [~,~,est_mom]=obj_run(res);
                    disp   '   truth               estimates   '
                    [ round(data(:,1),2)  round(est_mom,2) ]
                    disp ' psearch done ! :)'
         csvwrite(strcat(folder,'pattern_estimates_',ver,'.csv'),res)

    rb=zeros(br,size(option_moments,2));

    if boot==1
        for i=1:size(rb,1)
            rng(i);
            X1=rand(n-1,2);
            c_avg     = csvread(strcat(folder,'c_avg_',num2str(i),'.csv'))  ;
            bal_avg   = csvread(strcat(folder,'bal_avg_',num2str(i),'.csv'));
            dc_shr = csvread(strcat(folder,'dc_shr_',num2str(i),'.csv'));
            data_moments_boot = [ c_avg; bal_avg; dc_shr ]

            data = data_moments_boot(option_moments,:);

            options = optimoptions('patternsearch','Display','iter','MaxFunctionEvaluations',200,'MaxIterations',30,'InitialMeshSize',1,'UseParallel',true);
            weights =  eye(size(data,1))./(data.^2) ;   % normalize moments to be between zero and one (matters quite a bit)
            ag = given(option);
            obj_run = @(a1)objopt(a1,given,data,option,option_moments_est,weights,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X1);
                        disp ' old obj: '
                        obj_run(ag)
                        disp ' '
                        disp 'pattern search ... '
                        tic
                        [res,fval,~,Output] = patternsearch(obj_run,ag,[],[],[],[],lb,ub,[],options)
                        fprintf('The number of iterations was : %d\n', Output.iterations);
                        fprintf('The number of function evaluations was : %d\n', Output.funccount);
                        toc
                        [~,~,est_mom]=obj_run(res);
                        disp   '   truth               estimates   '
                        [ round(data(:,1),2)  round(est_mom,2) ]
                        disp ' psearch done ! :)'
             csvwrite(strcat(folder,'pattern_estimates_',ver,'_',num2str(i),'.csv'),res)
        end
    end
end


%%% reload data moments in case bootstrap overwrote them
[c_avg,c_std,bal_avg,bal_med,bal_std,bal_corr,...
    dc_shr,...
    bal_0,bal_end,bal_0_end,...
    am_d, am_d4,...
    am1,am2,am3,am4,...
    amar1,amar2,amar3,amar4,...
    y_avg,y_cv,Aub,Alb,Blb,...
    p1,p2,prob_caught,...
    delinquency_cost,r_lend,dc_prob] ...
        = import_to_matlab_t3(folder,one_price,1);
data_moments = [ c_avg; bal_avg; dc_shr; am_d; bal_0; bal_end ] ;
data = data_moments(option_moments,:);
r_lend     = .0047 ;
r_high     = .0945 ;
Alb = -2.*y_avg ;
Aub =  2.*y_avg ;


if results==1
    rb=zeros(br,size(option_moments,2));
    if boot==1
        for i = 1:size(rb,1)
           rb(i,:) =  csvread(strcat(folder,'pattern_estimates_',ver,'_',num2str(i),'.csv'));
        end
    else
        rb=zeros(size(rb,1),size(rb,2));
    end
    r = csvread(strcat(folder,'pattern_estimates_',ver,'.csv'));


    j=print_estimates(cd_dir,r,rb,ver);

    if given_sim==1
        r= given(option);
    end

    %%% SET ESTIMATES INTO GIVEN
    given(option) = r;


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% RUN COUNTERFACTUALS                %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%% BASELINE
    rng(1);
    X=rand(n-1,2);
    [~,ucon,sim]=obj(given,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);

    [rev_goal,lend_cost,delinquency_cost_cf,visit_cost,wwr]=cost_calc(sim,r_lend,visit_price,marginal_cost,p1,p2,s);

    %%% UTILITY DERIVATIVE (for compensating variation)
    res_poor = given ;
    res_poor(:,9) = given(:,9) - 100;
    [~,u_poor,sim_poor] = obj(res_poor,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    u_ch = (ucon-u_poor)/100;

    %%% Print baseline (reg)
    h=counterfactuals_price_print(cd_dir,strcat('reg_',ver),given(17),ucon,u_ch,ucon,ucon,sim,sim,rev_goal,rev_goal,lend_cost,delinquency_cost_cf,visit_cost,wwr,s,given);
    wnum(cd_dir,strcat('lend_cost_sum_reg_',ver,'.tex'), (lend_cost + delinquency_cost_cf) ,'%5.0f');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% 1. NO-LOAN (PREPAID)  %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp ' NO-LOAN (PREPAID METERING) '
    res_nl = given;
    res_nl(:,2) = .8;
    [~,ucon_nl,sim_nl] =obj(res_nl,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    (ucon_nl-ucon)/u_ch

    [rev_goal_nl,lend_cost_nl,delinquency_cost_nl,visit_cost_nl,wwr_nl] = cost_calc(sim_nl,r_lend,visit_price,marginal_cost,p1,p2,s);

    %%% Revenue-neutral price adjustment (closed form)
    R =  rev_goal + (wwr_nl-rev_goal_nl);
    I = mean(sim_nl(:,1)) - (given(7)-p1)./(p2.*2+1);
    as = given(:,7);
    mc = marginal_cost;
    p2s = p2;
    p1_nlcp =  (I + as + mc + 2*I*p2s - 2*p2s*(4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2) + 2*mc*p2s - (4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2))/(2*(p2s + 1));

    res_nlcp = res_nl;
    res_nlcp(:,10) = p1_nlcp;
    [~,ucon_nlcp,sim_nlcp] =obj(res_nlcp,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'compensated CV from prepaid metering'
    (ucon_nlcp-ucon)/u_ch

    [rev_goal_nlcp,lend_cost_nlcp,delinquency_cost_nlcp,visit_cost_nlcp,wwr_nlcp] = cost_calc(sim_nlcp,r_lend,visit_price,marginal_cost,p1_nlcp,p2,s);

    h=counterfactuals_price_print(cd_dir,strcat('nl_',ver),0,ucon,u_ch,ucon_nl,ucon_nlcp,sim_nl,sim_nlcp,rev_goal,rev_goal_nlcp,lend_cost_nlcp,delinquency_cost_nlcp,visit_cost_nlcp,wwr_nlcp,s,res_nlcp);
    wnum(cd_dir,strcat('lend_cost_sum_nl_',ver,'.tex'), (lend_cost_nlcp + delinquency_cost_nlcp) ,'%5.0f');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% 2. HALF-RATE ENFORCEMENT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp ' HALF-RATE ENFORCEMENT '
    res_hf = given;
    res_hf(:,17)=given(:,17)/2;
    [~,ucon_hf,sim_hf] = obj(res_hf,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    (ucon_hf-ucon)/u_ch

    [rev_goal_hf,lend_cost_hf,delinquency_cost_hf,visit_cost_hf,wwr_hf] = cost_calc(sim_hf,r_lend,visit_price,marginal_cost,p1,p2,s);

    R =  rev_goal + (wwr_hf-rev_goal_hf);
    I = mean(sim_hf(:,1)) - (given(7)-p1)./(p2.*2+1);
    as = given(:,7);
    mc = marginal_cost;
    p2s = p2;
    p1_hft =  (I + as + mc + 2*I*p2s - 2*p2s*(4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2) + 2*mc*p2s - (4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2))/(2*(p2s + 1));

    %%% Grid search to refine revenue-neutral price
    Ogride = (-1:.25:-.25)' ;
    R_ov = zeros(size(Ogride,1),1);
    P_ov = zeros(size(Ogride,1),1);

    for i=1:size(Ogride,1)
        p1r =p1_hft + Ogride(i);
            res_hfr = res_hf;
            res_hfr(:,10) = p1r;
            [~,ucon_hfr,sim_hfr] =obj(res_hfr,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
            [rev_goal_hfr] = cost_calc(sim_hfr,r_lend,visit_price,marginal_cost,p1r,p2,s);
        R_ov(i)=rev_goal-rev_goal_hfr;
        P_ov(i)=p1r;
    end

    [~,R_ind]=min(abs(R_ov));
    p1_hf = P_ov(R_ind);

    res_hfcp = res_hf;
    res_hfcp(:,10) = p1_hf;
    [~,ucon_hfcp,sim_hfcp] =obj(res_hfcp,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'compensated CV from half-rate enforcement'
    (ucon_hfcp-ucon)/u_ch

    [rev_goal_hfcp,lend_cost_hfcp,delinquency_cost_hfcp,visit_cost_hfcp,wwr_hfcp] = cost_calc(sim_hfcp,r_lend,visit_price,marginal_cost,p1_hf,p2,s);

    h=counterfactuals_price_print(cd_dir,strcat('hf_',ver),given(17)/2,ucon,u_ch,ucon_hf,ucon_hfcp,sim_hf,sim_hfcp,rev_goal,rev_goal_hfcp,lend_cost_hfcp,delinquency_cost_hfcp,visit_cost_hfcp,wwr_hfcp,s,res_hfcp);
    wnum(cd_dir,strcat('lend_cost_sum_hf_',ver,'.tex'), (lend_cost_hfcp + delinquency_cost_hfcp) ,'%5.0f');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% 3. LATE PENALTY        %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp ' LATE PENALTY '
    %%% Late penalty = 10% of average unpaid balance per month with B<0
    late_penalty = 0.1 * bal_avg ;  %%% ~123.5 PhP
    res_lp = given;
    res_lp(:,4) = late_penalty;  %%% hasscost: deducted from income when Bprime<0
    [~,ucon_lp,sim_lp] = obj(res_lp,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'utility from late penalty'
    (ucon_lp-ucon)/u_ch

    [rev_goal_lp,lend_cost_lp,delinquency_cost_lp,visit_cost_lp,wwr_lp] = cost_calc(sim_lp,r_lend,visit_price,marginal_cost,p1,p2,s);

    %%% Revenue-neutral price adjustment
    R =  rev_goal + (wwr_lp-rev_goal_lp);
    I = mean(sim_lp(:,1)) - (given(7)-p1)./(p2.*2+1);
    as = given(:,7);
    mc = marginal_cost;
    p2s = p2;
    p1_lpt =  (I + as + mc + 2*I*p2s - 2*p2s*(4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2) + 2*mc*p2s - (4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2))/(2*(p2s + 1));

    %%% Grid search to refine
    Ogride_lp = (-1:.25:-.25)' ;
    R_ov_lp = zeros(size(Ogride_lp,1),1);
    P_ov_lp = zeros(size(Ogride_lp,1),1);

    for i=1:size(Ogride_lp,1)
        p1r =p1_lpt + Ogride_lp(i);
            res_lpr = res_lp;
            res_lpr(:,10) = p1r;
            [~,ucon_lpr,sim_lpr] =obj(res_lpr,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
            [rev_goal_lpr] = cost_calc(sim_lpr,r_lend,visit_price,marginal_cost,p1r,p2,s);
        R_ov_lp(i)=rev_goal-rev_goal_lpr;
        P_ov_lp(i)=p1r;
    end

    [~,R_ind_lp]=min(abs(R_ov_lp));
    p1_lp = P_ov_lp(R_ind_lp);

    res_lpcp = res_lp;
    res_lpcp(:,10) = p1_lp;
    [~,ucon_lpcp,sim_lpcp] =obj(res_lpcp,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'compensated CV from late penalty'
    (ucon_lpcp-ucon)/u_ch

    [rev_goal_lpcp,lend_cost_lpcp,delinquency_cost_lpcp,visit_cost_lpcp,wwr_lpcp] = cost_calc(sim_lpcp,r_lend,visit_price,marginal_cost,p1_lp,p2,s);

    h=counterfactuals_price_print(cd_dir,strcat('lp_',ver),given(17),ucon,u_ch,ucon_lp,ucon_lpcp,sim_lp,sim_lpcp,rev_goal,rev_goal_lpcp,lend_cost_lpcp,delinquency_cost_lpcp,visit_cost_lpcp,wwr_lpcp,s,res_lpcp);
    wnum(cd_dir,strcat('lend_cost_sum_lp_',ver,'.tex'), (lend_cost_lpcp + delinquency_cost_lpcp) ,'%5.0f');


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% 4. 4.9% INTEREST RATE  %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp ' 4.9% INTEREST RATE ON UNPAID BILLS '
    res_ir = given;
    res_ir(:,2) = 0.049;  %%% r_water: interest rate on unpaid water bills
    [~,ucon_ir,sim_ir] = obj(res_ir,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'utility from interest rate'
    (ucon_ir-ucon)/u_ch

    [rev_goal_ir,lend_cost_ir,delinquency_cost_ir,visit_cost_ir,wwr_ir] = cost_calc(sim_ir,r_lend,visit_price,marginal_cost,p1,p2,s);

    %%% Revenue-neutral price adjustment
    R =  rev_goal + (wwr_ir-rev_goal_ir);
    I = mean(sim_ir(:,1)) - (given(7)-p1)./(p2.*2+1);
    as = given(:,7);
    mc = marginal_cost;
    p2s = p2;
    p1_irt =  (I + as + mc + 2*I*p2s - 2*p2s*(4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2) + 2*mc*p2s - (4*I^2*p2s^2 + 4*I^2*p2s + I^2 + 4*I*as*p2s + 2*I*as - 4*I*mc*p2s - 2*I*mc + as^2 - 2*as*mc + mc^2 - 4*R*p2s - 4*R)^(1/2))/(2*(p2s + 1));

    %%% Grid search to refine
    Ogride_ir = (-1:.25:-.25)' ;
    R_ov_ir = zeros(size(Ogride_ir,1),1);
    P_ov_ir = zeros(size(Ogride_ir,1),1);

    for i=1:size(Ogride_ir,1)
        p1r =p1_irt + Ogride_ir(i);
            res_irr = res_ir;
            res_irr(:,10) = p1r;
            [~,ucon_irr,sim_irr] =obj(res_irr,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
            [rev_goal_irr] = cost_calc(sim_irr,r_lend,visit_price,marginal_cost,p1r,p2,s);
        R_ov_ir(i)=rev_goal-rev_goal_irr;
        P_ov_ir(i)=p1r;
    end

    [~,R_ind_ir]=min(abs(R_ov_ir));
    p1_ir = P_ov_ir(R_ind_ir);

    res_ircp = res_ir;
    res_ircp(:,10) = p1_ir;
    [~,ucon_ircp,sim_ircp] =obj(res_ircp,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
    disp 'compensated CV from 4.9% interest rate'
    (ucon_ircp-ucon)/u_ch

    [rev_goal_ircp,lend_cost_ircp,delinquency_cost_ircp,visit_cost_ircp,wwr_ircp] = cost_calc(sim_ircp,r_lend,visit_price,marginal_cost,p1_ir,p2,s);

    h=counterfactuals_price_print(cd_dir,strcat('ir_',ver),given(17),ucon,u_ch,ucon_ir,ucon_ircp,sim_ir,sim_ircp,rev_goal,rev_goal_ircp,lend_cost_ircp,delinquency_cost_ircp,visit_cost_ircp,wwr_ircp,s,res_ircp);
    wnum(cd_dir,strcat('lend_cost_sum_ir_',ver,'.tex'), (lend_cost_ircp + delinquency_cost_ircp) ,'%5.0f');


    disp '=== DONE: All counterfactuals for delta=0.027 robustness ==='
end
