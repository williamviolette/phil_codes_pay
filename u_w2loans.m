function [util1,util2,util3,w1,w2,w3] = ...
    u_w2loans(A,Aprime,alpha,p,r_high,r_low,Y,lambda)

r_lend = r_low;

%%% 1 : No detect
A1_cut = A_cut(A,alpha,r_low,Y);
I1_s1 = (Aprime>0);
I1_s2 = (Aprime<=0 & Aprime>=A1_cut);
I1_s3 = (Aprime<=0 & Aprime<A1_cut);

w1 = w_reg(A,Aprime,alpha,p,r_lend,Y).*I1_s1 + ...
     w_reg(A,Aprime,alpha,p,r_low,Y).*I1_s2 + ...
     w_b(A,Aprime,alpha,p,r_high,r_low,Y).*I1_s3 ;

util1 = v_reg(A,Aprime,alpha,p,r_lend,Y).*I1_s1 + ...
        v_reg(A,Aprime,alpha,p,r_low,Y).*I1_s2 + ...
        v_b(A,Aprime,alpha,p,r_high,r_low,Y).*I1_s3 ;
util1(w1<=0) = -inf;


%%% 2 : No detect again (2)

% mean(mean(I1_s1)) + mean(mean(I1_s2)) + mean(mean(I1_s3))
% mean(mean(I2_s1)) + mean(mean(I2_s2a)) + mean(mean(I2_s3a)) + mean(mean(I2_s2b)) + mean(mean(I2_s3b)) + mean(mean(I2_s2c)) + mean(mean(I2_s3c))

I2_s1 = (Aprime>0);   %%% save this period

A2_cut = A_cut(A,alpha,r_low,Y);         %%% borrow, saved last period
I2_s2a = (Aprime<=0 & Aprime>=A2_cut & A>=0);
I2_s3a = (Aprime<=0 & Aprime<A2_cut & A>=0);

A2_cut2 = A_cut2(A,alpha,r_low,Y);       %%% borrow, borrowed a little last period (less than standard cut point)
I2_s2b = (Aprime<=0 & Aprime>=A2_cut2    &     A>=A1_cut & A<0);
I2_s3b = (Aprime<=0 & Aprime<A2_cut2     &     A>=A1_cut & A<0);

A2_cut2_1 = A_cut2_1(A,alpha,r_low,Y);   %%% borrow, borrowed a lot last period (more than the standard cut point)
I2_s2c = (Aprime<=0 & Aprime>=A2_cut2_1  &    A<A1_cut);
I2_s3c = (Aprime<=0 & Aprime<A2_cut2_1   &    A<A1_cut);

w2 = w_reg(A,Aprime,alpha,p,r_lend,Y).*I2_s1 + ... %%% saving
         w_reg(A,Aprime,alpha,p,r_low,Y).*I2_s2a + ...
         w_b(A,Aprime,alpha,p,r_high,r_low,Y).*I2_s3a + ...
         w_reg(A,Aprime,alpha,p,r_low,Y).*I2_s2b + ... %%% borrow, borrowed a little
         w_b2(A,A,Aprime,alpha,p,r_high,r_low,Y).*I2_s3b + ... 
         w_reg(A,Aprime,alpha,p,r_low,Y).*I2_s2c + ... %%% borrow, borrowed a lot
         w_b2(A,A1_cut,Aprime,alpha,p,r_high,r_low,Y).*I2_s3c ;

util2 =  v_reg(A,Aprime,alpha,p,r_lend,Y).*I2_s1 + ... %%% saving
         v_reg(A,Aprime,alpha,p,r_low,Y).*I2_s2a + ...
         v_b(A,Aprime,alpha,p,r_high,r_low,Y).*I2_s3a + ...
         v_reg(A,Aprime,alpha,p,r_low,Y).*I2_s2b + ... %%% borrow, borrowed a little
         v_b2(A,A,Aprime,alpha,p,r_high,r_low,Y).*I2_s3b + ... 
         v_reg(A,Aprime,alpha,p,r_low,Y).*I2_s2c + ... %%% borrow, borrowed a lot
         v_b2(A,A1_cut,Aprime,alpha,p,r_high,r_low,Y).*I2_s3c ;     
     
util2(w2<=0) = -inf;

%%% 3 : Finally Detected ! ( can't borrow at a discount rate anymore )
I3_s1 = (Aprime>=0);
I3_s2 = (Aprime<0);

w3 = w_reg(A,Aprime,alpha,p,r_lend,Y).*I3_s1 + ...
     w_reg(A,Aprime,alpha,p,r_high,Y).*I3_s2  ;

util3 = v_reg(A,Aprime,alpha,p,r_lend,Y).*I3_s1 + ...
        v_reg(A,Aprime,alpha,p,r_high,Y).*I3_s2  ;
util3(w3<=0) = -inf;


w1=w1.*(w1>0);
w2=w2.*(w2>0);
w3=w3.*(w3>0);

util1=util1.*lambda;
util2=util2.*lambda;
util3=util3.*lambda;


