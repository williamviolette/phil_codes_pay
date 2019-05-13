function [A,Aprime,B,Bprime,D,Dprime,nA,nB] = grid_int(nA,sigA,nB,sigB,nD, int_size)

nBa=nB-1;

Agrid = 0 + sqrt(2)*sigA*erfinv(2*((1:nA)'./(nA+1))-1);
Agrid = round(Agrid,0);
Agrid = l_int(Agrid,int_size);
nA_temp= size(Agrid,1);


Bgrid = 0 + sqrt(2)*sigB*erfinv(2*((1:nBa)'./(2.*nBa+1))-1);
Bgrid =round(sort(-1.*abs(Bgrid),'descend'),0);
Bgrid = [0;Bgrid];
Bgrid = l_int(Bgrid,int_size);
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

nA = size(Agrid,1);
nB = size(Bgrid,1);
