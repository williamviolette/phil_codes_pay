function [h,mom,est_mom] = dc_objopt(a,given,data,option,option_moments,weights,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s)

given(option)=a; % put guess in given

est_mom = dc_obj(given,prob,A,Aprime,nA,B,Bprime,nB,D,Dprime,nD,chain,s);

mom = (est_mom(option_moments)-data);

h = mom'*weights*mom;

est_mom=est_mom(option_moments);

end