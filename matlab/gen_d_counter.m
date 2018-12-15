function [util1,util2,w1,w2] = ...
         gen_d_counter(A,Aprime,r_high,r_lend,Y_high,Y_low,p1,p2,alpha,lambda_high,lambda_low)

Aprime_inc = (Aprime./(1+r_high)).*(Aprime<=0) + (Aprime./(1+r_lend)).*(Aprime>0);
 
[util1,w1] = u_d(0,0,alpha,p1,p2,Y_high + A - Aprime_inc, lambda_high );
[util2,w2] = u_d(0,0,alpha,p1,p2,Y_low  + A - Aprime_inc, lambda_low  );


  
