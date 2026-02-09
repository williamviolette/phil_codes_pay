
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
data_moments = [ c_avg c_std bal_avg bal_std bal_corr ];

p_avg     = csvread(strcat(folder,'p_avg.csv'));
y_avg     = csvread(strcat(folder,'y_avg.csv'));
prob_caught = csvread(strcat(folder,'prob_caught.csv'));
delinquency_cost = csvread(strcat(folder,'delinquency_cost.csv'));

n = 10000; 

minA =  -20000;                     % minimum value of the asset grid
maxA =  50000;                     % maximum value of the asset grid   
inA  =  200;                     % size of asset grid increments

nA   = round((maxA-minA)/inA+1);   % number of grid points
Agrid = [ minA:inA:maxA ]';
Aprime = repmat(Agrid,1,nA);
A = repmat(Agrid,1,nA)';
%prob_caught = .02 ;
prob   = [ (1-prob_caught) (1-prob_caught) prob_caught prob_caught; 
           (1-prob_caught) (1-prob_caught) prob_caught prob_caught;
           (1-prob_caught) (1-prob_caught) prob_caught prob_caught;
           (1-prob_caught) (1-prob_caught) prob_caught prob_caught]./2 ;   % prob(i,j) = probability (Y(t+1)=Yj | Y(t) = Yi)
s0 = 1;  
[chain,state] = markov(prob,n,s0);
       
% given :  r_low , r_high , lambda , alpha , beta_up , Y , p , n , metric,m
        %    1        2        3       4        5      6   7   8     9 10
%given   =   [ 0     .1        .4    .03     .15    y_avg   p_avg  n  10  3 ];
given   =   [ 0     .04        .6    .03     .01    y_avg   p_avg  n  10  3 0];
mult    = 1; %%% multiplier on the starting values


option = [ 2 3 4 ];

h = m_1loan3_lend2_obj(given,prob,A,Aprime,Agrid,inA,minA,nA,chain);







k = 5;
option_moments = (1:k) ;

if real_data == 1
    data = data_moments(option_moments)'; % need to transpose here
else
    data = h(option_moments);
end

weights =        eye(k)./(data.^2) ;   % normalize moments to be between zero and one (matters quite a bit)

ag = given(1,option);    
obj = @(a1)m_1loan3_objopt(a1,given,data,option,option_moments,weights,prob,A,Aprime,Agrid,inA,minA,nA,chain);


if est == 1
    if est_many == 1
        %%% run mamy starting values! %%%
    R = zeros(size(mult_set,2),size(option,2));
    OBJ_VAL = zeros(size(mult_set,2),1);
        for k = 1:size(mult_set,2)
            ag
            mult_set(k).*ag
            res = fminsearch(obj,mult_set(k).*ag)

            [~,mom_pred]=m_1loan3_objopt(res,given,data,option,option_moments,weights,prob,A,Aprime,Agrid,inA,minA,nA,chain);
            weights_new = inv(mom_pred*mom_pred'); %%% optimal weighting matrix runs fine

            obj_new = @(a1)m_1loan3_objopt(a1,given,data,option,option_moments,weights_new,prob,A,Aprime,Agrid,inA,minA,nA,chain);
            res_new = fminunc(obj_new,res)

            res_out = given
            res_out(option) = res_new
            output1 = m_1loan3_obj(res_out,prob,A,Aprime,Agrid,inA,minA,nA,chain)
            R(k,:) = res_new;
            OBJ_VAL(k,:) = obj_new(res_new);
        end
    else
        ag
        mult.*ag
        res = fminsearch(obj,mult.*ag)

        [~,mom_pred]=m_1loan3_objopt(res,given,data,option,option_moments,weights,prob,A,Aprime,Agrid,inA,minA,nA,chain);
        weights_new = inv(mom_pred*mom_pred'); %%% optimal weighting matrix runs fine

        obj_new = @(a1)m_1loan3_objopt(a1,given,data,option,option_moments,weights_new,prob,A,Aprime,Agrid,inA,minA,nA,chain);
        res_new = fminunc(obj_new,res)

        res_out = given
        res_out(option) = res_new
        output1 = m_1loan3_obj(res_out,prob,A,Aprime,Agrid,inA,minA,nA,chain)
        csvwrite(strcat(folder,'estimates.csv'),res_out)
    end
else
    res_out = csvread(strcat(folder,'estimates.csv'));
end

mult_set'.*ag
R
OBJ_VAL


if counter==1

    %[h,util] = m_1loan3_obj(res_out,prob,A,Aprime,Agrid,inA,minA,nA,chain)

    res_counter = res_out;
    res_counter(1) = res_out(2);

    [~,util] = m_1loan3_obj(res_out,prob,A,Aprime,Agrid,inA,minA,nA,chain)

    [~,util_counter] = m_1loan3_obj(res_counter,prob,A,Aprime,Agrid,inA,minA,nA,chain)

    Ys = 2;
    Ywindow = 200;
    Ygrid = ((res_out(6)-Ywindow):Ys:(res_out(6)))' ;
    U = zeros(size(Ygrid,1),1);

    for i=1:size(Ygrid,1)
       res_temp = res_out;
       res_temp(6) = Ygrid(i);
       [~,util_temp] = m_1loan3_obj(res_temp,prob,A,Aprime,Agrid,inA,minA,nA,chain);
       U(i,1) = abs(util_temp - util_counter);
    end

    plot(Ygrid,U)
    [~,ind]=min(U)
    Ygrid(ind)
    
end

%%%% 92 PhP
%%% cost of providing: 600 * 4% interest rate on bond market = 24 PhP
%%% default rate * cost per default  = 20.8 PhP  


%%%%%% then take into account the regulatory framework!





% plot(1:size(h(end-8:end),1),h(end-8:end))



