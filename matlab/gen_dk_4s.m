function [util1,util2,util3,util4,w1,w2,w3,w4] = ...
         gen_dk_4s(A,B,Aprime,Bprime,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,alpha,k_high,k_low,lambda_high,lambda_low)

% TEST
%{
k_high=0;
k_low=0;
Y_high = 10000;
Y_low = 10000;
p1=16.2;
p2=0.21   ;  
alpha=.02;
lambda_high = 0;
lambda_low=0;
A = 0;
B = -500;
Aprime = 0;
Bprime = -500;
% 
% A = -500;
% B = 0;
% Aprime = -500;
% Bprime = 0;

r_high = .04;
r_lend = 0;
water_lending=0;

r_water = 0
%}


if water_lending == 0
    r_water = r_water.*(Aprime<=0) + (r_water+.5).*(Aprime>0); 
end

Aprime_inc = (Aprime./(1+r_high)).*(Aprime<=0) + (Aprime./(1+r_lend)).*(Aprime>0);
Bprime_inc = (Bprime./(1+r_water)).*(Bprime>=B) + (B./(1+r_water)).*(Bprime<B); %% capped at B because the rest is raised through L

L          = 0.*(Bprime>=B) + ((Bprime - B)./(1+r_water)).*(Bprime<B); %% need to raise Bprime-B (or zero)

% if water_lending == 0
%     L=L.*(Aprime<=0); 
%     Bprime_inc=Bprime_inc.*(Aprime<=0);
% end
    
%%% the utility function takes into account L ...

y_12 = A + B - Aprime_inc -  Bprime_inc ; 
y_34 = A + B - Aprime_inc ; %%% don't get ANY Bprime_inc !! (default, so go back to zero...)

%%% START TRY: L=0
% L_cut = cut_dk(alpha,k_high,p1,p2,Y_low + y_12);
%%% L_CUT ISSUE?!  NO BOUNDS!
% L_cut = -3000;
% L=L.*(L>=L_cut & L_cut<=0) + L_cut.*(L<L_cut & L_cut<=0)  ;
% debt_12 = 0;
%%% END TRY

debt_12 = 1;
[util1,w1] = u_dk(L,debt_12,alpha,p1,p2, Y_high + y_12, lambda_high,k_high);
[util2,w2] = u_dk(L,debt_12,alpha,p1,p2, Y_low  + y_12, lambda_low,k_low);
 
debt_34 = 0;
[util3,w3] = u_dk((L.*0),debt_34,alpha,p1,p2,Y_high + y_34, lambda_high,k_high);
[util4,w4] = u_dk((L.*0),debt_34,alpha,p1,p2,Y_low  + y_34, lambda_low,k_low);


% if water_lending==1  %%% DEFINITELY GET THE PROBLEM HERE ALSO!!!
%    util1=util3;
%    util2=util4;
% end



%  util1
%  util3
  