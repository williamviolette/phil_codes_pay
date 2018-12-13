function [util1,util2,util3,util4,w1,w2,w3,w4,wd1,wd2,wd3,wd4] = ...
    u_con(A,Aprime,alpha,p1,p2,r_high,r_lend,Y_high,Y_low,lambda_high,lambda_low,m)

simple = 1;

if simple == 1

    r_low=0;

    A_cut_s1 = A_cut3_con(A,alpha,m,p1,p2,Y_high);
    I1_s1 = (Aprime>0);
    I1_s2 = (Aprime<=0 & Aprime>=A_cut_s1);
    I1_s3 = (Aprime<=0 & Aprime<A_cut_s1);

    w1 = w_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_high).*I1_s1 + ...
         w_reg_con(A,Aprime,alpha,p1,p2,r_low,Y_high).*I1_s2 + ...
         w_reg_con(A,((Aprime-A_cut_s1)./(1+r_high)) + A_cut_s1,alpha,p1,p2,r_low,Y_high).*I1_s3 ;

    util1 = v_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_high).*I1_s1 + ...
            v_reg_con(A,Aprime,alpha,p1,p2,r_low,Y_high).*I1_s2 + ...
            v_reg_con(A,((Aprime-A_cut_s1)./(1+r_high)) + A_cut_s1,alpha,p1,p2,r_low,Y_high).*I1_s3 ;
    util1(w1<=0) = -inf;

    wd1 = Aprime.*I1_s2 + ...  % full assets when within first cut point
          A_cut_s1 ...
          .*I1_s3 ; % water assets when greater than first cut point

    %%% 2

    A_cut_s2 = A_cut3_con(A,alpha,m,p1,p2,Y_low);
    I2_s1 = (Aprime>0);
    I2_s2 = (Aprime<=0 & Aprime>=A_cut_s2);
    I2_s3 = (Aprime<=0 & Aprime<A_cut_s2);

    w2 = w_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_low).*I2_s1 + ...
         w_reg_con(A,Aprime,alpha,p1,p2,r_low,Y_low).*I2_s2 + ...
         w_reg_con(A,((Aprime-A_cut_s2)./(1+r_high)) + A_cut_s2,alpha,p1,p2,r_low,Y_low).*I2_s3 ;

    util2 = v_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_low).*I2_s1 + ...
            v_reg_con(A,Aprime,alpha,p1,p2,r_low,Y_low).*I2_s2 + ...
            v_reg_con(A,((Aprime-A_cut_s2)./(1+r_high)) + A_cut_s2,alpha,p1,p2,r_low,Y_low).*I2_s3 ;

    util2(w2<=0) = -inf;

    wd2 = Aprime.*I2_s2 + ...
          A_cut_s2 ...
          .*I2_s3 ; % water assets when greater than first cut point

    %%% 3
    I3_s1 = (Aprime>=0);
    I3_s2 = (Aprime<0);

    w3 = w_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_high).*I3_s1 + ...
         w_reg_con(A,Aprime,alpha,p1,p2,r_high,Y_high).*I3_s2  ;

    util3 = v_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_high).*I3_s1 + ...
            v_reg_con(A,Aprime,alpha,p1,p2,r_high,Y_high).*I3_s2  ;
    util3(w3<=0) = -inf;

    wd3 = w3.*0 ; % no savings here

    %%% 4
    I4_s1 = (Aprime>=0);
    I4_s2 = (Aprime<0);

    w4 = w_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_low).*I4_s1 + ...
         w_reg_con(A,Aprime,alpha,p1,p2,r_high,Y_low).*I4_s2  ;

    util4 = v_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_low).*I4_s1 + ...
            v_reg_con(A,Aprime,alpha,p1,p2,r_high,Y_low).*I4_s2  ;
    util4(w4<=0) = -inf;

    wd4 = w4.*0 ; % no savings here either

    w1=w1.*(w1>0);
    w2=w2.*(w2>0);
    w3=w3.*(w3>0);
    w4=w4.*(w4>0);

    util1 = util1.*lambda_high;
    util2 = util2.*lambda_low;
    util3 = util3.*lambda_high;
    util4 = util4.*lambda_low;
    
    
else
    r_low=0;
    % r_lend = r_high;
    % mean(mean(A_cut3(A,alpha,1,r_low,Y_high)))
    % mean(mean(A_cut3(A,alpha,2,r_low,Y_high))) 
    % mean(mean(A_cut3(A,alpha,3,r_low,Y_high)))

    A_cut_s1 = A_cut3_con(A,alpha,m,p1,p2,Y_high);
    I1_s1 = (Aprime>0);
    I1_s2 = (Aprime<=0 & Aprime>=A_cut_s1);
    I1_s3 = (Aprime<=0 & Aprime<A_cut_s1);

    w1 = w_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_high).*I1_s1 + ...
         w_reg_con(A,Aprime,alpha,p1,p2,r_low,Y_high).*I1_s2 + ...
         w_b_con(A,Aprime,alpha,m,p1,p2,r_high,Y_high).*I1_s3 ;

    util1 = v_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_high).*I1_s1 + ...
            v_reg_con(A,Aprime,alpha,p1,p2,r_low,Y_high).*I1_s2 + ...
            v_b_con(A,Aprime,alpha,m,p1,p2,r_high,Y_high).*I1_s3 ;
    util1(w1<=0) = -inf;

    wd1 = Aprime.*I1_s2 + ...  % full assets when within first cut point
          m.*(-w_b_con(A,Aprime,alpha,m,p1,p2,r_high,Y_high).* ...
          (p1 + p2.*w_b_con(A,Aprime,alpha,m,p1,p2,r_high,Y_high))) ...
          .*I1_s3 ; % water assets when greater than first cut point

    %%% 2

    A_cut_s2 = A_cut3_con(A,alpha,m,p1,p2,Y_low);
    I2_s1 = (Aprime>0);
    I2_s2 = (Aprime<=0 & Aprime>=A_cut_s2);
    I2_s3 = (Aprime<=0 & Aprime<A_cut_s2);

    w2 = w_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_low).*I2_s1 + ...
         w_reg_con(A,Aprime,alpha,p1,p2,r_low,Y_low).*I2_s2 + ...
         w_b_con(A,Aprime,alpha,m,p1,p2,r_high,Y_low).*I2_s3 ;

    util2 = v_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_low).*I2_s1 + ...
            v_reg_con(A,Aprime,alpha,p1,p2,r_low,Y_low).*I2_s2 + ...
            v_b_con(A,Aprime,alpha,m,p1,p2,r_high,Y_low).*I2_s3 ;

    util2(w2<=0) = -inf;

    wd2 = Aprime.*I2_s2 + ...
          m.*(-w_b_con(A,Aprime,alpha,m,p1,p2,r_high,Y_low).* ...
          (p1 + p2.*w_b_con(A,Aprime,alpha,m,p1,p2,r_high,Y_low))) ...
          .*I2_s3 ; % water assets when greater than first cut point

    %%% 3
    I3_s1 = (Aprime>=0);
    I3_s2 = (Aprime<0);

    w3 = w_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_high).*I3_s1 + ...
         w_reg_con(A,Aprime,alpha,p1,p2,r_high,Y_high).*I3_s2  ;

    util3 = v_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_high).*I3_s1 + ...
            v_reg_con(A,Aprime,alpha,p1,p2,r_high,Y_high).*I3_s2  ;
    util3(w3<=0) = -inf;

    wd3 = w3.*0 ; % no savings here

    %%% 4
    I4_s1 = (Aprime>=0);
    I4_s2 = (Aprime<0);

    w4 = w_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_low).*I4_s1 + ...
         w_reg_con(A,Aprime,alpha,p1,p2,r_high,Y_low).*I4_s2  ;

    util4 = v_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_low).*I4_s1 + ...
            v_reg_con(A,Aprime,alpha,p1,p2,r_high,Y_low).*I4_s2  ;
    util4(w4<=0) = -inf;

    wd4 = w4.*0 ; % no savings here either

    w1=w1.*(w1>0);
    w2=w2.*(w2>0);
    w3=w3.*(w3>0);
    w4=w4.*(w4>0);

    util1 = util1.*lambda_high;
    util2 = util2.*lambda_low;
    util3 = util3.*lambda_high;
    util4 = util4.*lambda_low;
    
end




% 
% At = 1000;
% Aprimet=1000;
% alphat=.02;
% Y_hight=30000;
% p2t = .2;
% r_lendt=.04;
% p1t = 15;
% 
% wr = 0:1:15;
% wv=zeros(1,size(wr,2));
% 
% for i=1:size(wr,2)
%     wv(1,i)=w_reg_con(At,Aprimet,alphat,wr(i),p2t,r_lendt,Y_hight);
% end
% 
% plot(wv,wr)
% 
% w_reg_con(At,Aprimet,alphat,p1t,p2t,r_lendt,Y_hight)
% 
% w_reg_con(-20000,-20000,alphat,p1t,p2t,r_lendt,Y_hight)
% 
% ac = ((Aprime-A_cut_s1)./(1+r_high)) + A_cut_s1;
% 
% 
% tt = w_reg_con(A(1,1),ac(1,1),alpha,p1,p2,r_low,Y_high)
% tt(1,1)
% tt(1,:)

