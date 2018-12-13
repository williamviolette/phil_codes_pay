function [h,mom,est_mom] = d_objopt(a,given,data,option,option_moments,weights,prob,A,Aprime,nA,B,Bprime,nB,chain)

given(option)=a; % put guess in given

est_mom = d_obj(given,prob,A,Aprime,nA,B,Bprime,nB,chain);

mom = (est_mom(option_moments)-data(option_moments));

h = mom'*weights*mom;

est_mom=est_mom(option_moments);

end