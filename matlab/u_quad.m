function [util,w] = u_quad(L,debt,alpha,p1,p2,y,lambda)

    
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

        L_cut = cut_quad(alpha,p1,p2);

        vb = v_b_quad(L,alpha,p1,p2,y);
        vb(isinf(vb))=-1000000;
        vb(imag(vb)~=0)=-1000000;

        util  = v_reg_quad(L,alpha,p1,p2,y).*(L>=L_cut) + ...
              vb.*(L<L_cut);
        util(imag(util)~=0)=-1000000;
        
        if nargout>1
            w   = w_reg_quad(alpha,p1,p2).*(L>=L_cut) + ...  %%% less negative!
                  w_b_quad(L,p1,p2).*(L<L_cut);   %%% more negative !
        end
else
        util  = v_reg_quad(L,alpha,p1,p2,y);
        util(imag(util)~=0)=-1000000;
        if nargout>1
            w   = w_reg_quad(alpha,p1,p2);
        end
end


util(y<=0)=-1000000;
util(imag(util)~=0)=-1000000;

if nargout>1
    util(w<0)=-1000000;
end

if lambda~=0 && lambda~=1
    util = util.*lambda;  
end 
  
