

clear
rng(1)

folder ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp_pay/moments/';
cd_dir ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_codes_pay/paper/tables/';


real_data     = 1     ;
second_output = 0     ;
pick_sv       = 0     ;
short_est     = 0     ;
full_est      = 0     ;
est_many      = 0     ;
est_tables    = 0     ;
counter       = 0     ;

bs            = 0 ; % bootstrap option
br       = [1 10] ; % rep interval
br_est   = [1 10] ;
int_size = 1; % number of interpolations
Fset     = 2;     % number of Chow iterations
refinement =1 ; % refine the number of stuff
prob_caught_sim = 0 ;

one_price       = 0 ;

marginal_cost = 5;
ppinst = 51;
        
s=155; % sets account length

mult_set = [  1  ];


%%%% is it sensitive to theta?    previously 25, 25 (7 takes 1608 (28*28*2=1568)) (8 takes 3702 (32*32*2=4096))

n = 10000; 
nA = 30 %%%  3,3: 572s  5,5: 176s (46it, 319fun)  7,7: 350s (84it, 555fun)   
nB = 30 %%%  8,8: 500s (136it, 859fun)  10,10: 660s (164it, 1009fun)  14,14: 369s (70it, 454fun)  20, 20:  1180s (104it, 656fun)

sigA = 0;
sigB = 0;
nD   = 2;

%%%%%%%%% ESTIMATION %%%%%%%%%%

inc_t  = 2;  %%% which inc to estimate1
 
option = [ 3 5 7 12 ];   %%% what to estimate

% option = [ 3 7 12 ];   %%% what to estimate
   
    
    
option_moments       = [ 1 2 3 4 ];  %%% moments to use!
% option_moments     = [ 1       ];
option_moments_est   = [ 1 2 3 4 ];
% option_moments_est = [ 1       ];



    visit_price = 200;
    erate = 45;
    popadj = 2.4*12;
    
[c_avg,c_std,bal_avg,bal_med,bal_std,bal_corr,...
    am1,am2,am3,am4,...
    amar1,amar2,amar3,amar4,...
    y_avg,Aub,Alb,Blb,...
    p1,p2,prob_caught,...
    delinquency_cost,r_lend,dc_prob] ...
        = import_to_matlab_t3(folder,one_price);
    
% data_moments = [  c_avg; c_std; bal_avg; bal_std; bal_corr; am1; am2; am3; am4; amar1; amar2; amar3; amar4 ];
data_moments = [ c_avg; bal_avg; (am1+am2)./2 ; (amar1+amar2)./2]  ;
% data_moments = [ c_avg; bal_med; (am1+am2)./2 ; (amar1+amar2)./2]  ;


n_states=4;
prob = [(1-prob_caught).*ones(n_states,n_states/2) (prob_caught).*ones(n_states,n_states/2)]./(n_states./2); 
s0 = 1;  
[chain,state] = markov(prob,n,s0);

format long g

    % given :  r_lend , r_water, r_high ,  lambda (U) ,   theta (y), gamma (a), alpha , beta_up , Y , p1, p2 ,pd,  n , metric, waterlend,
           %    1         2       3         4         5           6         7        8       9    10  11  12       %    
%given=       [ r_lend    0      .03         0        0.28        0      .026      .02     y_avg p1  p2  170   n   10  0 ];

%given=       [ r_lend    0      .02         0        0.28        0      .026      .01     y_avg p1  p2  170   n   10  0 ];
% \given=     [ r_lend    0      .02         0        0.35        0      .026      .015     y_avg p1(1)  p2(1)  170   n   10  0 ];

given=       [  r_lend    0      .02        0         0.3        0      .037     .015     y_avg(1)  p1(1)  p2(1)  170   n   10  0; ...
                r_lend    0      .02        0         0.3        0      .029     .015     y_avg(2)  p1(1)  p2(1)  150   n   10  0; ...
                r_lend    0      .02        0         0.3        0      .017     .015     y_avg(3)  p1(1)  p2(1)  170   n   10  0 ];


if real_data == 1
            data = data_moments(option_moments,:); % need to transpose here
else
            data = h(option_moments,:);
end
           
% given = given(inc_t,:)
% Alb = Alb(inc_t)
% Aub = Aub(inc_t)
% Blb = Blb(inc_t)

tic
[est_mom,~,~,~,~,A1,B1]=dc_obj_chow_pol_finite(given(inc_t,:),prob,nA,sigA,Alb(inc_t),Aub(inc_t),nB,sigB,Blb(inc_t),nD,chain,s,int_size,refinement);
toc

round(est_mom(option_moments_est),2)
round(data(option_moments,inc_t),2)




    if short_est==1
        weights =  eye(size(data(:,inc_t),1))./(data(:,inc_t).^2) ;   % normalize moments to be between zero and one (matters quite a bit)
        ag = given(inc_t,option);    
        obj = @(a1)dc_objopt_chow_finite(a1,given(inc_t,:),data(:,inc_t),option,option_moments_est,weights,prob,nA,sigA,Alb(inc_t),Aub(inc_t),nB,sigB,Blb(inc_t),nD,chain,s,int_size,refinement);
                    disp ' old obj: ' 
                    obj(ag)
                    disp ' '
                    disp 'pattern search ... '
                    tic
                    [res,fval,~,Output] = patternsearch(obj,ag)
                    fprintf('The number of iterations was : %d\n', Output.iterations);
                    fprintf('The number of function evaluations was : %d\n', Output.funccount);
                    toc
                    [~,~,est_mom]=obj(res);
                    disp   '   truth               estimates   ' 
                    [ round(data(:,inc_t),2)  round(est_mom,2) ]
                    disp ' psearch done ! :)'
    end
   
   
    
    if full_est==1
        for i =1:3
            weights =  eye(size(data(:,i),1))./(data(:,i).^2) ;   % normalize moments to be between zero and one (matters quite a bit)
            ag = given(i,option);    
            obj = @(a1)dc_objopt_chow_finite(a1,given(i,:),data(:,i),option,option_moments_est,weights,prob,nA,sigA,Alb(i),Aub(i),nB,sigB,Blb(i),nD,chain,s,int_size,refinement);

                        disp ' old obj: ' 
                        obj(ag)
                        disp ' '
                        disp 'pattern search ... '
                        tic
                        [res,fval,~,Output] = patternsearch(obj,ag)
                        fprintf('The number of iterations was : %d\n', Output.iterations);
                        fprintf('The number of function evaluations was : %d\n', Output.funccount);
                        toc
                        [~,~,est_mom]=obj(res);
                        disp   '   truth               estimates   ' 
                        [ round(data(:,inc_t),2)  round(est_mom,2) ]
                        disp ' psearch done ! :)'
                        
            csvwrite(strcat(folder,'estimates_t',string(i),'.csv'),res)
        end
    end
   
    
    
    
    
    
    
    
    

%{a


%%%% Do more with the fit, especially at the end of the series!

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
    estimates = [csvread(strcat(folder,'estimates_t1.csv')); ...
                 csvread(strcat(folder,'estimates_t2.csv')); ...
                 csvread(strcat(folder,'estimates_t3.csv'))];
    
    res_out = given;
    res_out(:,option)=estimates;

    %%% current
    [h,util, h_t1,h_t2,h_t3, simc_t1,simc_t2,simc_t3]           =run3(res_out,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement);
   
%     c_h = h(1) ;
    
    %%% value of 10 PhP
    res_poor = res_out;
    res_poor(:,9) = res_out(:,9) - 10;

    [h_poor,util_poor] =run3(res_poor,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement);
    
    du_dy10 = (mean(util)-mean(util_poor))/10;    
    du_dy10_t = (util-util_poor)/10;    
    
    
    %%% utility loss from no loans
    res_nl = res_out;
	res_nl(:,2) = .8;
    [h_nl,util_nl, h_nl_t1,h_nl_t2,h_nl_t3, simc_nl_t1,simc_nl_t2,simc_nl_t3] =run3(res_nl,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement);
    
    U_nl = (mean(util_nl)-mean(util))/du_dy10
    U_nl_t = (util_nl-util)./du_dy10_t
%     c_nl = h_nl(1);
    
    

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% OPP COST APPROACH   %%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
    %%% lendingcost
    lend_cost        =  mean([mean(abs(simc_t1(:,3))) ...
                              mean(abs(simc_t2(:,3))) ...
                              mean(abs(simc_t3(:,3)))]).*r_lend;
    
    delinquency_cost =  mean([mean(abs(simc_t1(simc_t1(:,6)==s,3))) ...
                              mean(abs(simc_t2(simc_t2(:,6)==s,3))) ...
                              mean(abs(simc_t3(simc_t3(:,6)==s,3)))])./s ;
    
    wwr = mean(mean([(p1 - marginal_cost + p2.*simc_t1(:,1)).*simc_t1(:,1) ...
                     (p1 - marginal_cost + p2.*simc_t2(:,1)).*simc_t2(:,1) ...
                     (p1 - marginal_cost + p2.*simc_t3(:,1)).*simc_t3(:,1) ]));
    
    visit_cost =mean([  visit_price.*(size(simc_t1([0 ;  simc_t1(1:(size(simc_t1,1)-1),3)]<0 & simc_t1(:,5)>2,1),1)/size(simc_t1,1)) ...
                        visit_price.*(size(simc_t2([0 ;  simc_t2(1:(size(simc_t2,1)-1),3)]<0 & simc_t2(:,5)>2,1),1)/size(simc_t2,1)) ...
                        visit_price.*(size(simc_t3([0 ;  simc_t3(1:(size(simc_t3,1)-1),3)]<0 & simc_t3(:,5)>2,1),1)/size(simc_t3,1)) ]) ;
    
    res_nle = res_out;
	res_nle(:,2) = .8;
    
    rev_goale = wwr - (lend_cost + delinquency_cost + visit_cost ) ;
    
    Pgride = (0:.01:.1)' ;
    Re = zeros(size(Pgride,1),1);
    rev_new = zeros(size(Pgride,1),1);
    
    for i=1:size(Pgride,1)
        p1ne = p1+Pgride(i);
        res_nle_temp=res_nle;
        res_nle_temp(:,10) = p1ne;
        
        [~,~, ~,~,~, simc_nle_t1,simc_nle_t2,simc_nle_t3] =run3(res_nle_temp,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement);
    
         wwr_nle = mean(mean([(p1ne - marginal_cost + p2.*simc_nle_t1(:,1)).*simc_nle_t1(:,1) ...
                              (p1ne - marginal_cost + p2.*simc_nle_t2(:,1)).*simc_nle_t2(:,1) ...
                              (p1ne - marginal_cost + p2.*simc_nle_t3(:,1)).*simc_nle_t3(:,1) ]));

        rev_nle = wwr_nle ;
        Re(i,1) = abs(rev_nle - rev_goale);
        rev_new(i,1)=rev_nle;
    end
    
    plot(Pgride,Re);
    [~,inde]=min(Re);
    Pgride(inde)
  
    p1ce=p1+Pgride(inde);
   
    res_ppe =res_nle;
    res_ppe(:,10) = p1ce;
   
    [h_ppe,util_ppe] =run3(res_ppe,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement);
    
    U_ppe_t = (util_ppe-util)./du_dy10_t
    U_ppe = (mean(util_ppe) -mean(util))./du_dy10
%     c_ppe = h_ppe(1);
    
    
    
    %%% %%% pre-paid %%% %%% 
    %%% current revenue
    
%     rev_goal = wwr - delinquency_cost + ppinst - coste - visit_costd;
    
    res_pp_start = res_out;
	res_pp_start(:,2) = .8;
    res_pp_start(:,9) = res_out(:,9) - delinquency_cost;
    
    
    Pgrid = (5.5:.2:6.5)' ;
    Rpp = zeros(size(Pgrid,1),1);
    revpp=zeros(size(Pgrid,1),1);
    
    for i=1:size(Pgrid,1)
        p1n = p1+Pgrid(i);
        res_pp_temp=res_pp_start;
        res_pp_temp(:,10) = p1n;
        
        [~,~, ~,~,~, simc_pp_t1,simc_pp_t2,simc_pp_t3] =run3(res_pp_temp,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement);
  
        wwr_pp = mean(mean([(p1n - marginal_cost + p2.*simc_pp_t1(:,1)).*simc_pp_t1(:,1) ...
                             (p1n - marginal_cost + p2.*simc_pp_t2(:,1)).*simc_pp_t2(:,1) ...
                             (p1n - marginal_cost + p2.*simc_pp_t3(:,1)).*simc_pp_t3(:,1) ]));

        rev_pp = wwr_pp - ( ppinst );
        Rpp(i,1) = abs(rev_pp - rev_goale);
        revpp(i,1) = rev_pp;
    end
    plot(Pgrid,Rpp);
    [~,ind]=min(Rpp);
    Pgrid(ind)
    
    p1c=p1+Pgrid(ind);
    
    res_pp=res_pp_start; % with pre-paid meters, don't get delinquency or loan, but get lower marginal price!
    res_pp(:,10)=p1c;
    
    [h_pp,util_pp] =run3(res_pp,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement);
    
    U_pp_t = (util_pp-util)./du_dy10_t
    U_pp = (mean(util_pp)-mean(util))/mean(du_dy10)

    %     c_pp = h_pp(1);
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




    
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ALL OLD STUFF  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ALL OLD STUFF 
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ALL OLD STUFF  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ALL OLD STUFF 
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ALL OLD STUFF  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ALL OLD STUFF 
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ALL OLD STUFF  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ALL OLD STUFF 
%      
% if pick_sv == 1
% 
% 
% %     S = [.003     .005   .01; ...
% %          0.2    0.2   0.2; ...
% %         0.025     .025    .025; ...
% %         150     150    150  ]';
%     
%     S = [.01     .0101   .012 ; ...
%          0.2    0.2   0.2; ...
%         .025     .025    .025; ...
%         170     170    170  ]';
%     
%     if real_data == 1
%         data = data_moments(option_moments,:); % need to transpose here
%     else
%         data = h(option_moments,:);
%     end
% 
%     weights =  eye(size(data(:),1))./(data(:).^2) ;   % normalize moments to be between zero and one (matters quite a bit)
%     ag = given(1,option);    
%     obj = @(a1)dc_objopt_chow(a1,given,data,option,option_moments,weights,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven);
%     
%     H = zeros(size(data,1),size(S,1));
%     U = zeros(1,size(S,1));
%     tic
%     for ss = 1:size(S,1)
%         a = S(ss,:);
%         [US] =  obj(a);
%         given1 = given;
%         given1(option)=a;
%         [h] =  dc_obj_chow(given1,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven);
%         H(:,ss)=h(option_moments);
%         U(1,ss)=US;
%     end
%     toc
%     
%     R = [H;U];
%     S'
%     round(R,2)
%     round([data_moments(option_moments)],2)
% end





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



% OLD EST MANY !! 
% 
%     if est_many == 1
%     
%     if real_data == 1
%         data = data_moments(option_moments,:); % need to transpose here
%     else
%         data = h(option_moments,:);
%     end
% 
%     weights =  eye(size(data(:),1))./(data(:).^2) ;   % normalize moments to be between zero and one (matters quite a bit)
%     ag = given(:,option);    
%     obj = @(a1)dc_objopt_inc_finite(a1,given,data,option,option_moments,weights,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement);
% 
%     
% 
%             %%% run mamy starting values! %%%
%         R = zeros(size(mult_set,2),size(option,2));
%         OBJ_VAL = zeros(size(mult_set,2),1);
%         OUTPUT = zeros(size(mult_set,2),size(data_moments,2));
%             for k = 1:size(mult_set,2)
%                 ag
%                 mult_set(k).*ag
% 
%                 disp ' old obj: ' 
%                 obj(ag)
%                 disp ' '
%                 disp 'pattern search ... '
%                 tic
%                 [res,fval,~,Output] = patternsearch(obj,mult_set(k).*ag)
%                 fprintf('The number of iterations was : %d\n', Output.iterations);
%                 fprintf('The number of function evaluations was : %d\n', Output.funccount);
%                 toc
%                 [~,~,est_mom]=obj(res);
%                 round(est_mom,2)
%                 disp ' psearch done ! :)'
%                 round(data,2)
%                 res_new = res;          
%                 R(k,:) = res_new;
%                 OBJ_VAL(k,:) = obj(res_new);
% 
%             end
% 
% %         mult_set'.*ag
% %         R
% %         OBJ_VAL
% % 
% %         [OUTPUT' data_moments']
% 
%         [~,ind]=min(OBJ_VAL);
%         estimates = R(ind,:);
% % 
% %       csvwrite(strcat(folder,'estimates.csv'),estimates)
%     end
%     
% 
% 
%     


%%% TESTING GROUNDS 

%         
% given1 = given;
% 
% nA1 = 30;
% nB1 = 30;
% 
% f_int = 5;
% r_int = 5;
% f_s = linspace(0,500,f_int);
% r_s = linspace(.01,.03,r_int);
% 
% mom_s = zeros(f_int*r_int,5);
% 
% h_t = zeros(f_int,r_int);
% 
% data_t = round(data(option_moments,inc_t),1);

% for f = 1:f_int
%     tic
%     for r = 1:r_int
%         
%         given_t = given1(inc_t,:);
%         given_t(12) = f_s(f);
%         given_t(3) = r_s(r);
%         
%         [est_mom]=dc_obj_chow_pol_finite(given_t(inc_t,:),prob,nA1,sigA,Alb(inc_t),Aub(inc_t),nB1,sigB,Blb(inc_t),nD,chain,s,int_size,refinement);
%     
%         h_t(f,r)=sum((round(est_mom(option_moments_est),1) - data_t).^2./(data_t));
%     end
%     toc
% end
% 
% surf(h_t)