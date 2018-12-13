function [h,mom] = con_objopt(a,given,data,option,option_moments,weights,prob,A,Aprime,Agrid,inA,minA,nA,chain)

given(option)=a; % put guess in given

est_mom = con_obj(given,prob,A,Aprime,Agrid,inA,minA,nA,chain);

%h = sum( ( weights'.*( (est_mom(option_moments)-data(option_moments))./data(option_moments)) ).^2 );


mom = (est_mom(option_moments)-data(option_moments));

h = mom'*weights*mom;

%h = sum( ( ( (est_mom(option_moments)-data(option_moments))./data(option_moments)) ).^2 );


end