function    [h,util,sim,nA,nB,A,B] = dc_obj_chow_fc(given,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement)



r_lend          = given(1,1);
r_water         = given(1,2);
r_high          = given(1,3);
fc              = given(1,4);
theta           = given(1,5);
gamma           = given(1,6);
alpha           = given(1,7);
beta_up         = given(1,8);
Y               = given(1,9);
p1              = given(1,10);
p2              = given(1,11);
pd              = given(1,12);
n               = given(1,13);
curve           = given(1,14);
r_slope         = given(1,15);
water_lending   = given(1,16);
gamma_shock     = 0;

% gamma_shock = 0
% gamma = 0
% alpha = .018
% theta = .4
% curve = 1.2

beta = 1/( 1 + beta_up );


lambda_high = 1 ;
lambda_low  = 1 ;

k_high=0;
k_low=0;

if gamma>0
   k_high  =  gamma + gamma_shock;
   k_low   = gamma - gamma_shock;
elseif gamma_shock~=0
   k_high = 0;
   k_low = 0;
   lambda_high = gamma_shock;
   lambda_low  = -1.*gamma_shock;
end


Y_high = Y.*(1+theta) ;  % high value for income
Y_low  = Y.*(1-theta) ;  % low value for income

p1d = p1;
p2d = p2;


   [A,Aprime,B,Bprime,D,Dprime,nA,nB] = grid_int(nA,sigA,Alb,Aub,nB,sigB,Blb,nD, int_size,refinement);
   
    [util1,util2,util3,util4] = ...
         gen_curve_fc(A,B,D,Aprime,Bprime,Dprime,r_high,r_slope,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,p1d,p2d,pd,alpha,k_high,k_low,lambda_high,lambda_low,curve,fc);

%     v = zeros(size(A,1),4)   ;
    v = -100000.*(Aprime(:,1)<0).*ones(size(Aprime,1),4);
    
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
    
    dev=NaN(T+5,1);
    
    mDecis = zeros(size(v,1),size(v,2),T);
    mV = zeros(size(v,1),size(v,2),T);
    
    
    for t = T:-1:1

        if dev(t+1,1)==0 && dev(t+2,1)==0 && dev(t+3,1)==0 && dev(t+4,1)==0
            mDecis(:,:,t)=mDecis(:,:,t+1);
            mV(:,:,t)=mV(:,:,t+1);
           
        else
            [tv1,tdecis1]=max(util1 + beta.*repmat(v*prob(1,:)',1,size(util1,1)));
            [tv2,tdecis2]=max(util2 + beta.*repmat(v*prob(2,:)',1,size(util1,1)));
            [tv3,tdecis3]=max(util3 + beta.*repmat(v*prob(3,:)',1,size(util1,1)));
            [tv4,tdecis4]=max(util4 + beta.*repmat(v*prob(4,:)',1,size(util1,1)));
            tdecis=[ tdecis1' tdecis2' tdecis3' tdecis4' ];

            tv=[ tv1' tv2' tv3' tv4' ];

            v = tv  ;

            mDecis(:,:,t)=tdecis;
            mV(:,:,t)=tv;
        end
        
        if t<T
            dev(t,1) = mean(mean((mDecis(:,:,t+1)-mDecis(:,:,t)).^2));
        end
    end
   
% dev
% mean(mV(:,1,:))
% plot(1:size(dev,1),dev)
% mean(mean((mDecis(:,:,3)-mDecis(:,:,4)).^2))
% mean(mean((mDecis(:,:,28)-mDecis(:,:,29)).^2))

%%%%% POLICY SIM ! %%%%%%

% [Im,Jm] = find(B==0 & A==min(min(abs(A))) & A>0 & D==0);
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
             gen_curve(Athis,Bthis,Dthis,Ap,Bp,Dp,r_high,r_slope,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,p1d,p2d,pd,alpha,k_high,k_low,lambda_high,lambda_low,curve);
        u_full = [u1 u2 u3 u4];
        u      = u_full(chain(II));
%         [~,~,~,~,...
%                  w1,w2,w3,w4] = ...
%              gen_curve(Athis,Bthis,Dthis,Ap,Bp,Dp,r_high,r_slope,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,p1d,p2d,pd,alpha,k_high,k_low,lambda_high,lambda_low,curve);
%         u      = Vnow;

        cons_full = [w1 w2 w3 w4];
        cons = cons_full(chain(II));


        controls(II,:) = [ cons Ap Bp Dp chain(II) ii u ];
        Athis = Ap;
        Bthis = Bp;
        Dthis = Dp;
    end
end


%%%   [controls repmat([1:Acc]',Tsim,1)]
% last_year = (controls(:,6)>Acc-12);
% controls1 = controls(controls(:,6)<Acc-12,:);


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
         median(w_debt_m(dd_m~=1 & ind_m<=Acc-tm)); ...
         mean(dd_m(state_m>=3 & wd1==1 & dd1==0 & ind_m<=Acc-tm)) ; ...
         mean(dd_m(state_m>=3 & wd4==1 & dd1==0 & ind_m<=Acc-tm)) ]; 
  
if nargout>1
     util = sum(mean(v).*mean(prob));
end

if nargout>2
   sim = controls;    
end



