function [h,mom,est_mom] = dc_objopt_inc_finite(a,given,data,option,option_moments,weights,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement)

given(:,option)=a; % put guess in given

est_mom1=dc_obj_chow_pol_finite(given(1,:),prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement);
est_mom2=dc_obj_chow_pol_finite(given(2,:),prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement);
est_mom3=dc_obj_chow_pol_finite(given(3,:),prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement);

est_mom = [est_mom1(option_moments); est_mom2(option_moments); est_mom3(option_moments)] ;

mom = (est_mom-data(:)) ;

h = mom'*weights*mom ;

end