function out1 = A_cut2(A,alpha,r,y)
%A_CUT2
%    OUT1 = A_CUT2(A,ALPHA,R,Y)

%    This function was generated by the Symbolic Math Toolbox version 8.2.
%    03-Dec-2018 15:21:33

out1 = -((r+1.0).*(-A+A.*alpha+alpha.*y))./(-alpha+r+1.0);
