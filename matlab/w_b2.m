function out1 = w_b2(A,Ab,Ap,alpha,p,rh,rl,y)
%W_B2
%    OUT1 = W_B2(A,AB,AP,ALPHA,P,RH,RL,Y)

%    This function was generated by the Symbolic Math Toolbox version 8.2.
%    08-Dec-2018 13:23:15

out1 = (alpha.*(A-Ap+y+A.*rh+A.*rl-Ab.*rh-Ap.*rl+rh.*y+rl.*y+A.*rh.*rl+rh.*rl.*y))./(p.*(rl+rh.*rl+1.0));
