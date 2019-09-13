function [util,w] = u_ql(L,debt,alpha,p1,p2,y,lambda,k)

    
if debt==1
%     alpha = .2
%     k = 10
%     y = 100
%     p1 = 2
%     L = 10
% L = Lf_12;
% debt = 1;
% p1 = p1f;
% y = Y_high+y_12f;
% lambda = lambda_high;
% k = k_high;

        L_cut = cut_ql(alpha,k,p1);

        vb = v_b_ql(L,alpha,k,p1,y);
        vb(isinf(vb))=-1000000;
        vb(imag(vb)~=0)=-1000000;

        util  = v_reg_ql(L,alpha,k,p1,y).*(L>=L_cut) + ...
              vb.*(L<L_cut);
        util(imag(util)~=0)=-1000000;
        
        if nargout>1
            w   = w_reg_ql(alpha,k,p1).*(L>=L_cut) + ...  %%% less negative!
                  w_b_ql(L,p1).*(L<L_cut);   %%% more negative !
        end
else
        util  = v_reg_ql(L,alpha,k,p1,y);
        util(imag(util)~=0)=-1000000;
        if nargout>1
            w   = w_reg_ql(alpha,k,p1);
        end
        %w   = w_reg_dk(L,alpha,p1,p2,y);
end


util(y<=0)=-1000000;
util(imag(util)~=0)=-1000000;

if nargout>1
    util(w<0)=-1000000;
end

if lambda~=0 && lambda~=1
    util = util.*lambda;  
end 
  
