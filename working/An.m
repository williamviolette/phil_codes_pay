function out1 = An(r,yh,yl)
%AN
%    OUT1 = AN(R,YH,YL)

%    This function was generated by the Symbolic Math Toolbox version 8.2.
%    14-Nov-2018 11:53:04

out1 = yl.*(-2.0./3.0)+(yh.*(2.0./3.0))./(r+1.0);