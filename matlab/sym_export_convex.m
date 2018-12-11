

%{

%%% cobb-doug  THIS WORKS WELL TO BALL-PARK EFFECTS!
clear;
syms x w y p rl rh A l alpha Ap

assume(rl>0 & rl<1)
assume(rh>0 & rh<1)
assume(l>0)
assume(p>0)
assume(w>0)
assume(x>0)
assume(y>0)
assume(alpha>0 & alpha<1)


BC = ( (y+A) - ( ( Ap + ((p*w)/(1+rl)) ) /(1+rh) ) + ((p*w)/(1+rl))  -   (p*w+x) ) 

lan  =  (1-alpha)*log(x) + (alpha)*log(w) + l*BC

dw = diff(lan,w)
dx = diff(lan,x)
dl = diff(lan,l)

[ws,xs,ls,pt,st] = solve([dw,dx,dl],[w,x,l],'ReturnConditions',true)

ws

simplify(ws)

wse = ws(2,1)
xse = xs(2,1)

vse = (1-alpha)*log(xse) + (alpha)*log(wse)

steps=10
matlabFunction(simplify(wse,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','w_b.m')
matlabFunction(simplify(vse,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','v_b.m')

eval(subs(wse,[A,Ap,p,rl,rh,y,alpha],[10,-100,20,.02,.05,10000,.02]))

eval(subs(diff(wse,rl),[A,Ap,p,rl,rh,y,alpha],[10,-100,20,.02,.05,10000,.02]))

eval(subs(diff(wse,rh),[A,Ap,p,rl,rh,y,alpha],[10,-100,20,.02,.05,10000,.02]))

%}



%{

%%% ADD EXTRA BORROWING STATE (CONDITIONAL ON FIRST PERIOD BORROWING...)
clear;
syms x w y p rl rh A l alpha Ap Ab

assume(rl>0 & rl<1)
assume(rh>0 & rh<1)
assume(l>0)
assume(p>0)
assume(w>0)
assume(x>0)
assume(y>0)
assume(alpha>0 & alpha<1)


BC = ( (y+A) - ( ( Ap + ((p*w - Ab)/(1+rl)) ) /(1+rh) ) + ((p*w - Ab)/(1+rl))  -   (p*w+x) ) 

lan  =  (1-alpha)*log(x) + (alpha)*log(w) + l*BC

dw = diff(lan,w)
dx = diff(lan,x)
dl = diff(lan,l)

[ws,xs,ls,pt,st] = solve([dw,dx,dl],[w,x,l],'ReturnConditions',true)

ws

simplify(ws)

wse = ws(1,1)
xse = xs(1,1)

vse = (1-alpha)*log(xse) + (alpha)*log(wse)

steps=10
matlabFunction(simplify(wse,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','w_b2.m')
matlabFunction(simplify(vse,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','v_b2.m')


%}







%{

%%% NOW JUST DO SIMPLE COBB DOUG!
%%% cobb-doug reg
clear;
syms x w y p r A l alpha Ap

assume(r>0 & r<1)
assume(l>0)
assume(p>0)
assume(w>0)
assume(x>0)
assume(y>0)
assume(alpha>0 & alpha<1)


BC = ( (y+A) - ((Ap)/(1+r)) -   (p*w+x) ) 

lan  =  (1-alpha)*log(x) + (alpha)*log(w) + l*BC

dw = diff(lan,w)
dx = diff(lan,x)
dl = diff(lan,l)

[ws,xs,ls,pt,st] = solve([dw,dx,dl],[w,x,l],'ReturnConditions',true)

ws

simplify(ws)

wse = ws(1,1)
xse = xs(1,1)

vse = (1-alpha)*log(xse) + (alpha)*log(wse)

steps=10
% matlabFunction(simplify(wse,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','w_reg.m')
% matlabFunction(simplify(vse,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','v_reg.m')


%%% cut point?

cut_point = solve(-wse*p - Ap, Ap)
% 
% matlabFunction(simplify(cut_point,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','A_cut.m')



%%% borrowing a little last period
cut_point2 = solve(-wse*p + A - Ap, Ap)
% 
% matlabFunction(simplify(cut_point2,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','A_cut2.m')

%%% borrowing a ton last period
cut_point2_1 = solve(-2*wse*p - Ap, Ap)
% 
% matlabFunction(simplify(cut_point2_1,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','A_cut2_1.m')



%}





%{

%%% NOW JUST DO SIMPLE COBB DOUG!
%%% cobb-doug reg
clear;
syms x w y p r A l alpha Ap rho1 rho2

assume(r>0 & r<1)
assume(l>0)
assume(p>0)
assume(w>0)
assume(x>0)
assume(y>0)
assume(alpha>0 & alpha<1)
assume(rho1>0)
assume(rho2>0)

BC = ( y -  ((rho1+w*rho2)*w + x) ) 

lan  =  (1-alpha)*log(x) + (alpha)*log(w) + l*BC

dw = diff(lan,w)
dx = diff(lan,x)
dl = diff(lan,l)

[ws,xs,ls,pt,st] = solve([dw,dx,dl],[w,x,l],'ReturnConditions',true)

simplify(ws)

eval(subs(ws,[rho1,rho2,y,alpha],[1,1,30000,.02]))
eval(subs(xs,[rho1,rho2,y,alpha],[1,1,30000,.02]))


xs


wse = ws(1,1)
xse = xs(1,1)


%}

