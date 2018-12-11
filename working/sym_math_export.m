

%{a

%%% cobb-doug  THIS WORKS WELL TO BALL-PARK EFFECTS!
clear;
syms x w y p rl rh A l alpha

assume(rl>0 & rl<1)
assume(rh>0 & rh<1)
assume(l>0)
assume(p>0)
assume(w>0)
assume(x>0)
assume(y>0)
assume(alpha>0 & alpha<1)



BC = ( y - ( ( A - ((p*w)/(1+rl)) ) /(1+rh) ) - ((p*w)/(1+rl))  - (p*w+x) ) 

lan  =  (1-alpha)*log(x) + (alpha)*log(w) + l*BC

dw = diff(lan,w)
dx = diff(lan,x)
dl = diff(lan,l)

[ws,xs,ls,pt,st] = solve([dw,dx,dl],[w,x,l],'ReturnConditions',true)

ws

solutions=[ws]

simplify(ws)









% subs(d*log(x1s) + z*log(w1s),z,1-d)
% expand(d*log(x1s) + z*log(w1s))





