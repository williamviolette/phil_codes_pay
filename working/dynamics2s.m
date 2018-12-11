
% do dynamics now..

% start with simple model, then do simple deaton, then do complex deaton

%%% deaton superrrr simple



clear;

dimIter=30;

delta = 0.2; 
 r = 0.1;
 yl = 6;
 yh = 10;
sigma = 3;
 
S=-2:0.1:8;
n = length(S);

ctot= 4.*ones(n,n);
v=ctot.^(1-sigma)/(1-sigma);

        % next period (j)  % minus this period (i)
Ch = (1+r)*(S) + yh - S';
Cl = (1+r)*(S) + yl - S';

Uh = Ch.^(1-sigma)/(1-sigma);
Ul = Cl.^(1-sigma)/(1-sigma);

vH1 = max(v);
vL1 = max(v);

T=100
for j=1:T
        w=ones(n,1)*(vH1+vL1);
        wh = Uh + (1/(1+delta)).*.5*w';
        wl = Ul + (1/(1+delta)).*.5*w';
        vH1=max(wh);
        vL1=max(wl);
end

[valH,indH]=max(wh);
[valL,indL]=max(wl);
optsh = S(indH);
optsl = S(indL);

plot(S,optsh,S,optsl,S,S)


