function    [h,util] = d_obj(given,prob,A,Aprime,nA,B,Bprime,nB,chain)

r_lend          = given(1,1);
r_water         = given(1,2);
r_high          = given(1,3);
lambda          = given(1,4);
alpha           = given(1,5);
beta_up         = given(1,6);
Y               = given(1,7);
p1              = given(1,8);
p2              = given(1,9);
n               = given(1,10);
metric          = given(1,11);
water_lending   = given(1,12);

beta = 1/( 1 + beta_up );

Y_high = Y ;  % high value for income
Y_low  = Y ;  % low value for income

lambda_high = 1 + lambda ;
lambda_low  = 1 - lambda ;


[util1,util2,util3,util4] = ...
         gen_d(A,B,Aprime,Bprime,r_high,r_lend,r_water,water_lending,Y_high,Y_low,lambda_high,lambda_low,p1,p2,alpha);

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

Imark = size(A,1);
Athis = A(Imark,1);  % initial asset levels
Bthis = B(Imark,1);  % initial asset levels
states   = zeros(n-1,2);
controls = zeros(n-1,3);

for i = 1:n-1
    Inext = decis(Imark,chain(i));
    Ap = Aprime(Inext,1);
    Bp = Bprime(Inext,1);
    Imark  = Inext;
    
    [~,~,~,~,w1,w2,w3,w4] = ...
         gen_d(Athis,Bthis,Ap,Bp,r_high,r_lend,r_water,water_lending,Y_high,Y_low,lambda_high,lambda_low,p1,p2,alpha);

    cons_full = [w1 w2 w3 w4];
    cons = cons_full(chain(i));
    
    states(i,:) = [ Athis chain(i) ];
    controls(i,:) = [ cons Ap Bp];
    Athis = Ap;
    Bthis = Bp;
end

% plot((1:n-1)',controls(:,1))
% [ states controls ]

w_debt = -1.*controls(:,3);
        
C = controls(:,1);
state_now = states(:,2);
state_next = [0; states(1:end-1,2)];

c_pre = mean(C(state_next>=3 & controls(:,2)<0));  % sending debt to next period
c_post = mean(C(state_now>=3 & states(:,1)<0));    % getting hit with debt and enforcement 

h = [mean(mean(C)); std(C);  mean(w_debt);  std(w_debt); corr(w_debt,C);  c_pre; c_post  ];





if nargout>1
    
    Imark = size(A,1);
    Athis = A(Imark,1);  % initial asset levels
    Bthis = B(Imark,1);  % initial asset levels
    U = zeros(n-1,1);
    for i = 1:n-1
        Inext = decis(Imark,chain(i));
        Ap = Aprime(Inext,1);
        Bp = Bprime(Inext,1);
        Imark  = Inext;

        [u1,u2,u3,u4] = ...
             gen_d(Athis,Bthis,Ap,Bp,r_high,r_lend,r_water,water_lending,Y_high,Y_low,lambda_high,lambda_low,p1,p2,alpha);
        
        u_full = [u1 u2 u3 u4];
        U(i,1) =u_full(chain(i)); 

        Athis = Ap;
        Bthis = Bp;
    end
    
    util = mean(U);

end

