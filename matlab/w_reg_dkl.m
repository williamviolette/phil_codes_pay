function wse = w_reg_dkl(L,alpha,k,p1,y)
%W_REG_DKL
%    WSE = W_REG_DKL(L,ALPHA,K,P1,Y)

%    This function was generated by the Symbolic Math Toolbox version 8.2.
%    13-May-2019 13:54:26

wse = -k+alpha.*k-(L.*alpha-alpha.*y)./p1;