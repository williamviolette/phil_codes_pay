function [h,mom,est_mom] = objopt(a,given,data,option,option_moments_est,weights,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X)

given(option)=a; % put guess in given

est_mom=obj(given,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X);

mom = (est_mom(option_moments_est)-data);

h = mom'*weights*mom;

est_mom=est_mom(option_moments_est);

end