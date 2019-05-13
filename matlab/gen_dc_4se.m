function [util1,util2,util3,util4,w1,w2,w3,w4] = ...
         gen_dc_4se(A,B,D,Aprime,Bprime,Dprime,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,p1d,p2d,pd,alpha,k_high,k_low,lambda_high,lambda_low)




if water_lending == 0
    r_w = r_water.*(Aprime<=0) + (r_water+.5).*(Aprime>0); 
else
    r_w = r_water; 
end

Aprime_inc = (Aprime./(1+r_high)).*(Aprime<=0) + (Aprime./(1+r_lend)).*(Aprime>0);  %% UNCHANGED

Bprime_inc = (Bprime.*(Bprime>=B) + B.*(Bprime<B))./(1+r_w); %% capped at B because the rest is raised through L

cc = (D==0).*(Dprime==0); 
cd = (D==0).*(Dprime==1);
dc = (D==1).*(Dprime==0);
dd = (D==1).*(Dprime==1);

if p1==p1d && p2==p2d
    p1f = p1;
    p2f = p2;
else
    p1f = p1.*cc + p1d.*cd + p1.*dc + p1d.*dd;
    p2f = p2.*cc + p2d.*cd + p2.*dc + p2d.*dd;
end

Lf_12 = ((Bprime - B)./(1+r_w)).*(Bprime<B).*cc ;

y_34f = (A-Aprime_inc + B)     + (-Bprime_inc).*(cd+dd) - pd.*(cd+dd) ;

y_12f =  y_34f + (-1.*Bprime_inc).*cc  ;


if nargout>4
    debt_12 = 1;
    [util1,w1] = u_dk(Lf_12,debt_12,alpha,p1f,p2f, Y_high + y_12f, lambda_high,k_high);
    [util2,w2] = u_dk(Lf_12,debt_12,alpha,p1f,p2f, Y_low  + y_12f, lambda_low,k_low);
 
    debt_34 = 0;
    [util3,w3] = u_dk(0,debt_34,alpha,p1f,p2f,Y_high + y_34f, lambda_high,k_high);
    [util4,w4] = u_dk(0,debt_34,alpha,p1f,p2f,Y_low  + y_34f, lambda_low,k_low);
else
        debt_12 = 1;
        [util1] = u_dk(Lf_12,debt_12,alpha,p1f,p2f, Y_high + y_12f, lambda_high,k_high);
        [util2] = u_dk(Lf_12,debt_12,alpha,p1f,p2f, Y_low  + y_12f, lambda_low,k_low);

        debt_34 = 0;
        [util3] = u_dk(0,debt_34,alpha,p1f,p2f,Y_high + y_34f, lambda_high,k_high);
        [util4] = u_dk(0,debt_34,alpha,p1f,p2f,Y_low  + y_34f, lambda_low,k_low);
end
    


% [cc_1,cc_w1] = u_dk(L,1,   alpha,p1,p2,   Y + A-Aprime_inc + B-Bprime_inc  , lambda_high,k_high);
% [cd_1,cd_w1] = u_dk(L.*0,0,alpha,p1c,p2c, Y + A-Aprime_inc + B-Bprime_inc , lambda_high,k_high);
% [dc_1,dc_w1] = u_dk(L.*0,0,alpha,p1c,p2c, Y + A-Aprime_inc + B   , lambda_high,k_high);
% [dd_1,dd_w1] = u_dk(L.*0,0,alpha,p1c,p2c, Y + A-Aprime_inc + B-Bprime_inc , lambda_high,k_high);
% 
% util1 = cc_1.*(C==0).*(Cprime==0) + cd_1.*(C==0).*(Cprime==1) + dc_1.*(C==1).*(Cprime==0) + dd_1.*(C==1).*(Cprime==1);
% w1 = cc_w1.*(C==0).*(Cprime==0) + cd_w1.*(C==0).*(Cprime==1) + dc_w1.*(C==1).*(Cprime==0) + dd_w1.*(C==1).*(Cprime==1);

% y_12 = A + B - Aprime_inc -  Bprime_inc ; 
% y_34 = A + B - Aprime_inc ; %%% don't get ANY Bprime_inc !! (default, so go back to zero...)




% given connected, choose to be connected  : C==0, Cprime==0
    %%% payoff: (p1, p2)   + (B - Bprime_inc (YES L))  [OR 0 if caught]
    
% given connected, choose to be disconnected  : C==0, Cprime==1
    %%% payoff: (p1c, p2c)  + (B - Bprime_inc (NO L))  UCOST pd
    
% given disconnected, choose to be connected  : C==1, Cprime==0
    %%% payoff: (p1, p2)  + 0 (NO Bprime AT ALL) (NO L)
    
% given disconnected, choose to be disconnected  : C==1, Cprime==1
    %%% payoff: (p1c, p2c)  + (B - Bprime_inc (NO L))  UCOST pd


% cc : (1:No/2,1:No/2)
% cd : ((No/2) +1:end,1:No/2)
% dc : (1:No/2,(No/2) +1:end)
% dd : ((No/2) +1:end,(No/2) +1:end)




% TEST
%{
% k_high=0;
% k_low=0;
% Y_high = 10000;
% Y_low = 10000;
% p1=16.2;
% p2=0.21   ;  
% 
% p1d=17;
% p2d=0.21;

% alpha=.02;
% lambda_high = 0;
% lambda_low=0;

D = 0;
Dprime = 0;

A = -17688 
B = -6687
Aprime = -17688 
Bprime = -7835


A = -17688 
B = -7835
Aprime = -17688 
Bprime = -7835



% r_high = .04;
% r_lend = 0;
% water_lending=0;

% r_water = 0
%}






  