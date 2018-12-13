

clear
rng(1)

folder ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp_pay/moments/';


real_data = 1;
est       = 1;
est_many  = 1;
counter   = 0;

mult_set = [ .5 .8 .9 1 1.1 1.2 1.5 ];

%%% import key stats
c_avg     = csvread(strcat(folder,'c_avg.csv'));
c_std     = csvread(strcat(folder,'c_std.csv'));
bal_avg   = csvread(strcat(folder,'bal_avg.csv'));
bal_std   = csvread(strcat(folder,'bal_std.csv'));
bal_corr  = csvread(strcat(folder,'bal_corr.csv'));
c_avg_pre  = csvread(strcat(folder,'c_avg_pre.csv'));
c_avg_dc  = csvread(strcat(folder,'c_avg_dc.csv'));

data_moments = [ c_avg c_std bal_avg bal_std bal_corr c_avg_pre c_avg_dc ];

p1        = csvread(strcat(folder,'p_int.csv'));
p2        = csvread(strcat(folder,'p_slope.csv'));
p_avg     = csvread(strcat(folder,'p_avg.csv'));
y_avg     = csvread(strcat(folder,'y_avg.csv'));
prob_caught = csvread(strcat(folder,'prob_caught.csv'));
delinquency_cost = csvread(strcat(folder,'delinquency_cost.csv'));
r_lend    = csvread(strcat(folder,'irate.csv'))./12 ; %%% convert to monthly here!


n = 10000;

minA =  -20000;                     % minimum value of the asset grid
maxA =  50000;                     % maximum value of the asset grid   
inA  =  1000;                    % size of asset grid increments

minB =  -8000;                 % minimum value of the asset grid
maxB =  0;                     % maximum value of the asset grid   
inB  =  250;                   % size of asset grid increments


nA   = round((maxA-minA)/inA+1);   % number of grid points
Agrid = [ minA:inA:maxA ]';
Aprime_r = repmat(Agrid,1,nA);
A_r = repmat(Agrid,1,nA)';

nB  = round((maxB-minB)/inB+1);   % number of grid pointsB
Bgrid = [ minB:inB:maxB ]';
Bprime_r = repmat(Bgrid,1,nB);
B_r = repmat(Bgrid,1,nB)';

A      = repelem(A_r,nB,nB);
Aprime = repelem(Aprime_r,nB,nB);
B      = repmat(B_r,nA,nA);
Bprime = repmat(Bprime_r,nA,nA);

%prob_caught = .01 ;

n_states=4;
prob = kron([ (1-prob_caught) prob_caught ]./n_states,ones(n_states));

s0 = 1;  
[chain,state] = markov(prob,n,s0);

 

%alpha = (p_avg*c_avg)/y_avg ;
       

% given :  r_lend , r_water, r_high , lambda , alpha , beta_up , Y , p1, p2 ,  n , metric, waterlend,
        %    1        2          3       4         5     6   7   8     9 10
given   =   [ r_lend   0    .04         .6    .024    .02  y_avg p1 p2 n   10  0 ];
mult    = 1; %%% multiplier on the starting values

option_moments = [ 7 ];
option = [ 3 ];

% h = d_obj(given,prob,A,Aprime,nA,B,Bprime,nB,chain);

    data = data_moments'; % need to transpose here
    weights =  eye(size(option_moments,2))./(data(option_moments).^2) ;   % normalize moments to be between zero and one (matters quite a bit)

given1   =   [ r_lend   0    .04     .6    .021    .02  y_avg p1 p2  n   10  0 ];
S = [-.05 0 .025 .05 .075 .1 .125 .15  ];
S = [-.05 0 .05 .1 .15  ];

H = zeros(7,size(S,2));
U = zeros(1,size(S,2));
for s = 1:size(S,2)
    given1(3) = S(s);
    [h,US] = d_obj(given1,prob,A,Aprime,nA,B,Bprime,nB,chain);
    H(:,s)=h;
    U(1,s)=US;
end

S 
H
data




%{

ag = given(1,option);  
obj = @(a1)d_objopt(a1,given,data,option,option_moments,weights,prob,A,Aprime,nA,B,Bprime,nB,chain);

rs=0:.01:.2;
H=zeros(size(rs,2),1);
M=zeros(size(rs,2),size(option_moments,2));

for r=1:size(rs,2)
    aj = rs(r);
    [ht,mt] = obj(aj);
    H(r,1) = ht;
    M(r,:) = mt;
end

plot(rs,H)

%}




%%% higher interest rate means over consumption to use AS CREDIT!

%%% utility declines (thank god)

% 
% 
% 
% 
% 
% k = 5;
% option_moments = (1:k) ;
% 
% if real_data == 1
%     data = data_moments(option_moments)'; % need to transpose here
% else
%     data = h(option_moments);
% end
% 
% weights =        eye(k)./(data.^2) ;   % normalize moments to be between zero and one (matters quite a bit)
% 
% ag = given(1,option);    
% obj = @(a1)con_objopt(a1,given,data,option,option_moments,weights,prob,A,Aprime,Agrid,inA,minA,nA,chain);
% 
% 
% if est == 1
%     if est_many == 1
%         %%% run mamy starting values! %%%
%     R = zeros(size(mult_set,2),size(option,2));
%     OBJ_VAL = zeros(size(mult_set,2),1);
%         for k = 1:size(mult_set,2)
%             ag
%             mult_set(k).*ag
%             res = fminsearch(obj,mult_set(k).*ag)
% 
%             [~,mom_pred]=m_1loan3_objopt(res,given,data,option,option_moments,weights,prob,A,Aprime,Agrid,inA,minA,nA,chain);
%             weights_new = inv(mom_pred*mom_pred'); %%% optimal weighting matrix runs fine
% 
%             obj_new = @(a1)m_1loan3_objopt(a1,given,data,option,option_moments,weights_new,prob,A,Aprime,Agrid,inA,minA,nA,chain);
%             res_new = fminunc(obj_new,res)
% 
%             res_out = given
%             res_out(option) = res_new
%             output1 = m_1loan3_obj(res_out,prob,A,Aprime,Agrid,inA,minA,nA,chain)
%             R(k,:) = res_new;
%             OBJ_VAL(k,:) = obj_new(res_new);
%         end
%     else
%         ag
%         mult.*ag
%         res = fminsearch(obj,mult.*ag)
% 
%         [~,mom_pred]=m_1loan3_objopt(res,given,data,option,option_moments,weights,prob,A,Aprime,Agrid,inA,minA,nA,chain);
%         weights_new = inv(mom_pred*mom_pred'); %%% optimal weighting matrix runs fine
% 
%         obj_new = @(a1)m_1loan3_objopt(a1,given,data,option,option_moments,weights_new,prob,A,Aprime,Agrid,inA,minA,nA,chain);
%         res_new = fminunc(obj_new,res)
% 
%         res_out = given
%         res_out(option) = res_new
%         output1 = m_1loan3_obj(res_out,prob,A,Aprime,Agrid,inA,minA,nA,chain)
%         csvwrite(strcat(folder,'estimates.csv'),res_out)
%     end
% else
%     res_out = csvread(strcat(folder,'estimates.csv'));
% end
% 
% mult_set'.*ag
% R
% OBJ_VAL
% 
% 
% if counter==1
% 
%     %[h,util] = m_1loan3_obj(res_out,prob,A,Aprime,Agrid,inA,minA,nA,chain)
% 
%     res_counter = res_out;
%     res_counter(1) = res_out(2);
% 
%     [~,util] = m_1loan3_obj(res_out,prob,A,Aprime,Agrid,inA,minA,nA,chain)
% 
%     [~,util_counter] = m_1loan3_obj(res_counter,prob,A,Aprime,Agrid,inA,minA,nA,chain)
% 
%     Ys = 2;
%     Ywindow = 200;
%     Ygrid = ((res_out(6)-Ywindow):Ys:(res_out(6)))' ;
%     U = zeros(size(Ygrid,1),1);
% 
%     for i=1:size(Ygrid,1)
%        res_temp = res_out;
%        res_temp(6) = Ygrid(i);
%        [~,util_temp] = m_1loan3_obj(res_temp,prob,A,Aprime,Agrid,inA,minA,nA,chain);
%        U(i,1) = abs(util_temp - util_counter);
%     end
% 
%     plot(Ygrid,U)
%     [~,ind]=min(U)
%     Ygrid(ind)
%     
% end
% 
% %%%% 92 PhP
% %%% cost of providing: 600 * 4% interest rate on bond market = 24 PhP
% %%% default rate * cost per default  = 20.8 PhP  
% 
% 
% %%%%%% then take into account the regulatory framework!
% 
% 
% 
% 
% 
% % plot(1:size(h(end-8:end),1),h(end-8:end))
% 
% 

