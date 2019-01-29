function    [h,util,sim] = dc_obj(given,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s)

r_lend          = given(1,1);
r_water         = given(1,2);
r_high          = given(1,3);
lambda          = given(1,4);
theta           = given(1,5);
gamma           = given(1,6);
alpha           = given(1,7);
beta_up         = given(1,8);
Y               = given(1,9);
p1              = given(1,10);
p2              = given(1,11);
pd              = given(1,12);
n               = given(1,13);
metric          = given(1,14);
water_lending   = given(1,15);

beta = 1/( 1 + beta_up );

lambda_high = 1+lambda;
lambda_low  = 1-lambda;

Y_high = Y.*(1+theta) ;  % high value for income
Y_low  = Y.*(1-theta) ;  % low value for income

p1d = p1;
p2d = p2;

k_high = gamma;
k_low  = -gamma;

[util1,util2,util3,util4] = ...
         gen_dc_4s(A,B,D,Aprime,Bprime,Dprime,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,p1d,p2d,pd,alpha,k_high,k_low,lambda_high,lambda_low);

v       = zeros(nA*nB*nD,size(prob,1));
decis   = zeros(nA*nB*nD,size(prob,1));


while metric > 1e-7

      [tv1,tdecis1]=max(util1 + beta.*repmat(v*prob(1,:)',1,nA*nB*nD));
      [tv2,tdecis2]=max(util2 + beta.*repmat(v*prob(2,:)',1,nA*nB*nD));
      [tv3,tdecis3]=max(util3 + beta.*repmat(v*prob(3,:)',1,nA*nB*nD));
      [tv4,tdecis4]=max(util4 + beta.*repmat(v*prob(4,:)',1,nA*nB*nD));
      tdecis=[ tdecis1' tdecis2' tdecis3' tdecis4' ];
      tv=[ tv1' tv2' tv3' tv4' ];

  metric=max(max(abs((tv-v)./tv)));
  v=tv;
  decis=tdecis;
end

Imark = 1;
Athis = A(Imark,1);  % initial asset levels
Bthis = B(Imark,1);  % initial asset levels
Dthis = D(Imark,1);
%Athis = 0;  % initial asset levels
%Bthis = 0;  % initial asset levels

states   = zeros(n-1,2);
controls = zeros(n-1,4);

for ii = 1:n-1
    Inext = decis(Imark,chain(ii));
    Ap = Aprime(Inext,1);
    Bp = Bprime(Inext,1);
    Dp = Dprime(Inext,1);
    Imark  = Inext;

         [~,~,~,~,...
             w1,w2,w3,w4] = ...
         gen_dc_4s(Athis,Bthis,Dthis,Ap,Bp,Dp,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,p1d,p2d,pd,alpha,k_high,k_low,lambda_high,lambda_low);

         cons_full = [w1 w2 w3 w4];
    
    cons = cons_full(chain(ii));
    
    states(ii,:) = [ Athis chain(ii) ];
    controls(ii,:) = [ cons Ap Bp Dp];
    Athis = Ap;
    Bthis = Bp;
    Dthis = Dp;
end

% plot((1:n-1)',controls(:,1))
% [ states controls ]



w_debt = -1.*controls(:,3);
        
C = controls(:,1);
dd = (controls(:,4)==1);

state_now  = states(:,2);
state_pre  = [0; states(1:end-1,2)];
state_pre2 = [0;0; states(1:end-2,2)];
state_pre3 = [0;0;0; states(1:end-3,2)];
%state_pre4 = [0;0;0;0; states(1:end-4,2)];
% state_pre5 = [0;0;0;0;0; states(1:end-5,2)];

d_post      = mean(controls(state_now>=3,4));
d_post_pre  = mean(controls(state_pre>=3,4));
d_post_pre2 = mean(controls(state_pre2>=3,4));
d_post_pre3 = mean(controls(state_pre3>=3,4));
% d_post_pre4 = mean(controls(state_pre4>=3,4));
% d_post_pre5 = mean(controls(state_pre5>=3,4));

dd_mom=[d_post; d_post_pre; d_post_pre2; d_post_pre3];


h = [mean(mean(C(dd~=1))); std(C(dd~=1));  ...
    mean(w_debt(dd~=1));  std(w_debt(dd~=1)); ...
    corr(w_debt(dd~=1),C(dd~=1)); ...
    dd_mom ];


if s==1
    %%% balance in the pre-period!

    w_debt_pre  = [0; w_debt(1:end-1,1)];
    w_debt_pre1 = [0;0; w_debt(1:end-2,1)];
    w_debt_pre2 = [0;0;0; w_debt(1:end-3,1)];
    w_debt_pre3 = [0;0;0;0; w_debt(1:end-4,1)];
    w_debt_pre4 = [0;0;0;0;0; w_debt(1:end-5,1)];
    w_debt_pre5 = [0;0;0;0;0;0; w_debt(1:end-6,1)];
    %w_debt_pre6 = [0;0;0;0;0;0;0; w_debt(1:end-7,1)];
    % w_debt_pre7 = [0;0;0;0;0;0;0;0; w_debt(1:end-8,1)];

    w_pre  = (w_debt_pre>0  & w_debt_pre1>0 & w_debt_pre2>0) ;
    w_pre1 = (w_debt_pre1>0 & w_debt_pre2>0 & w_debt_pre3>0) ;
    w_pre2 = (w_debt_pre2>0 & w_debt_pre3>0 & w_debt_pre4>0) ;
    w_pre3 = (w_debt_pre3>0 & w_debt_pre4>0 & w_debt_pre5>0) ;
    %w_pre4 = (w_debt_pre4>0 & w_debt_pre5>0 & w_debt_pre6>0) ;

    % [w_debt_pre w_debt_pre2 w_debt_pre3 w_pre1]

    d_post_pre_b  = mean(controls(state_pre>=3  & w_pre==1,4));
    d_post_pre1_b  = mean(controls(state_pre>=3  & w_pre1==1,4));
    d_post_pre2_b = mean(controls(state_pre2>=3 & w_pre2==1,4));
    d_post_pre3_b = mean(controls(state_pre3>=3 & w_pre3==1,4));
    %d_post_pre4_b = mean(controls(state_pre4>=3 & w_pre4==1,4));
    % d_post_pre5_b = mean(controls(state_pre5>=3 & w_debt_pre5>bt,4));

    ddb_mom = [d_post_pre_b; d_post_pre1_b; d_post_pre2_b; d_post_pre3_b];
    h = [h;ddb_mom];

end



if nargout>1
    util = sum(mean(v).*mean(prob));
end

if nargout>2
   sim = [controls states(:,2)];    
end



%  c_pre; c_post; (c_pre-c_post)

% state_next  = [states(2:end,2); 0];

% B_est = controls(:,3);
% B_est_pre = [0; controls(1:end-1,3)]; %%% key typo

% state_now_ind=2;
% state_next_ind=3;     
    
% c_pre  = mean(C(state_now<=state_now_ind & state_next>=state_next_ind & B_est<0));  % sending debt to next period
% c_post = mean(C(state_now>=state_next_ind & state_pre<=state_now_ind  & B_est_pre<0 ));    % getting hit with debt and enforcement 


