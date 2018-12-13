function [util1,util2,util3,util4,w1,w2,w3,w4] = ...
         gen_d_8s(A,B,Aprime,Bprime,r_high,r_lend,r_water,water_lending,Y_high,Y_low,lambda_high,lambda_low,p1,p2,alpha)

Aprime_inc = (Aprime./(1+r_high)).*(Aprime<=0) + (Aprime./(1+r_lend)).*(Aprime>0);
Bprime_inc = (Bprime./(1+r_water)).*(Bprime>=B) + (B./(1+r_water)).*(Bprime<B); %% capped at B because the rest is raised through L
L          = 0.*(Bprime>=B) + ((Bprime - B)./(1+r_water)).*(Bprime<B); %% need to raise Bprime-B (or zero)

if water_lending == 0
    L=L.*(Aprime<=0);
    Bprime_inc=Bprime_inc.*(Aprime<=0);
end
    
y_12 =  A + B - Aprime_inc -  Bprime_inc ;
y_34 = A + B - Aprime_inc ; %%% don't get ANY Bprime_inc !! (default, so go back to zero...)

debt_12 = 1;
[util1,w1] = u_d(L,debt_12,alpha,p1,p2, Y_high + y_12, lambda_high);
[util2,w2] = u_d(L,debt_12,alpha,p1,p2, Y_low + y_12, lambda_low);
 
debt_34 = 0;
[util3,w3] = u_d((L.*0),debt_34,alpha,p1,p2,Y_high + y_34, lambda_high);
[util4,w4] = u_d((L.*0),debt_34,alpha,p1,p2,Y_low + y_34, lambda_low);
 