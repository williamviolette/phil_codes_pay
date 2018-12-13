

%{a

%%% cobb-doug  THIS WORKS WELL TO BALL-PARK EFFECTS!
clear;
syms x w y p1 p2 rl rh A l alpha Ap m

assume(rl>0 & rl<1)
assume(rh>0 & rh<1)
assume(l>0)
assume(p1>0)
assume(p2>0)
assume(w>0)
assume(x>0)
assume(y>0)
assume(alpha>0 & alpha<1)
assume(m>0)


p = p1+p2*w;

BC = ( (y+A) - ( ( Ap + (m*p*w) ) /(1+rh) ) + (p*w)  -   (p*w + x) ) 

lan  =  (1-alpha)*log(x) + (alpha)*log(w) + l*BC

steps=10
dw = simplify(diff(lan,w),'IgnoreAnalyticConstraints',true,'Steps',steps)
dx = simplify(diff(lan,x),'IgnoreAnalyticConstraints',true,'Steps',steps)
dl = simplify(diff(lan,l),'IgnoreAnalyticConstraints',true,'Steps',steps)

[ws,xs,ls] = solve([dw,dx,dl],[w,x,l])

%[ws,xs,ls,pt,st] = solve([dw,dx,dl],[w,x,l],'ReturnConditions',true)



simplify(ws)

eval(subs(ws,[p1,p2,y,alpha,rh,A,Ap,m],[1,1,30000,.02,.1,100,100,3]))
eval(subs(xs,[p1,p2,y,alpha,rh,A,Ap,m],[1,1,30000,.02,.1,100,100,3]))

steps=10

wse = simplify(ws(1,1),'IgnoreAnalyticConstraints',true,'Steps',steps) 
eval(subs(wse,[p1,p2,y,alpha,rh,A,Ap],[1,1,30000,.02,.1,100,100]))

xse = simplify(xs(1,1),'IgnoreAnalyticConstraints',true,'Steps',steps) 
eval(subs(xse,[p1,p2,y,alpha,rh,A,Ap],[1,1,30000,.02,.1,100,100]))

vse = (1-alpha)*log(xse) + (alpha)*log(wse)

matlabFunction(wse,'File','w_b_con.m')
matlabFunction(vse,'File','v_b_con.m')
%matlabFunction(simplify(vse,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','v_b_con.m')

%eval(subs(wse,[A,Ap,p,rl,rh,y,alpha],[10,-100,20,.02,.05,10000,.02]))

%eval(subs(diff(wse,rl),[A,Ap,p,rl,rh,y,alpha],[10,-100,20,.02,.05,10000,.02]))

%eval(subs(diff(wse,rh),[A,Ap,p,rl,rh,y,alpha],[10,-100,20,.02,.05,10000,.02]))



%}


%{a

%%% NOW JUST DO SIMPLE COBB DOUG!
%%% cobb-doug reg

clear;
syms x w y p1 p2 r A l alpha Ap

assume(r>0 & r<1)
assume(l>0)
assume(p1>0)
assume(p2>0)
assume(w>0)
assume(x>0)
assume(y>0)
assume(alpha>0 & alpha<1)


p = p1+p2*w;
BC = ( (y+A) - ((Ap)/(1+r)) -   (p*w+x) ) 

lan  =  (1-alpha)*log(x) + (alpha)*log(w) + l*BC

dw = diff(lan,w)
dx = diff(lan,x)
dl = diff(lan,l)

[ws,xs,ls,pt,st]  =  solve([dw,dx,dl],[w,x,l],'ReturnConditions',true)



%s1=eval(subs(st,[p1,p2,y,alpha,A,Ap,r],[15,.2,30000,.02,-100,-100,.1]))

simplify(ws)
wt=eval(subs(ws,[p1,p2,y,alpha,A,Ap,r],[15,.2,30000,.02,100,100,.1]))
wt=eval(subs(ws,[p1,p2,y,alpha,A,Ap,r],[15,.2,30000,.02,200,100,0]))
xt=eval(subs(xs,[p1,p2,y,alpha,A,Ap,r],[15,.2,30000,.02,100,100,.1]))
 eval(subs(xs,[p1,p2,y,alpha,A,Ap,r],[1,1,30000,.02,100,100,.1]))
 vs = eval(subs((1-alpha)*log(wt) + (alpha)*log(xt),alpha,.02))
% % vs(2,1)
% % eval(subs(vs,[p1,p2,y,alpha,A,Ap,r],[15,.2,30000,.02,100,100,.1]))
%eval(subs(ws,[p1,p2,y,alpha,rh,A,Ap],[1,1,30000,.02,.1,100,100]))


steps=10
wse = simplify(ws(4,1),'IgnoreAnalyticConstraints',true,'Steps',steps) 
xse = simplify(xs(4,1),'IgnoreAnalyticConstraints',true,'Steps',steps) 


vse = (1-alpha)*log(xse) + (alpha)*log(wse)

matlabFunction(wse,'File','w_reg_con.m')
matlabFunction(vse,'File','v_reg_con.m')


%%% cut point?
% 
% [cut_point,pc,sc] = solve(-wse*(p1+p2*wse) - Ap, Ap,'ReturnConditions',true)
% 
% 
% %s1=eval(subs(st,[p1,p2,y,alpha,A,Ap,r],[15,.2,30000,.02,-100,-100,.1]))
% 
% matlabFunction(simplify(cut_point,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','A_cut_con.m')
% 

syms m
%%% borrow 3x consumption! per period
%cut_point3 = solve(-m*wse*p - Ap, Ap)

wsr0=simplify(subs(wse,r,0));

wst=simplify(m*wsr0*(p1+p2*wsr0));

cut_point3 = simplify(solve(-wst-Ap,Ap));

t1=eval(subs(cut_point3,[p1,p2,y,alpha,A,m],[15,.2,30000,.02,-100,3]))
% [cut_point3,pc,sc] = solve(-m*wsr0*(p1+p2*wsr0) - Ap, Ap,'ReturnConditions',true)

matlabFunction(simplify(cut_point3(2,1),'IgnoreAnalyticConstraints',true,'Steps',steps),'File','A_cut3_con.m')

% 
% 
% %%% borrowing a little last period
% cut_point2 = solve(-wse*p + A - Ap, Ap)
% 
% matlabFunction(simplify(cut_point2,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','A_cut2_con.m')
% 
% %%% borrowing a ton last period
% cut_point2_1 = solve(-2*wse*p - Ap, Ap)
% 
% matlabFunction(simplify(cut_point2_1,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','A_cut2_1_con.m')
% 



%}

