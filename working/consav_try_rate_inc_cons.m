


clear
close all
format short g
! rm consav.out
diary consav.out; 
disp('A SIMPLE CONSUMPTION-SAVING MODEL');
disp('');
%
%  set parameter values
%

r_low  = 0.01;
r_high = 0.03;
beta   = inv(1+0.04);              % subjective discount factor 
prob   = [ .25 .25 .25 .25; .25  .25 .25 .25];   % prob(i,j) = probability (Y(t+1)=Yj | Y(t) = Yi)
prob_markov = [prob;prob];
Y_high = 5 ;               % high value for income
Y_low  = 2 ;           % low value for income

minA =  -10.0001;                     % minimum value of the asset grid
maxA =  10.0001;                     % maximum value of the asset grid   
inA  =  0.1;                     % size of asset grid increments
nA   = round((maxA-minA)/inA+1);   % number of grid points
Agrid = [ minA:inA:maxA ]';

Aprime = repmat(Agrid,1,nA);

Aprime_borrow = Aprime;
Aprime_borrow(Aprime>0)=0;
Aprime_save = Aprime;
Aprime_save(Aprime<0)=0;

A = repmat(Agrid,1,nA)';

cons1 = A + Y_high -  ( (Aprime_borrow/(1+r_low)) +  (Aprime_save/(1+r_low)) );
cons2 = A + Y_low  -  ( (Aprime_borrow/(1+r_low)) +  (Aprime_save/(1+r_low)) );
cons3 = A + Y_high -  ( (Aprime_borrow/(1+r_high)) + (Aprime_save/(1+r_low)) );
cons4 = A + Y_low  -  ( (Aprime_borrow/(1+r_high)) + (Aprime_save/(1+r_low)) );

cons1(cons1<=0)  =  NaN;
cons2(cons2<=0)  =  NaN;
cons3(cons3<=0)  =  NaN;
cons4(cons4<=0)  =  NaN;

util1 =  log(cons1);
util2 =  log(cons2);
util3 =  log(cons3);
util4 =  log(cons4);

util1(isnan(util1)) = -inf;
util2(isnan(util2)) = -inf;
util3(isnan(util3)) = -inf;
util4(isnan(util4)) = -inf;

v       = repmat(0,nA,4);
decis   = repmat(0,nA,4);
metric  = 10;
iter = 0;
tme = cputime;
[rs,cs] = size(util1);

while metric > 1e-7

  [tv1,tdecis1]=max(util1 + beta*repmat(v*prob(1,:)',1,nA));
  [tv2,tdecis2]=max(util2 + beta*repmat(v*prob(2,:)',1,nA));
  [tv3,tdecis3]=max(util3 + beta*repmat(v*prob(1,:)',1,nA));
  [tv4,tdecis4]=max(util4 + beta*repmat(v*prob(2,:)',1,nA));
  
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
n = 20000;                   % number of periods to simulate
s0 = 1;                    % initial state 
states   = zeros(n-1,2);
controls = zeros(n-1,2);
[chain,state] = markov(prob_markov,n,s0);
for i = 1:n-1
    Aprime = decis(Amark,chain(i));
    Amark  = tdecis(Amark,chain(i));
    
    Aprime_borrow = Aprime;
    Aprime_borrow(Aprime>0)=0;
    Aprime_save = Aprime;
    Aprime_save(Aprime<0)=0;
    
    cons1 = Athis + Y_high -  ( (Aprime_borrow/(1+r_low)) + (Aprime_save/(1+r_low)));
    cons2 = Athis + Y_low  -  ( (Aprime_borrow/(1+r_low)) + (Aprime_save/(1+r_low)));
    cons3 = Athis + Y_high -  ( (Aprime_borrow/(1+r_high)) + (Aprime_save/(1+r_low)));
    cons4 = Athis + Y_low  -  ( (Aprime_borrow/(1+r_high)) + (Aprime_save/(1+r_low)));

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
   %if  states(i-3,2)==2 && states(i-2,2)==2 && states(i-1,2)==2 && states(i,2)==4
   %if  states(i-3,2)<=2 && states(i-2,2)<=2 && states(i-1,2)<=2 && states(i,2)>=3
   if states(i,2)>=3
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
