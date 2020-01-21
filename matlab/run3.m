function [h,util, ...
    h_t1,h_t2,h_t3, simc_t1,simc_t2,simc_t3] = run3(given,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement)


[h_t1,~,simc_t1] = dc_obj_chow_pol_finite(given(1,:),prob,nA,sigA,Alb(1),Aub(1),nB,sigB,Blb(1),nD,chain,s,int_size,refinement);

[h_t2,~,simc_t2] = dc_obj_chow_pol_finite(given(2,:),prob,nA,sigA,Alb(2),Aub(2),nB,sigB,Blb(2),nD,chain,s,int_size,refinement);

[h_t3,~,simc_t3] = dc_obj_chow_pol_finite(given(3,:),prob,nA,sigA,Alb(3),Aub(3),nB,sigB,Blb(3),nD,chain,s,int_size,refinement);


h = [h_t1 h_t2 h_t3];

util = [mean(simc_t1(:,7)) mean(simc_t2(:,7)) mean(simc_t3(:,7))];
% util = [util1 util2 util3];



