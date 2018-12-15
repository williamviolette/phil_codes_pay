function [h,mom,est_mom] = dk_objopt_8s(a,given,data,option,option_moments,weights,prob,A,Aprime,nA,B,Bprime,nB,chain)

given(option)=a; % put guess in given

est_mom = dk_obj_8s(given,prob,A,Aprime,nA,B,Bprime,nB,chain);

mom = (est_mom(option_moments)-data);

h = mom'*weights*mom;

est_mom=est_mom(option_moments);

end