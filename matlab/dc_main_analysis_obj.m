


clear
rng(1)

folder ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp_pay/moments/';
cd_dir ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_codes_pay/paper/tables/';



real_data      = 1    ;
given_sim      = 1    ;

est_pattern    = 0 ;
results        = 0    ;
boot           = 0    ;
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

ver = 'b';

  %  alpha pd pc 
option = [ 7 12 17 ];   %%% what to estimate
lb = [ 40 10  .01 ];
ub = [ 80 400 .99 ];

option_moments       = [ 1 2 3 4 5  ];  %%% moments to use!
option_moments_est   = [ 1 2 3 4 5  ];

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
Aub =  1.*y_avg ;

%%% annual rate of 5.75%, which implies a monthly interest rate of .0047
r_lend     = .0047 ;
r_high     = .0945 ;

% beta_set = .02508  % 1/((1+beta_set)^(12))
beta_set   = .01
if strcmp(ver,'bhigh')==1
    beta_set = .01
end
if strcmp(ver,'blow')==1
    beta_set = .0025
end
% (1+.01)^(12)-1   % 1/(1+x) = 1/((1+d)^12)

% y_cv=.2

    %             1       2        3         4         5       6      7     8         9      10  11   12   13  14     15    16     17     18      19    20  21                
    % given :  r_lend , r_water, r_high, hasscost, inc shock, untie, alpha, beta_up , Y   ,  p1, p2 , pd,  n, curve, fee,  vhass   pc     pm      Blb   Tg  sp     
given =        [   0     0       r_high      0        y_cv      0      50   beta_set  y_avg  p1  p2   413  n    1     0     0    .042  bal_0_end  Blb   12  .8 ];
if strcmp(ver,'bhigh')==1
    given =    [   0     0       r_high      0        y_cv      0      54   beta_set  y_avg  p1  p2   190  n    1     0     0   .24   bal_0_end Blb   ];
end
if strcmp(ver,'blow')==1
    given =    [   0     0       r_high      0        y_cv      0      55   beta_set  y_avg  p1  p2   150  n    1     0     0   .16   bal_0_end Blb   ];
end


% csvwrite(strcat(folder,'given.csv'),given);
                        
            
if real_data == 1
            data = data_moments(option_moments,:); % need to transpose here
else
            data = h(option_moments,:);
end
   
tic
% [est_mom,ucon,controls,~,~,A1,B1]=obj(given,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
[est_mom,ucon,controls,~,~,A1,B1]=obj_tgr(given,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
toc

disp ' A loan '
sum(controls(:,2)==min(controls(:,2)))
disp ' A savings '
sum(controls(:,2)==max(controls(:,2)))
disp ' B loan '
sum(controls(:,3)==min(controls(:,3)))
disp ' B loan (pre DC)'
sum(controls(controls(:,6)<300,3)==min(controls(controls(:,6)<300,3)))
disp ' B loan (last DC)'
sum(controls(controls(:,6)==s,3)==min(controls(controls(:,6)==s,3)))/sum(controls(:,6)==s)
disp 'B loan 0 (last DC)'
sum(controls(controls(:,6)==s,3)==0)/sum(controls(:,6)==s)
disp ' B loan average '
mean(controls(controls(:,6)==s,3))

disp ' Sim '
round(est_mom(option_moments_est),2)
disp ' Data '
round(data(option_moments),2)
       


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
            X1=rand(n-1,1);
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


    

if results==1
    rb=zeros(br,size(option_moments,2));
    if boot==1
        for i = 1:size(rb,1)
           rb(i,:) =  csvread(strcat(folder,'pattern_estimates_',ver,'_',num2str(i),'.csv'));
        end
    end
    r = csvread(strcat(folder,'pattern_estimates_',ver,'.csv'));

%     j=print_estimates(cd_dir,r,rb,ver);
%     j=fit_print(cd_dir,r,ver,given,option,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
if given_sim==1
    r= given(option);
end
    j=counterfactuals_fixedcost(cd_dir,r,ver,given,option,ppinst,r_lend,visit_price,marginal_cost,p1,p2,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
end






    
    %%%% BALLPARKING REVENUE RAISING MORE %%%%
    
%    jj = -(-alpha + 2*p2*(alpha^2 - 4*R - 4*R*p2)^(1/2) + (alpha^2 - 4*R - 4*R*p2)^(1/2))/(2*(p2 + 1))
%    jj = -(4*R - p1*(alpha^2 + 2*alpha*p1 + p1^2 - 8*R)^(1/2) - alpha^2 + p1^2 + alpha*(alpha^2 + 2*alpha*p1 + p1^2 - 8*R)^(1/2))/(8*R)
%  
%  price=[1:40]';
%  WSE = (55-price)./(p2.*2.0+1.0);
%  REV = WSE.*(price+p2*WSE);
%  
%  plot(price,REV)
%  
%  REV=zeros(size(price,1),size(price,2))

%  price2=.01.*[1:40]'
%  WSE = (55-p1)./(price2.*2.0+1.0)
%  REV = WSE.*(p1+price2.*WSE)
%  plot(price2,REV)
%  wse = (50-20)./(5*2.0+1.0)
    


%     syms p1s p2s as R
%      assume(p1s>0)
%      assume(p2s>0)
%      assume(as>0)
%      assume(R>0)
%      wse = (as-p1s)./(p2s.*2.0+1.0)
%  rr = wse*(p1s+p2s*wse)
%     solve(rr-R,p1s)
% 
%  assume(p1s>0)
%  assume(p2s>0)
%  assume(as>0)
%  assume(R>0)
%  wse = (as-p1s)./(p2s.*2.0+1.0)
%  rr = wse*(p1s+p2s*wse)
%  solve(rr-R,p2s)



%%% SUPER USEFUL GRID TEST THAT DEFINITELY CONFIRMS 50 50 AND EVEN 40 40
% gt = [20:10:60]' ;
% res = zeros(size(gt,1),5)
% for i=1:size(gt,1)
%     nA = gt(i) 
%     nB = gt(i)
%     tic
%     [est_mom,ucon,controls,~,~,A1,B1]=obj(given,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);
%     toc
%     res(i,:)=est_mom';
% end
% res

%         weights =  eye(size(data,1))./(data.^2) ;   % normalize moments to be between zero and one (matters quite a bit)
%         ag = given(option);    
%         obj_run = @(a1)objopt(a1,given,data,option,option_moments_est,weights,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,s,int_size,refinement);
%         obj_run(ag)
                    










% if short_est==1
%         options = optimoptions('surrogateopt','Display','iter','MaxFunctionEvaluations',20,'InitialPoints',given(option));
%         weights =  eye(size(data,1))./(data.^2) ;   % normalize moments to be between zero and one (matters quite a bit)
%         ag = given(option);    
%         obj_run = @(a1)objopt(a1,given,data,option,option_moments_est,weights,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,s,int_size,refinement);
%                     disp ' old obj: ' 
%                     obj_run(ag)
%                     disp ' '
%                     disp 'surrogate opt ... '
%                     tic
%                     [res,fval,~,Output] = surrogateopt(obj_run,lb,ub,options)
%                     toc
%                     [~,~,est_mom]=obj_run(res);
%                     disp   '   truth               estimates   ' 
%                     [ round(data(:,1),2)  round(est_mom,2) ]
%                     disp ' psearch done ! :)'
% end
% 
% 




