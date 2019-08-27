function [h,mom,est_mom] = dc_objopt_chow_finite(a,given,data,option,option_moments,weights,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement)

given(option)=a; % put guess in given

est_mom=dc_obj_chow_pol_finite(given,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement);

mom = (est_mom(option_moments)-data);

h = mom'*weights*mom;

est_mom=est_mom(option_moments);

end