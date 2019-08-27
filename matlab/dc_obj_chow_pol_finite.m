function    [h,util,sim,nA,nB,A,B] = dc_obj_chow_pol_finite(given,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,refinement)



r_lend          = given(1,1);
r_water         = given(1,2);
r_high          = given(1,3);
lambda          = given(1,4);
theta           = given(1,5);
gamma           = given(1,6);
alpha           = given(1,7);
beta_up         = given(1,8);
Y               = given(1,9);
p1              = given(1,10);
p2              = given(1,11);
pd              = given(1,12);
n               = given(1,13);
metric          = given(1,14);
water_lending   = given(1,15);

beta = 1/( 1 + beta_up );

lambda_high = 1+lambda;
lambda_low  = 1-lambda;

Y_high = Y.*(1+theta) ;  % high value for income
Y_low  = Y.*(1-theta) ;  % low value for income

p1d = p1;
p2d = p2;

k_high = gamma;
k_low  = -gamma;


   [A,Aprime,B,Bprime,D,Dprime,nA,nB] = grid_int(nA,sigA,Alb,Aub,nB,sigB,Blb,nD, int_size,refinement);
       
   
   
    [util1,util2,util3,util4] = ...
         gen_dc_4se(A,B,D,Aprime,Bprime,Dprime,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,p1d,p2d,pd,alpha,k_high,k_low,lambda_high,lambda_low);
   

    v = zeros(size(A,1),4)   ;
          
    T = 80;
    Acc = 155;
    Tsim = fix(n/Acc);
    
    dev=NaN(T+5,1);
    
    mDecis = zeros(size(v,1),size(v,2),T);
    mV = zeros(size(v,1),size(v,2),T);
    
    for t = T:-1:1

        
        if dev(t+1,1)==0 && dev(t+2,1)==0 && dev(t+3,1)==0
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

[Im,Jm] = find(B==0 & A==min(min(abs(A))) & A>0 & D==0);

states   = zeros(Acc*Tsim-1,2);
controls = zeros(Acc*Tsim-1,5);

for jj = 1:Tsim

    Athis = A(Im(1),Jm(1));
    Bthis = B(Im(1),Jm(1));
    Dthis = D(Im(1),Jm(1));
    Imark = Jm(1);
    
    for ii = 1:Acc
        II = (jj-1)*Acc + ii;
        
        if ii<Acc-T +1
            Inext = mDecis(Imark,chain(II),1);
        else
            ii_alt= ii - (Acc-T);  
            Inext = mDecis(Imark,chain(II),ii_alt);
        end
        
        Ap = Aprime(Inext,1);
        Bp = Bprime(Inext,1);
        Dp = Dprime(Inext,1);
        Imark  = Inext;

        [~,~,~,~,...
                 w1,w2,w3,w4] = ...
             gen_dc_4se(Athis,Bthis,Dthis,Ap,Bp,Dp,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,p1d,p2d,pd,alpha,k_high,k_low,lambda_high,lambda_low);

             cons_full = [w1 w2 w3 w4];

        cons = cons_full(chain(II));

        states(II,:) = [ Athis chain(II) ];
        controls(II,:) = [ cons Ap Bp Dp ii ];
        Athis = Ap;
        Bthis = Bp;
        Dthis = Dp;
    end
end

%   [controls repmat([1:Acc]',Tsim,1)]



% for ii = 1:(n-1)
%     if ii<(n-1)-T +1
%         Inext = mDecis(Imark,chain(ii),1);
%     else
%         ii_alt= ii - ((n-1)-T);  
%         Inext = mDecis(Imark,chain(ii),ii_alt);
%     end
%     %Inext
%     %Inext = decis(Imark,chain(ii));
%     Ap = Aprime(Inext,1);
%     Bp = Bprime(Inext,1);
%     Dp = Dprime(Inext,1);
%     Imark  = Inext;
%     
%     [~,~,~,~,...
%              w1,w2,w3,w4] = ...
%          gen_dc_4se(Athis,Bthis,Dthis,Ap,Bp,Dp,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,p1d,p2d,pd,alpha,k_high,k_low,lambda_high,lambda_low);
%     
%          cons_full = [w1 w2 w3 w4];
%     
%     cons = cons_full(chain(ii));
%     
%     states(ii,:) = [ Athis chain(ii) ];
%     controls(ii,:) = [ cons Ap Bp Dp];
%     Athis = Ap;
%     Bthis = Bp;
%     Dthis = Dp;
% end





w_debt = -1.*controls(:,3);
        
C = controls(:,1);
dd = (controls(:,4)==1);

state_now  = states(:,2);
state_pre  = [0; states(1:end-1,2)];
state_pre2 = [0;0; states(1:end-2,2)];
state_pre3 = [0;0;0; states(1:end-3,2)];
%state_pre4 = [0;0;0;0; states(1:end-4,2)];
% state_pre5 = [0;0;0;0;0; states(1:end-5,2)];

d_post      = mean(controls(state_now>=3,4));
d_post_pre  = mean(controls(state_pre>=3,4));
d_post_pre2 = mean(controls(state_pre2>=3,4));
d_post_pre3 = mean(controls(state_pre3>=3,4));
% d_post_pre4 = mean(controls(state_pre4>=3,4));
% d_post_pre5 = mean(controls(state_pre5>=3,4));

dd_mom=[d_post; d_post_pre; d_post_pre2; d_post_pre3];

% corr_moment = corr(w_debt(dd~=1),C(dd~=1));
corr_moment = 0;

h = [mean(mean(C(dd~=1))); std(C(dd~=1));  ...
    mean(w_debt(dd~=1));  std(w_debt(dd~=1)); ...
    corr_moment; ...
    dd_mom ];


if s==1
    %%% balance in the pre-period!

    w_debt_pre  = [0; w_debt(1:end-1,1)];
    w_debt_pre1 = [0;0; w_debt(1:end-2,1)];
    w_debt_pre2 = [0;0;0; w_debt(1:end-3,1)];
    w_debt_pre3 = [0;0;0;0; w_debt(1:end-4,1)];
    w_debt_pre4 = [0;0;0;0;0; w_debt(1:end-5,1)];
    w_debt_pre5 = [0;0;0;0;0;0; w_debt(1:end-6,1)];
    %w_debt_pre6 = [0;0;0;0;0;0;0; w_debt(1:end-7,1)];
    % w_debt_pre7 = [0;0;0;0;0;0;0;0; w_debt(1:end-8,1)];

    w_pre  = (w_debt_pre>0  & w_debt_pre1>0 & w_debt_pre2>0) ;
    w_pre1 = (w_debt_pre1>0 & w_debt_pre2>0 & w_debt_pre3>0) ;
    w_pre2 = (w_debt_pre2>0 & w_debt_pre3>0 & w_debt_pre4>0) ;
    w_pre3 = (w_debt_pre3>0 & w_debt_pre4>0 & w_debt_pre5>0) ;
    %w_pre4 = (w_debt_pre4>0 & w_debt_pre5>0 & w_debt_pre6>0) ;

    % [w_debt_pre w_debt_pre2 w_debt_pre3 w_pre1]

    d_post_pre_b  = mean(controls(state_now>=3  & w_pre==1,4));
    d_post_pre1_b  = mean(controls(state_pre>=3  & w_pre1==1,4));
    d_post_pre2_b = mean(controls(state_pre2>=3 & w_pre2==1,4));
    d_post_pre3_b = mean(controls(state_pre3>=3 & w_pre3==1,4));
    %d_post_pre4_b = mean(controls(state_pre4>=3 & w_pre4==1,4));
    % d_post_pre5_b = mean(controls(state_pre5>=3 & w_debt_pre5>bt,4));

    ddb_mom = [d_post_pre_b; d_post_pre1_b; d_post_pre2_b; d_post_pre3_b];
    h = [h;ddb_mom];

end



if nargout>1
    util = sum(mean(v).*mean(prob));
end

if nargout>2
   sim = [controls states(:,2)];    
end




% S_0 = states(:,2);
% S_1 = [0;states(1:end-1,2)];
% 
% A_1 = controls(:,2);
% A_0 = [0;controls(1:end-1,2)];
% 
% B_1 = controls(:,3);
% B_0 = [0;controls(1:end-1,3)];
% 
% D_1 = controls(:,4);
% D_0 = [0;controls(1:end-1,4)];
% 
% scatter(A_0(D_0==0 & S_0==1 & B_0==0),A_1(D_0==0 & S_0==1 & B_0==0))
% scatter(B_0(D_0==0 & S_0==1 & A_0<0),B_1(D_0==0 & S_0==1 & A_0<0))





