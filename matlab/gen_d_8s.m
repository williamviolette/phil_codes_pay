function [util1,util2,util3,util4,util5,util6,util7,util8,...
            w1,w2,w3,w4,w5,w6,w7,w8] = ...
         gen_d_8s(A,B,Aprime,Bprime,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,alpha_high,alpha_low,lambda_high,lambda_low,key4)

     
Aprime_inc = (Aprime./(1+r_high)).*(Aprime<=0) + (Aprime./(1+r_lend)).*(Aprime>0);
Bprime_inc = (Bprime./(1+r_water)).*(Bprime>=B) + (B./(1+r_water)).*(Bprime<B); %% capped at B because the rest is raised through L
L          = 0.*(Bprime>=B) + ((Bprime - B)./(1+r_water)).*(Bprime<B); %% need to raise Bprime-B (or zero)

if water_lending == 0
    L=L.*(Aprime<=0);
    Bprime_inc=Bprime_inc.*(Aprime<=0);
end
    
y_14 =  A + B - Aprime_inc -  Bprime_inc ;
y_58 =  A + B - Aprime_inc ; %%% don't get ANY Bprime_inc !! (default, so go back to zero...)
debt_14 = 1;
debt_58 = 0; 
 
if key4==0

    [util1,w1] = u_d(L,debt_14,alpha_high,p1,p2, Y_high + y_14, lambda_high);
    [util2,w2] = u_d(L,debt_14,alpha_high,p1,p2, Y_low + y_14, lambda_high);
    [util3,w3] = u_d(L,debt_14,alpha_low ,p1,p2, Y_high + y_14, lambda_low);
    [util4,w4] = u_d(L,debt_14,alpha_low ,p1,p2, Y_low + y_14, lambda_low);


    [util5,w5] = u_d((L.*0),debt_58,alpha_high,p1,p2,Y_high + y_58, lambda_high);
    [util6,w6] = u_d((L.*0),debt_58,alpha_high,p1,p2,Y_low + y_58, lambda_high);
    [util7,w7] = u_d((L.*0),debt_58,alpha_low ,p1,p2,Y_high + y_58, lambda_low);
    [util8,w8] = u_d((L.*0),debt_58,alpha_low ,p1,p2,Y_low + y_58, lambda_low);
end

if key4==1
    [util1,w1] = u_d(L,debt_14,alpha_high,p1,p2, Y_high + y_14, lambda_high);
    [util2,w2] = u_d(L,debt_14,alpha_high,p1,p2, Y_low + y_14, lambda_low);
    [util3,w3] = u_d((L.*0),debt_58,alpha_high,p1,p2,Y_high + y_58, lambda_high);
    [util4,w4] = u_d((L.*0),debt_58,alpha_high,p1,p2,Y_low + y_58, lambda_low);
    util5 = 0;
    util6 = 0;
    util7 = 0;
    util8 = 0;
    w5 = 0;
    w6 = 0;
    w7 = 0;
    w8 = 0;
end


% 
% debt_14 = 1;
% [util1,w1] = u_d(L,debt_14,alpha_high,p1,p2, Y_high + y_14, lambda_high);
% [util2,w2] = u_d(L,debt_14,alpha_high,p1,p2, Y_low + y_14, lambda_high);
% [util3,w3] = u_d(L,debt_14,alpha_low ,p1,p2, Y_high + y_14, lambda_low);
% [util4,w4] = u_d(L,debt_14,alpha_low ,p1,p2, Y_low + y_14, lambda_low);
%  
% debt_58 = 0;
% [util5,w5] = u_d((L.*0),debt_58,alpha_high,p1,p2,Y_high + y_58, lambda_high);
% [util6,w6] = u_d((L.*0),debt_58,alpha_high,p1,p2,Y_low + y_58, lambda_high);
% [util7,w7] = u_d((L.*0),debt_58,alpha_low ,p1,p2,Y_high + y_58, lambda_low);
% [util8,w8] = u_d((L.*0),debt_58,alpha_low ,p1,p2,Y_low + y_58, lambda_low);
%  

