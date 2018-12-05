

clear;
syms yl yh A p r

% obj = (A+yl)^-2 + p*2*(yh-(A/2))^-2 + (1-p)*((yh-A)^-2 + (yh)^-2);


obj = log(A+yl) + p*2*log(yh-(A/2)) + (1-p)*(log(yh-A) + log(yh));


obj_d = diff(obj,A);
solve_set = [obj_d];
[As] ...
    =  solve(solve_set,A)

simplify(As)

steps=10;
matlabFunction(simplify(As,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','As.m')


%%% NORMAL INTEREST
clear;
syms yl yh A p r

obj = log(A+yl) + 2*log(yh-(A*(1+r)/2));

[An] ...
    =  solve(diff(obj,A),A)

steps=10;
matlabFunction(simplify(An,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','An.m')


%%% plug in
clear;

p = .9;
yl = 10;
yh = 20;
r = .2;

as = As(p,yh,yl)
as = as(2)

vs = log(as+yl) + p*2*log(yh-(as/2)) + (1-p)*(log(yh-as) + log(yh))

c1s = as+yl
c2s_no_def = yh-(as/2)
c2s_def = yh-as
yh


an = An(r,yh,yl)


vn = log(an+yl) + 2*log(yh-(an*(1+r)/2))

c1n = an+yl
c2n_def = yh-(an*(1+r)/2)



