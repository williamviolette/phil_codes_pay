function out1 = w_b_d(L,p1,p2)
%W_B_D
%    OUT1 = W_B_D(L,P1,P2)

%    This function was generated by the Symbolic Math Toolbox version 8.2.
%    12-Dec-2018 11:52:36

out1 = ((p1-sqrt(L.*p2.*-4.0+p1.^2)).*(-1.0./2.0))./p2;
