function [h,mom,est_mom] = d_objopt_8s(a,given,data,option,option_moments,weights,prob,A,Aprime,nA,B,Bprime,nB,chain,key4)

given(option)=a; % put guess in given

est_mom = d_obj_8s(given,prob,A,Aprime,nA,B,Bprime,nB,chain,key4);

mom = (est_mom(option_moments)-data);

h = mom'*weights*mom;

est_mom=est_mom(option_moments);

end