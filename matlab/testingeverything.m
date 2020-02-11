



Y_high = 20000
debt_12 = 1
p1f = 25
p2f = .3
alpha = 2000

Lf_12 = -2000
lambda_high = 1


[util1,w1] = u_ql(Lf_12,debt_12,alpha,p1f,p2f,Y_high, lambda_high)

L1 = [-2000:10:-1000];
J = ones(size(L1,2),2);

L_cut = cut_ql(alpha,p1f,p2f)


for i = 1:size(L1,2)
    [util1,w1]=u_ql(L1(i),debt_12,alpha,p1f,p2f,Y_high+L1(i), lambda_high);
    J(i,:)=[util1 w1];
end

plot(L1',J(:,1))