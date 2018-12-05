


clear
close all
format short g
! rm consav.out
diary consav.out; 
disp('A SIMPLE CONSUMPTION-SAVING MODEL');
disp('');

rng(1)

r_low  = 0.00;
r_high = 0.2;
beta   = inv(1+0.01+r_high);              % subjective discount factor 

prob   = [ 0, .9, .1  ; ...
           0, .9, .1  ; ...
           1,  0,  0 ];
prob = kron(prob./2,ones(2));

       
Y_high = 25000 ;               % high value for income
Y_low  = 25000 ;           % low value for income

lambda_high = 1.3 ;
lambda_low  = 0.7 ;

alpha = .02;
p = 25;

minA =  -20000;                     % minimum value of the asset grid
maxA =  50000;                     % maximum value of the asset grid   
inA  =  500;                     % size of asset grid increments
nA   = round((maxA-minA)/inA+1);   % number of grid points
Agrid = [ minA:inA:maxA ]';

Aprime = repmat(Agrid,1,nA);

A = repmat(Agrid,1,nA)';

[util1h,util2h,util3h,w1h,w2h,w3h] = ...
    u_w2_2(A,Aprime,alpha,p,r_high,r_low,Y_high,lambda_high);

[util1l,util2l,util3l,w1l,w2l,w3l] = ...
    u_w2_2(A,Aprime,alpha,p,r_high,r_low,Y_low,lambda_low);

v       = repmat(0,nA,size(prob,1));
decis   = repmat(0,nA,size(prob,1));
metric  = 10;
iter = 0;
tme = cputime;
[rs,cs] = size(util1h);

while metric > 1e-7

  [tv1h,tdecis1h]=max(util1h + beta.*repmat(v*prob(1,:)',1,nA)); 
  [tv1l,tdecis1l]=max(util1l + beta.*repmat(v*prob(2,:)',1,nA));
  [tv2h,tdecis2h]=max(util2h + beta.*repmat(v*prob(3,:)',1,nA));
  [tv2l,tdecis2l]=max(util2l + beta.*repmat(v*prob(4,:)',1,nA));
  [tv3h,tdecis3h]=max(util3h + beta.*repmat(v*prob(5,:)',1,nA));
  [tv3l,tdecis3l]=max(util3l + beta.*repmat(v*prob(6,:)',1,nA));
  
  tdecis=[tdecis1h' tdecis1l' ...
     	  tdecis2h' tdecis2l' ...
          tdecis3h' tdecis3l' ];
      
  tv=[tv1h' tv1l' ...
      tv2h' tv2l' ...
      tv3h' tv3l' ];
  
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


%{a

%    simulate life histories of the agent

disp('SIMULATING LIFE HISTORY');
Agrid = [ (minA:inA:maxA)' ];  % asset grid  
Amark = size(Agrid,1);
Athis = Agrid(Amark,1);        % initial level of assets
n = 30000;                   % number of periods to simulate
s0 = 1;                    % initial state 
states   = zeros(n-1,2);
controls = zeros(n-1,2);
[chain,state] = markov(prob,n,s0);
for i = 1:n-1
    Aprime = decis(Amark,chain(i));
    Amark  = tdecis(Amark,chain(i));
    
    [~,~,~,w1h,w2h,w3h] = ...
    u_w2_2(Athis,Aprime,alpha,p,r_high,r_low,Y_high,lambda_high);

    [~,~,~,w1l,w2l,w3l] = ...
    u_w2_2(Athis,Aprime,alpha,p,r_high,r_low,Y_low,lambda_low);

    cons_full = [w1h w1l w2h w2l w3h w3l];
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
   if states(i,2)>=5 && controls(i,2)<0
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

