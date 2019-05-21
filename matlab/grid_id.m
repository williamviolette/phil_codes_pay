function [Agrid,Bgrid]=grid_id(nA,sigA,Alb,Aub,nB,sigB,Blb)

% nBa=nB-1;

nAg = 1000;
nBg = 1000;

Agrid = 0 + sqrt(2)*sigA*erfinv(2*((1:nAg)'./(nAg+1))-1);
Agrid = Agrid(Agrid<=Aub & Agrid>=Alb);
Agrid = [Alb; Agrid(2:end-1); Aub];
Agrid = l_int_target(Agrid,nA);
Agrid = round(Agrid,0);

Bgrid = 0 + sqrt(2)*sigB*erfinv(2*((1:nBg)'./(2.*nBg+1))-1);
Bgrid = sort(-1.*abs(Bgrid),'descend') ;
Bgrid = Bgrid(Bgrid>=Blb);
Bgrid = [Bgrid(1:end-1); Blb];
Bgrid = [0;Bgrid];
Bgrid = l_int_target(Bgrid,nB);
Bgrid =round(Bgrid,0);

