function [util,w] = u_dk(L,debt,alpha,p1,p2,y,lambda,k)

if debt==1
    L_cut = cut_dk(alpha,k,p1,p2,y);
    %L_cut = cut_dk(alpha,p1,p2,y);
    
    vb = v_b_dk(L,alpha,k,p1,p2,y);
    vb(isinf(vb))=-1000000;
    
    util  = v_reg_dk(L,alpha,k,p1,p2,y).*(L>=L_cut) + ...
          vb.*(L<L_cut);

    w   = w_reg_dk(L,alpha,k,p1,p2,y).*(L>=L_cut) + ...  %%% less negative!
          w_b_dk(L,p1,p2).*(L<L_cut);   %%% more negative !
    %w   = w_reg_dk(L,alpha,p1,p2,y).*(L>=L_cut) + ...  %%% less negative!
    %      w_b_dk(L,p1,p2).*(L<L_cut);   %%% more negative !

else
    util  = v_reg_dk(L,alpha,k,p1,p2,y);
    w   = w_reg_dk(L,alpha,k,p1,p2,y);
    %w   = w_reg_dk(L,alpha,p1,p2,y);
end

util(y<=0)=-1000000;
util(w<0)=-1000000;

if lambda~=0 && lambda~=1
    util = util.*lambda;  
end 
  

%     wbd = w_b_d(Lg(i),p1,p2);
%     vbd = v_b_d(Lg(i),alpha,p1,p2,y);


% B,A,Aprime, GOES INTO INC! (IN BOTH PERIODS)



% alpha = .02
% p1 = 15
% p2 = .2
% y = 30000
%  
% Lg = -1.*(0:10:5000)';
% 
% Wr = zeros(size(Lg,1),1);
% Vr = zeros(size(Lg,1),1);
% 
% C = zeros(size(Lg,1),1);
%    
% % cut_d(alpha,p1,p2,y) % gives L under the other terms
% 
% Wb = zeros(size(Lg,1),1);
% Vb = zeros(size(Lg,1),1);
% 
% for i = 1:size(Lg,1)
%     wrd = w_reg_d(Lg(i),alpha,p1,p2,y);
%     vrd = v_reg_d(Lg(i),alpha,p1,p2,y);
%     wbd = w_b_d(Lg(i),p1,p2);
%     vbd = v_b_d(Lg(i),alpha,p1,p2,y);
%     Wr(i,1) = wrd;
%     Vr(i,1) = vrd;
%     Wb(i,1) = wbd;
%     Vb(i,1) = vbd; 
% end
% 
% plot(Lg,Wr,Lg,Wb)
% plot(Lg,Vr,Lg,Vb)
% 
% [~,ind]=min(abs(Wr-Wb))
% Lg(ind)
% cut = cut_d(alpha,p1,p2,y) %%% ok, that works GREAT !




end



% 
% simple = 1;
% 
% if simple == 1
% 
%     r_low=0;
% 
%     A_cut_s1 = A_cut3_con(A,alpha,m,p1,p2,Y_high);
%     I1_s1 = (Aprime>0);
%     I1_s2 = (Aprime<=0 & Aprime>=A_cut_s1);
%     I1_s3 = (Aprime<=0 & Aprime<A_cut_s1);
% 
%     w1 = w_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_high).*I1_s1 + ...
%          w_reg_con(A,Aprime,alpha,p1,p2,r_low,Y_high).*I1_s2 + ...
%          w_reg_con(A,((Aprime-A_cut_s1)./(1+r_high)) + A_cut_s1,alpha,p1,p2,r_low,Y_high).*I1_s3 ;
% 
%     util1 = v_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_high).*I1_s1 + ...
%             v_reg_con(A,Aprime,alpha,p1,p2,r_low,Y_high).*I1_s2 + ...
%             v_reg_con(A,((Aprime-A_cut_s1)./(1+r_high)) + A_cut_s1,alpha,p1,p2,r_low,Y_high).*I1_s3 ;
%     util1(w1<=0) = -inf;
% 
%     wd1 = Aprime.*I1_s2 + ...  % full assets when within first cut point
%           A_cut_s1 ...
%           .*I1_s3 ; % water assets when greater than first cut point
% 
%     %%% 2
% 
%     A_cut_s2 = A_cut3_con(A,alpha,m,p1,p2,Y_low);
%     I2_s1 = (Aprime>0);
%     I2_s2 = (Aprime<=0 & Aprime>=A_cut_s2);
%     I2_s3 = (Aprime<=0 & Aprime<A_cut_s2);
% 
%     w2 = w_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_low).*I2_s1 + ...
%          w_reg_con(A,Aprime,alpha,p1,p2,r_low,Y_low).*I2_s2 + ...
%          w_reg_con(A,((Aprime-A_cut_s2)./(1+r_high)) + A_cut_s2,alpha,p1,p2,r_low,Y_low).*I2_s3 ;
% 
%     util2 = v_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_low).*I2_s1 + ...
%             v_reg_con(A,Aprime,alpha,p1,p2,r_low,Y_low).*I2_s2 + ...
%             v_reg_con(A,((Aprime-A_cut_s2)./(1+r_high)) + A_cut_s2,alpha,p1,p2,r_low,Y_low).*I2_s3 ;
% 
%     util2(w2<=0) = -inf;
% 
%     wd2 = Aprime.*I2_s2 + ...
%           A_cut_s2 ...
%           .*I2_s3 ; % water assets when greater than first cut point
% 
%     %%% 3
%     I3_s1 = (Aprime>=0);
%     I3_s2 = (Aprime<0);
% 
%     w3 = w_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_high).*I3_s1 + ...
%          w_reg_con(A,Aprime,alpha,p1,p2,r_high,Y_high).*I3_s2  ;
% 
%     util3 = v_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_high).*I3_s1 + ...
%             v_reg_con(A,Aprime,alpha,p1,p2,r_high,Y_high).*I3_s2  ;
%     util3(w3<=0) = -inf;
% 
%     wd3 = w3.*0 ; % no savings here
% 
%     %%% 4
%     I4_s1 = (Aprime>=0);
%     I4_s2 = (Aprime<0);
% 
%     w4 = w_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_low).*I4_s1 + ...
%          w_reg_con(A,Aprime,alpha,p1,p2,r_high,Y_low).*I4_s2  ;
% 
%     util4 = v_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_low).*I4_s1 + ...
%             v_reg_con(A,Aprime,alpha,p1,p2,r_high,Y_low).*I4_s2  ;
%     util4(w4<=0) = -inf;
% 
%     wd4 = w4.*0 ; % no savings here either
% 
%     w1=w1.*(w1>0);
%     w2=w2.*(w2>0);
%     w3=w3.*(w3>0);
%     w4=w4.*(w4>0);
% 
%     util1 = util1.*lambda_high;
%     util2 = util2.*lambda_low;
%     util3 = util3.*lambda_high;
%     util4 = util4.*lambda_low;
%     
%     
% else
%     r_low=0;
%     % r_lend = r_high;
%     % mean(mean(A_cut3(A,alpha,1,r_low,Y_high)))
%     % mean(mean(A_cut3(A,alpha,2,r_low,Y_high))) 
%     % mean(mean(A_cut3(A,alpha,3,r_low,Y_high)))
% 
%     A_cut_s1 = A_cut3_con(A,alpha,m,p1,p2,Y_high);
%     I1_s1 = (Aprime>0);
%     I1_s2 = (Aprime<=0 & Aprime>=A_cut_s1);
%     I1_s3 = (Aprime<=0 & Aprime<A_cut_s1);
% 
%     w1 = w_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_high).*I1_s1 + ...
%          w_reg_con(A,Aprime,alpha,p1,p2,r_low,Y_high).*I1_s2 + ...
%          w_b_con(A,Aprime,alpha,m,p1,p2,r_high,Y_high).*I1_s3 ;
% 
%     util1 = v_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_high).*I1_s1 + ...
%             v_reg_con(A,Aprime,alpha,p1,p2,r_low,Y_high).*I1_s2 + ...
%             v_b_con(A,Aprime,alpha,m,p1,p2,r_high,Y_high).*I1_s3 ;
%     util1(w1<=0) = -inf;
% 
%     wd1 = Aprime.*I1_s2 + ...  % full assets when within first cut point
%           m.*(-w_b_con(A,Aprime,alpha,m,p1,p2,r_high,Y_high).* ...
%           (p1 + p2.*w_b_con(A,Aprime,alpha,m,p1,p2,r_high,Y_high))) ...
%           .*I1_s3 ; % water assets when greater than first cut point
% 
%     %%% 2
% 
%     A_cut_s2 = A_cut3_con(A,alpha,m,p1,p2,Y_low);
%     I2_s1 = (Aprime>0);
%     I2_s2 = (Aprime<=0 & Aprime>=A_cut_s2);
%     I2_s3 = (Aprime<=0 & Aprime<A_cut_s2);
% 
%     w2 = w_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_low).*I2_s1 + ...
%          w_reg_con(A,Aprime,alpha,p1,p2,r_low,Y_low).*I2_s2 + ...
%          w_b_con(A,Aprime,alpha,m,p1,p2,r_high,Y_low).*I2_s3 ;
% 
%     util2 = v_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_low).*I2_s1 + ...
%             v_reg_con(A,Aprime,alpha,p1,p2,r_low,Y_low).*I2_s2 + ...
%             v_b_con(A,Aprime,alpha,m,p1,p2,r_high,Y_low).*I2_s3 ;
% 
%     util2(w2<=0) = -inf;
% 
%     wd2 = Aprime.*I2_s2 + ...
%           m.*(-w_b_con(A,Aprime,alpha,m,p1,p2,r_high,Y_low).* ...
%           (p1 + p2.*w_b_con(A,Aprime,alpha,m,p1,p2,r_high,Y_low))) ...
%           .*I2_s3 ; % water assets when greater than first cut point
% 
%     %%% 3
%     I3_s1 = (Aprime>=0);
%     I3_s2 = (Aprime<0);
% 
%     w3 = w_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_high).*I3_s1 + ...
%          w_reg_con(A,Aprime,alpha,p1,p2,r_high,Y_high).*I3_s2  ;
% 
%     util3 = v_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_high).*I3_s1 + ...
%             v_reg_con(A,Aprime,alpha,p1,p2,r_high,Y_high).*I3_s2  ;
%     util3(w3<=0) = -inf;
% 
%     wd3 = w3.*0 ; % no savings here
% 
%     %%% 4
%     I4_s1 = (Aprime>=0);
%     I4_s2 = (Aprime<0);
% 
%     w4 = w_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_low).*I4_s1 + ...
%          w_reg_con(A,Aprime,alpha,p1,p2,r_high,Y_low).*I4_s2  ;
% 
%     util4 = v_reg_con(A,Aprime,alpha,p1,p2,r_lend,Y_low).*I4_s1 + ...
%             v_reg_con(A,Aprime,alpha,p1,p2,r_high,Y_low).*I4_s2  ;
%     util4(w4<=0) = -inf;
% 
%     wd4 = w4.*0 ; % no savings here either
% 
%     w1=w1.*(w1>0);
%     w2=w2.*(w2>0);
%     w3=w3.*(w3>0);
%     w4=w4.*(w4>0);
% 
%     util1 = util1.*lambda_high;
%     util2 = util2.*lambda_low;
%     util3 = util3.*lambda_high;
%     util4 = util4.*lambda_low;
%     





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

