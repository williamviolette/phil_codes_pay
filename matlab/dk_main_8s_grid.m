

clear
octave_setup;
rng(1)

folder ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp_pay/moments/';


real_data     = 1     ;
first_output  = 0     ;
second_output = 0     ;
est_many      = 0     ;
counter       = 1     ;



mult_set = [  .9   1  ];

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

%prob_caught=.05;

n = 10000;  %%% GRID SIZE AFFECTS THE MAXIMUM !!!!!!!

nA = 25 ;
sigA = 10000 ;
Agrid = 0 + sqrt(2)*sigA*erfinv(2*((1:nA)'./(nA+1))-1);
Agrid = round(Agrid,0);
%hist(Agrid,100)

nB = 25 ;
sigB = 3800 ;
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


n_states=8;


pyk = .2 ;

pym = [ pyk  (1-pyk) pyk  (1-pyk) ; ...
        pyk  (1-pyk) pyk  (1-pyk) ; ...
        (1-pyk) pyk  (1-pyk)  pyk ; ...
        (1-pyk) pyk  (1-pyk)  pyk  ];

prob = [(1-prob_caught).*[pym; pym] (prob_caught).*[pym; pym]]./2;

%prob = [(1-prob_caught).*ones(n_states,n_states/2) (prob_caught).*ones(n_states,n_states/2)]./(n_states./2);

%%% CORRELATED SHOCKS! %%% % LAST THING TO MATCH...
                  %   Yh, kh   Yh, kl   Yl, kh   yl, kl
% 1 : Y_high k_high     X      (1-X)       X     (1-X)
% 2 : Y_high k_low      X      (1-X)       X     (1-X)
% 3 : Y_low k_high     (1-X)     X        (1-X)    X
% 4 : Y_low k_low      (1-X)     X        (1-X)    X




s0 = 1;  
[chain,state] = markov(prob,n,s0);

%alpha = (p_avg*c_avg)/y_avg ;       


% given :  r_lend , r_water, r_high ,  lambda (U) , theta (y), gamma (k), alpha , beta_up , Y , p1, p2 ,  n , metric, waterlend,
        %    1         2       3          4          5          6         7          8     9 10
%given   =   [ r_lend   0    .04           .3          .3         0       .018    .02     y_avg p1 p2 n   10  0 ];
%mult    = 1; %%% multiplier on the starting values

%option_moments = [ 7 ];
%option = [ 3 ];

format long g



if first_output == 1
    h = dk_obj_8s(given,prob,A,Aprime,nA,B,Bprime,nB,chain);


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





%{a
if second_output == 1

    %%% set theta high, adjust gamma to hit VAR and alpha to hit MEAN, then
    %%% look for R to hit 
    
    data = data_moments'; % need to transpose here
    % given :  r_lend , r_water, r_high ,  lambda (U) ,   theta (y), gamma (a), alpha , beta_up , Y , p1, p2 ,  n , metric, waterlend,
            %    1         2       3          4            5           6         7          8     9 10
    given   =   [ r_lend   0     .03          .2          0.4         0       .019      .02     y_avg p1 p2 n   10  0 ];

    S = [ 0 .01 .02 .03 .04 .05 .06 .07 .08 ];
    S = [ 0  .03  .05 ];

    H = zeros(7,size(S,2));
    U = zeros(1,size(S,2));
    for s = 1:size(S,2)
        given(3) = S(s);
        [h,US] = dk_obj_8s(given,prob,A,Aprime,nA,B,Bprime,nB,chain);
        H(:,s)=h;
        U(1,s)=US;
    end

    fileID = fopen(strcat(folder,'kcompn_main_','lambda_',num2str(given(4),'%6.2f'), ...
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


    round(R,2)
    round([data;data(6,:)-data(7,:)],2)

end




%%%%%%%%% ESTIMATION %%%%%%%%%%

% given :  r_lend , r_water, r_high ,  lambda (U) ,   theta (y), gamma (a), alpha , beta_up , Y , p1, p2 ,  n , metric, waterlend,
            %    1     2       3          4            5           6         7          8     9 10
given   =   [ r_lend   0     .04          0            0.2         15       .018    .02     y_avg p1 p2 n   10  0 ];

option = [ 3   5  6  7 ];

option_moments = [ 1 2 3 4 6 7 ];


if real_data == 1
    data = data_moments(option_moments)'; % need to transpose here
else
    data = h(option_moments);
end

weights =  eye(size(option_moments,2))./(data.^2) ;   % normalize moments to be between zero and one (matters quite a bit)


ag = given(1,option);    
obj = @(a1)dk_objopt_8s(a1,given,data,option,option_moments,weights,prob,A,Aprime,nA,B,Bprime,nB,chain);



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
            output1 =  dk_obj_8s(res_out,prob,A,Aprime,nA,B,Bprime,nB,chain)
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




if counter==1

    %[h,util] = m_1loan3_obj(res_out,prob,A,Aprime,Agrid,inA,minA,nA,chain)
%     
%     estimates = csvread(strcat(folder,'estimates.csv'));
%     res_out = given;
%     res_out(option)=estimates;
%     res_counter = res_out;
%     res_counter(2) = res_counter(3); %%% what if there were NO B!!! 
%     res_counter(2) = .3;
    
    % given :  r_lend , r_water, r_high ,  lambda (U) , theta (y), gamma (a), alpha , beta_up , Y , p1, p2 ,  n , metric, waterlend,
            %    1         2       3          4          5          6         7          8     9 10
    %res_out=     [ r_lend   0     .032      0      0.2156       15.3     .0205    .02     y_avg p1 p2 n   10  0 ];

    res_out =     [ r_lend   0     .032      0      0.2156       15.3     .0205    .02     (y_avg+delinquency_cost) p1 p2 n   10  0 ];
    res_counter = [ r_lend  .6     .032      0      0.2156       15.3     .0205    .02     y_avg p1 p2 n   10  0 ];
    
    
    
    ww = w_reg_dk(0,res_out(7),0,p1,p2, (y_avg + delinquency_cost) );
    
    %ww = w_reg_dk(0,res_out(7),0,p1+1,p2,y_avg);
    
    rev_goal = ((p1 + p2.*ww).*ww) - delinquency_cost;
    
    Pgrid = -1.*(0:.01:10)' ;
    R = zeros(size(Pgrid,1),1);
    for i=1:size(Pgrid,1)
        p1n = p1+Pgrid(i);
        ww = w_reg_dk(0,res_out(7),0,p1n,p2,y_avg);
        rev = (p1n + p2.*ww).*ww;
        R(i,1) = abs(rev - rev_goal);
    end
    %plot(Pgrid,R);
    [~,ind]=min(R);
    Pgrid(ind)
    
    p1c=p1+Pgrid(ind);
           % given :  r_lend , r_water, r_high ,  lambda (U) , theta (y), gamma (a), alpha , beta_up , Y , p1, p2 ,  n , metric, waterlend,
                   %    1         2       3          4          5          6         7          8       9        10
    res_out     = [ r_lend      0       .03         0.15      0.7        0        .02        .02     (y_avg+delinquency_cost)   p1   p2  n   10  0 ];
    res_counter = [ r_lend     .8       .03         0.15      0.7        0        .02        .02       y_avg                    p1c  p2  n   10  0 ];
    
     
    [~,util] = dk_obj_8s(res_out,prob,A,Aprime,nA,B,Bprime,nB,chain)
    [~,util_counter] = dk_obj_8s(res_counter,prob,A,Aprime,nA,B,Bprime,nB,chain)
    
    format long g
    util - util_counter
    
    res_poor = res_out;
    res_poor(9) = res_out(9) - 10;
    [~,util_poor] =dk_obj_8s(res_poor,prob,A,Aprime,nA,B,Bprime,nB,chain);

    du_dy10 = (util-util_poor)/10;
    
    du_poor =  (util-util_poor)
    du =    (util - util_counter)
    dy = du/du_dy10
    
    Ys = 5;

    
%     Ywindow = 60;
%     Ygrid = ((res_out(9)-Ywindow):Ys:(res_out(9)+Ys))' ;
%     U = zeros(size(Ygrid,1),1);
% 
%     for i=1:size(Ygrid,1)
%        res_temp = res_out;
%        res_temp(9) = Ygrid(i);
%        [~,util_temp] = dk_obj_8s(res_temp,prob,A,Aprime,nA,B,Bprime,nB,chain);
%        U(i,1) = abs(util_temp - util_counter);
%     end
% 
%     plot(Ygrid,U)
%     [~,ind]=min(U)
%     
%     [Ygrid(ind) res_out(9) (Ygrid(ind)-res_out(9))]


end