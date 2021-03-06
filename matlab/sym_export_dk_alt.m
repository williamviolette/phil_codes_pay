

%{a

%%% cobb-doug  THIS WORKS WELL TO BALL-PARK EFFECTS!
%matlabFunction(simplify(vse,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','v_b_con.m')
%eval(subs(wse,[A,Ap,p,rl,rh,y,alpha],[10,-100,20,.02,.05,10000,.02]))
%eval(subs(diff(wse,rl),[A,Ap,p,rl,rh,y,alpha],[10,-100,20,.02,.05,10000,.02]))
%eval(subs(diff(wse,rh),[A,Ap,p,rl,rh,y,alpha],[10,-100,20,.02,.05,10000,.02]))



%}


%{a

%%% NOW JUST DO SIMPLE COBB DOUG!
%%% cobb-doug reg

clear;
syms x w y p1 p2 r A l alpha Ap L k

assume(r>0 & r<1)
assume(l>0)
assume(p1>0)
assume(p2>0)
assume(w>0)
assume(x>0)
assume(y>0)
assume(alpha>0 & alpha<1)



p = p1+p2*w;
BC = ( y - L -   (p*w+x) ) 

lan  =  (1-alpha)*log(x) + (alpha)*log(k*w) + l*BC

dw = simplify(diff(lan,w))
dx = diff(lan,x)
dl = diff(lan,l)


[ws,xs,ls]  =  solve([dw,dx,dl],[w,x,l])

%[ws,xs,ls,pt,st]  =  solve([dw,dx,dl],[w,x,l],'ReturnConditions',true)

%s1=eval(subs(st,[p1,p2,y,alpha,A,Ap,r],[15,.2,30000,.02,-100,-100,.1]))

simplify(ws)
wt=eval(subs(ws,[p1,p2,y,alpha,A,Ap,r,L,k],[15,.2,30000,.02,100,100,.1,100,0]))
%wt=eval(subs(ws,[p1,p2,y,alpha,A,Ap,r],[15,.2,30000,.02,200,100,0]))
%xt=eval(subs(xs,[p1,p2,y,alpha,A,Ap,r],[15,.2,30000,.02,100,100,.1]))
% eval(subs(xs,[p1,p2,y,alpha,A,Ap,r],[1,1,30000,.02,100,100,.1]))
% vs = eval(subs((1-alpha)*log(wt) + (alpha)*log(xt),alpha,.02))
% % vs(2,1)
% % eval(subs(vs,[p1,p2,y,alpha,A,Ap,r],[15,.2,30000,.02,100,100,.1]))
%eval(subs(ws,[p1,p2,y,alpha,rh,A,Ap],[1,1,30000,.02,.1,100,100]))


steps=10
wse = simplify(ws(1,1),'IgnoreAnalyticConstraints',true,'Steps',steps) 
xse = simplify(xs(1,1),'IgnoreAnalyticConstraints',true,'Steps',steps) 


vse = (1-alpha)*log(xse) + (alpha)*log(k*wse)

matlabFunction(wse,'File','w_reg_dk.m')
matlabFunction(vse,'File','v_reg_dk.m')


%%% cut point?
% [cut_point,pc,sc] = solve(-wse*(p1+p2*wse) - Ap, Ap,'ReturnConditions',true)
% %s1=eval(subs(st,[p1,p2,y,alpha,A,Ap,r],[15,.2,30000,.02,-100,-100,.1]))
% matlabFunction(simplify(cut_point,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','A_cut_con.m')

%%% borrow 3x consumption! per period
%cut_point3 = solve(-m*wse*p - Ap, Ap)

wsr0=simplify(subs(wse,r,0));

wst=simplify(wsr0*(p1+p2*wsr0));

cut_point3 = simplify(solve(-wst-L,L));

t1=eval(subs(cut_point3,[p1,p2,y,alpha,k],[15,.1,30000,.02,0]))

% [cut_point3,pc,sc] = solve(-m*wsr0*(p1+p2*wsr0) - Ap, Ap,'ReturnConditions',true)

matlabFunction(simplify(cut_point3(1,1),'IgnoreAnalyticConstraints',true,'Steps',steps),'File','cut_dk.m')

%%%%% NEED TO SOLVE FOR EXACT FUNDING

syms wt

weq = solve( -wt*(p1+p2*wt) - L,wt)

eval(subs(weq,[L,p1,p2],[-1000,15,.2]))

weq_opt = simplify(weq(1,1));
xeq_opt = simplify(y - L - weq_opt*(p1 + p2*weq_opt));

veq_opt = simplify((1-alpha)*log(xeq_opt) + (alpha)*log(weq_opt*k));

matlabFunction(simplify(weq_opt,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','w_b_dk.m')
matlabFunction(simplify(veq_opt,'IgnoreAnalyticConstraints',true,'Steps',steps),'File','v_b_dk.m')




%}

