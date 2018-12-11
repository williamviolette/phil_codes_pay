clear;
syms x1 w1 x2 w2 y p B L r G A l1 l2



U = log(  (y-B) + (y/(1+r)) - (w2/(1+r)) ) + log(w2)

df = diff(U,w2)

w2opt=simplify(solve(df,w2))

w1opt=simplify(subs( (y-B) + (y/(1+r)) - (w2/(1+r)), w2,w2opt))

ch = simplify(w1opt-w2opt)

dB = diff(ch,B)


chs=subs(ch,[y,B],[0,1000])

solve(chs-4,r)



% bc1 = (y-B) + L  -  w1 
% bc2 = y + (1+r)*L - w2

% w1 + (w2/(1+r)) = (y-B) + (y/(1+r)) 

%U = ln(w1) + G*ln(w2)




%{

u1 = x1 + w1 - (1/(2*A))*(w1-G+A)^2 ;

u2 = x2 + w2 - (1/(2*A))*(w2-G+A)^2 ;

u1 = (w1^A) * (x1^(1-A));
u2 = (w2^A) * (x2^(1-A));

BC1 = L + y - B - p*w1 + x1 ;

BC2 = y - L*(1+r) - p*w2 + x2 ;


lan = u1 + u2 + l1*BC1 + l2*BC2;


df_x1 = diff(lan,x1);
df_x2 = diff(lan,x2);

df_w1 = diff(lan,w1);
df_w2 = diff(lan,w2);

df_L  = diff(lan,L);

[x1s,x2s,w1s,w2s,Ls,l1s,l2s] = solve([df_x1,df_x2,df_w1,df_w2,df_L,BC1,BC2],[x1,x2,w1,w2,L,l1,l2])

%}
