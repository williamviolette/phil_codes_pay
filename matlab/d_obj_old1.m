%function    [h,util] = d_obj(given,prob,A,Aprime,Agrid,inA,minA,nA,chain)


%%%%% ADDED IN 
clear
rng(1)

folder ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp_pay/moments/';


mult_set = [ .5 .8 .9 1 1.1 1.2 1.5 ];

p1        = csvread(strcat(folder,'p_int.csv'));
p2        = csvread(strcat(folder,'p_slope.csv'));
p_avg     = csvread(strcat(folder,'p_avg.csv'));
y_avg     = csvread(strcat(folder,'y_avg.csv'));
prob_caught = csvread(strcat(folder,'prob_caught.csv'));
%delinquency_cost = csvread(strcat(folder,'delinquency_cost.csv'));
r_lend    = csvread(strcat(folder,'irate.csv'))./12 ; %%% convert to monthly here!

n = 10000; 

minA =  -20000;                     % minimum value of the asset grid
maxA =  50000;                     % maximum value of the asset grid   
inA  =  5000;                     % size of asset grid increments

minB =  -5000;                     % minimum value of the asset grid
maxB =  0;                     % maximum value of the asset grid   
inB  =  1000;                     % size of asset grid increments


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



prob_caught = .01 ;
prob   = [ (1-prob_caught) (1-prob_caught) prob_caught prob_caught; 
           (1-prob_caught) (1-prob_caught) prob_caught prob_caught;
           (1-prob_caught) (1-prob_caught) prob_caught prob_caught;
           (1-prob_caught) (1-prob_caught) prob_caught prob_caught]./2 ;   % prob(i,j) = probability (Y(t+1)=Yj | Y(t) = Yi)
s0 = 1;  
[chain,state] = markov(prob,n,s0);
  
% given :  r_lend , r_high ,    lambda , alpha ,  beta_up , Y , p1, p2 ,  n , metric,m
        %    1        2            3       4         5       6   7   8     9 10
given   =   [ r_lend     .04        .4    .024    .15    y_avg p1 p2 n   10  3 ];
mult    = 1; %%% multiplier on the starting values


r_u = .1;

r_lend  = given(1,1);
r_high  = given(1,2);
lambda  = given(1,3);
alpha   = given(1,4);
beta_up = given(1,5);
Y       = given(1,6);
p1      = given(1,7);
p2      = given(1,8);
n       = given(1,9);
metric  = given(1,10);
m       = given(1,11);


%function [util1,util2,util3,util4,w1,w2,w3,w4,wd1,wd2,wd3,wd4] = ...
%    u_d(A,Aprime,alpha,p1,p2,r_high,r_lend,Y_high,Y_low,lambda_high,lambda_low,m)


%r_lend = r_high;
% beta = 1/(1 + beta_up + r_high + .01);
beta = 1/( 1 + beta_up );

Y_high = Y ;               % high value for income
Y_low  = Y ;           % low value for income

lambda_high = 1 + lambda ;
lambda_low  = 1 - lambda ;

metric = 10 ;       %%%%%%%% SETTING METRIC HERE !!!!! %%%%%%%%%%
c1 = Y_high + A + B - (Aprime./(1+r_high)) - Bprime.*(Bprime<=2.*B) ;
c2 = Y_low + A + B - (Aprime./(1+r_high)) -  Bprime.*(Bprime<=2.*B) ;
c3 = Y_high + A + B - (Aprime./(1+r_high))  ;
c4 = Y_low + A + B - (Aprime./(1+r_high))  ;

util1 = log( c1 ).*lambda_high;
util2 = log( c2 ).*lambda_low;
util3 = log( c3 ).*lambda_high;
util4 = log( c4 ).*lambda_low;

util1(c1<=0)=-inf;
util2(c2<=0)=-inf;
util3(c3<=0)=-inf;
util4(c4<=0)=-inf;


    
%[util1,util2,util3,util4] = ...
%    u_con(A,Aprime,alpha,p1,p2,r_high,r_lend,Y_high,Y_low,lambda_high,lambda_low,m); 

v       = zeros(nA*nB,4);
decis   = zeros(nA*nB,4);

while metric > 1e-7

  [tv1,tdecis1]=max(util1 + beta.*repmat(v*prob(1,:)',1,nA*nB));
  [tv2,tdecis2]=max(util2 + beta.*repmat(v*prob(2,:)',1,nA*nB));
  [tv3,tdecis3]=max(util3 + beta.*repmat(v*prob(3,:)',1,nA*nB));
  [tv4,tdecis4]=max(util4 + beta.*repmat(v*prob(4,:)',1,nA*nB));
  
  tdecis=[tdecis1' tdecis2' tdecis3' tdecis4'];
  tv=[tv1' tv2' tv3' tv4'];
  
  metric=max(max(abs((tv-v)./tv)));
  v=tv;
  decis=tdecis;
end

% decis=(decis-1)*inA + minA; % initial level of assets


Imark = size(A,1);
Athis = A(Imark,1);        % initial level of assets
Bthis = B(Imark,1);
states   = zeros(n-1,2);
controls = zeros(n-1,3);

for i = 1:n-1
    Inext = decis(Imark,chain(i));
    Ap = Aprime(Inext,1);
    Bp = Bprime(Inext,1);
    Imark  = Inext;
    
    cons1 = Y_high + Athis + Bthis - (Ap./(1+r_high)) - Bp.*(Bp<=2.*Bthis) ;
    cons2 = Y_low + Athis + Bthis - (Ap./(1+r_high)) -  Bp.*(Bp<=2.*Bthis) ;
    cons3 = Y_high + Athis + Bthis - (Ap./(1+r_high))  ;
    cons4 = Y_low + Athis + Bthis - (Ap./(1+r_high))  ;

%     util1 = log( c1 ).*lambda_high;
%     util2 = log( c2 ).*lambda_low;
%     util3 = log( c3 ).*lambda_high;
%     util4 = log( c4 ).*lambda_low;
% 
%     util1(c1<=0)=-inf;
%     util2(c2<=0)=-inf;
%     util3(c3<=0)=-inf;
%     util4(c4<=0)=-inf;
    
%    [~,~,~,~,cons1,cons2,cons3,cons4,wd1,wd2,wd3,wd4] = ...
%    u_con(Athis,Aprime,alpha,p1,p2,r_high,r_lend,Y_high,Y_low,lambda_high,lambda_low,m);   

    cons_full = [cons1 cons2 cons3 cons4];
    %wd_full = [wd1 wd2 wd3 wd4];
    cons = cons_full(chain(i));
    %wd = wd_full(chain(i));
    
    states(i,:) = [ Athis chain(i) ];
    controls(i,:) = [ cons Ap Bp];
    Athis = Ap;
    Bthis = Bp;
end

plot((1:n-1)',controls(:,1))

%w_debt_max = m.*p.*controls(:,1); %%% max debt is bounded at m!
%w_debt = ( controls(:,2).*(controls(:,2)>w_debt_max) + ...
%            w_debt_max.*(controls(:,2)<=w_debt_max) ).* ...
%            (controls(:,2)<0).*(states(:,2)<=2);  %%% only measured when no default (and when negative) (otherwise zero)

w_debt = -1.*controls(:,3);
        
%SAV = controls(:,2);
C = controls(:,1);
state_now = states(:,2);
state_next = [0; states(1:end-1,2)];

c_pre = mean(C(state_next>=3 & controls(:,2)<0)); % sending debt to next period
c_post = mean(C(state_now>=3 & states(:,1)<0)); % getting hit with debt and enforcement 

h = [mean(mean(C)); std(C);  mean(w_debt);  std(w_debt); corr(w_debt,C);  c_pre; c_post  ];


%{

if nargout>1
    Amark = size(Agrid,1);
    Athis = Agrid(Amark,1);        % initial level of assets        
    states   = zeros(n-1,2);
    controls = zeros(n-1,2);
    U = zeros(n-1,1);
    for i = 1:n-1
        Aprime = decis(Amark,chain(i));
        Amark  = tdecis(Amark,chain(i));

        [u1,u2,u3,u4,cons1,cons2,cons3,cons4] = ...
         u_con(Athis,Aprime,alpha,p1,p2,r_high,r_lend,Y_high,Y_low,lambda_high,lambda_low,m);   

        cons_full = [cons1 cons2 cons3 cons4];
        cons = cons_full(chain(i));
        
        u_full = [u1 u2 u3 u4];
        U(i,1) =u_full(chain(i)); 
        
        states(i,:) = [ Athis chain(i) ];
        controls(i,:) = [ cons Aprime ];
        Athis = Aprime;
    end
    
util = mean(U);

%}


%end

% h = [ mean(mean(C)); std(C); (mean(mean(SAV))); std(SAV); corr(SAV,C); avg_debt; CM ];


%SM=mean(S1(:,2:end),2);
%C_avg_debt = mean(C(controls(:,2)<0));
%C_avg_lend = mean(C(controls(:,2)>=0));
%C_std_debt = std(C(controls(:,2)<0));
%C_std_lend = std(C(controls(:,2)>=0));


%plot((1:n-1)',SAV);
%plot((1:n-1)',C);
%plot(1:size(S1,1),SM')
%plot(1:size(C1,1),CM')

