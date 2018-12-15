function    [h,util] = d_obj_8s_counter(given,prob,A,Aprime,nA,chain)

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
n               = given(1,12);
metric          = given(1,13);
water_lending   = given(1,14);

beta = 1/( 1 + beta_up );

lambda_high = 1+lambda;
lambda_low  = 1-lambda;

Y_high = Y.*(1+theta) ;  % high value for income
Y_low  = Y.*(1-theta) ;  % low value for income

[util1,util2] = ...
         gen_d_counter(A,Aprime,r_high,r_lend,Y_high,Y_low,p1,p2,alpha,lambda_high,lambda_low);

     
v       = zeros(nA,size(prob,1));
decis   = zeros(nA,size(prob,1));

while metric > 1e-7
    
  [tv1,tdecis1]=max(util1 + beta.*repmat(v*prob(1,:)',1,nA));
  [tv2,tdecis2]=max(util2 + beta.*repmat(v*prob(2,:)',1,nA));

  tdecis=[tdecis1' tdecis2' ];
  tv=[tv1' tv2'];
  
  metric=max(max(abs((tv-v)./tv)));
  v=tv;
  decis=tdecis;
end

Imark = size(A,1);
Athis = A(Imark,1);  % initial asset levels
states   = zeros(n-1,2);
controls = zeros(n-1,2);

for i = 1:n-1
    Inext = decis(Imark,chain(i));
    Ap = Aprime(Inext,1);
    Imark  = Inext;
    [~,~,...
        w1,w2] = ...
         gen_d_counter(Athis,Ap,r_high,r_lend,Y_high,Y_low,p1,p2,alpha,lambda_high,lambda_low);
     
    cons_full = [w1 w2];

    cons = cons_full(chain(i));
    states(i,:) = [ Athis chain(i) ];
    controls(i,:) = [ cons Ap];
    Athis = Ap;
end


% plot((1:n-1)',controls(:,1))
% [ states controls ]

%w_debt = -1.*controls(:,3);
        
C = controls(:,1);

h = [mean(mean(C)); std(C) ];



if nargout>1
    
    Imark = size(A,1);
    Athis = A(Imark,1);  % initial asset levels
    U = zeros(n-1,1);
    for i = 1:n-1
        Inext = decis(Imark,chain(i));
        Ap = Aprime(Inext,1);
        Imark  = Inext;

        [u1,u2] = ...
         gen_d_counter(Athis,Ap,r_high,r_lend,Y_high,Y_low,p1,p2,alpha,lambda_high,lambda_low);
     
        u_full = [u1 u2];
        U(i,1) =u_full(chain(i)); 

        Athis = Ap;
    end
    
    util = mean(U);

end

