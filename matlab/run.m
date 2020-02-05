function [h,util] = run(given,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement)


[h,~,simc] = dc_obj_chow_pol_finite(given,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement);

util = mean(simc(:,7));



