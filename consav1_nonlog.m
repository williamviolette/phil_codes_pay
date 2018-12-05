

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
r      = .05;               % interest rate
beta   = inv(1+r+.2);              % subjective discount factor 
prob   = [ .5 .5; .5  .5];   % prob(i,j) = probability (Y(t+1)=Yj | Y(t) = Yi)
Y_high = 2.00;               % high value for income
Y_low  = 0;           % low value for income
rho = 1.1;
%
%   form asset grid
%   
%minA =  0.0001;                     % minimum value of the asset grid
minA =  -1.0001;                     % minimum value of the asset grid
maxA =  5.0001;                     % maximum value of the asset grid   
inA  =  0.005;                     % size of asset grid increments
nA   = round((maxA-minA)/inA+1);   % number of grid points
Agrid = [ minA:inA:maxA ]';
% 
%  tabulate the utility function such that for zero or negative
%  consumption, utility remains a large negative number so that
%  such values will never be chosen as utility maximizing      
%

Aprime = repmat(Agrid,1,nA);
A = repmat(Agrid,1,nA)';

cons1 = ((1+r)*(A + Y_high)-Aprime)/(1+r);
cons2 = ((1+r)*(A + Y_low)-Aprime)/(1+r);

cons1(find(cons1<=0)) = NaN;
cons2(find(cons2<=0)) = NaN;

%util1 =  log(cons1);
%util2 =  log(cons2);

util1 =  ((cons1).^(1-rho)-1)./(1-rho) ;
util2 =  ((cons2).^(1-rho)-1)./(1-rho) ;

util1(find(isnan(util1))) = -inf;
util2(find(isnan(util2))) = -inf;

v       = repmat(0,nA,2);
decis   = repmat(0,nA,2);
metric  = 10;
iter = 0;
tme = cputime;
[rs,cs] = size(util1);

while metric > 1e-7

  [tv1,tdecis1]=max(util1 + beta*repmat(v*prob(1,:)',1,nA));
  [tv2,tdecis2]=max(util2 + beta*repmat(v*prob(2,:)',1,nA));
  
  tdecis=[tdecis1' tdecis2'];
  tv=[tv1' tv2'];
  
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

g2=sparse(cs,cs);
g1=sparse(cs,cs);
for i=1:cs
    g1(i,tdecis1(i))=1;
    g2(i,tdecis2(i))=1;
end
trans=[ prob(1,1)*g1 prob(1,2)*g1; prob(2,1)*g2 prob(2,2)*g2];
trans= trans';
probst = (1/(2*nA))*ones(2*nA,1);
%probst = zeros(2*nA,1);
%probst(nA,1) = 1;
test = 1;
jter = 1;
while ((test > 10^(-8)) & (jter < 10000));
   probst1 = trans*probst;
   test=max(abs(probst1-probst));
   probst = probst1;
   jter = jter+1;
end;
disp('found invariant distribution in');
disp([ jter ]);
disp('iterations');
%
%   vectorize the decision rule to be conformable with probst
%   calculate mean level of assets
%
AA=decis(:);
meanA=probst'*AA;
%
%  calculate measure over (A,Y) pairs
%  lambda has same dimensions as decis
%
lambda=zeros(cs,2);
lambda(:)=probst;
%
%   calculate stationary distribution of assets 
%
probA=sum(lambda');     
probA=probA';
%
%   print out results
%
disp('PARAMETER VALUES');
disp('');
disp('    r      beta       '); 
disp([ r beta ]);
disp(''); 
disp('RESULTS ');
disp('');
disp('      mean of A ');
disp([ meanA ]);
%
%    simulate life histories of the agent
%
disp('SIMULATING LIFE HISTORY');
Agrid = [ (minA:inA:maxA)' ];  % asset grid  
Amark = 1;
Athis = Agrid(Amark,1);        % initial level of assets
n = 1000;                   % number of periods to simulate
s0 = 1;                    % initial state 
states   = zeros(n-1,2);
controls = zeros(n-1,2);
[chain,state] = markov(prob,n,s0);
for i = 1:n-1;
    if chain(i) == 1;
       Aprime = decis(Amark,1);
       cons   = ((1+r)*(Athis+Y_high)-Aprime)/(1+r); 
       Amark  = tdecis(Amark,1);
    elseif chain(i) == 2;
       Aprime = decis(Amark,2);
       cons   = ((1+r)*(Athis+Y_low)-Aprime)/(1+r); 
       Amark = tdecis(Amark,2);
    else;
      disp('something is wrong with chain');
    end;
    states(i,:) = [ Athis chain(i) ];
    controls(i,:) = [ cons Aprime ];
    Athis = Aprime;
end;


C = controls(:,1);
Y = states(:,1) + (states(:,2)==1).*Y_high + (states(:,2)==2).*Y_low;

G = [Y C];
G = sortrows(G,1);

plot(G(:,1),G(:,2),G(:,2),G(:,2))

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
