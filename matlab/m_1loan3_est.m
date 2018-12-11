function    m_1loan3_est(a,A,Aprime,r_low,Y,p,prob,n,metric)


%  prob,n,Aprime,r_low,Y,p,A,metric

parameters: r_high beta_up lambda alpha

%%% ESTIMATE DISCOUNT RATE?

r_lend = r_high;
beta = 1/(beta_up + r_high + .01);
Y_high = Y ;               % high value for income
Y_low  = Y ;           % low value for income

lambda_high = 1 + lambda ;
lambda_low  = 1 - lambda ;

[util1,util2,util3,util4,w1,w2,w3,w4] = ...
    u_w1loan3(A,Aprime,alpha,p,r_high,r_low,r_lend,Y_high,Y_low,lambda_high,lambda_low,m);

v       = repmat(0,nA,4);
decis   = repmat(0,nA,4);

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
end

decis=(decis-1)*inA + minA;

Amark = size(Agrid,1);
Athis = Agrid(Amark,1);        % initial level of assets
s0 = 1;                    % initial state 
states   = zeros(n-1,2);
controls = zeros(n-1,2);
% [chain,state] = markov(prob,n,s0);
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

