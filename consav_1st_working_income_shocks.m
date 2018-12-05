


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
beta   = inv(1+r+.1);              % subjective discount factor 
prob   = [ .25 .25 .25 .25; .25  .25 .25 .25];   % prob(i,j) = probability (Y(t+1)=Yj | Y(t) = Yi)
prob_markov = [prob;prob];
Y_high = 2.0;               % high value for income
Y_low  = 1;           % low value for income

minA =  -2.0001;                     % minimum value of the asset grid
maxA =  4.0001;                     % maximum value of the asset grid   
inA  =  0.005;                     % size of asset grid increments
nA   = round((maxA-minA)/inA+1);   % number of grid points
Agrid = [ minA:inA:maxA ]';

Aprime = repmat(Agrid,1,nA);
Aprime0 = Aprime;
Aprime0(Aprime<0)=0;

A = repmat(Agrid,1,nA)';

cons1 = ((1+r)*(A + Y_high)-Aprime)/(1+r);
cons2 = ((1+r)*(A + Y_low)-Aprime)/(1+r);
cons3 = ((1+r)*(A + Y_high)-Aprime0)/(1+r);
cons4 = ((1+r)*(A + Y_low)-Aprime0)/(1+r);

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
Amark = size(Agrid,1) - 500;
Athis = Agrid(Amark,1);        % initial level of assets
n = 1000;                   % number of periods to simulate
s0 = 1;                    % initial state 
states   = zeros(n-1,2);
controls = zeros(n-1,2);
[chain,state] = markov(prob_markov,n,s0);
for i = 1:n-1
    I = 1;
    if i>1
        I=chain(i-1)<=2;
    end
    if chain(i) == 1
       Aprime = decis(Amark,1);
       cons   = ((1+r)*(Athis.*I+Y_high)-Aprime)/(1+r); 
       Amark  = tdecis(Amark,1);
    elseif chain(i) == 2
       Aprime = decis(Amark,2);
       cons   = ((1+r)*(Athis.*I+Y_low) - Aprime)/(1+r); 
       Amark = tdecis(Amark,2);
    elseif chain(i) == 3
       Aprime = decis(Amark,3);
       Aprime = (Aprime*(Aprime<0));
       cons   = ((1+r)*(Athis+Y_high) - Aprime)/(1+r); 
       Amark  = tdecis(Amark,1);
    elseif chain(i) == 4
       Aprime = decis(Amark,4);
       Aprime = (Aprime*(Aprime<0));
       cons   = ((1+r)*(Athis+Y_low) - Aprime)/(1+r); 
       Amark  = tdecis(Amark,1);        
    else
      disp('something is wrong with chain');
    end
    states(i,:) = [ Athis chain(i) ];
    controls(i,:) = [ cons Aprime ];
    Athis = Aprime;
end


SAV = controls(:,2);

C = controls(:,1);
Y = states(:,1) + (states(:,2)==1 | states(:,2)==3).*Y_high + (states(:,2)==2 | states(:,2)==4).*Y_low;

G = [Y C];
G = sortrows(G,1);

plot((1:n-1)',SAV);
plot((1:n-1)',C);

states(C<0,2)

sum(states(SAV==0,2)==3)/sum(states(:,2)==3)
sum(states(SAV==0,2)==4)/sum(states(:,2)==4)

plot(G(:,1),G(:,2),G(:,2),G(:,2))

plot(G(:,1),G(:,2))

% C1 = [1;1;1;1];
% for i=4:size(states,1)-5
%    if states(i-3,2)<=2 && states(i-2,2)<=2 && states(i-1,2)<=2 && states(i,2)>=3
%       C1=[C1 C(i-3:i,1)]; 
%    end 
% end

C1 = [1;1;1;1;1];
for i=4:size(states,1)-5
   if states(i-3,2)==2 && states(i-2,2)==2 && states(i-1,2)==2 && states(i,2)==4
      C1=[C1 C(i-3:i+1,1)]; 
   end 
end

CM=mean(C1,2)

plot(1:5,CM')



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
