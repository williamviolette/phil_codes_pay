
% do dynamics now..

% start with simple model, then do simple deaton, then do complex deaton

%%% deaton superrrr simple



clear;

dimIter=30;

delta = 0.2; 
 r = 0.1;
 y = 5;
sigma = 3;
 
S=0:0.1:8;
n = length(S);

ctot = y;   %% eat all income
ctot = ctot'*ones(1,n);   

ctot= 2.*ones(n,n);
v=ctot.^(1-sigma)/(1-sigma);


for i=1:n % savings for next period
    for j=1:n % current income
        C(i,j) = (1+r)*(S(j)) + y - S(i);
    end
end

U = C.^(1-sigma)/(1-sigma);


T=100
for j=1:T
        w=U+(1/(1+delta))*v;
        v1=max(w);
        v=v1'*ones(1,n);
end
[val,ind]=max(w);
opts = S(ind);

plot(S,opts,S,S)


