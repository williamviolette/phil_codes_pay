

clear;
cd "/Users/willviolette/Library/CloudStorage/Dropbox/Mac/Documents/GitHub/phil_codes_pay/matlab";
octave_setup;
rng(1)

folder ='/Users/willviolette/Library/CloudStorage/Dropbox/Mac/Documents/GitHub/phil_codes_pay/moments/';
cd_dir ='/Users/willviolette/Library/CloudStorage/Dropbox/Mac/Documents/GitHub/phil_codes_pay/paper/tables_new/';


real_data     = 1     ;
second_output = 0     ;
pick_sv       = 0     ;
est_many      = 1     ;
est_tables    = 0     ;
counter       = 0     ;

bs            = 0 ; % bootstrap option
br       = [1 10] ; % rep interval
br_est   = [1 10] ;
int_size = 2; % number of interpolations
Fset     = 2;     % number of Chow iterations
refinement =1 ; % refine the number of stuff
prob_caught_sim = 0 ;

one_price       = 0;

marginal_cost = 5;
ppinst = 51;

s=1; % 1 adds amar moments

mult_set = [  1  ];

%%% refine est: n,8000  nA,8 nB,8 one run,2.86s  total,1482s est  : 0.00999719545886186          0.20936753044794        0.0305679439809489          186.940162736175
%%% refine est: n,8000  nA,7 nB,7 one run,2.08s  total,

%%% refine est: n,8000  nA,4 nB,4 one run,1.15s  total,263s est   : 0.0082459593512591         0.206349551895979        0.0344387679922885          191.276497204238
%%% refine est: n,10000 nA,4 nB,4 one run,1.15s  total,214s est  : 0.00846661771927642          0.21708577762795        0.0309834203143979          204.089802134792
%%% refine est: n,20000 nA,4 nB,4 one run,1.49s  total,300s est  : 0.00917935145792283         0.229700672268095        0.0309756300297088          184.423288245618

%%% alpha, r, pd
% 4n, .82s, 400s
% 6n, .93s, 182s
% 7a,7b, 1.2s, 4o, 4m,  890s  0.00687099456787109      0.342904357910156     0.0223438510894775          210
% 8a,8b, 1.6s, 4o, 4m, 2654s  0.00923959374427795      0.28075626373291      0.0257720718383789          172.5
% 8a,8b, 1.6s, 4o,10m, 1119s  0.0108501559495926       0.264359741210938     0.0201444396972656          74
% 5a,8b, 1.6s, 4o,4m,  1161s  0.0051939731836319       0.340272216796875     0.0255288848876953          138

% 9a,9b, 3.2s, 4o, 6m, 3141s  0.010084400177002        0.264434127807617        0.0252093443870544          147
% 8a,8b, 1.6s, 4o, 6m, 1840s  0.00968910217285156      0.278489379882813        0.0257682571411133          138.5
% 6a,6b, 1.0s, 4o, 6m, 461s   0.0101792311668396       0.2798779296875          0.025755859375              138


%%% FIXED THE lending rate
% 6a,6b, , 4o, 6m, 1068s D.01  0.0260908889770508         0.374820499420166         0.0219125518798828                     -22.5
% 4a,4b, , 4o, 4m, 839s  D.015 0.0212795925140381         0.319558410644531         0.025053955078125                       -86
% 4a,4b, , 4o, 4m, 1060s D.015 0.00805168271064758        0.404805450439453        0.0246228942871094                        91
% 6a,6b, , 4o, 4m, 980   D.015 0.0225921165943146         0.3403564453125         0.0242452392578125                       164
% 7a,7b, , 4o, 4m, 685   D.015 0.0219416809082031         0.341806030273437         0.023702956199646                       150



%%% ALL ARE VERY CLOSE! VERY NICE! !!


%%%% is it sensitive to theta?

n = 10000;
nA = 15  %%% previously 25, 25 (7 takes 1608 (28*28*2=1568)) (8 takes 3702 (32*32*2=4096))
nB = 15

Alb = -1.*csvread(strcat(folder,'Ab.csv'));
Aub = csvread(strcat(folder,'Ab.csv'));
Blb = -1.*csvread(strcat(folder,'Bb.csv'));

sigA = 0;
sigB = 0;
nD   = 2;




%%%%%%%%% ESTIMATION %%%%%%%%%%

option = [ 3 5 7 12 ];   %%% what to estimate

% option = [ 3 7 12 ];   %%% what to estimate

%option_moments = [ 1 2 3 4 6 7 ];
% option_moments = [ 1 3   6 7 8 9   10 11 12 13    ];  %%% moments to use!

%option_moments = [  1 3   6 7   10 11    ];  %%% moments to use!

option_moments  = [ 1 3   6    10     ];  %%% moments to use!

%option_moments = [ 1  ];  %%% moments to use!





if bs==1
    bmat = csvread(strcat(folder,'B.csv'));
    if one_price==1
        p1 = bmat(1,:);
        p2 = 0;
    else
        p1 = bmat(1,:);
        p2 = bmat(2,:);
    end

    % prob_caught = bmat(3,:);
    % prob_caught = .05.*ones(size(prob_caught,1),size(prob_caught,2))  %%% HAVE HIGH PROB OF GETTING CAUGHT
    % prob_caught = .05; %%% HAVE HIGH PROB OF GETTING CAUGHT

    c_avg    = bmat(4,:);
    c_std    = bmat(5,:);
    bal_avg  = bmat(6,:);
    bal_std  = bmat(7,:);
    bal_corr = bmat(8,:);

    am1 = bmat(10,:); %%% start with plus 2! fix this later?!
    am2 = bmat(11,:);
    am3 = bmat(12,:);
    am4 = bmat(13,:);

    amar1 = bmat(16,:); %%% same plus 2 here too
    amar2 = bmat(17,:);
    amar3 = bmat(18,:);
    amar4 = bmat(19,:);

else
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

end

    prob_caught = csvread(strcat(folder,'prob_caught.csv'));

    y_avg       = csvread(strcat(folder,'y_avg.csv'));
    delinquency_cost = csvread(strcat(folder,'delinquency_cost.csv'));
    r_lend      = csvread(strcat(folder,'irate.csv'));
    r_lend      = ((1+r_lend)^(1/12)) - 1;
    dc_prob     = csvread(strcat(folder,'dc_per_month_account.csv'));
    visit_price = 200;
    erate = 45;
    popadj = 2.4*12;

data_moments = [  c_avg; c_std; bal_avg; bal_std; bal_corr; am1; am2; am3; am4; amar1; amar2; amar3; amar4 ];







n_states=4;
prob = [(1-prob_caught).*ones(n_states,n_states/2) (prob_caught).*ones(n_states,n_states/2)]./(n_states./2);
s0 = 1;

[chain,state] = markov(prob,n,s0);

format long g



    % given :  r_lend , r_water, r_high ,  lambda (U) ,   theta (y), gamma (a), alpha , beta_up , Y , p1, p2 ,pd,  n , metric, waterlend,
           %    1         2       3         4             5          6         7        8       9    10  11  12       %
%given=       [ r_lend    0      .03         0            0.28        0      .026      .02     y_avg p1  p2  170   n   10  0 ];

%given=       [ r_lend    0      .02         0            0.28        0      .026      .01     y_avg p1  p2  170   n   10  0 ];
given=       [ r_lend    0      .02         0            0.35        0      .026      .015     y_avg p1(1)  p2(1)  170   n   10  0 ];



%oldgiven=   [ r_lend    0      .04         0            0.3         0       .018      .02     y_avg p1  p2  pd   n   10  0 ];
% new oldgiven    =   [ r_lend    0      .01         0            0.21        0       .031      .02     y_avg p1  p2  180   n   10  0 ];


%%% TEST CODE HERE !!! %%%


    tic
    vgiven=0;
        [h,US,~,nA1,nB1,A1,B1,vgiven] = dc_obj_chow(given,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven);
        %round(h(option_moments),2)
        h
    %     nA1
    %     nB1
    %     unique(A1)
    %     unique(B1)
    toc
% %
disp ' value iteration '
     tic
         [h,US,~,nA1,nB1,A1,B1]         = dc_obj_chow(given,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven);
     toc
% %
     disp ' policy iteration '
     pol=1;
    tic
        [h,US,~,nA1,nB1,A1,B1]         = dc_obj_chow_pol(given,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven,pol);
    toc

if pick_sv == 1


%     S = [.003     .005   .01; ...
%          0.2    0.2   0.2; ...
%         0.025     .025    .025; ...
%         150     150    150  ]';

    S = [.01     .0101   .012 ; ...
         0.2    0.2   0.2; ...
        .025     .025    .025; ...
        170     170    170  ]';

    if real_data == 1
        data = data_moments(option_moments); % need to transpose here
    else
        data = h(option_moments);
    end

    weights =  eye(size(option_moments,2))./(data.^2) ;   % normalize moments to be between zero and one (matters quite a bit)
    ag = given(1,option);
    obj = @(a1)dc_objopt_chow(a1,given,data,option,option_moments,weights,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven);

    H = zeros(size(data,1),size(S,1));
    U = zeros(1,size(S,1));
    tic
    for ss = 1:size(S,1)
        a = S(ss,:);
        [US] =  obj(a);
        given1 = given;
        given1(option)=a;
        [h] =  dc_obj_chow(given1,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven);
        H(:,ss)=h(option_moments);
        U(1,ss)=US;
    end
    toc

    R = [H;U];
    S'
    round(R,2)
    round([data_moments(option_moments)],2)
end


%{a



if bs~=1

    if real_data == 1
        data = data_moments(option_moments); % need to transpose here
    else
        data = h(option_moments);
    end

    weights =  eye(size(option_moments,2))./(data.^2) ;   % normalize moments to be between zero and one (matters quite a bit)
    ag = given(1,option);
    obj = @(a1)dc_objopt_chow(a1,given,data,option,option_moments,weights,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven);


    if est_many == 1
            %%% run mamy starting values! %%%
        R = zeros(size(mult_set,2),size(option,2));
        OBJ_VAL = zeros(size(mult_set,2),1);
        OUTPUT = zeros(size(mult_set,2),size(data_moments,2));
            for k = 1:size(mult_set,2)
                ag
                mult_set(k).*ag

                disp ' old obj: '
                obj(ag)
                disp ' '
                disp 'pattern search ... '
                tic
                [res,fval,~,Output] = patternsearch(obj,mult_set(k).*ag)
                fprintf('The number of iterations was : %d\n', Output.iterations);
                fprintf('The number of function evaluations was : %d\n', Output.funccount);
                toc
                [~,~,est_mom]=obj(res);
                round(est_mom,2)
                disp ' psearch done ! :)'
                round(data,2)
                res_new = res;
                R(k,:) = res_new;
                OBJ_VAL(k,:) = obj(res_new);

            end

%         mult_set'.*ag
%         R
%         OBJ_VAL
%
%         [OUTPUT' data_moments']
%
%         [~,ind]=min(OBJ_VAL);
        estimates = R(ind,:);
%
        csvwrite(strcat(folder,'estimates.csv'),estimates)
    end

else %%% HERE IS BOOSTRAPPED
     for j=br(1):br(2)

        pd = 200;

        %given    =   [ r_lend    0      .04         0            0.2         0       .024      .02     y_avg  p1(j)  p2(j)  pd   n   10  0 ];
        given=       [ r_lend    0      .02         0            0.35        0      .026      .015     y_avg p1(j)  p2(j)  170   n   10  0 ];

        rng(j);
        s0 = 1;
        [chain1,state1] = markov(prob,n,s0);

        data = data_moments(option_moments, j ); % need to transpose here

        weights =  eye(size(option_moments,2))./(data.^2) ;   % normalize moments to be between zero and one (matters quite a bit)
        ag = given(1,option);
        obj = @(a1)dc_objopt_chow(a1,given,data,option,option_moments,weights,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven);

        if est_many == 1
                %%% run mamy starting values! %%%
            R = zeros(size(mult_set,2),size(option,2));
            OBJ_VAL = zeros(size(mult_set,2),1);
            OUTPUT = zeros(size(data_moments,1),size(mult_set,2));
                for k = 1:size(mult_set,2)
                    ag
                    mult_set(k).*ag

                    disp ' old obj: '
                    obj(ag)
                    disp ' '
                    disp 'pattern search ... '
                    tic
                    [res,fval,~,Output] = patternsearch(obj,mult_set(k).*ag)
                    fprintf('The number of iterations was : %d\n', Output.iterations);
                    fprintf('The number of function evaluations was : %d\n', Output.funccount);
                    toc
                    [~,~,est_mom]=obj(res);
                    round(est_mom,2)
                    disp ' psearch done ! :)'
                    round(data,2)

                    res_new = res;

                    R(k,:) = res_new;
                    OBJ_VAL(k,:) = obj(res_new);
                end

            mult_set'.*ag
            R
            OBJ_VAL

            [~,ind]=min(OBJ_VAL);
            estimates = R(ind,:);

            csvwrite(strcat(folder,'estimates_',num2str(j),'.csv'),estimates)
        end
     end
end


if est_tables==1

    %%% Estimates table
    estimates = csvread(strcat(folder,'estimates.csv'));
    res_out = given;
    res_out(option)=estimates;

    est_boot=[];
    for h=br_est(1):br_est(2)
        e_temp = csvread(strcat(folder,'estimates_',num2str(h),'.csv'));
        est_boot = [est_boot; e_temp];
    end

    est_var = std(est_boot);

    %%% PRINT ESTIMATES
    %[~]=est_print(estimates,cd_dir);
    fileID = fopen(strcat(cd_dir,'est_irate.tex'),'w');
        fprintf(fileID,'%s\n',num2str(estimates(1),'%5.3f'));
        fclose(fileID);
    fileID = fopen(strcat(cd_dir,'est_theta.tex'),'w');
        fprintf(fileID,'%s\n',num2str(estimates(2),'%5.3f'));
        fclose(fileID);
    fileID = fopen(strcat(cd_dir,'est_alpha.tex'),'w');
        fprintf(fileID,'%s\n',num2str(estimates(3),'%5.3f'));
        fclose(fileID);
    fileID = fopen(strcat(cd_dir,'est_fc.tex'),'w');
        fprintf(fileID,'%s\n',num2str(estimates(4),'%5.1f'));
        fclose(fileID);

    fileID = fopen(strcat(cd_dir,'est_sd_irate.tex'),'w');
        fprintf(fileID,'%s\n',num2str(est_var(1),'%5.4f'));
        fclose(fileID);
    fileID = fopen(strcat(cd_dir,'est_sd_theta.tex'),'w');
        fprintf(fileID,'%s\n',num2str(est_var(2),'%5.4f'));
        fclose(fileID);
    fileID = fopen(strcat(cd_dir,'est_sd_alpha.tex'),'w');
        fprintf(fileID,'%s\n',num2str(est_var(3),'%5.5f'));
        fclose(fileID);
    fileID = fopen(strcat(cd_dir,'est_sd_fc.tex'),'w');
        fprintf(fileID,'%s\n',num2str(est_var(4),'%5.4f'));
        fclose(fileID);

    %%% print percentages %%%
        fileID = fopen(strcat(cd_dir,'est_theta_per.tex'),'w');
            fprintf(fileID,'%s\n',num2str(estimates(2)*100,'%5.1f'));
            fclose(fileID);

         fileID = fopen(strcat(cd_dir,'est_irate_per.tex'),'w');
            fprintf(fileID,'%s\n',num2str(estimates(1)*100,'%5.1f'));
            fclose(fileID);

         fileID = fopen(strcat(cd_dir,'est_irate_annual_per.tex'),'w');
            fprintf(fileID,'%s\n',num2str( ((1+estimates(1))^(12) - 1)*100,'%5.1f'));
            fclose(fileID);



    %%% PRINT FIT!
    %output = dc_obj(res_out,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s);
    output= dc_obj_chow(res_out,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven);
    output_data = data_moments;

    fileID = fopen(strcat(cd_dir,'table_fit_est.tex'),'w');
        fprintf(fileID,'%s\n',strcat('Mean Usage (m3) &',num2str(output_data(1),'%5.2f'),'&', num2str(output(1),'%5.2f'),'\\'));
        fprintf(fileID,'%s\n',strcat('Mean Outstanding Balance (PhP) &',num2str(output_data(3),'%5.1f'),'&', num2str(output(3),'%5.1f'),'\\'));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'table_fit_est_dc.tex'),'w');
        fprintf(fileID,'%s\n',strcat('\multicolumn{1}{r}{ $\text{Visited}_{t-1}$ } &',num2str(output_data(6),'%5.2f'),'&', num2str(output(6),'%5.2f'),'\\'));
        fprintf(fileID,'%s\n',strcat('\multicolumn{1}{r}{ $\text{Visited}_{t-2}$ } &',num2str(output_data(7),'%5.2f'),'&', num2str(output(7),'%5.2f'),'\\'));
        fprintf(fileID,'%s\n',strcat('\multicolumn{1}{r}{ $\text{Visited}_{t-3}$ }  &',num2str(output_data(8),'%5.2f'),'&', num2str(output(8),'%5.2f'),'\\'));
        fprintf(fileID,'%s\n',strcat('\multicolumn{1}{r}{ $\text{Visited}_{t-4}$ } &',num2str(output_data(9),'%5.2f'),'&', num2str(output(9),'%5.2f'),'\\'));

        fprintf(fileID,'%s\n',strcat('\multicolumn{1}{r}{$\text{Visited \& 90+ days overdue}_{t-1}$ } &',num2str(output_data(10),'%5.2f'),'&', num2str(output(10),'%5.2f'),'\\'));
        fprintf(fileID,'%s\n',strcat('\multicolumn{1}{r}{$\text{Visited \& 90+ days overdue}_{t-2}$ } &',num2str(output_data(11),'%5.2f'),'&', num2str(output(11),'%5.2f'),'\\'));
        fprintf(fileID,'%s\n',strcat('\multicolumn{1}{r}{$\text{Visited \& 90+ days overdue}_{t-3}$ } &',num2str(output_data(12),'%5.2f'),'&', num2str(output(12),'%5.2f'),'\\'));
        fprintf(fileID,'%s\n',strcat('\multicolumn{1}{r}{$\text{Visited \& 90+ days overdue}_{t-4}$ } &',num2str(output_data(13),'%5.2f'),'&', num2str(output(13),'%5.2f'),'\\'));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'table_fit_out.tex'),'w');
        fprintf(fileID,'%s\n',strcat('SD Usage &',num2str(output_data(2),'%5.1f'),'&', num2str(output(2),'%5.1f'),'\\'));
        fprintf(fileID,'%s\n',strcat('SD Outstanding Balance  &',num2str(output_data(4),'%5.1f'),'&', num2str(output(4),'%5.1f'),'\\'));
        fprintf(fileID,'%s\n',strcat('Corr. Usage and Out. Bal. &',num2str(output_data(5),'%5.2f'),'&', num2str(output(5),'%5.2f'),'\\'));
    fclose(fileID);

    %%% Moments fit
    %output = dc_obj(res_out,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s);
    %output_data = data_moments';
    %[~]=fit_print(output,output_data,cd_dir);

    %%% Deaton Figure : export to stata
    %     [~,~,sim] = dc_obj(res_out,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s);
    %     csvwrite(strcat(folder,'sim.csv'),sim)
end





if counter==1

    %%% pull in estimates
    estimates = csvread(strcat(folder,'estimates.csv'));
    res_out = given;
    res_out(option)=estimates;

    %%% current
    %[h,util,simc] = dc_obj(res_out,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s);
    [h,util,simc] = dc_obj_chow(res_out,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven);
    c_h = h(1);

    %%% value of 10 PhP
    res_poor = res_out;
    res_poor(9) = res_out(9) - 10;
    %[~,util_poor] =dc_obj(res_poor,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s);
    [~,util_poor] =dc_obj_chow(res_poor,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven);
    du_dy10 = (util-util_poor)/10;

    %%% utility loss from no loans
    res_nl = res_out;
	res_nl(2) = .8;
    % [h_nl,util_nl] = dc_obj(res_nl,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s)   ;
    [h_nl,util_nl] = dc_obj_chow(res_nl,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven)  ;

    U_nl = (util_nl-util)/du_dy10
    c_nl = h_nl(1);



        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% OPP COST APPROACH   %%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%% lendingcost
    lend_costd = abs(mean(simc(:,3))).*r_lend;

    %%% water use at baseline
    wwd = mean(simc(:,1));
    wwr = mean((p1 - marginal_cost +p2.*simc(:,1)).*simc(:,1));

    simc_pre = [0 0 0 0 0;  simc(1:(size(simc,1)-1),:)];
    visit_costd=visit_price.*(size(simc(simc_pre(:,3)<0 & simc(:,5)>2,:),1)/size(simc,1));

    res_nle = res_out;
	res_nle(2) = .8;
    res_nle(9)=res_out(9) - delinquency_cost;

    coste = abs(mean(simc(:,3))).*r_lend;

    rev_goale = wwr - (coste + delinquency_cost  + visit_costd) ;

    Pgride = (0:.01:.04)' ;
    Re = zeros(size(Pgride,1),1);
    for i=1:size(Pgride,1)
        p1ne = p1+Pgride(i);
        res_nle_temp=res_nle;
        res_nle_temp(10) = p1ne;

        %[~,~,simc_temp] = dc_obj(res_nle_temp,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s);
        [~,~,simc_temp] = dc_obj_chow(res_nle_temp,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven) ;
        reve = mean((p1ne - marginal_cost +p2.*simc_temp(:,1)).*simc_temp(:,1));
        %wwe = w_reg_dk(0,res_nle(7),0,p1ne,p2,y_avg);
        %reve = (p1ne - marginal_cost + p2.*wwe).*wwe;
        Re(i,1) = abs(reve - rev_goale);
    end
    plot(Pgride,Re);
    [~,inde]=min(Re);
    Pgride(inde)

    p1ce=p1+Pgride(inde);

    res_ppe =res_nle;
    res_ppe(10) = p1ce;

    %[h_ppe,util_ppe] = dc_obj(res_ppe,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s);
    [h_ppe,util_ppe] = dc_obj_chow(res_ppe,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven) ;

    U_ppe = (util_ppe-util)/du_dy10;
    c_ppe = h_ppe(1);


        fileID = fopen(strcat(cd_dir,'U_ppe.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(U_ppe,'%5.1f')));
    fclose(fileID);
        fileID = fopen(strcat(cd_dir,'U_ppe_abs.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(abs(U_ppe),'%5.1f')));
    fclose(fileID);
            fileID = fopen(strcat(cd_dir,'U_ppe_abs_usd.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(abs(U_ppe)/erate,'%5.1f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'U_ppe_abs_usd_per.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str((abs(U_ppe)/erate)*popadj,'%5.1f')));
    fclose(fileID);
 fileID = fopen(strcat(cd_dir,'c_h_ppe_drop.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(100*abs((c_h-c_ppe)/c_h),'%5.1f')));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'c_ppe.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(c_ppe,'%5.1f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'c_ppe2.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(c_ppe,'%5.2f')));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'p_int_ppe.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(p1ce,'%5.1f')));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'p_int_ppe2.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(p1ce,'%5.2f')));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'p_int2.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(p1,'%5.2f')));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'p_int_ppe.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(p1ce,'%5.1f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'p_increase_per_ppe.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(100*abs((p1ce-p1)/p1),'%5.1f')));
    fclose(fileID);
     fileID = fopen(strcat(cd_dir,'coste.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(coste,'%5.1f')));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'visit_cost.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(visit_costd,'%5.1f')));
    fclose(fileID);


    %%% %%% pre-paid %%% %%%
    %%% current revenue
    %%%%% NOTE!!!! THIS IS AN AVERAGE CONSUMPTION CHANGE!! NOTE!!!!!!
    %ww = w_reg_dk(0,res_out(7),0,p1,p2, y_avg );

    rev_goal = wwr - delinquency_cost + ppinst - coste - visit_costd;

    res_pp_start = res_out;
	res_pp_start(2) = .8;
    res_pp_start(9) = res_out(9) - delinquency_cost;


    Pgrid = (6:.2:7)' ;
    R = zeros(size(Pgrid,1),1);
    for i=1:size(Pgrid,1)
        p1n = p1+Pgrid(i);
        res_pp_temp=res_pp_start;
        res_pp_temp(10) = p1n;

        %[~,~,simc_temp_pp] = dc_obj(res_pp_temp,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s);
        [~,~,simc_temp_pp] = dc_obj_chow(res_pp_temp,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven) ;
        rev = mean((p1n - marginal_cost +p2.*simc_temp_pp(:,1)).*simc_temp_pp(:,1));

        p1n = p1+Pgrid(i);
        %ww = w_reg_dk(0,res_out(7),0,p1n,p2,y_avg);
        %rev = (p1n - marginal_cost + p2.*ww).*ww;
        R(i,1) = abs(rev - rev_goal);
    end
    plot(Pgrid,R);
    [~,ind]=min(R);
    Pgrid(ind)

    p1c=p1+Pgrid(ind);

    res_pp=res_pp_start; % with pre-paid meters, don't get delinquency or loan, but get lower marginal price!
    res_pp(10)=p1c;

    %[h_pp,util_pp] = dc_obj(res_pp,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s);
    [h_pp,util_pp] = dc_obj_chow(res_pp,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven) ;

    U_pp = (util_pp-util)/du_dy10;
    c_pp = h_pp(1);



    estimates_c = [0 1 1 ; c_h c_nl c_pp ;  0 U_nl U_pp  ; delinquency_cost delinquency_cost 0;  p1 p1 p1c];


    %fprintf(fileID,'%s\n','\begin{tabular}{lccc}');
    %fprintf(fileID,'%s\n','& Current & No Water Credit & No Water Credit and \\');
    %fprintf(fileID,'%s\n','&         &                  & Revenue Neutral \\');




    amount_avg     = csvread(strcat(folder,'bill_all.csv'));


    fileID = fopen(strcat(cd_dir,'U_nl_per.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(abs(U_nl/amount_avg)*100,'%5.0f')));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'U_nl.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(U_nl,'%5.1f')));
    fclose(fileID);
        fileID = fopen(strcat(cd_dir,'U_pp.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(U_pp,'%5.1f')));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'U_nl_abs.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(abs(U_nl),'%5.1f')));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'U_nl_abs_usd.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(abs(U_nl)/erate,'%5.1f')));
    fclose(fileID);

        fileID = fopen(strcat(cd_dir,'U_pp_abs.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(abs(U_pp),'%5.1f')));
    fclose(fileID);
     fileID = fopen(strcat(cd_dir,'U_pp_abs_usd.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(abs(U_pp)/erate,'%5.1f')));
    fclose(fileID);
     fileID = fopen(strcat(cd_dir,'U_pp_abs_usd_per.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str((abs(U_pp)/erate)*popadj,'%5.1f')));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'c_h.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(c_h,'%5.1f')));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'c_h2.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(c_h,'%5.2f')));
    fclose(fileID);

        fileID = fopen(strcat(cd_dir,'c_nl.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(c_nl,'%5.1f')));
    fclose(fileID);
        fileID = fopen(strcat(cd_dir,'c_nl2.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(c_nl,'%5.2f')));
    fclose(fileID);
        fileID = fopen(strcat(cd_dir,'c_h_nl_drop.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(100*abs((c_h-c_nl)/c_h),'%5.1f')));
    fclose(fileID);

               fileID = fopen(strcat(cd_dir,'c_h_pp_drop.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(100*abs((c_h-c_pp)/c_h),'%5.1f')));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'c_pp.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(c_pp,'%5.1f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'c_pp2.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(c_pp,'%5.2f')));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'del_raised.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(abs(ppinst-delinquency_cost),'%5.1f')));
    fclose(fileID);





    fileID = fopen(strcat(cd_dir,'p_int_pp.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(p1c,'%5.1f')));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'p_int_pp2.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(p1c,'%5.2f')));
    fclose(fileID);


    fileID = fopen(strcat(cd_dir,'p_increase_per.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(100*abs((p1c-p1)/p1),'%5.1f')));
    fclose(fileID);


    %%%% OUT-DATED TABLE STUFF %%%%

    fileID = fopen(strcat(cd_dir,'counter_usage.tex'),'w');
        fprintf(fileID,'%s\n',strcat('Mean Usage (m3) &',num2str(c_h,'%5.1f'),'&', num2str(c_nl,'%5.1f'),'&', num2str(c_pp,'%5.1f'),'\\'));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'counter_cv.tex'),'w');
        fprintf(fileID,'%s\n',strcat('Compensating Variation (PhP)  &',' & ',num2str(U_nl,'%5.1f'),'&', num2str(U_pp,'%5.1f'),'\\'));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'counter_price.tex'),'w');
        fprintf(fileID,'%s\n',strcat('Price Intercept (PhP)  &',num2str(p1,'%5.1f'),'&', num2str(p1,'%5.1f'),'&', num2str(p1c,'%5.1f'),'\\'));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'counter_fixed.tex'),'w');
       fprintf(fileID,'%s\n',strcat('Fixed Savings (PhP)  &',num2str(delinquency_cost,'%5.1f'),'&', num2str(delinquency_cost,'%5.1f'),'&', num2str(0,'%5.0f'),'\\'));
    fclose(fileID);


    fileID = fopen(strcat(cd_dir,'counter_price_nomid.tex'),'w');
        fprintf(fileID,'%s\n',strcat('Price Intercept (PhP)  &',num2str(p1,'%5.1f'),'& &', num2str(p1c,'%5.1f'),'\\'));
    fclose(fileID);

    fileID = fopen(strcat(cd_dir,'counter_fixed_nomid.tex'),'w');
       fprintf(fileID,'%s\n',strcat('Fixed Savings (PhP)  &',num2str(delinquency_cost,'%5.1f'),'& &', num2str(0,'%5.0f'),'\\'));
    fclose(fileID);

       %fprintf(fileID,'%s\n','\end{tabular} ');


    %[~] = counter_print(estimates_c,cd_dir);

    %}
end


%%%% PRINTING PARAMETERS

%prob_caught=.05;

% fileID = fopen(strcat(cd_dir,'breps.tex'),'w');
%         fprintf(fileID,'%s\n',num2str(br(2),'%5.0f'));
%         fclose(fileID);
%
 %%% GRID SIZE AFFECTS THE MAXIMUM !!!!!!!  previously 5000, now just 2000
%     fileID = fopen(strcat(cd_dir,'par_n_iter.tex'),'w');
%         fprintf(fileID,'%s\n',num2sepstr(n,'%5.0f'));
%         fclose(fileID);



% [A,Aprime,B,Bprime,D,Dprime] = grid_start(nA,sigA,nB,sigB,nD) ;



%     fileID = fopen(strcat(cd_dir,'par_sigB.tex'),'w');
%         fprintf(fileID,'%s\n',num2sepstr(sigB,'%5.0f'));
%         fclose(fileID);

%     fileID = fopen(strcat(cd_dir,'par_nA.tex'),'w');
%         fprintf(fileID,'%s\n',num2sepstr(nA,'%5.0f'));
%         fclose(fileID);

%     fileID = fopen(strcat(cd_dir,'par_sigA.tex'),'w');
%         fprintf(fileID,'%s\n',num2sepstr(sigA,'%5.0f'));
%         fclose(fileID);


%hist(Agrid,100)
%     fileID = fopen(strcat(cd_dir,'par_Amin.tex'),'w');
%         fprintf(fileID,'%s\n',num2sepstr(min(Agrid),'%5.0f'));
%         fclose(fileID);
%     fileID = fopen(strcat(cd_dir,'par_Amax.tex'),'w');
%         fprintf(fileID,'%s\n',num2sepstr(max(Agrid),'%5.0f'));
%         fclose(fileID);

% fileID = fopen(strcat(cd_dir,'par_Bmin.tex'),'w');
%         fprintf(fileID,'%s\n',num2sepstr(min(Bgrid),'%5.0f'));
%         fclose(fileID);
%     fileID = fopen(strcat(cd_dir,'par_Bmax.tex'),'w');
%         fprintf(fileID,'%s\n',num2sepstr(max(Bgrid),'%5.0f'));
%         fclose(fileID);
%     fileID = fopen(strcat(cd_dir,'par_nB.tex'),'w');
%         fprintf(fileID,'%s\n',num2sepstr(nB,'%5.0f'));
%         fclose(fileID);
%hist(Bgrid,100)

%     fileID = fopen(strcat(cd_dir,'par_totalsize.tex'),'w');
%         fprintf(fileID,'%s\n',num2sepstr(size(D,1),'%5.0f'));
%         fclose(fileID);

%%%% set grid right!!







%{


%%%%% DIFFERENCE IS DUE TO THE DEL. COST!

%%%%%  COULD PROPOSE AN OPTIMAL DISCONNECTION VISIT STRATEGY

    %%%% CV APPROACH!
%      Ys=1;
%      Ywindow = 60;
%      Ygrid = ((res_out(9)-Ywindow):Ys:(res_out(9)+Ys))' ;
%      U = zeros(size(Ygrid,1),1);
%      for i=1:size(Ygrid,1)
%         res_temp = res_out;
%         res_temp(9) = Ygrid(i);
%         [~,util_temp] = dk_obj(res_temp,prob,A,Aprime,nA,B,Bprime,nB,chain,s);
%         U(i,1) = abs(util_temp - util_nl);
%      end
%      plot(Ygrid,U)
%      [~,ind]=min(U)
%      [Ygrid(ind) res_out(9) (Ygrid(ind)-res_out(9))]
%  LINES UP WELL WITH THE APPROXIMATION THANKFULLY!


    %%% TEST PROB DETECTION!

    prob_caught1 = 1
    prob1 = [(1-prob_caught1).*ones(n_states,n_states/2) (prob_caught1).*ones(n_states,n_states/2)]./(n_states./2);

    s01 = 1;
    [chain1,state1] = markov(prob1,n,s01);

    [h1,util1,simc1] = dc_obj(res_out,prob1,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain1,s);
    %c_h1 = h(1);

    h
    util
    h1
    util1

    U_1 = (util1-util)/du_dy10

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% OPTIMAL DETECTION !! %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%% lendingcost
    lend_costd = abs(mean(simc(:,3))).*r_lend;

    %%% water use at baseline
    wwd = mean(simc(:,1));
    wwr = mean((p1+p2.*simc(:,1)).*simc(:,1));

    %%% delinquency cost
    del_costd = (1/prob_caught).*wwr.*dc_prob;

    %%% visit cost
    simc_pre = [0 0 0 0 0;  simc(1:(size(simc,1)-1),:)];
    visit_costd=visit_price.*(size(simc(simc_pre(:,3)<0 & simc(:,5)>2,:),1)/size(simc,1));

    %size(simc(simc(:,3)<0 & simc(:,5)>2,:),1)
    %w_reg_dk(0,res_out(7),0,p1,p2, y_avg );

                    %%% revenue coming in %%%
    rev_goald = ((p1 - marginal_cost + p2.*wwd).*wwd) - (lend_costd + del_costd  + visit_costd)      ;


    Cgridd = (.02:.08:1)' ;
    Pgridd = (-1:.5:10)' ;

    Rd = zeros(size(Pgridd,1),size(Cgridd,1));
    Ud = zeros(size(Pgridd,1),size(Cgridd,1));


    for i=1:size(Pgridd,1)
        for j=1:size(Cgridd,1)

            p1nd = p1+Pgridd(i); % new price
            prob_caught1 = Cgridd(j); % new prob of getting caught
            del_costd1 = (1/prob_caught1).*wwr.*dc_prob; % benefit of not getting caught

            resd = res_out;
            resd(9)=res_out(9) + (del_costd1 - del_costd);
            resd(10)=p1nd;

            prob1 = [(1-prob_caught1).*ones(n_states,n_states/2) (prob_caught1).*ones(n_states,n_states/2)]./(n_states./2);
            s01 = 1;
            [chain1,~] = markov(prob1,n,s01);

            [h1,util1,simc1] = dc_obj(resd,prob1,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain1,s);
            simc_pre1 = [0 0 0 0 0;  simc1(1:(size(simc1,1)-1),:)];
            visit_costd1=visit_price.*(size(simc1(simc_pre1(:,3)<0 & simc1(:,5)>2,:),1)/size(simc1,1));

            wwd1 = mean(simc1(:,1));

            lend_costd1 = abs(mean(simc1(:,3))).*r_lend;

            rev_goal1 = ((p1nd - marginal_cost + p2.*wwd1).*wwd1) - (lend_costd1 + del_costd1  + visit_costd1) ;

            Rd(i,j) = rev_goal1;
            Ud(i,j) = util1;

        end
    end



 [r_min,ind_min]=  min(abs(Rd-rev_goald))
  Ud(ind_min)

 % plot(Cgridd,(Ud(ind_min)-max(Ud(ind_min)))./(max(Ud(ind_min))-min(Ud(ind_min))),Cgridd,r_min./max(r_min))

plot(Cgridd,(Ud(ind_min)-util)/du_dy10)
%}

                    %[~,mom_pred]=m_1loan3_objopt(res,given,data,option,option_moments,weights,prob,A,Aprime,Agrid,inA,minA,nA,chain);
                    %weights_new = inv(mom_pred*mom_pred'); %%% optimal weighting matrix runs fine
                    %obj_new = @(a1)m_1loan3_objopt(a1,given,data,option,option_moments,weights_new,prob,A,Aprime,Agrid,inA,minA,nA,chain);
                    %res_new = fminunc(obj_new,res)


% % % if second_output == 1
% % %
% % % %%% set theta high, adjust gamma to hit VAR and alpha to hit MEAN, then look for R to hit
% % %
% % %     data = data_moments;
% % %
% % %     %S = [ .04  ]; %  .04  .06
% % %     S = [ 0 .01 .02 .03  ]
% % %     %S = [ 0  .03  .05 ];
% % %     H = zeros(size(data,1),size(S,2));
% % %     U = zeros(1,size(S,2));
% % %     tic
% % %     for ss = 1:size(S,2)
% % %         given(3) = S(ss);
% % %         [h,US] =  dc_obj_chow(given,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven);
% % %         H(:,ss)=h;
% % %         U(1,ss)=US;
% % %     end
% % %     toc
% % %
% % %
% % %     R = [S;H];
% % %
% % %     om = [ 1 3   6 7 8 9   10 11 12 13    ];  %%% moments to use!
% % %     om = [ 1 3   6 7 8 9   10 11 12 13    ];  %%% moments to use!
% % %
% % %     round(R(om+1,:),2)
% % %     round([data_moments(om)],2)
% % % end

