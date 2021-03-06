function    [h,util,sim,nA,nB,A,B,vstart] = dc_obj_chow(given,prob,nA,sigA,Alb,Aub,nB,sigB,Blb,nD,chain,s,int_size,Fset,refinement,vgiven)




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

[A,Aprime,B,Bprime,D,Dprime] = grid_start(nA,sigA,Alb,Aub,nB,sigB,Blb,nD,refinement);

[util1,util2,util3,util4] = ...
         gen_dc_4se(A,B,D,Aprime,Bprime,Dprime,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,p1d,p2d,pd,alpha,k_high,k_low,lambda_high,lambda_low);

if sum(size(vgiven))>2
    v = vgiven;
else
    v       = zeros(size(A,1),size(prob,1));
end


[v,decis]=opt_loop(v,util1,util2,util3,util4,beta,prob,metric);

if nargout>7 
    vstart = v;
end



for f =1:Fset

   if refinement==0
        v=[grid_int_v(v(:,1),nA,nB,int_size) ...
           grid_int_v(v(:,2),nA,nB,int_size) ...
           grid_int_v(v(:,3),nA,nB,int_size) ...
           grid_int_v(v(:,4),nA,nB,int_size)];
   end
        [A,Aprime,B,Bprime,D,Dprime,nA,nB] = grid_int(nA,sigA,Alb,Aub,nB,sigB,Blb,nD, int_size,refinement);   
   if refinement==1
        v=[l_int_target(v(:,1),size(A,1)) ...
           l_int_target(v(:,1),size(A,1)) ...
           l_int_target(v(:,1),size(A,1)) ...
           l_int_target(v(:,1),size(A,1)) ];
   end
   
    [util1,util2,util3,util4] = ...
         gen_dc_4se(A,B,D,Aprime,Bprime,Dprime,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,p1d,p2d,pd,alpha,k_high,k_low,lambda_high,lambda_low);
    [v,decis]=opt_loop(v,util1,util2,util3,util4,beta,prob,metric);
    
end




% vv   =zeros(size(decis,1),1);
% 
% Imark=1;
% for ii = 1:n-1
%     Inext = decis(Imark,chain(ii));
%     vv(Inext)=vv(Inext)+1;
%     Imark = Inext;
% end
% 
% [vv Aprime(:,1) Bprime(:,1) Dprime(:,1)]


% vv=zeros(size(decis,1),1)
% vv(unique(decis(:,1)))=1;
% sum(vv)
% vv(unique(decis(:,2)))=1;
% vv(unique(decis(:,3)))=1;
% vv(unique(decis(:,4)))=1;
% sum(vv)


% hold on
% plot((1:size(A,1))',A(1,:)')
% yyaxis right
% plot((1:size(A,1))',l_int_target(v(:,1),size(A,1)))
% 


%%%%% POLICY SIM ! %%%%%%


Imark = 1;
Athis = A(Imark,1);  % initial asset levels
Bthis = B(Imark,1);  % initial asset levels
Dthis = D(Imark,1);
%Athis = 0;  % initial asset levels
%Bthis = 0;  % initial asset levels

states   = zeros(n-1,2);
controls = zeros(n-1,4);

for ii = 1:n-1
    Inext = decis(Imark,chain(ii));
    Ap = Aprime(Inext,1);
    Bp = Bprime(Inext,1);
    Dp = Dprime(Inext,1);
    Imark  = Inext;
    
    [~,~,~,~,...
             w1,w2,w3,w4] = ...
         gen_dc_4se(Athis,Bthis,Dthis,Ap,Bp,Dp,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,p1d,p2d,pd,alpha,k_high,k_low,lambda_high,lambda_low);
    
         cons_full = [w1 w2 w3 w4];
    
    cons = cons_full(chain(ii));
    
    states(ii,:) = [ Athis chain(ii) ];
    controls(ii,:) = [ cons Ap Bp Dp];
    Athis = Ap;
    Bthis = Bp;
    Dthis = Dp;
end


S = [0;states(1:end-1,2)];

A_1 = controls(:,2);
A_0 = [0;controls(1:end-1,2)];

B_1 = controls(:,3);
B_0 = [0;controls(1:end-1,3)];

D_1 = controls(:,4);
D_0 = [0;controls(1:end-1,4)];


scatter(A_0(D_0==0 & S==1 & B_0==0),A_1(D_0==0 & S==1 & B_0==0))


scatter(A_0(D_0==0 & S==1 & B_0==0),A_1(D_0==0 & S==1 & B_0==0))


scatter(A_0(D_0==0 & S==1 & B_0<0),A_1(D_0==0 & S==1 & B_0<0))


scatter(A_0(S==2 & D_0==1)+B_0(S==2 & D_0==1),D_1(S==2 & D_0==1))



plot(states(:,1),controls(:,2))

scatter(states(states(:,2)==1 & controls(:,3)==0,1),controls(states(:,2)==1 & controls(:,3)==0,2))

scatter(states(states(:,2)==1 ,1),controls(states(:,2)==1,3))

% scatter(controls(states(:,2)==1 ,1) + states(states(:,2)==1 ,3),controls(states(:,2)==1,3))

% plot((1:n-1)',controls(:,1))
% [ states controls ]

%controls_pre  = [0; controls(1:end-1,3)];
%C(controls(:,3)<-7000 & controls_pre>-7000)

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









%  c_pre; c_post; (c_pre-c_post)

% state_next  = [states(2:end,2); 0];

% B_est = controls(:,3);
% B_est_pre = [0; controls(1:end-1,3)]; %%% key typo

% state_now_ind=2;
% state_next_ind=3;     
    
% c_pre  = mean(C(state_now<=state_now_ind & state_next>=state_next_ind & B_est<0));  % sending debt to next period
% c_post = mean(C(state_now>=state_next_ind & state_pre<=state_now_ind  & B_est_pre<0 ));    % getting hit with debt and enforcement 


%%%%% PREDICTIVE APPROACH TO POLICY FUNCTION ! 

% 
% At = A(1,:)';
% Bt = B(1,:)';
% At_3 = A(1,:)';
% At1 = Aprime(decis(:,1),1);
% 
% % At = Aprime(decis(:,1),1);
% 
% 
% Dt_3 = D(3,:)';
% Dt1_3 = Dprime(decis(:,3),1);
% 
% plot(At(1:37:(size(At,1)/2),1),At1(1:37:(size(At,1)/2),1))
% 
% plot(At(36:37:(size(At,1)/2),1),At1(10:37:(size(At,1)/2),1))
% 
% 
% plot(At(1:1:(size(At,1)/2))+Bt(1:1:(size(At,1)/2),1),Dt1_3(1:1:(size(At,1)/2),1))
% 
% plot(At((size(At,1)/2)+1:1:end)+Bt((size(At,1)/2)+1:1:end),Dt1_3((size(At,1)/2)+1:1:end) )
% 
% [a_sorted, a_order] = sort(Bt((size(At,1)/2)+1:1:end));
% newB = B(a_order,:)
% 
% test= [Bt((size(At,1)/2)+1:1:end) Dt1_3((size(At,1)/2)+1:1:end)];
% test(a_order,:)
% 
% 
% [At((size(At,1)/2)+1:1:end) Bt((size(At,1)/2)+1:1:end) Dt1_3((size(At,1)/2)+1:1:end)]
% %%%% MAKE APPROXIMATION OF POLICY FUNCTION WITH A FUNCTION, COMPARE TO ACTUAL FUNCTION! !! %%%%
% 
% Atomorrow = [Aprime(decis(:,1),1) Aprime(decis(:,2),1) Aprime(decis(:,3),1) Aprime(decis(:,4),1)] ;
% Btomorrow = [Bprime(decis(:,1),1) Bprime(decis(:,2),1) Bprime(decis(:,3),1) Bprime(decis(:,4),1)] ;
% Dtomorrow = [Dprime(decis(:,1),1) Dprime(decis(:,2),1) Dprime(decis(:,3),1) Dprime(decis(:,4),1)] ;
% 
% Xp = Xprep(A(1,:)',B(1,:)', D(1,:)');
% 
% bA = [ regress(Atomorrow(:,1),Xp)  regress(Atomorrow(:,2),Xp)  regress(Atomorrow(:,3),Xp)  regress(Atomorrow(:,4),Xp) ]; 
% bB = [ regress(Btomorrow(:,1),Xp)  regress(Btomorrow(:,2),Xp)  regress(Btomorrow(:,3),Xp)  regress(Btomorrow(:,4),Xp) ]; 
% bD = [ regress(Dtomorrow(:,1),Xp)  regress(Dtomorrow(:,2),Xp)  regress(Dtomorrow(:,3),Xp)  regress(Dtomorrow(:,4),Xp) ]; 
% 
% Imark = 1;
% Athis = A(Imark,1);  % initial asset levels
% Bthis = B(Imark,1);  % initial asset levels
% Dthis = D(Imark,1);
% 
% controls_new = zeros(n-1,4);
% 
% for ii = 1:n-1
%     chain(ii);
%     Ap = Xprep(Athis,Bthis,Dthis)*bA(:,chain(ii));
%     Bp = Xprep(Athis,Bthis,Dthis)*bB(:,chain(ii));
%     Dp = round(Xprep(Athis,Bthis,Dthis)*bD(:,chain(ii)),1);
%     
%     controls_new(ii,:) = [ chain(ii) Ap Bp Dp ];
%     Athis = Ap;
%     Bthis = Bp;
%     Dthis = Dp;
% end


%%% PLOT COMPARISON ! %%%

% 
% nt = 50;
% hold on
% plot( (1:nt)' ,controls(1:nt,2) , (1:nt)' ,controls_new(1:nt,2) )
%  
% yyaxis right
% plot( (1:nt)' ,controls(1:nt,3) , (1:nt)' ,controls_new(1:nt,3) )
% 
% 
% hold on 
% plot((1:200)',controls(1:200,2))
% yyaxis right
% plot((1:200)',controls(1:200,3))





% 
% 
% %%%%% PREDICTIVE APPROACH TO POLICY FUNCTION !
% 
% At = A(1,:)';
% Bt = B(1,:)';
% % At_3 = A(1,:)';
% % At1 = Aprime(decis(:,1),1);
% % 
% % At = Aprime(decis(:,1),1);
% 
% Dt = D(1,:)';
% 
% Dt_1 = Dprime(decis(:,1),1); 
% 
% 
% 
% Bt1_1 = Bprime(decis(:,1),1); 
% Bt1_2 = Bprime(decis(:,2),1); 
% 
% Bt1_3 = Bprime(decis(:,3),1); 
% Bt1_4 = Bprime(decis(:,4),1); 
% 
% bound = [Bt(boundary(Bt,Bt1_1)) Bt1_1(boundary(Bt,Bt1_1))];
% plane = bound( (bound(:,1)~=min(bound(:,1))) & (bound(:,2)~=max(bound(:,2))) ,:);
% b_plane = regress(plane(:,2),[ones(size(plane,1),1) plane(:,1)])
% 
% 
% bound_2 = [Bt(boundary(Bt,Bt1_2)) Bt1_2(boundary(Bt,Bt1_2))];
% plane_2 = bound_2( (bound_2(:,1)~=min(bound_2(:,1))) & (bound_2(:,2)~=max(bound_2(:,2))) ,:);
% b_plane_2 = regress(plane_2(:,2),[ones(size(plane_2,1),1) plane_2(:,1)])
% 
% hold on
% scatter(plane_2(:,1),plane_2(:,2))
% scatter(plane(:,1),plane(:,2))
% 
% 
% scatter(Bt,Bt1_1)
% 
% scatter(Bt(Dt==1),Bt1_2(Dt==1))
% 
% scatter(At,Bt1_4)
% 
% scatter(Bt,Bt1_3)
% scatter(Bt,Bt1_4)
% 
% 
% Dt1_1 = Dprime(decis(:,1),1); 
% Dt1_2 = Dprime(decis(:,2),1); 
% Dt1_3 = Dprime(decis(:,3),1); 
% Dt1_4 = Dprime(decis(:,4),1); 
% 
% [Dt1_1 Dt1_2 Dt1_3 Dt1_4 Dt At Bt]
% 
% kk = [ Dt1_4 At Bt Dt]
% 
% 
% h_temp = [0 0];
% 
% for i = 2:size(kk,1)
%    if  kk(i-1,1)==0 && kk(i,1)==1
%         h_temp=[h_temp ; kk(i,2) kk(i,3)] 
%    end
% end
% 
% plot(h_temp(2:4,2),h_temp(2:4,1))
% 
% plot(At(1:37:(size(At,1)/2),1),At1(1:37:(size(At,1)/2),1))
% 
% 
% % At Bt  
% %%% D rule = 
% 
% plot(At(36:37:(size(At,1)/2),1),At1(10:37:(size(At,1)/2),1))
% 
% 
% plot(At(1:1:(size(At,1)/2))+Bt(1:1:(size(At,1)/2),1),Dt1_3(1:1:(size(At,1)/2),1))
% 
% plot(At((size(At,1)/2)+1:1:end)+Bt((size(At,1)/2)+1:1:end),Dt1_3((size(At,1)/2)+1:1:end) )
% 
% [a_sorted, a_order] = sort(Bt((size(At,1)/2)+1:1:end));
% newB = B(a_order,:)
% 
% test= [Bt((size(At,1)/2)+1:1:end) Dt1_3((size(At,1)/2)+1:1:end)];
% test(a_order,:)
% 
% 
% [At((size(At,1)/2)+1:1:end) Bt((size(At,1)/2)+1:1:end) Dt1_3((size(At,1)/2)+1:1:end)]
% %%%% MAKE APPROXIMATION OF POLICY FUNCTION WITH A FUNCTION, COMPARE TO ACTUAL FUNCTION! !! %%%%
% 
% Atomorrow = [Aprime(decis(:,1),1) Aprime(decis(:,2),1) Aprime(decis(:,3),1) Aprime(decis(:,4),1)] ;
% Btomorrow = [Bprime(decis(:,1),1) Bprime(decis(:,2),1) Bprime(decis(:,3),1) Bprime(decis(:,4),1)] ;
% Dtomorrow = [Dprime(decis(:,1),1) Dprime(decis(:,2),1) Dprime(decis(:,3),1) Dprime(decis(:,4),1)] ;
% 
% Xp = Xprep(A(1,:)',B(1,:)', D(1,:)');
% 
% bA = [ regress(Atomorrow(:,1),Xp)  regress(Atomorrow(:,2),Xp)  regress(Atomorrow(:,3),Xp)  regress(Atomorrow(:,4),Xp) ]; 
% bB = [ regress(Btomorrow(:,1),Xp)  regress(Btomorrow(:,2),Xp)  regress(Btomorrow(:,3),Xp)  regress(Btomorrow(:,4),Xp) ]; 
% bD = [ regress(Dtomorrow(:,1),Xp)  regress(Dtomorrow(:,2),Xp)  regress(Dtomorrow(:,3),Xp)  regress(Dtomorrow(:,4),Xp) ]; 
% 
% Imark = 1;
% Athis = A(Imark,1);  % initial asset levels
% Bthis = B(Imark,1);  % initial asset levels
% Dthis = D(Imark,1);
% 
% controls_new = zeros(n-1,4);
% 
% for ii = 1:n-1
%     chain(ii);
%     Ap = Xprep(Athis,Bthis,Dthis)*bA(:,chain(ii));
%     Bp = Xprep(Athis,Bthis,Dthis)*bB(:,chain(ii));
%     Dp = round(Xprep(Athis,Bthis,Dthis)*bD(:,chain(ii)),1);
%     
%     controls_new(ii,:) = [ chain(ii) Ap Bp Dp ];
%     Athis = Ap;
%     Bthis = Bp;
%     Dthis = Dp;
% end
% 
% 
% %% PLOT COMPARISON ! %%%
% 
% 
% nt = 50;
% hold on
% plot( (1:nt)' ,controls(1:nt,2) , (1:nt)' ,controls_new(1:nt,2) )
%  
% yyaxis right
% plot( (1:nt)' ,controls(1:nt,3) , (1:nt)' ,controls_new(1:nt,3) )
% 
% 
% hold on 
% plot((1:200)',controls(1:200,2))
% yyaxis right
% plot((1:200)',controls(1:200,3))
% 
% 
% 


