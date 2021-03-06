function out1 = cut_dk(alpha,k,p1,p2,y)
%CUT_DK
%    OUT1 = CUT_DK(ALPHA,K,P1,P2,Y)

%    This function was generated by the Symbolic Math Toolbox version 8.2.
%    15-Dec-2018 17:56:10

t2 = p1.^2;
t3 = k.^2;
t4 = p2.^2;
t5 = -alpha+1.0;
t6 = 1.0./sqrt(t5);
t7 = t3.*t4.*4.0;
t8 = alpha.*p2.*y.*8.0;
t9 = alpha.*k.*p1.*p2.*4.0;
t15 = alpha.*t2;
t16 = k.*p1.*p2.*4.0;
t10 = t2+t7+t8+t9-t15-t16-alpha.*t3.*t4.*4.0;
t11 = sqrt(t10);
t12 = 1.0./p2;
t13 = alpha-2.0;
t14 = 1.0./t13;
t17 = alpha.^2;
out1 = (t12.*t14.*(t2-t7-t15+t16+alpha.*t3.*t4.*8.0-alpha.*p2.*y.*4.0-t3.*t4.*t17.*4.0+p2.*t17.*y.*2.0-alpha.*k.*p1.*p2.*8.0+k.*p1.*p2.*t17.*4.0))./(alpha.*4.0-4.0)+(t12.*t14.*(p1-k.*p2.*2.0).*((alpha.*p1)./2.0+t6.*t11-alpha.*k.*p2-(alpha.*t6.*t11)./2.0))./4.0;
