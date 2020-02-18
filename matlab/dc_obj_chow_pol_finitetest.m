function    [h,util,sim,nA,nB,A,B] = dc_obj_chow_pol_finitetest(given,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement)



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

% gamma_shock = 0
% gamma = 0
% alpha = .018
% theta = .4
% curve = 1.2

beta = 1/( 1 + beta_up );

Y_high = Y.*(1+theta) ;  % high value for income
Y_low  = Y.*(1-theta) ;  % low value for income

%    [A,Aprime,B,Bprime,D,Dprime,nA,nB] = grid_int(nA,sigA,Alb,Aub,nB,sigB,Blb,nD, int_size,refinement);
[A,Aprime,B,Bprime,D,Dprime,nA,nB] = grid_int_full(nA,sigA,Alb,Aub,nB,sigB,Blb,nD, int_size,refinement,untied);
   
   [util1,util2,util3,util4] = ...
         gen_curve_quad(A,B,D,Aprime,Bprime,Dprime,r_high,r_lend,r_water,h,vh,Y_high,Y_low,p1,p2,pd,alpha,curve,untied,fee);

%    [util1,util2,util3,util4] = ...
%          gen_curve_quada(A,B,D,Aprime,Bprime,Dprime,r_high,r_lend,r_water,h,vh,Y_high,Y_low,p1,p2,pd,alpha,curve,untied,fee);

% UA = util1;
% mean(mean(UA1-UA))
     
%     v = zeros(size(A,1),4)   ;
%     b_end = [ zeros(size(Aprime,1),2) -100000.*(Bprime(:,1)<0).*(Dprime(:,1)==0)   -100000.*(Bprime(:,1)<0).*(Dprime(:,1)==0)];
%     b_end1 = -100000.*(Bprime(:,1)<B(1,:)').*(Dprime(:,1)==1) ;
%     v = -100000.*(Aprime(:,1)<0).*ones(size(Aprime,1),4) + b_end ;
    
    v = -100000.*(Aprime(:,1)<0).*ones(size(Aprime,1),4) ;
%     v = v + [zeros(size(Bprime,1),1) -100000.*(Bprime(:,1)<0) zeros(size(Bprime,1),1) -100000.*(Bprime(:,1)<0)];
%     if untied==1 
%          v = v-100000.*(Bprime(:,1)<0).*ones(size(Aprime,1),4);
%     end
   
    if r_water>.6
        v = -100000.*(Bprime(:,1)<0).*ones(size(Bprime,1),4) + v;
        util1=util1.*(Bprime(:,:)==0) + -100000.*(Bprime(:,:)<0);
        util2=util2.*(Bprime(:,:)==0) + -100000.*(Bprime(:,:)<0);
        util3=util3.*(Bprime(:,:)==0) + -100000.*(Bprime(:,:)<0);
        util4=util4.*(Bprime(:,:)==0) + -100000.*(Bprime(:,:)<0);
    end  
    
    T = 80;
    Acc = s;
    Tsim = fix(n/Acc);
    
    
    mDecis = zeros(size(v,1),size(v,2),T);
    mV = zeros(size(v,1),size(v,2),T);
   
    for t = T:-1:1
            if t==T
                [tv1,tdecis1]=max(util1 + beta.*repmat(v*prob(1,:)',1,size(util1,1)));
                [tv2,tdecis2]=max(util2 - 10000.*(Bprime<0) + beta.*repmat(v*prob(2,:)',1,size(util1,1)));
                [tv3,tdecis3]=max(util3 + beta.*repmat(v*prob(3,:)',1,size(util1,1)));
                [tv4,tdecis4]=max(util4 - 10000.*(Bprime<0) + beta.*repmat(v*prob(4,:)',1,size(util1,1)));
%             elseif t==T-1
%                 [tv1,tdecis1]=max(util1 + beta.*repmat(v*probe(1,:)',1,size(util1,1)));
%                 [tv2,tdecis2]=max(util2 + beta.*repmat(v*probe(1,:)',1,size(util1,1)));
%                 [tv3,tdecis3]=max(util3 + beta.*repmat(v*probe(1,:)',1,size(util1,1)));
%                 [tv4,tdecis4]=max(util4 + beta.*repmat(v*probe(1,:)',1,size(util1,1)));
             else
                [tv1,tdecis1]=max(util1 + beta.*repmat(v*prob(1,:)',1,size(util1,1)));
                [tv2,tdecis2]=max(util2 + beta.*repmat(v*prob(2,:)',1,size(util1,1)));
                [tv3,tdecis3]=max(util3 + beta.*repmat(v*prob(3,:)',1,size(util1,1)));
                [tv4,tdecis4]=max(util4 + beta.*repmat(v*prob(4,:)',1,size(util1,1)));
            end
                tdecis=[ tdecis1' tdecis2' tdecis3' tdecis4' ];

                tv=[ tv1' tv2' tv3' tv4' ];
                v = tv  ;

                 mDecis(:,:,t)=tdecis;
                 mV(:,:,t)=tv;
    end
  

   
%%%%% POLICY SIM ! %%%%%%

[Im,Jm] = find(B==0 & A==0 & D==0,1);


%states  = zeros(Acc*Tsim-1,2);
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
%             Vnow  = mV(Imark,chain(II),1);
        else
            ii_alt= ii - (Acc-T);  
            Inext = mDecis(Imark,chain(II),ii_alt);
%             Vnow  = mV(Imark,chain(II),ii_alt);
        end
        
        Ap = Aprime(Inext,1);
        Bp = Bprime(Inext,1);
        Dp = Dprime(Inext,1);
        Imark  = Inext;

        [u1,u2,u3,u4,...
                 w1,w2,w3,w4] = ...
             gen_curve_quad(Athis,Bthis,Dthis,Ap,Bp,Dp,r_high,r_lend,r_water,h,vh,Y_high,Y_low,p1,p2,pd,alpha,curve,untied,fee);
        u_full = [u1 u2 u3 u4];
        u      = u_full(chain(II));

        cons_full = [w1 w2 w3 w4];
        cons = cons_full(chain(II));


        controls(II,:) = [ cons Ap Bp Dp chain(II) ii u ];
        Athis = Ap;
        Bthis = Bp;
        Dthis = Dp;
    end
end


tm = 12;

cr = size(controls(:,5),1)/Acc;

C_m         =     reshape(controls(:,1),[Acc,cr]);
w_debt_m    = -1.*reshape(controls(:,3),[Acc,cr]);
dd_m        =     reshape(controls(:,4),[Acc,cr]);
state_m     =     reshape(controls(:,5),[Acc,cr]);
ind_m       =     reshape(controls(:,6),[Acc,cr]);

dd1= ([zeros(1,cr); dd_m(1:end-1,:)] );
    
wd1= ([zeros(1,cr); w_debt_m(1:end-1,:)]>0 );

wd4= ([zeros(1,cr); w_debt_m(1:end-1,:)]>0 & ...
      [zeros(2,cr); w_debt_m(1:end-2,:)]>0 & ...
      [zeros(3,cr); w_debt_m(1:end-3,:)]>0 & ...
      [zeros(4,cr); w_debt_m(1:end-4,:)]>0  ) ;

h = [    mean(mean(C_m(dd_m~=1 & ind_m<=Acc-tm))); ...
         mean(w_debt_m(dd_m~=1 & ind_m<=Acc-tm)); ...
         mean(dd_m(state_m>=3 & wd1==1 & dd1==0 & ind_m<=Acc-tm)) ; ...
         mean(dd_m(state_m>=3 & wd4==1 & dd1==0 & ind_m<=Acc-tm)) ]; 

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



