
% do dynamics now..

% start with simple model, then do simple deaton, then do complex deaton



clear;

dimIter=30;
beta = 0.75;

K=0:0.01:1;

[rowK,colK]=size(K);


V = zeros(colK,dimIter);

for iter=1:dimIter
    aux = zeros(colK,colK) + NaN;
    for ik=1:colK
       for ik2=1:(ik-1)
           aux(ik,ik2)=log(K(ik)-K(ik2)) + beta*V(ik2,iter);
       end
    end
    V(:,iter+1)=max(aux');
end

[Val,Ind]=max(aux');

optK=K(Ind);
optK=optK+Val*0;

optC=K'-optK';

