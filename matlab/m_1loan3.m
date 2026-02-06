


clear
octave_setup;

rng(1)

n = 100000;                   % number of periods to simulate

r_low  = 0.00;
r_high = 0.08;
r_lend = 0.08;
beta   = inv(1+0.01+r_high);              % subjective discount factor 
% beta   = inv(1+0.21);              % subjective discount factor 
% beta = 1/(1+.1)

m=3;


p_caught = .0084 ;

prob   = [ (1-p_caught) (1-p_caught) p_caught p_caught; 
           (1-p_caught) (1-p_caught) p_caught p_caught;
           (1-p_caught) (1-p_caught) p_caught p_caught;
           (1-p_caught) (1-p_caught) p_caught p_caught]./2 ;   % prob(i,j) = probability (Y(t+1)=Yj | Y(t) = Yi)


Y_high = 30000 ;               % high value for income
Y_low  = 30000 ;           % low value for income

alpha = .02;
p = 26;

lambda_high = 1.3 ;
lambda_low  = .7 ;

minA =  -20000;                     % minimum value of the asset grid
maxA =  50000;                     % maximum value of the asset grid   
inA  =  500;                     % size of asset grid increments
nA   = round((maxA-minA)/inA+1);   % number of grid points
Agrid = [ minA:inA:maxA ]';

Aprime = repmat(Agrid,1,nA);

% Conditions 
%  1) Aprime>0 : v_reg(r_high) , w_reg(r_high)
%  2) Aprime<0 & Aprime>A_cut : v_reg(r_low) , w_reg(r_low)
%  3) Aprime<A_cut :    v_b(r_high, r_low)  , w_b(r_high, r_low)

A = repmat(Agrid,1,nA)';

[util1,util2,util3,util4,w1,w2,w3,w4] = ...
    u_w1loan3(A,Aprime,alpha,p,r_high,r_low,r_lend,Y_high,Y_low,lambda_high,lambda_low,m);

v       = repmat(0,nA,4);
decis   = repmat(0,nA,4);
metric  = 10;
iter = 0;
tme = cputime;
[rs,cs] = size(util1);

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
iter = iter+1;
end
disp('fixed point solved via value function iteration took');
disp([ iter ]);
disp('iterations and');
disp([ cputime-tme ]);
disp('seconds');

decis=(decis-1)*inA + minA;
%   form transition matrix
%   trans is the transition matrix from state at t (row)
%   to the state at t+1 (column) 
%   The eigenvector associated with the unit eigenvalue
%   of trans' is  the stationary distribution. 


%{a

%    simulate life histories of the agent

disp('SIMULATING LIFE HISTORY');
Agrid = [ (minA:inA:maxA)' ];  % asset grid  
Amark = size(Agrid,1);
Athis = Agrid(Amark,1);        % initial level of assets
s0 = 1;                    % initial state 
states   = zeros(n-1,2);
controls = zeros(n-1,2);
[chain,state] = markov(prob,n,s0);
for i = 1:n-1
    Aprime = decis(Amark,chain(i));
    Amark  = tdecis(Amark,chain(i));
    
    [~,~,~,~,cons1,cons2,cons3,cons4] = ...
    u_w1loan3(Athis,Aprime,alpha,p,r_high,r_low,r_lend,Y_high,Y_low,lambda_high,lambda_low,m);
    
    cons_full = [cons1 cons2 cons3 cons4];
    cons = cons_full(chain(i));
    
    states(i,:) = [ Athis chain(i) ];
    controls(i,:) = [ cons Aprime ];
    Athis = Aprime;
end


SAV = controls(:,2);

C = controls(:,1);
Y = states(:,1) + (states(:,2)==1 | states(:,2)==3).*Y_high + (states(:,2)==2 | states(:,2)==4).*Y_low;

G = [Y C];
G = sortrows(G,1);

mean(C(states(:,2)==1))
mean(C(states(:,2)==2))
mean(C(states(:,2)==3))
mean(C(states(:,2)==4))

sum(states(SAV==0,2)==3)/sum(states(:,2)==3)
sum(states(SAV==0,2)==4)/sum(states(:,2)==4)

plot(G(:,1),G(:,2),G(:,2),G(:,2))

plot(G(:,1),G(:,2))


C1 = [1;1;1;1;1;1;1;1;1];
S1 = [1;1;1;1;1;1;1;1;1];
for i=6:size(states,1)-6
   if states(i,2)>=3 && controls(i,2)<0
      C1=[C1 C(i-4:i+4,1)]; 
      S1=[S1 SAV(i-4:i+4,1)]; 
   end 
end


CM=mean(C1(:,2:end),2)
SM=mean(S1(:,2:end),2)

plot((1:n-1)',SAV);
plot((1:n-1)',C);

plot(1:size(S1,1),SM')
plot(1:size(C1,1),CM')

CM(5)-CM(4)

%}


%{

plot((1:n-1)',controls(:,1));
title('CONSUMPTION/SAVING MODEL: CONSUMPTION');


plot(Y,controls(:,1))
plot(controls(:,1),(controls(:,2)))
plot(INC,controls(:,1),INC,controls(:,2))
title('income: consumption+ assets')




figure(1)
plot(Agrid',v(:,1),'-',Agrid',v(:,2),':');
title('CONSUMPTION/SAVING MODEL: VALUE FUNCTION');
%print cs_value.ps

figure(2)
plot(Agrid',decis(:,1),'.',Agrid',decis(:,2),':',Agrid',Agrid','-');
title('CONSUMPTION/SAVING MODEL: POLICY FUNCTION');
axis([ 0 maxA 0 maxA ]);
%print cs_policy.ps


figure(2)
plot(Agrid',decis(:,1),'.',Agrid',decis(:,2),':',Agrid',Agrid','-');
title('CONSUMPTION/SAVING MODEL: POLICY FUNCTION');
axis([ minA maxA minA maxA ])

figure(4)
plot((1:n-1)',controls(:,2));
title('CONSUMPTION/SAVING MODEL: SAVING');
%print cs_saving.ps


figure(3)
plot((1:n-1)',controls(:,1));
title('CONSUMPTION/SAVING MODEL: CONSUMPTION');
%print cs_consum.ps







%figure(5)
%plot(Agrid,probA);
%title('DISTRIBUTION OF ASSETS');
%xlabel('ASSETS');
%ylabel('FRACTION OF AGENTS');
%print asset_dist.ps

%}
