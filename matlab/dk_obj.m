function    [h,util,sim] = dk_obj(given,prob,A,Aprime,nA,B,Bprime,nB,chain,s)

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

%alpha_high = alpha.*(1+gamma);
%alpha_low = alpha.*(1-gamma);

k_high = gamma;
k_low  = -gamma;


if s==8
    [util1,util2,util3,util4,util5,util6,util7,util8] = ...
         gen_dk_8s(A,B,Aprime,Bprime,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,alpha,k_high,k_low,lambda_high,lambda_low);
elseif s==4
    [util1,util2,util3,util4] = ...
         gen_dk_4s(A,B,Aprime,Bprime,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,alpha,k_high,k_low,lambda_high,lambda_low);
end

     
v       = zeros(nA*nB,size(prob,1));
decis   = zeros(nA*nB,size(prob,1));

while metric > 1e-7

  if s==8
      [tv1,tdecis1]=max(util1 + beta.*repmat(v*prob(1,:)',1,nA*nB));
      [tv2,tdecis2]=max(util2 + beta.*repmat(v*prob(2,:)',1,nA*nB));
      [tv3,tdecis3]=max(util3 + beta.*repmat(v*prob(3,:)',1,nA*nB));
      [tv4,tdecis4]=max(util4 + beta.*repmat(v*prob(4,:)',1,nA*nB));
      [tv5,tdecis5]=max(util5 + beta.*repmat(v*prob(5,:)',1,nA*nB));
      [tv6,tdecis6]=max(util6 + beta.*repmat(v*prob(6,:)',1,nA*nB));
      [tv7,tdecis7]=max(util7 + beta.*repmat(v*prob(7,:)',1,nA*nB));
      [tv8,tdecis8]=max(util8 + beta.*repmat(v*prob(8,:)',1,nA*nB));
      tdecis=[tdecis1' tdecis2' tdecis3' tdecis4' tdecis5' tdecis6' tdecis7' tdecis8'];
      tv=[tv1' tv2' tv3' tv4' tv5' tv6' tv7' tv8'];
  elseif s==4
      [tv1,tdecis1]=max(util1 + beta.*repmat(v*prob(1,:)',1,nA*nB));
      [tv2,tdecis2]=max(util2 + beta.*repmat(v*prob(2,:)',1,nA*nB));
      [tv3,tdecis3]=max(util3 + beta.*repmat(v*prob(3,:)',1,nA*nB));
      [tv4,tdecis4]=max(util4 + beta.*repmat(v*prob(4,:)',1,nA*nB));
      tdecis=[ tdecis1' tdecis2' tdecis3' tdecis4' ];
      tv=[ tv1' tv2' tv3' tv4' ];
  end
  
  metric=max(max(abs((tv-v)./tv)));
  v=tv;
  decis=tdecis;
end

Imark = 1;
Athis = A(Imark,1);  % initial asset levels
Bthis = B(Imark,1);  % initial asset levels
%Athis = 0;  % initial asset levels
%Bthis = 0;  % initial asset levels

states   = zeros(n-1,2);
controls = zeros(n-1,3);

for ii = 1:n-1
    Inext = decis(Imark,chain(ii));
    Ap = Aprime(Inext,1);
    Bp = Bprime(Inext,1);
    Imark  = Inext;

    if s==8
        [~,~,~,~,~,~,~,~,...
            w1,w2,w3,w4,w5,w6,w7,w8] = ...
             gen_dk_8s(Athis,Bthis,Ap,Bp,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,alpha,k_high,k_low,lambda_high,lambda_low); 
        cons_full = [w1 w2 w3 w4 w5 w6 w7 w8];
    elseif s==4
        [~,~,~,~,...
            w1,w2,w3,w4] = ...
             gen_dk_4s(Athis,Bthis,Ap,Bp,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,alpha,k_high,k_low,lambda_high,lambda_low); 
        cons_full = [w1 w2 w3 w4];
    end
    
    cons = cons_full(chain(ii));
    
    states(ii,:) = [ Athis chain(ii) ];
    controls(ii,:) = [ cons Ap Bp];
    Athis = Ap;
    Bthis = Bp;
end

% plot((1:n-1)',controls(:,1))
% [ states controls ]

w_debt = -1.*controls(:,3);
        
C = controls(:,1);
state_now  = states(:,2);
state_pre = [0; states(1:end-1,2)];
state_next  = [states(2:end,2); 0];

B_est = controls(:,3);
B_est_pre = [0; controls(1:end-1,3)]; %%% key typo


if s==8
    state_now_ind=4;
    state_next_ind=5;
elseif s==4
    state_now_ind=2;
    state_next_ind=3;     
end
    
c_pre  = mean(C(state_now<=state_now_ind & state_next>=state_next_ind & B_est<0));  % sending debt to next period
c_post = mean(C(state_now>=state_next_ind & state_pre<=state_now_ind  & B_est_pre<0 ));    % getting hit with debt and enforcement 

    
h = [mean(mean(C)); std(C);  mean(w_debt);  std(w_debt); corr(w_debt,C);  c_pre; c_post; (c_pre-c_post)  ];





if nargout>1
    
    util = sum(mean(v).*mean(prob));
    
    %{
    Imark = 1;
    Athis = A(Imark,1);  % initial asset levels
    Bthis = B(Imark,1);  % initial asset levels
    %Athis=0;
    %Bthis=0;
    U = zeros(n-1,1);
    for zz = 1:n-1
        Inext = decis(Imark,chain(zz));
        Ap = Aprime(Inext,1);
        Bp = Bprime(Inext,1);
        Imark  = Inext;

        if s==8
            [u1,u2,u3,u4,u5,u6,u7,u8] = ...
                     gen_dk_8s(Athis,Bthis,Ap,Bp,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,alpha,k_high,k_low,lambda_high,lambda_low);
            u_full = [u1 u2 u3 u4 u5 u6 u7 u8];
        elseif s==4
            [u1,u2,u3,u4] = ...
                     gen_dk_4s(Athis,Bthis,Ap,Bp,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,alpha,k_high,k_low,lambda_high,lambda_low);
            u_full = [u1 u2 u3 u4]; 
        end
        U(zz,1) =u_full(chain(zz)); 

        Athis = Ap;
        Bthis = Bp;
    end
    
    util = mean(U);
    %}
end

if nargout>2
   sim = [controls states(:,2)];    
end


