

clear
rng(1)

folder ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp_pay/moments/';
cd_dir ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_codes_pay/paper/tables/';


real_data     = 1     ;
second_output = 0     ;
pick_sv       = 0     ;
short_est     = 1     ;
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
        
s=1; % 1 adds amar moments

mult_set = [  1  ];


%%%% is it sensitive to theta?    previously 25, 25 (7 takes 1608 (28*28*2=1568)) (8 takes 3702 (32*32*2=4096))

n = 10000; 
nA = 20 %%%  3,3: 572s  5,5: 176s (46it, 319fun)  7,7: 350s (84it, 555fun)   
nB = 20 %%%  8,8: 500s (136it, 859fun)  10,10: 660s (164it, 1009fun)  14,14: 369s (70it, 454fun)  20, 20:  1180s (104it, 656fun)

sigA = 0;
sigB = 0;
nD   = 2;

%%%%%%%%% ESTIMATION %%%%%%%%%%

 inc_t = 3;  %%% which inc to estimate1
 
option = [ 3 5 7 12 ];   %%% what to estimate

% option = [ 3 7 12 ];   %%% what to estimate
   
    
    
option_moments  = [ 1 2 3 4 ];  %%% moments to use!

% option_moments  = [ 1  ];  %%% moments to use!

option_moments_est = [1 3 6 10];

% option_moments_est = [1 ];



    visit_price = 200;
    erate = 45;
    popadj = 2.4*12;
    
[c_avg,c_std,bal_avg,bal_std,bal_corr,...
    am1,am2,am3,am4,...
    amar1,amar2,amar3,amar4,...
    y_avg,Aub,Alb,Blb,...
    p1,p2,prob_caught,...
    delinquency_cost,r_lend,dc_prob] ...
        = import_to_matlab_t3(folder,one_price);
    
% data_moments = [  c_avg; c_std; bal_avg; bal_std; bal_corr; am1; am2; am3; am4; amar1; amar2; amar3; amar4 ];
data_moments = [ c_avg; bal_avg; (am1+am2)./2 ; (amar1+amar2)./2]  ;

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

given=       [  r_lend    0      .02        0         0.39        0      .037      .015     y_avg(1)  p1(1)  p2(1)  100   n   10  0; ...
                r_lend    0      .02        0         0.39        0      .029     .015     y_avg(2)  p1(1)  p2(1)  100   n   10  0; ...
                r_lend    0      .02        0         0.39        0      .02      .015     y_avg(3)  p1(1)  p2(1)  100   n   10  0 ];


if real_data == 1
            data = data_moments(option_moments,:); % need to transpose here
else
            data = h(option_moments,:);
end
            


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


tic
[est_mom,~,~,~,~,A1,B1]=dc_obj_chow_pol_finite(given(inc_t,:),prob,nA,sigA,Alb(inc_t),Aub(inc_t),nB,sigB,Blb(inc_t),nD,chain,s,int_size,refinement);
toc

round(est_mom(option_moments_est),1)
round(data(option_moments,inc_t),1)
% 






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
   
    
    
    
    
    
    if est_many == 1
    
    if real_data == 1
        data = data_moments(option_moments,:); % need to transpose here
    else
        data = h(option_moments,:);
    end

    weights =  eye(size(data(:),1))./(data(:).^2) ;   % normalize moments to be between zero and one (matters quite a bit)
    ag = given(:,option);    
    obj = @(a1)dc_objopt_inc_finite(a1,given,data,option,option_moments,weights,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement);

    

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

        [~,ind]=min(OBJ_VAL);
        estimates = R(ind,:);
% 
%       csvwrite(strcat(folder,'estimates.csv'),estimates)
    end
    


    
    
    
    
    
    
    
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ALL OLD STUFF  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ALL OLD STUFF 
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ALL OLD STUFF  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ALL OLD STUFF 
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ALL OLD STUFF  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ALL OLD STUFF 
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ALL OLD STUFF  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ALL OLD STUFF 
     
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
        data = data_moments(option_moments,:); % need to transpose here
    else
        data = h(option_moments,:);
    end

    weights =  eye(size(data(:),1))./(data(:).^2) ;   % normalize moments to be between zero and one (matters quite a bit)
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

