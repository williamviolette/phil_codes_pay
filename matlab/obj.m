function    [h,util,sim,nA,nB,A,B] = obj(given,nA,sigA,Alb,Aub,nB,sigB,nD,s,int_size,refinement,X)


r_lend          = given(1,1);
r_water         = given(1,2);
r_high          = given(1,3);
h               = given(1,4);
theta           = given(1,5);
untied          = given(1,6);
alpha           = given(1,7);
beta_up         = given(1,8);
Y               = given(1,9);
p1              = given(1,10);
p2              = given(1,11);
pd              = given(1,12);
n               = given(1,13);
curve           = given(1,14);
fee             = given(1,15);
vh              = given(1,16);
prob_caught     = given(1,17);
prob_move       = given(1,18);
Blb             = given(1,19);
Tg              = given(1,20);

prob = [(1-prob_caught) (1-prob_caught) (prob_caught) (prob_caught)]./2; 

chain =  1.*(X(:,1)<=prob(1)) + ...
         2.*(X(:,1)>prob(1) & X(:,1)<=prob(1)+prob(2)) + ...
         3.*(X(:,1)>prob(1)+prob(2) & X(:,1)<=prob(1)+prob(2)+prob(3)) + ...
         4.*(X(:,1)>prob(1)+prob(2)+prob(3));

chaine = 1.*(X(:,2)<prob_move);

     
beta = 1/( 1 + beta_up );

Y_high = Y.*(1+theta) ;  % high value for income
Y_low  = Y.*(1-theta) ;  % low value for income

[A,Aprime,B,Bprime,D,Dprime,nA,nB] = grid_int_full(nA,sigA,Alb,Aub,nB,sigB,Blb,nD, int_size,refinement,untied);
   
   [util1,util2,util3,util4] = ...
         gen_curve_quad(A,B,D,Aprime,Bprime,Dprime,r_high,r_lend,r_water,h,vh,Y_high,Y_low,p1,p2,pd,alpha,curve,untied,fee);


    v = -100000.*(Aprime(:,1)<0).*ones(size(Aprime,1),4) ;
   
    if r_water>.6
        v = -100000.*(Bprime(:,1)<0).*ones(size(Bprime,1),4) + v;
        util1=util1.*(Bprime(:,:)==0) + -100000.*(Bprime(:,:)<0);
        util2=util2.*(Bprime(:,:)==0) + -100000.*(Bprime(:,:)<0);
        util3=util3.*(Bprime(:,:)==0) + -100000.*(Bprime(:,:)<0);
        util4=util4.*(Bprime(:,:)==0) + -100000.*(Bprime(:,:)<0);
    end  
    
    
    va = v;
    
    T = 30+Tg;
    Acc = s;
    Tsim = fix(n/Acc);

    
    
%     dev=NaN(T+5,1);
  
    mDecis = zeros(size(v,1),size(v,2),T);
    mV = zeros(size(v,1),size(v,2),T);
    mDecisa = zeros(size(v,1),size(v,2),T);
    mVa = zeros(size(v,1),size(v,2),T);
    
    M_move = 10000.*(Bprime<0);  %%% deal with moving away from Manila
    M_dl   = 10000.*(Bprime<B).*(Dprime==1);  %%% deal with 
    M_dl_end = 10000.*(Bprime<B);
    
    for t = T:-1:1
            if t==T
                    [tv1,tdecis1]=max(util1 - M_dl_end + beta.*repmat(v*prob',1,size(util1,1)));
                    [tv2,tdecis2]=max(util2 - M_dl_end + beta.*repmat(v*prob',1,size(util1,1)));
                    [tv3,tdecis3]=max(util3 - M_dl_end + beta.*repmat(v*prob',1,size(util1,1)));
                    [tv4,tdecis4]=max(util4 - M_dl_end + beta.*repmat(v*prob',1,size(util1,1)));
                    
                    [tv1a,tdecis1a]=max(util1 - M_dl_end - M_move   + beta.*repmat(va*prob',1,size(util1,1)));
                    [tv2a,tdecis2a]=max(util2 - M_dl_end - M_move   + beta.*repmat(va*prob',1,size(util1,1)));
                    [tv3a,tdecis3a]=max(util3 - M_dl_end - M_move   + beta.*repmat(va*prob',1,size(util1,1)));
                    [tv4a,tdecis4a]=max(util4 - M_dl_end - M_move   + beta.*repmat(va*prob',1,size(util1,1)));
              elseif t<T && t>T-Tg
                    [tv1,tdecis1]=max(util1 - M_dl  + beta.*repmat(v*prob',1,size(util1,1)));
                    [tv2,tdecis2]=max(util2 - M_dl  + beta.*repmat(v*prob',1,size(util1,1)));
                    [tv3,tdecis3]=max(util3 - M_dl  + beta.*repmat(v*prob',1,size(util1,1)));
                    [tv4,tdecis4]=max(util4 - M_dl  + beta.*repmat(v*prob',1,size(util1,1)));
                    
                    [tv1a,tdecis1a]=max(util1 - M_dl  + beta.*repmat(va*prob',1,size(util1,1)));
                    [tv2a,tdecis2a]=max(util2 - M_dl  + beta.*repmat(va*prob',1,size(util1,1)));
                    [tv3a,tdecis3a]=max(util3 - M_dl  + beta.*repmat(va*prob',1,size(util1,1)));
                    [tv4a,tdecis4a]=max(util4 - M_dl  + beta.*repmat(va*prob',1,size(util1,1)));
              elseif t==T-Tg
                    [tv1,tdecis1]=max(util1 - M_dl + beta.*repmat((1-prob_move).*(v*prob') + (prob_move).*(va*prob'),1,size(util1,1)));
                    [tv2,tdecis2]=max(util2 - M_dl + beta.*repmat((1-prob_move).*(v*prob') + (prob_move).*(va*prob'),1,size(util1,1)));
                    [tv3,tdecis3]=max(util3 - M_dl + beta.*repmat((1-prob_move).*(v*prob') + (prob_move).*(va*prob'),1,size(util1,1)));
                    [tv4,tdecis4]=max(util4 - M_dl + beta.*repmat((1-prob_move).*(v*prob') + (prob_move).*(va*prob'),1,size(util1,1)));
              else
                [tv1,tdecis1]=max(util1 + beta.*repmat(v*prob',1,size(util1,1)));
                [tv2,tdecis2]=max(util2 + beta.*repmat(v*prob',1,size(util1,1)));
                [tv3,tdecis3]=max(util3 + beta.*repmat(v*prob',1,size(util1,1)));
                [tv4,tdecis4]=max(util4 + beta.*repmat(v*prob',1,size(util1,1)));
            end
                tdecis=[ tdecis1' tdecis2' tdecis3' tdecis4' ];
                tv=[ tv1' tv2' tv3' tv4' ];
                v = tv  ;
                mDecis(:,:,t)=tdecis;
                mV(:,:,t)=tv;
                 
                if t>T-Tg
                    tdecisa=[ tdecis1a' tdecis2a' tdecis3a' tdecis4a' ];
                    tva=[ tv1a' tv2a' tv3a' tv4a' ];
                    va = tva  ;
                    mDecisa(:,:,t)=tdecisa;
                    mVa(:,:,t)=tva;
                end


             
%              if t<T    
%                  dev(t,1) = mean(mean((mDecis(:,:,t+1)-mDecis(:,:,t)).^2));
%              end
    end
  
    
    
%  plot(1:size(dev,1),dev)
   
%%%%% POLICY SIM ! %%%%%%

[Im,Jm] = find(B==0 & A==0 & D==0,1);

controls = zeros(Acc*Tsim-1,7);

for jj = 1:Tsim

    Athis = A(Im,Jm);
    Bthis = B(Im,Jm);
    Dthis = D(Im,Jm);
    Imark = Jm(1);
    
    for ii = 1:Acc
        II = (jj-1)*Acc + ii;
        
        if ii<Acc-T +1
            Inext = mDecis(Imark,chain(II),1);
        else
            ii_alt= ii - (Acc-T);
            if ii>Acc-Tg && chaine(jj)==1
                Inext = mDecisa(Imark,chain(II),ii_alt);            
            else
                Inext = mDecis(Imark,chain(II),ii_alt);
            end
        end
        
        Ap = Aprime(Inext,1);
        Bp = Bprime(Inext,1);
        Dp = Dprime(Inext,1);
        Imark  = Inext;

        [~,~,~,~,w1,w2,w3,w4] = ...
             gen_curve_quad(Athis,Bthis,Dthis,Ap,Bp,Dp,r_high,r_lend,r_water,h,vh,Y_high,Y_low,p1,p2,pd,alpha,curve,untied,fee);
         
        cons_full = [w1 w2 w3 w4];
        cons = cons_full(chain(II));

        controls(II,:) = [ cons Ap Bp Dp chain(II) ii chaine(jj) ];
        Athis = Ap;
        Bthis = Bp;
        Dthis = Dp;
    end
end


tm = 12;
    
h = [    mean(controls(:,1)); ...
         mean(-1.*controls(:,3)); ...
         mean(controls(:,4)==1);
         mean(controls([0; controls(1:end-1,3)]<0 & controls(:,5)>=3 & controls(:,6)<Acc-tm & controls(:,6)~=1 & [0; controls(1:end-1,4)]~=1,4)) ; ...
         mean(controls(:,3)==0); ...
         mean(abs(controls(controls(:,6)==s,3)))   ];

     
% mV(1,1,:)
     
if nargout>1
%        util = [ max(max(mV(Jm,:,size(mV,3)))) mean(mean(mV(:,:,size(mV,3)))) mean(mean(mV(Jm,:,size(mV,3)))) Jm mean(mean(C_m)) mean(mean(w_debt_m)) mean(mean(util1))];

%  util = [mV(1,:,1)  mean(mean(controls(:,7)))];
 util = prob(1,:)*mV(Jm,:,1)';
%       util = [sum(mean(mV(:,:,1)).*mean(prob))  mean(mean(controls(:,7)))];
%     util = prob(1,:)*mV(Jm,:,1)';
end

if nargout>2
   sim = controls;    
end



