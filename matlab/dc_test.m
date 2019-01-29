




k_high=0;
k_low=0;
Y_high = 10000;
Y_low  = 10000;
p1=16.2   ;
p2=0.21   ;  

p1d=p1    ;
p2d=p2    ;

alpha=.02 ;
lambda_high = 0;
lambda_low=0;

D = 0;
Dprime = 0;

A = 0;
B = -500;
Aprime = 0;
Bprime = -500;

r_high = .04;
r_lend = 0;
water_lending=0;

r_water = 0;

pd = 0;

        Dprime=0;
        [util1,util2,util3con,util4,w1,w2,w3,w4] = ...
         gen_dc_4s(A,B,D,Aprime,Bprime,Dprime,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,p1d,p2d,pd,alpha,k_high,k_low,lambda_high,lambda_low);
        Dprime=1;
        [util1,util2,util3dis,util4,w1,w2,w3,w4] = ...
         gen_dc_4s(A,B,D,Aprime,Bprime,Dprime,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,p1d,p2d,pd,alpha,k_high,k_low,lambda_high,lambda_low);

     util3con
     util3dis

     
         jj = 1;
         
    Pgrid = (0:.01*jj:10*jj)' ;
    R = zeros(size(Pgrid,1),1);
    
    for i=1:size(Pgrid,1)
        %p2d = p2+Pgrid(i)/10;
        %p1d = p1+Pgrid(i);
        pd= Pgrid(i).*100;
        Dprime=0;
        [util1,util2,util3con,util4,w1,w2,w3,w4] = ...
         gen_dc_4s(A,B,D,Aprime,Bprime,Dprime,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,p1d,p2d,pd,alpha,k_high,k_low,lambda_high,lambda_low);
        Dprime=1;
        [util1,util2,util3dis,util4,w1,w2,w3,w4] = ...
         gen_dc_4s(A,B,D,Aprime,Bprime,Dprime,r_high,r_lend,r_water,water_lending,Y_high,Y_low,p1,p2,p1d,p2d,pd,alpha,k_high,k_low,lambda_high,lambda_low);
        R(i,1) = util3dis - util3con;
        %R(i,1) = util3con;
    end
    plot(Pgrid,R);

     