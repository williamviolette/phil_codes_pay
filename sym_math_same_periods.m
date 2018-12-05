

%{a

%%% cobb-doug  THIS WORKS WELL TO BALL-PARK EFFECTS!
clear;
syms x1 w1 x2 w2 y1 y2 p B L r G A l1 l2 d z D

assume(r>0 & r<1)
assume(l1>0)
assume(p>0)
assume(w1>0)
assume(w2>0)
assume(x1>0)
assume(x2>0)
assume(y1>0)
assume(y2>0)

assume(D>0 & D<1)

lan  =  d*log(x1) + z*log(w1)  + (1/(1+D))*( d*log(x2) + z*log(w2) )  +  l1*( (y1) + (y2/(1+r))  - (p*w1+x1 + ((p*w2+x2)/(1+r))) )    

dw1 = diff(lan,w1)
dw2 = diff(lan,w2)

dx1 = diff(lan,x1)
dx2 = diff(lan,x2)

dl1 = diff(lan,l1)

[w1s,w2s,x1s,x2s,l1s,ps,cs] = solve([dw1,dw2,dx1,dx2,dl1],[w1,w2,x1,x2,l1],'ReturnConditions',true)


simplify(w1s)
simplify(w2s)


subs(d*log(x1s) + z*log(w1s),z,1-d)

expand(d*log(x1s) + z*log(w1s))





