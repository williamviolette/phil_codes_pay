function out1 = cut_dkl(alpha,k,p1,y)
%CUT_DKL
%    OUT1 = CUT_DKL(ALPHA,K,P1,Y)

%    This function was generated by the Symbolic Math Toolbox version 8.2.
%    13-May-2019 13:54:26

out1 = y+k.*p1+y./(alpha-1.0);
