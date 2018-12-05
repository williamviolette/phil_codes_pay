

%{a

%%% cobb-doug  THIS WORKS WELL TO BALL-PARK EFFECTS!
clear;
syms x1 w1 x2 w2 y y2 p B L r r1 G A l1 l2 d z D

assume(r>0 & r<1)
assume(r1>0 & r1<1)
assume(l1>0)
assume(p>0)
assume(w1>0)
assume(w2>0)
assume(x1>0)
assume(x2>0)
assume(y>0)
assume(y2>0)
assume(d>0 & d<1)
assume(D>0 & D<1)


lan  =  (1-d)*log(x1) + (d)*log(w1) + l1*( y - ( ( A - ((p*w1)/(1+r)) ) /(1+r1) ) - ((p*w1)/(1+r))  - (p*w1+x1) )    

dw1 = diff(lan,w1)

dx1 = diff(lan,x1)

dl1 = diff(lan,l1)

[w1s,x1s,l1s,pt,st] = solve([dw1,dx1,dl1],[w1,x1,l1],'ReturnConditions',true)

w1s

simplify(w1s)

wt = d*(y-(A/(1+r1)))/(p*(((1+r)*(1+r1)+r1)/((1+r)*(1+r1))))

simplify(wt)


eval(subs(w1s,[r,r1,y,A,d,p],[03,.04,1000,100,.03,10]))

eval(subs(wt ,[r,r1,y,A,d,p],[03,.04,1000,100,.03,10]))


% subs(d*log(x1s) + z*log(w1s),z,1-d)
% expand(d*log(x1s) + z*log(w1s))





