

clear
rng(1)

folder ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp_pay/moments/';
cd_dir ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_codes_pay/paper/tables/';


real_data     = 1     ;
second_output = 0     ;
est_many      = 0     ;
est_tables    = 0     ;
counter       = 1     ;


s=1; % 1 adds amar moments

mult_set = [  1  ];

%%% import key stats
c_avg     = csvread(strcat(folder,'c_avg.csv'));
c_std     = csvread(strcat(folder,'c_std.csv'));
bal_avg   = csvread(strcat(folder,'bal_avg.csv'));
bal_std   = csvread(strcat(folder,'bal_std.csv'));
bal_corr  = csvread(strcat(folder,'bal_corr.csv'));
am1       = csvread(strcat(folder,'am1.csv'));
am2       = csvread(strcat(folder,'am2.csv'));
am3       = csvread(strcat(folder,'am3.csv'));
am4       = csvread(strcat(folder,'am4.csv'));
% cm5       = csvread(strcat(folder,'cm5.csv'));  %%

amar1       = csvread(strcat(folder,'amar1.csv'));
amar2       = csvread(strcat(folder,'amar2.csv'));
amar3       = csvread(strcat(folder,'amar3.csv'));
amar4       = csvread(strcat(folder,'amar4.csv'));



data_moments = [  c_avg c_std bal_avg bal_std bal_corr am1 am2 am3 am4 amar1 amar2 amar3 amar4 ];

p1        = csvread(strcat(folder,'p_int.csv'));
p2        = csvread(strcat(folder,'p_slope.csv'));
p_avg     = csvread(strcat(folder,'p_avg.csv'));
y_avg     = csvread(strcat(folder,'y_avg.csv'));
prob_caught = csvread(strcat(folder,'prob_caught.csv'));

prob_caught = .05  %%% HAVE HIGH PROB OF GETTING CAUGHT
delinquency_cost = csvread(strcat(folder,'delinquency_cost.csv'));
r_lend    = csvread(strcat(folder,'irate.csv'))./12 ; %%% convert to monthly here!

%prob_caught=.05;

n = 5000;  %%% GRID SIZE AFFECTS THE MAXIMUM !!!!!!!

nA = 25 ;
sigA = 10000 ;
Agrid = 0 + sqrt(2)*sigA*erfinv(2*((1:nA)'./(nA+1))-1);
Agrid = round(Agrid,0);
%hist(Agrid,100)

nB = 25 ;
sigB = 3800 ;
Bgrid = 0 + sqrt(2)*sigB*erfinv(2*((1:nB)'./(2.*nB+1))-1);
Bgrid =round(sort(-1.*abs(Bgrid),'descend'),0);
Bgrid = [0;Bgrid];
nB=size(Bgrid,1);
%hist(Bgrid,100)

nD = 2;

Aprime_r = repmat(Agrid,1,nA);
A_r = repmat(Agrid,1,nA)';
Bprime_r = repmat(Bgrid,1,nB);
B_r = repmat(Bgrid,1,nB)';

A_r1      = repelem(A_r,nB,nB);
Aprime_r1 = repelem(Aprime_r,nB,nB);
B_r1      = repmat(B_r,nA,nA);
Bprime_r1 = repmat(Bprime_r,nA,nA);

A = repmat(A_r1,nD,nD);
B = repmat(B_r1,nD,nD);
Aprime = repmat(Aprime_r1,nD,nD);
Bprime = repmat(Bprime_r1,nD,nD);

D = [ zeros( size(A_r1,1).*nD , size(A_r1,1) )  ...
      ones( size(A_r1,1).*nD , size(A_r1,1) ) ] ;
Dprime = D';  
  

%%%% set grid right!!



n_states=4;
prob = [(1-prob_caught).*ones(n_states,n_states/2) (prob_caught).*ones(n_states,n_states/2)]./(n_states./2); 

s0 = 1;  
[chain,state] = markov(prob,n,s0);

format long g


pd = 200;
    % given :  r_lend , r_water, r_high ,  lambda (U) ,   theta (y), gamma (a), alpha , beta_up , Y , p1, p2 ,pd,  n , metric, waterlend,
           %    1         2       3         4             5          6         7        8       9    10  11  12       %    
given    =   [ r_lend    0      .04         0            0.2         0       .024      .02     y_avg p1  p2  pd   n   10  0 ];


%oldgiven=   [ r_lend    0      .04         0            0.3         0       .018      .02     y_avg p1  p2  pd   n   10  0 ];

   
  
%{a
if second_output == 1

%%% set theta high, adjust gamma to hit VAR and alpha to hit MEAN, then look for R to hit 
    
    data = data_moments'; % need to transpose here

    %S = [ .04  ];
    S = [ 0 .02  .04  .06  .08 ]
    %S = [ 0  .03  .05 ];
    H = zeros(size(data,1),size(S,2));
    U = zeros(1,size(S,2));
    for ss = 1:size(S,2)
        given(3) = S(ss);
        [h,US] =  dc_obj(given,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s);
        H(:,ss)=h;
        U(1,ss)=US;
    end

    fileID = fopen(strcat(folder,'kcompn_main_','lambda_',num2str(given(4),'%6.2f'), ...
                             '_theta_',num2str(given(5),'%6.2f'), ...
                             '_gamma_',num2str(given(6),'%6.2f'),'.txt'),'w');
    fprintf(fileID,'%10s\n',' ');
    fprintf(fileID,'%30s \n',strcat('lambda: ',num2str(given(4),'%6.2f'), ...
                             '  theta: ',num2str(given(5),'%6.2f'), ...
                             '  gamma: ',num2str(given(6),'%6.2f')));
    R = [S;H];
    fprintf(fileID,[repmat('%6.2f\t', 1, size(R, 2)) '\n'], R');
    fprintf(fileID,'%10s\n',' ');
    fprintf(fileID,'%10s\n',' Data ');
    fprintf(fileID,'%10s\n',' ');
    fprintf(fileID,[repmat('%6.2f\t', 1, size([data], 2)) '\n'], [data]');
    fclose(fileID);
    
    round(R,2)
    round([data],2)
end


%%%%%%%%% ESTIMATION %%%%%%%%%%

option = [ 3   5  7 12 ];   %%% what to estimate
%option_moments = [ 1 2 3 4 6 7 ];
option_moments = [ 1 3   6 7 8 9   10 11 12 13    ];  %%% moments to use!

if real_data == 1
    data = data_moments(option_moments)'; % need to transpose here
else
    data = h(option_moments);
end

weights =  eye(size(option_moments,2))./(data.^2) ;   % normalize moments to be between zero and one (matters quite a bit)
ag = given(1,option);    
obj = @(a1)dc_objopt(a1,given,data,option,option_moments,weights,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s);
            

if est_many == 1
        %%% run mamy starting values! %%%
    R = zeros(size(mult_set,2),size(option,2));
    OBJ_VAL = zeros(size(mult_set,2),1);
    OUTPUT = zeros(size(mult_set,2),size(data_moments,2));
        for k = 1:size(mult_set,2)
            ag
            mult_set(k).*ag
            res = fminsearch(obj,mult_set(k).*ag)
                %[~,mom_pred]=m_1loan3_objopt(res,given,data,option,option_moments,weights,prob,A,Aprime,Agrid,inA,minA,nA,chain);
                %weights_new = inv(mom_pred*mom_pred'); %%% optimal weighting matrix runs fine
                %obj_new = @(a1)m_1loan3_objopt(a1,given,data,option,option_moments,weights_new,prob,A,Aprime,Agrid,inA,minA,nA,chain);
                %res_new = fminunc(obj_new,res)
            res_new = res;
            
            res_out = given
            res_out(option) = res_new
            output1 =  dc_obj(res_out,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s)
            OUTPUT(k,:) = output1
            R(k,:) = res_new;
            OBJ_VAL(k,:) = obj(res_new);
            
        end
        
    mult_set'.*ag
    R
    OBJ_VAL

    [OUTPUT' data_moments']

    [~,ind]=min(OBJ_VAL);
    estimates = R(ind,:);
    
    csvwrite(strcat(folder,'estimates.csv'),estimates)
end


if est_tables==1
    
    %%% Estimates table
    estimates = csvread(strcat(folder,'estimates.csv'));
    res_out = given;
    res_out(option)=estimates;
    
    [~]=est_print(estimates,cd_dir);
    
    %%% Moments fit
    output = dc_obj(res_out,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s);
    output_data = data_moments';
    [~]=fit_print(output,output_data,cd_dir);
    
    %%% Deaton Figure
    [~,~,sim] = dc_obj(res_out,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s);
    [~] = deaton_print(sim,cd_dir);
end





if counter==1

    %%% pull in estimates
    estimates = csvread(strcat(folder,'estimates.csv'));
    res_out = given;
    res_out(option)=estimates;

    %%% current
    [h,util] = dc_obj(res_out,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s);
    c_h = h(1);
   
    %%% value of 10 PhP
    res_poor = res_out;
    res_poor(9) = res_out(9) - 10;
    [~,util_poor] =dc_obj(res_poor,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s);

    du_dy10 = (util-util_poor)/10;    
    
    %%% utility loss from no loans
    res_nl = res_out;
	res_nl(2) = .8;
    [h_nl,util_nl] = dc_obj(res_nl,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s)    
    
    U_nl = (util_nl-util)/du_dy10
    c_nl = h_nl(1);
    
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

    
    %%% %%% pre-paid %%% %%% 
    %%% current revenue
    %%%%% NOTE!!!! THIS IS AN AVERAGE CONSUMPTION CHANGE!! NOTE!!!!!!
    ww = w_reg_dk(0,res_out(7),0,p1,p2, y_avg );
    
    rev_goal = ((p1 + p2.*ww).*ww) - delinquency_cost;
    
    Pgrid = -1.*(0:.01:10)' ;
    R = zeros(size(Pgrid,1),1);
    for i=1:size(Pgrid,1)
        p1n = p1+Pgrid(i);
        ww = w_reg_dk(0,res_out(7),0,p1n,p2,y_avg);
        rev = (p1n + p2.*ww).*ww;
        R(i,1) = abs(rev - rev_goal);
    end
    %plot(Pgrid,R);
    [~,ind]=min(R);
    Pgrid(ind)
    
    p1c=p1+Pgrid(ind);
    
    res_pp=res_out; % with pre-paid meters, don't get delinquency or loan, but get lower marginal price!
    res_pp(2)=.8;
    res_pp(9)=res_pp(9)-delinquency_cost;
    res_pp(10)=p1c;
    
    [h_pp,util_pp] = dc_obj(res_pp,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s);
    
    U_pp = (util_pp-util)/du_dy10;
    c_pp = h_pp(1);
    
    estimates_c = [0 1 1 ; c_h c_nl c_pp ;  0 U_nl U_pp  ; delinquency_cost delinquency_cost 0;  p1 p1 p1c];
    
    [~] = counter_print(estimates_c,cd_dir);

    %}
end