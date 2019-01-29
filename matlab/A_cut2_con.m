function out1 = A_cut2_con(A,alpha,p1,p2,r,w,y)
%A_CUT2_CON
%    OUT1 = A_CUT2_CON(A,ALPHA,P1,P2,R,W,Y)

%    This function was generated by the Symbolic Math Toolbox version 8.2.
%    11-Dec-2018 13:19:46

t2 = 1.0./p2;
t3 = r+1.0;
t4 = 1.0./t3;
t5 = p2.^2;
t6 = w.^2;
t7 = p1.^2;
t8 = alpha.^2;
t9 = r.^2;
t10 = t7./2.0;
t11 = t7.*t9;
t12 = r.*t7.*2.0;
t13 = t7.*t8;
t14 = alpha.*p2.*y.*8.0;
t15 = t5.*t6.*t8;
t16 = alpha.*p2.*r.*y.*1.6e1;
t17 = A.*alpha.*p2.*t9.*8.0;
t18 = p1.*p2.*t8.*w.*2.0;
t19 = alpha.*p2.*t9.*y.*8.0;
t20 = A.*alpha.*p2.*r.*8.0;
t31 = alpha.*t7.*2.0;
t32 = alpha.*r.*t7.*2.0;
t33 = p2.*t8.*y.*4.0;
t34 = alpha.*p1.*p2.*w.*2.0;
t35 = A.*p2.*r.*t8.*4.0;
t36 = p2.*r.*t8.*y.*8.0;
t37 = A.*p2.*t8.*t9.*4.0;
t38 = p2.*t8.*t9.*y.*4.0;
t39 = alpha.*p1.*p2.*r.*w.*2.0;
t21 = t7+t11+t12+t13+t14+t15+t16+t17+t18+t19+t20-t31-t32-t33-t34-t35-t36-t37-t38-t39;
t22 = sqrt(t21);
t23 = (t5.*t6)./2.0;
t24 = A.*p2;
t25 = A.*p2.*r;
t26 = p1.*p2.*w;
t27 = t10+t23+t24+t25+t26;
t28 = t2.*t4.*t27;
t29 = alpha-2.0;
t30 = 1.0./t29;
t40 = (p1.*t22)./2.0;
t41 = (r.*t7)./2.0;
t42 = (p2.*t22.*w)./2.0;
t43 = (p1.*p2.*r.*w)./2.0;
out1 = [t28-t2.*t4.*t30.*(-t10+t40+t41+t42+t43-t5.*t6-p1.*p2.*w.*(3.0./2.0));t28+t2.*t4.*t30.*(t10+t40-t41+t42-t43+t5.*t6+p1.*p2.*w.*(3.0./2.0))];