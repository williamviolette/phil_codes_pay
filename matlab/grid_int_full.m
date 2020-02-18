function [A,Aprime,B,Bprime,D,Dprime,nA,nB] = grid_int_full(nA,sigA,Alb,Aub,nB,sigB,Blb,nD, int_size,refinement,untied)



if sigA>0
    [Agrid,Bgrid]=grid_id(nA,sigA,Alb,Aub,nB,sigB,Blb);
else
    Agrid = ((0:(nA-1))./(nA-1))'.*(Aub - Alb) + Alb ;
    Bgrid = ((0:(nB-1))./(nB-1))'.*(0 - Blb) + Blb ;
end

if int_size>1
    Agrid = l_int(Agrid,int_size);
end

if isempty(find(Agrid==0,1))
   Agrid = [Agrid(1:size(Agrid,1)/2); 0; Agrid((size(Agrid,1)/2)+1:end)];
end
nA_temp= size(Agrid,1);


if int_size>1
    Bgrid = l_int(Bgrid,int_size);
end
nB_temp = size(Bgrid,1);

Aprime_r = repmat(Agrid,1,nA_temp);
A_r = repmat(Agrid,1,nA_temp)';
Bprime_r = repmat(Bgrid,1,nB_temp);
B_r = repmat(Bgrid,1,nB_temp)';

A_r1      = repelem(A_r,nB_temp,nB_temp);
Aprime_r1 = repelem(Aprime_r,nB_temp,nB_temp);
B_r1      = repmat(B_r,nA_temp,nA_temp);
Bprime_r1 = repmat(Bprime_r,nA_temp,nA_temp);

A = repmat(A_r1,nD,nD);
B = repmat(B_r1,nD,nD);
Aprime = repmat(Aprime_r1,nD,nD);
Bprime = repmat(Bprime_r1,nD,nD);

D = [ zeros( size(A_r1,1).*nD , size(A_r1,1) )  ...
      ones( size(A_r1,1).*nD , size(A_r1,1) ) ] ;
Dprime = D';  

if refinement==1
    [A,Aprime,B,Bprime,D,Dprime] = refine_no_arbitrage(A,Aprime,B,Bprime,D,Dprime,untied) ;
end

nA = size(Agrid,1);
nB = size(Bgrid,1);
