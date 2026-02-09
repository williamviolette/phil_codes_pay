

clear
rng(1)

folder ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp_pay/moments/';

%%% WELFARE IS WAYYYY TOO SMALL ; DOESNT MAKE SENSE!


key4 = 0; %%% determines the number of iterations! (1) lambda



real_data = 1;

est       = 0;
est_many  = 0;
counter   = 1;

first_output = 0;
second_output = 0;


mult_set = [ .9 1 1.1 ];

%%% import key stats
c_avg     = csvread(strcat(folder,'c_avg.csv'));
c_std     = csvread(strcat(folder,'c_std.csv'));
bal_avg   = csvread(strcat(folder,'bal_avg.csv'));
bal_std   = csvread(strcat(folder,'bal_std.csv'));
bal_corr  = csvread(strcat(folder,'bal_corr.csv'));
c_avg_pre  = csvread(strcat(folder,'c_avg_pre.csv'));
c_avg_dc  = csvread(strcat(folder,'c_avg_dc.csv'));

data_moments = [ c_avg c_std bal_avg bal_std bal_corr c_avg_pre c_avg_dc ];

p1        = csvread(strcat(folder,'p_int.csv'));
p2        = csvread(strcat(folder,'p_slope.csv'));
p_avg     = csvread(strcat(folder,'p_avg.csv'));
y_avg     = csvread(strcat(folder,'y_avg.csv'));
prob_caught = csvread(strcat(folder,'prob_caught.csv'));
delinquency_cost = csvread(strcat(folder,'delinquency_cost.csv'));
r_lend    = csvread(strcat(folder,'irate.csv'))./12 ; %%% convert to monthly here!

%prob_caught=.08;

n = 10000;

nA = 20;
sigA = 5000;
Agrid = 0 + sqrt(2)*sigA*erfinv(2*((1:nA)'./(nA+1))-1);
%hist(Agrid,100)

nB = 20;
sigB = 2000;
Bgrid = 0 + sqrt(2)*sigB*erfinv(2*((1:nB)'./(2.*nB+1))-1);
Bgrid =round(sort(-1.*abs(Bgrid),'descend'),0);
Bgrid = [0;Bgrid];
nB=size(Bgrid,1);
%hist(Bgrid,100)


Aprime_r = repmat(Agrid,1,nA);
A_r = repmat(Agrid,1,nA)';
Bprime_r = repmat(Bgrid,1,nB);
B_r = repmat(Bgrid,1,nB)';

A      = repelem(A_r,nB,nB);
Aprime = repelem(Aprime_r,nB,nB);
B      = repmat(B_r,nA,nA);
Bprime = repmat(Bprime_r,nA,nA);

%prob_caught = .01 ;

n_states= 8 ;
if key4==1
    n_states=4;
end
prob = [(1-prob_caught).*ones(n_states,n_states/2) (prob_caught).*ones(n_states,n_states/2)]./(n_states./2);

s0 = 1;  
[chain,state] = markov(prob,n,s0);

%alpha = (p_avg*c_avg)/y_avg ;       


% given :  r_lend , r_water, r_high ,  lambda (U) , theta (y), gamma (a), alpha , beta_up , Y , p1, p2 ,  n , metric, waterlend,
        %    1         2       3          4          5          6         7          8     9 10
%given   =   [ r_lend   0    .04           0.2       0         0      .018    .02     y_avg p1 p2 n   10  0 ];
% mult    = 1; %%% multiplier on the starting values
% option_moments = [ 7 ];
% option = [ 3 ];
% format short g

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% FIRST TEST OUTPUT %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if first_output == 1
    h = d_obj_8s(given,prob,A,Aprime,nA,B,Bprime,nB,chain,key4);


    round(h,1)

    fileID = fopen(strcat(folder,'d_main_','lambda_',num2str(given(4),'%6.2f'), ...
                             '_theta_',num2str(given(5),'%6.2f'), ...
                             '_gamma_',num2str(given(6),'%6.2f'),'.txt'),'w');
    fprintf(fileID,'%30s \n',strcat('lambda: ',num2str(given(4),'%6.2f'), ...
                             '  theta: ',num2str(given(5),'%6.2f'), ...
                             '  gamma: ',num2str(given(6),'%6.2f')));
    fprintf(fileID,'%6.3f\n',h);
    fclose(fileID);


    data = data_moments'; % need to transpose here
    data
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% SECOND TEST OUTPUT %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if second_output == 1

    data = data_moments'; % need to transpose here
    
    % given :  r_lend , r_water, r_high ,  lambda (U) ,   theta (y), gamma (a), alpha , beta_up , Y , p1, p2 ,  n , metric, waterlend,
            %    1         2       3          4            5           6         7          8     9 10
    given   =   [ r_lend   0    .04          0.15          0.2         0         .021    .015     y_avg p1 p2 n   10  0 ];

    S = [ .01 .02 .03 .04 .05 .08 ];

    H = zeros(7,size(S,2));
    U = zeros(1,size(S,2));
    for s = 1:size(S,2)
        given(3) = S(s);
        [h,US] = d_obj_8s(given,prob,A,Aprime,nA,B,Bprime,nB,chain,key4);
        H(:,s)=h;
        U(1,s)=US;
    end

    fileID = fopen(strcat(folder,'rcompn_main_','lambda_',num2str(given(4),'%6.2f'), ...
                             '_theta_',num2str(given(5),'%6.2f'), ...
                             '_gamma_',num2str(given(6),'%6.2f'),'.txt'),'w');
    fprintf(fileID,'%10s\n',' ');
    fprintf(fileID,'%30s \n',strcat('lambda: ',num2str(given(4),'%6.2f'), ...
                             '  theta: ',num2str(given(5),'%6.2f'), ...
                             '  gamma: ',num2str(given(6),'%6.2f')));
    R = [S;H;H(6,:)-H(7,:)];
    fprintf(fileID,[repmat('%6.2f\t', 1, size(R, 2)) '\n'], R');
    fprintf(fileID,'%10s\n',' ');
    fprintf(fileID,'%10s\n',' Data ');
    fprintf(fileID,'%10s\n',' ');
    fprintf(fileID,[repmat('%6.2f\t', 1, size([data;data(6,:)-data(7,:)], 2)) '\n'], [data;data(6,:)-data(7,:)]');
    fclose(fileID);
    
    [ round(R,2) round([0;data;data(6,:)-data(7,:)],2) ]
   
end



%%%%%%%%% ESTIMATION %%%%%%%%%%

% given :  r_lend , r_water, r_high ,  lambda (U) , theta (y), gamma (a), alpha , beta_up , Y , p1, p2 ,  n , metric, waterlend,
        %    1         2       3          4          5          6         7          8     9 10

given  =   [ r_lend   0    .04          0.21          0           0       .021    .02     y_avg p1  p2     n   10  0 ];
mult    = 1; %%% multiplier on the starting values

option = [ 3  4  7 ];

option_moments = [ 1 3 6 7 ];


if real_data == 1
    data = data_moments(option_moments)'; % need to transpose here
else
    data = h(option_moments);
end

weights =  eye(size(option_moments,2))./(data.^2) ;   % normalize moments to be between zero and one (matters quite a bit)


ag = given(1,option);    
obj = @(a1)d_objopt_8s(a1,given,data,option,option_moments,weights,prob,A,Aprime,nA,B,Bprime,nB,chain,key4);



if est_many == 1
        %%% run mamy starting values! %%%
    R = zeros(size(mult_set,2),size(option,2));
    OBJ_VAL = zeros(size(mult_set,2),1);
    OUTPUT = zeros(size(mult_set,2),size(data_moments,2));
        for k = 1:size(mult_set,2)
            ag
            mult_set(k).*ag
            res = fminsearch(obj,mult_set(k).*ag)

            %[~,mom_pred]=m_1loan3_objopt(res,given,data,option,option_moments,weights,prob,A,Aprime,Agrid,inA,minA,nA,chain);
            %weights_new = inv(mom_pred*mom_pred'); %%% optimal weighting matrix runs fine

            %obj_new = @(a1)m_1loan3_objopt(a1,given,data,option,option_moments,weights_new,prob,A,Aprime,Agrid,inA,minA,nA,chain);
            %res_new = fminunc(obj_new,res)
            res_new = res;
            
            res_out = given
            res_out(option) = res_new
            output1 =  d_obj_8s(res_out,prob,A,Aprime,nA,B,Bprime,nB,chain,key4)
            OUTPUT(k,:) = output1
            R(k,:) = res_new;
            OBJ_VAL(k,:) = obj(res_new);
            
        end
        
    mult_set'.*ag
    R
    OBJ_VAL

    [OUTPUT' data_moments']

    [~,ind]=min(OBJ_VAL);
    estimates = R(ind,:);
    
    csvwrite(strcat(folder,'estimates.csv'),estimates)
end



%%%%% HERE IS THE COUNTERFACTUAL !! %%%%%


if counter==1

    %[h,util] = m_1loan3_obj(res_out,prob,A,Aprime,Agrid,inA,minA,nA,chain)
    estimates = csvread(strcat(folder,'estimates.csv'));
    res_out = given;
    res_out(option)=estimates;
    res_counter = res_out;
    res_counter(2) = res_counter(3); %%% what if there were NO B!!! 
    %res_counter(2) = .1;
    
    % given :  r_lend , r_water, r_high ,  lambda (U) , theta (y), gamma (a), alpha , beta_up , Y , p1, p2 ,  n , metric, waterlend,
            %    1         2       3          4          5          6         7          8     9 10
    %res_out  =    [ r_lend   0    .028       0.174       0           0     .0202    .015     y_avg p1  p2     n   10  0 ];
    
    %res_out  =    [ r_lend    0    .028     0.2         0           0     .0202    .015     y_avg p1  p2     n   10  0 ];            
    %res_counter = [ r_lend   .028  .028     0.2         0           0     .0202    .015     y_avg p1  p2     n   10  0 ];
               

    [~,util] = d_obj_8s(res_out,prob,A,Aprime,nA,B,Bprime,nB,chain,key4)
    [~,util_counter] = d_obj_8s(res_counter,prob,A,Aprime,nA,B,Bprime,nB,chain,key4)
    
    format long g
    util - util_counter
    
    res_poor = res_out;
    res_poor(9) = res_out(9) - 10;
    [~,util_poor] = d_obj_8s(res_poor,prob,A,Aprime,nA,B,Bprime,nB,chain,key4);

    du_dy10 = (util-util_poor)/10;
    
    du_poor =  (util-util_poor)
    du =    (util - util_counter)
    dy = du/du_dy10
    
%     Ys = 2;
%     Ywindow = 20;
%     Ygrid = ((res_out(9)-Ywindow):Ys:(res_out(9)+(Ywindow./2)))' ;
%     U = zeros(size(Ygrid,1),1);
% 
%     for i=1:size(Ygrid,1)
%        res_temp = res_out;
%        res_temp(9) = Ygrid(i);
%        [~,util_temp] = d_obj_8s(res_temp,prob,A,Aprime,nA,B,Bprime,nB,chain,key4);
%        U(i,1) = abs(util_temp - util_counter);
%     end
% 
%     plot(Ygrid,U)
%     [~,ind]=min(U)
%     
%     [Ygrid(ind) res_out(9)]
%     
    
end



% 
%  n  = 2000;
%     nA = 20;
%     nB = 20;
%         
%     sigA = 5000;
%     Agrid = 0 + sqrt(2)*sigA*erfinv(2*((1:nA)'./(nA+1))-1);
%     %hist(Agrid,100)
% 
%     sigB = 2000;
%     Bgrid = 0 + sqrt(2)*sigB*erfinv(2*((1:nB)'./(2.*nB+1))-1);
%     Bgrid =round(sort(-1.*abs(Bgrid),'descend'),0);
%     Bgrid = [0;Bgrid];
%     nB=size(Bgrid,1);
%     %hist(Bgrid,100)
%     
%     Aprime_r = repmat(Agrid,1,nA);
%     A_r = repmat(Agrid,1,nA)';
%     Bprime_r = repmat(Bgrid,1,nB);
%     B_r = repmat(Bgrid,1,nB)';
% 
%     A      = repelem(A_r,nB,nB);
%     Aprime = repelem(Aprime_r,nB,nB);
%     B      = repmat(B_r,nA,nA);
%     Bprime = repmat(Bprime_r,nA,nA);
% 
%     %prob_caught = .01 ;
% 
%     n_states= 8 ;
%     if key4==1
%         n_states=4;
%     end
%     prob = [(1-prob_caught).*ones(n_states,n_states/2) (prob_caught).*ones(n_states,n_states/2)]./(n_states./2);
% 
%     s0 = 1;  
%     [chain,state] = markov(prob,n,s0);    
%     