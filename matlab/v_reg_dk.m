function vse = v_reg_dk(L,alpha,k,p1,p2,y)
%V_REG_DK
%    VSE = V_REG_DK(L,ALPHA,K,P1,P2,Y)

%    This function was generated by the Symbolic Math Toolbox version 8.2.
%    14-Dec-2018 10:45:06

t2 = k.^2;
t3 = p2.^2;
t4 = alpha.^2;
t5 = alpha-2.0;
t6 = 1.0./t5;
t7 = p1.^2;
t8 = t2.*t3.*4.0;
t9 = alpha.*p2.*y.*8.0;
t10 = t2.*t3.*t4.*4.0;
t11 = L.*p2.*t4.*4.0;
t12 = alpha.*k.*p1.*p2.*8.0;
t16 = p2.*t4.*y.*4.0;
t17 = alpha.*t2.*t3.*8.0;
t18 = L.*alpha.*p2.*8.0;
t19 = k.*p1.*p2.*4.0;
t20 = k.*p1.*p2.*t4.*4.0;
t13 = t7+t8+t9+t10+t11+t12-t16-t17-t18-t19-t20;
t14 = sqrt(t13);
t15 = 1.0./p2;
t21 = alpha-1.0;
t22 = 1.0./t5.^2;
vse = alpha.*log(k+t6.*(k-alpha.*k)+t6.*t15.*(p1./2.0-t14./2.0))-t21.*log(t21.*t22.*(L.*-8.0+y.*8.0+L.*alpha.*4.0-alpha.*y.*4.0+k.*p1.*4.0+k.*t14.*2.0-alpha.*k.*p1.*4.0).*(-1.0./2.0)+(p2.*t21.*t22.*(t2.*4.0-alpha.*t2.*4.0))./2.0-(t15.*t21.*t22.*(t7-p1.*t14))./2.0);
