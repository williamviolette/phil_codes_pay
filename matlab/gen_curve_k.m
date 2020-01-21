function [util1,util2,util3,util4,w1,w2,w3,w4] = ...
         gen_curve_k(A,B,D,Aprime,Bprime,Dprime,r_high,r_slope,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,p1d,p2d,pd,alpha,k,lambda_high,lambda_low,curve)




if water_lending == 0
    r_w = r_water.*(Aprime<=0) + (r_water+.5).*(Aprime>0); 
else
    r_w = r_water; 
end

% Aprime_inc = (Aprime./(1+r_high+(-1.*Aprime.*r_slope) )).*(Aprime<=0) + (Aprime./(1+r_lend)).*(Aprime>0);  %% UNCHANGED

if r_slope~=0
    Aprime_inc = (Aprime./(1+r_high+r_slope.*((-1.*Aprime).^2) )).*(Aprime<=0) + (Aprime./(1+r_lend)).*(Aprime>0);  %% UNCHANGED
else
    Aprime_inc = (Aprime./(1+r_high)).*(Aprime<=0) + (Aprime./(1+r_lend)).*(Aprime>0);  %% UNCHANGED
end

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


    if lambda_high==1 && lambda_low==1
        if nargout>4
            debt_12 = 1;
            [util1,w1] = u_dkc(Lf_12,debt_12,alpha,p1f,p2f, Y_high + y_12f, lambda_high,k);
            [util2,w2] = u_dkc(Lf_12,debt_12,alpha,p1f,p2f, Y_low  + y_12f, lambda_low,k);

            debt_34 = 0;
            [util3,w3] = u_dkc(0,debt_34,alpha,p1f,p2f,Y_high + y_34f, lambda_high,k);
            [util4,w4] = u_dkc(0,debt_34,alpha,p1f,p2f,Y_low  + y_34f, lambda_low,k);
        else
                debt_12 = 1;
                [util1] = u_dkc(Lf_12,debt_12,alpha,p1f,p2f, Y_high + y_12f, lambda_high,k);
                [util2] = u_dkc(Lf_12,debt_12,alpha,p1f,p2f, Y_low  + y_12f, lambda_low,k);

                debt_34 = 0;
                [util3] = u_dkc(0,debt_34,alpha,p1f,p2f,Y_high + y_34f, lambda_high,k);
                [util4] = u_dkc(0,debt_34,alpha,p1f,p2f,Y_low  + y_34f, lambda_low,k);
        end
    else
         if nargout>4
            debt_12 = 1;
            [util1,w1] = u_dkc(Lf_12,debt_12,alpha+lambda_high,p1f,p2f, Y_high + y_12f, 1,k);
            [util2,w2] = u_dkc(Lf_12,debt_12,alpha+lambda_low,p1f,p2f, Y_low  + y_12f, 1,k);

            debt_34 = 0;
            [util3,w3] = u_dkc(0,debt_34,alpha+lambda_high,p1f,p2f,Y_high + y_34f, 1,k);
            [util4,w4] = u_dkc(0,debt_34,alpha+lambda_low,p1f,p2f,Y_low  + y_34f, 1,k);
        else
                debt_12 = 1;
                [util1] = u_dkc(Lf_12,debt_12,alpha+lambda_high,p1f,p2f, Y_high + y_12f, 1,k);
                [util2] = u_dkc(Lf_12,debt_12,alpha+lambda_low,p1f,p2f, Y_low  + y_12f, 1,k);

                debt_34 = 0;
                [util3] = u_dkc(0,debt_34,alpha+lambda_high,p1f,p2f,Y_high + y_34f, 1,k);
                [util4] = u_dkc(0,debt_34,alpha+lambda_low,p1f,p2f,Y_low  + y_34f, 1,k);
        end
        
    end
    



if curve==1
    util1(util1>0)=log(util1(util1>0));
    util2(util2>0)=log(util2(util2>0));
    util3(util3>0)=log(util3(util3>0));
    util4(util4>0)=log(util4(util4>0));
else
    util1(util1>0)=( (util1(util1>0).^(1-curve)) - 1)./(1-curve);
    util2(util2>0)=( (util2(util2>0).^(1-curve)) - 1)./(1-curve);
    util3(util3>0)=( (util3(util3>0).^(1-curve)) - 1)./(1-curve);
    util4(util4>0)=( (util4(util4>0).^(1-curve)) - 1)./(1-curve);
end
    



  