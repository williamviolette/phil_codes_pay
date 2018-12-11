function [util1,util2,util3,util4,w1,w2,w3,w4] = ...
    u_w1loan3(A,Aprime,alpha,p,r_high,r_low,r_lend,Y_high,Y_low,lambda_high,lambda_low,m)

% r_lend = r_high;
% mean(mean(A_cut3(A,alpha,1,r_low,Y_high)))
% mean(mean(A_cut3(A,alpha,2,r_low,Y_high))) 
% mean(mean(A_cut3(A,alpha,3,r_low,Y_high)))

%%% 
A_cut_s1 = A_cut3(A,alpha,m,r_low,Y_high);
I1_s1 = (Aprime>0);
I1_s2 = (Aprime<=0 & Aprime>=A_cut_s1);
I1_s3 = (Aprime<0 & Aprime<A_cut_s1);

w1 = w_reg(A,Aprime,alpha,p,r_lend,Y_high).*I1_s1 + ...
    w_reg(A,Aprime,alpha,p,r_low,Y_high).*I1_s2 + ...
    w_b(A,Aprime,alpha,p,r_high,r_low,Y_high).*I1_s3 ;

util1 = v_reg(A,Aprime,alpha,p,r_lend,Y_high).*I1_s1 + ...
        v_reg(A,Aprime,alpha,p,r_low,Y_high).*I1_s2 + ...
        v_b(A,Aprime,alpha,p,r_high,r_low,Y_high).*I1_s3 ;
util1(w1<=0) = -inf;

%%% 2
A_cut_s2 = A_cut3(A,alpha,m,r_low,Y_low);
I2_s1 = (Aprime>0);
I2_s2 = (Aprime<=0 & Aprime>=A_cut_s2);
I2_s3 = (Aprime<0 & Aprime<A_cut_s2);

w2 = w_reg(A,Aprime,alpha,p,r_lend,Y_low).*I2_s1 + ...
    w_reg(A,Aprime,alpha,p,r_low,Y_low).*I2_s2 + ...
    w_b(A,Aprime,alpha,p,r_high,r_low,Y_low).*I2_s3 ;

util2 = v_reg(A,Aprime,alpha,p,r_lend,Y_low).*I2_s1 + ...
        v_reg(A,Aprime,alpha,p,r_low,Y_low).*I2_s2 + ...
        v_b(A,Aprime,alpha,p,r_high,r_low,Y_low).*I2_s3 ;
util2(w2<=0) = -inf;
    
%%% 3
I3_s1 = (Aprime>=0);
I3_s2 = (Aprime<0);

w3 = w_reg(A,Aprime,alpha,p,r_lend,Y_high).*I3_s1 + ...
     w_reg(A,Aprime,alpha,p,r_high,Y_high).*I3_s2  ;

util3 = v_reg(A,Aprime,alpha,p,r_lend,Y_high).*I3_s1 + ...
        v_reg(A,Aprime,alpha,p,r_high,Y_high).*I3_s2  ;
util3(w3<=0) = -inf;

%%% 4
I4_s1 = (Aprime>=0);
I4_s2 = (Aprime<0);

w4 = w_reg(A,Aprime,alpha,p,r_lend,Y_low).*I4_s1 + ...
     w_reg(A,Aprime,alpha,p,r_high,Y_low).*I4_s2  ;

util4 = v_reg(A,Aprime,alpha,p,r_lend,Y_low).*I4_s1 + ...
        v_reg(A,Aprime,alpha,p,r_high,Y_low).*I4_s2  ;
util4(w4<=0) = -inf;


w1=w1.*(w1>0);
w2=w2.*(w2>0);
w3=w3.*(w3>0);
w4=w4.*(w4>0);

util1 = util1.*lambda_high;
util2 = util2.*lambda_low;
util3 = util3.*lambda_high;
util4 = util4.*lambda_low;