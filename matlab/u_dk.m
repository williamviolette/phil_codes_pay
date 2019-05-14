function [util,w] = u_dk(L,debt,alpha,p1,p2,y,lambda,k)

if p2==0
    if debt==1
        L_cut = cut_dkl(alpha,k,p1,y);
        %L_cut = cut_dk(alpha,p1,p2,y);

        vb = v_b_dkl(L,alpha,k,p1,y);
        vb(isinf(vb))=-1000000;

        util  = v_reg_dkl(L,alpha,k,p1,y).*(L>=L_cut) + ...
              vb.*(L<L_cut);

        if nargout>1
            w   = w_reg_dkl(L,alpha,k,p1,y).*(L>=L_cut) + ...  %%% less negative!
                  w_b_dkl(L,p1).*(L<L_cut);   %%% more negative !
        end
        %w   = w_reg_dk(L,alpha,p1,p2,y).*(L>=L_cut) + ...  %%% less negative!
        %      w_b_dk(L,p1,p2).*(L<L_cut);   %%% more negative !

    else
        util  = v_reg_dkl(L,alpha,k,p1,y);
        if nargout>1
            w   = w_reg_dkl(L,alpha,k,p1,y);
        end
        %w   = w_reg_dk(L,alpha,p1,p2,y);
    end
    
else
    
    if debt==1
        L_cut = cut_dk(alpha,k,p1,p2,y);
        %L_cut = cut_dk(alpha,p1,p2,y);

        vb = v_b_dk(L,alpha,k,p1,p2,y);
        vb(isinf(vb))=-1000000;

        util  = v_reg_dk(L,alpha,k,p1,p2,y).*(L>=L_cut) + ...
              vb.*(L<L_cut);

        if nargout>1
            w   = w_reg_dk(L,alpha,k,p1,p2,y).*(L>=L_cut) + ...  %%% less negative!
                  w_b_dk(L,p1,p2).*(L<L_cut);   %%% more negative !
        end
        %w   = w_reg_dk(L,alpha,p1,p2,y).*(L>=L_cut) + ...  %%% less negative!
        %      w_b_dk(L,p1,p2).*(L<L_cut);   %%% more negative !

    else
        util  = v_reg_dk(L,alpha,k,p1,p2,y);
        if nargout>1
            w   = w_reg_dk(L,alpha,k,p1,p2,y);
        end
        %w   = w_reg_dk(L,alpha,p1,p2,y);
    end
end

util(y<=0)=-1000000;
if nargout>1
    util(w<0)=-1000000;
end

if lambda~=0 && lambda~=1
    util = util.*lambda;  
end 
  
