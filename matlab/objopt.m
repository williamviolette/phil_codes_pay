function [h,mom,est_mom] = objopt(a,given,data,option,option_moments_est,weights,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,s,int_size,refinement)

given(option)=a; % put guess in given

est_mom=obj(given,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,s,int_size,refinement);

mom = (est_mom(option_moments_est)-data);

h = mom'*weights*mom;

est_mom=est_mom(option_moments_est);

end