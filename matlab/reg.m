function  b=reg(outcome,Atoday,Btoday,Dtoday,j)

if size(j,1)==1
b = regress(outcome,[ones(size(Atoday,1),1) Atoday Atoday.*Atoday ...
    Btoday Dtoday Dtoday.*Atoday Dtoday.*Btoday]);
