function [util1,util2,util3,util4,w1,w2,w3,w4] = ...
         gen_curve_quad(A,B,D,Aprime,Bprime,Dprime,r_high,r_lend,r_water,h,vh,Y_high,Y_low,p1,p2,pd,alpha,curve,untied,fee)

     
Aprime_inc = (Aprime./(1+r_high)).*(Aprime<=0) + (Aprime./(1+r_lend)).*(Aprime>0);  %% UNCHANGED

if untied==0
    if r_water>0
        Bprime_inc = (Bprime.*(Bprime>=B) + B.*(Bprime<B))./(1+r_water); %% capped at B because the rest is raised through L
    else 
        Bprime_inc = Bprime.*(Bprime>=B) + B.*(Bprime<B);
    end

    cc = (D==0).*(Dprime==0); 
    cd = (D==0).*(Dprime==1);
    dc = (D==1).*(Dprime==0);
    dd = (D==1).*(Dprime==1);

    if r_water>0
        Lf_12 = ((Bprime - B)./(1+r_water)).*(Bprime<B).*cc ;
    else
        Lf_12 = (Bprime - B).*(Bprime<B).*cc ;
    end
    
    y_34f = (A-Aprime_inc + B)     + (-Bprime_inc).*(cd+dd) - pd.*(cd+dd) ;
    y_12f =  y_34f + (-1.*Bprime_inc).*cc  ;

    if h>0
        y_34f = y_34f-(Bprime<0).*h;
        y_12f = y_12f-(Bprime<0).*h;
    end
    if vh>0
       y_34f = y_34f - (B<0).*(cc+cd).*vh;
    end
    if fee~=0
        y_34f = y_34f-fee;
%         .*(cc+dc);
        y_12f = y_12f-fee;
%         .*(cc+dc);  
    end
    
    
        if nargout>4
                    debt_12 = 1;
                    [util1,w1] = u_quad(Lf_12,debt_12,alpha,p1,p2, Y_high + y_12f, 1);
                    [util2,w2] = u_quad(Lf_12,debt_12,alpha,p1,p2, Y_low  + y_12f, 1);

                    debt_34 = 0;
                    [util3,w3] = u_quad(0,debt_34,alpha,p1,p2,Y_high + y_34f, 1);
                    [util4,w4] = u_quad(0,debt_34,alpha,p1,p2,Y_low  + y_34f, 1);
                else
                        debt_12 = 1;
                        [util1] = u_quad(Lf_12,debt_12,alpha,p1,p2, Y_high + y_12f, 1);
                        [util2] = u_quad(Lf_12,debt_12,alpha,p1,p2, Y_low  + y_12f, 1);

                        debt_34 = 0;
                        [util3] = u_quad(0,debt_34,alpha,p1,p2,Y_high + y_34f, 1);
                        [util4] = u_quad(0,debt_34,alpha,p1,p2,Y_low  + y_34f, 1);
        end
else

    y_12f = (A-Aprime_inc + B-Bprime);
    if fee~=0
        y_12f = y_12f-fee;  
    end
        
        if nargout>4
                    debt_12 = 0;
                    [util1,w1] = u_quad(0,debt_12,alpha,p1,p2, Y_high + y_12f, 1);
                    [util2,w2] = u_quad(0,debt_12,alpha,p1,p2, Y_low  + y_12f, 1);
                    util3=util1;
                    w3=w1;
                    util4=util2;
                    w4=w2; 
        else
                        debt_12 = 0;
                        [util1] = u_quad(0,debt_12,alpha,p1,p2, Y_high + y_12f, 1);
                        [util2] = u_quad(0,debt_12,alpha,p1,p2, Y_low  + y_12f, 1);
                        util3=util1;
                        util4=util2;
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
    



  