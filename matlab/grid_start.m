function [A,Aprime,B,Bprime,D,Dprime] = grid_start(nA,sigA,Alb,Aub,nB,sigB,Blb,nD,refinement)

% nBa=nB-1;
% 
% Agrid = 0 + sqrt(2)*sigA*erfinv(2*((1:nA)'./(nA+1))-1);
% Agrid = round(Agrid,0);
% 
% Bgrid = 0 + sqrt(2)*sigB*erfinv(2*((1:nBa)'./(2.*nBa+1))-1);
% Bgrid =round(sort(-1.*abs(Bgrid),'descend'),0);
% Bgrid = [0;Bgrid];

if sigA>0
    [Agrid,Bgrid]=grid_id(nA,sigA,Alb,Aub,nB,sigB,Blb);
else
    Agrid = ((0:(nA-1))./(nA-1))'.*(Aub - Alb) + Alb ;
    Bgrid = ((0:(nB-1))./(nB-1))'.*(0 - Blb) + Blb ;
end

Aprime_r = repmat(Agrid,1,nA);
A_r = repmat(Agrid,1,nA)';
Bprime_r = repmat(Bgrid,1,nB);
B_r = repmat(Bgrid,1,nB)';


A_r1      = repelem(A_r,nB,nB);
Aprime_r1 = repelem(Aprime_r,nB,nB);
B_r1      = repmat(B_r,nA,nA);
Bprime_r1 = repmat(Bprime_r,nA,nA);

A = repmat(A_r1,nD,nD);
B = repmat(B_r1,nD,nD);
Aprime = repmat(Aprime_r1,nD,nD);
Bprime = repmat(Bprime_r1,nD,nD);

D = [ zeros( size(A_r1,1).*nD , size(A_r1,1) )  ...
      ones( size(A_r1,1).*nD , size(A_r1,1) ) ] ;
Dprime = D';  

if refinement==1
    [A,Aprime,B,Bprime,D,Dprime] = refine(A,Aprime,B,Bprime,D,Dprime) ;
end




% A,A(:,test)



