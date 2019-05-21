function [h,mom,est_mom] = dc_objopt_chow(a,given,data,option,option_moments,weights,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven)

given(option)=a; % put guess in given

est_mom =dc_obj_chow(given,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven);

mom = (est_mom(option_moments)-data);

h = mom'*weights*mom;

est_mom=est_mom(option_moments);

end