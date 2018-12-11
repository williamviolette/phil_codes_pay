function    [h,util] = m_1loan3_lend2_obj(given,prob,A,Aprime,Agrid,inA,minA,nA,chain)


r_low   = given(1,1);
r_high  = given(1,2);
lambda  = given(1,3);
alpha   = given(1,4);
beta_up = given(1,5);
Y       = given(1,6);
p       = given(1,7);
n       = given(1,8);
metric  = given(1,9);
m       = given(1,10);
r_lend  = given(1,11);

%  prob,n,Aprime,r_low,Y,p,A,metric
%  parameters: r_high beta_up lambda alpha

%r_lend = r_high;
% beta = 1/(1 + beta_up + r_high + .01);
beta = 1/( 1 + beta_up );

Y_high = Y ;               % high value for income
Y_low  = Y ;           % low value for income

lambda_high = 1 + lambda ;
lambda_low  = 1 - lambda ;

[util1,util2,util3,util4] = ...
    u_w1loan3_lend2(A,Aprime,alpha,p,r_high,r_low,r_lend,Y_high,Y_low,lambda_high,lambda_low,m);

v       = zeros(nA,4);
decis   = zeros(nA,4);

while metric > 1e-7

  [tv1,tdecis1]=max(util1 + beta.*repmat(v*prob(1,:)',1,nA));
  [tv2,tdecis2]=max(util2 + beta.*repmat(v*prob(2,:)',1,nA));
  [tv3,tdecis3]=max(util3 + beta.*repmat(v*prob(3,:)',1,nA));
  [tv4,tdecis4]=max(util4 + beta.*repmat(v*prob(4,:)',1,nA));
  
  tdecis=[tdecis1' tdecis2' tdecis3' tdecis4'];
  tv=[tv1' tv2' tv3' tv4'];
  
  metric=max(max(abs((tv-v)./tv)));
  v=tv;
  decis=tdecis;
end

decis=(decis-1)*inA + minA; %%% try to understand this better...

Amark = size(Agrid,1);
Athis = Agrid(Amark,1);        % initial level of assets        
states   = zeros(n-1,2);
controls = zeros(n-1,3);
for i = 1:n-1
    Aprime = decis(Amark,chain(i));
    Amark  = tdecis(Amark,chain(i));
    
    [~,~,~,~,cons1,cons2,cons3,cons4,wd1,wd2,wd3,wd4] = ...
    u_w1loan3_lend2(Athis,Aprime,alpha,p,r_high,r_low,r_lend,Y_high,Y_low,lambda_high,lambda_low,m);
    
    cons_full = [cons1 cons2 cons3 cons4];
    wd_full = [wd1 wd2 wd3 wd4];
    cons = cons_full(chain(i));
    wd = wd_full(chain(i));
    
    states(i,:) = [ Athis chain(i) ];
    controls(i,:) = [ cons Aprime wd];
    Athis = Aprime;
end


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
        u_w1loan3_lend2(Athis,Aprime,alpha,p,r_high,r_low,r_lend,Y_high,Y_low,lambda_high,lambda_low,m);

        cons_full = [cons1 cons2 cons3 cons4];
        cons = cons_full(chain(i));
        
        u_full = [u1 u2 u3 u4];
        U(i,1) =u_full(chain(i)); 
        
        states(i,:) = [ Athis chain(i) ];
        controls(i,:) = [ cons Aprime ];
        Athis = Aprime;
    end
    
util = mean(U);

end

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

