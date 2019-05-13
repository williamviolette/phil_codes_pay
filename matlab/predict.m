function  b=predict(outcome,Atoday,Btoday,Dtoday)

b = regress(outcome,[ones(size(Atoday,1),1) Atoday Atoday.*Atoday ...
    Btoday Dtoday Dtoday.*Atoday Dtoday.*Btoday])
