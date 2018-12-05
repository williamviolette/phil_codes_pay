

%{a

%%% cobb-doug  THIS WORKS WELL TO BALL-PARK EFFECTS!
clear;
syms x1 w1 x2 w2 y p B L r G A l1 l2 d z D

%assume(d>0 & d<1)
%assume(z>0 & z<1)
assume(r>0 & r<1)
assume(l1>0)
assume(p>0)
assume(w1>0)
assume(w2>0)
assume(x1>0)
assume(x2>0)
assume(B>0)
assume(y>0)
assume(D>0 & D<1)

% bc1 = (y-B) + L  -  p*w1 + x1
% bc2 = y + (1+r)*L - p*w2 + x2

% p*w1+x1 + ((p*w2+x2)/(1+r)) = (y-B) + (y/(1+r)) 


%U = x1+(G-w1)^2 + x2+(G-w2)^2

lan  =  d*log(x1) + z*log(w1)  + (1/(1+D))*( d*log(x2) + z*log(w2) )  +  l1*( (y-B) + (y/(1+r))  - (p*w1+x1 + ((p*w2+x2)/(1+r))) )    

dw1 = diff(lan,w1)
dw2 = diff(lan,w2)

dx1 = diff(lan,x1)
dx2 = diff(lan,x2)

dl1 = diff(lan,l1)

[w1s,w2s,x1s,x2s,l1s,ps,cs] = solve([dw1,dw2,dx1,dx2,dl1],[w1,w2,x1,x2,l1],'ReturnConditions',true)


ds = simplify(subs(simplify(w1s-w2s),d+z,1))


dr = eval(subs(ds,[B,y,p,z,D],[1200,22000,20,.04,.05]))

%eval(solve(dr+2,r))

eval(solve(eval(subs(ds,[B,y,p,z,D],[1200,22000,25,.05,.05])) + 4,r))


% wopt = simplify(subs(w1s,[B,d,r,D],[0,1-z,0,0]))

%}






%{

%%%% problem is ADDITIVE COBB - DOUG! been here before dude...


%%% cobb-doug
clear;
syms x1 w1 x2 w2 y p B L r G A l1 l2 d z

assume(d>0 & d<1)
assume(z>0 & z<1)
assume(r>0 & r<1)
assume(l1>0)
assume(p>0)

% bc1 = (y-B) + L  -  p*w1 + x1
% bc2 = y + (1+r)*L - p*w2 + x2

% p*w1+x1 + ((p*w2+x2)/(1+r)) = (y-B) + (y/(1+r)) 


%U = x1+(G-w1)^2 + x2+(G-w2)^2

lan  =  (x1^(d))*(w1^(z))  + (x2^(d))*(w2^(z))  +  l1*( (y-B) + (y/(1+r))  - (p*w1+x1 + ((p*w2+x2)/(1+r))) )    

dw1 = diff(lan,w1)
dw2 = diff(lan,w2)

dx1 = diff(lan,x1)
dx2 = diff(lan,x2)

%lt1 = solve(dx1,l1)
%lt2 = solve(dx2,l1)

dl1 = diff(lan,l1)

[w1s,w2s,x1s,x2s,l1s,ps,cs] = solve([dw1,dw2,dx1,dx2,dl1],[w1,w2,x1,x2,l1],'ReturnConditions',true)


%}


%{

%%% cobb-doug test
clear;
syms x1 w1 x2 w2 y p B L r G A l1 l2 d z


assume(d>0 & d<1)
assume(z>0 & z<1)
assume(r>0 & r<1)
assume(l1>0)

% bc1 = (y-B) + L  -  p*w1 + x1
% bc2 = y + (1+r)*L - p*w2 + x2

% p*w1+x1 + ((p*w2+x2)/(1+r)) = (y-B) + (y/(1+r)) 


%U = x1+(G-w1)^2 + x2+(G-w2)^2

lan  =  (x1^(d))*(w1^(z))  + (x2^(d))*(w2^(z))  +  l1*( (y-B)  - (p*w1+x1) )    

dw1 = diff(lan,w1)

dx1 = diff(lan,x1)

%lt1 = solve(dx1,l1)
%lt2 = solve(dx2,l1)

dl1 = diff(lan,l1)

[w1s,x1s,l1] = solve([dw1,dx1,dl1],[w1,x1,l1])
%}










%{
clear;
syms x1 w1 x2 w2 y p B L r G A l1 l2 d


% bc1 = (y-B) + L  -  p*w1 + x1
% bc2 = y + (1+r)*L - p*w2 + x2

% p*w1+x1 + ((p*w2+x2)/(1+r)) = (y-B) + (y/(1+r)) 


%U = x1+(G-w1)^2 + x2+(G-w2)^2

lan  =  x1 + (G-w1)^2  + d*(x2 + (G-w2)^2)  +  l1*( (y-B) + (y/(1+r))  - (p*w1+x1 + ((p*w2+x2)/(1+r))) )    

dw1 = diff(lan,w1)
dw2 = diff(lan,w2)

dx1 = diff(lan,x1)
dx2 = diff(lan,x2)


lt1 = solve(dx1,l1)
lt2 = solve(dx2,l1)


dl1 = diff(lan,l1)

K = solve([dw1,dw2,dx1,dx2,dl1],[w1,w2,x1,x2,l1])
%}





%{


%%% JUST X 
clear;
syms x1 w1 x2 w2 y p B L r G A l1 l2 x


% bc1 = (y-B) + L  -  p*w1 + x1
% bc2 = y + (1+r)*L - p*w2 + x2

% p*w1+x1 + ((p*w2+x2)/(1+r)) = (y-B) + (y/(1+r)) 


%U = x1+(G-w1)^2 + x2+(G-w2)^2

lan  =  x - (G-w1)^2  +  x - (G-w2)^2  +  l1*( (y-B) + (y/(1+r))  - (p*w1+x + ((p*w2+x)/(1+r)) ) )    

dw1 = diff(lan,w1)
dw2 = diff(lan,w2)

dx = diff(lan,x)
%dx2 = diff(lan,x2)

dl1 = diff(lan,l1)

K = solve([dw1,dw2,dx,dl1],[w1,w2,x,l1])

l1s = solve(dx,l1)

w1a = subs(solve(dw1,w1),l1,l1s)

w1e = eval(subs(w1a,[G,r,p],[10,.5,2]))

w2a = subs(solve(dw2,w2),l1,l1s)

w2e = eval(subs(w2a,[G,r,p],[10,.5,2]))


%}



%{

x1_temp = (y-B) + L  -  p*w1 

x2_temp = y + (1+r)*L - p*w2 

U_temp = x1_temp +(G-w1)^2 + A*(x2_temp +(G-w2)^2)

w1_temp  = ( (y-B) + (y/(1+r))  - ((p*w2+x2_temp)/(1+r)) -  x1_temp )/p

Us = subs(U_temp,w1,w1_temp)



df = diff(Us,w2)


w2opt=simplify(solve(df,w2))

subs(x2_temp,

w1opt=simplify(subs( (y-B) + (y/(1+r)) - (w2/(1+r)), w2,w2opt))

%}







%{

U = (  (y-B) + (y/(1+r)) - (w2/(1+r)) )^(.5) + (w2)^(.5)

df = diff(U,w2)

w2opt=simplify(solve(df,w2))

w1opt=simplify(subs( (y-B) + (y/(1+r)) - (w2/(1+r)), w2,w2opt))

ch = simplify(w1opt-w2opt)

dB = diff(ch,B)


chs=subs(ch,[y,B],[0,1000])

solve(chs-4,r)

%}


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
