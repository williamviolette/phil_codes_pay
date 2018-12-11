clear all

     sigma=1;
     beta=0.9;
     alpha=.75;
     delta=0.3;
     AH=1;
     AL=0.99;

N=100;
KstarH=(((1/(AH*alpha*beta))-((1-delta)/(AH*alpha))))^(1/(alpha-1));
KstarL=(((1/(AL*alpha*beta))-((1-delta)/(AL*alpha))))^(1/(alpha-1));
Kstar=0.5*(KstarH+KstarL);
Klo=Kstar*0.9;
Khi=Kstar*1.1;

step=(Khi-Klo)/N;
K=Klo:step:Khi;

n=length(K);        % n is the true length of the state space

% From the production function, Kalpha is the vector of output levels
Kalpha=K.^alpha;
% create a column of n ones 
colones=ones(n,1);
% create an nxn matrix here
s = colones*Kalpha;
s1 = colones*K;
% now take the transpose
ytotH = AH*s'+(1-delta)*s1';       % each column of S is Kalpha
ytotL = AL*s'+(1-delta)*s1';
% first guess of the value function

% here describe the level of utility associated with each element of the
% matrix S.  we use this below as our first guess for the dynamic programming
% problem.

if sigma==1
vH=log(ytotH);
vL=log(ytotL);
else
vH=ytotH.^(1-sigma)/(1-sigma);
vL=ytotL.^(1-sigma)/(1-sigma);
end

% calculate investment here; I plays the role of the future capital stock

rowones= colones';
% so I here is matrix where each column is K
I = K'*rowones;
% here J is a matrix where each row is K
J= colones*K;
Jalpha=J.^alpha;
% consumption: the flow of output plus undepreciated capital less investment
% you may want to work this out to see that it is correct

CH = (AH*Jalpha)-I +(1-delta)*J;
CL = (AL*Jalpha)-I +(1-delta)*J;

% current utility, current state as cols, future capital as rows
if sigma==1
UH=log(CH);
UL=log(CL);
else
UH=(CH.^(1-sigma))/(1-sigma);
UL=(CL.^(1-sigma))/(1-sigma);
end

rH=UH+beta*0.5*(vH+vL);
rL=UL+beta*0.5*(vH+vL);
vH1=max(rH);
vL1=max(rL);

t=100
for j=1:t
        w=ones(n,1)*(vH1+vL1);
        wH1=UH+beta*0.5*w';
        wL1=UL+beta*0.5*w';
        vH1=max(wH1);
        vL1=max(wL1);
        
end
[valH,indH]=max(wH1);
[valL,indL]=max(wL1);
optkh = K(indH);
optkl = K(indL);
% now build a vector for future capital using the m-vector.

figure(1)
plot(K,K','g',...
    'LineWidth',2)
hold on
plot(K,optkh','--r',...
    'LineWidth',2)
hold on
plot(K,optkl,':b',...
    'LineWidth',2)
xlabel('K');
ylabel('K`');
legend('45 degree line','Policy function- High Tech','Policy function- Low Tech',4);
text(0.4,0.65,'45 degree line','FontSize',18)
text(0.4,0.13,'K`','FontSize',18)

figure (2)
plot(K,(optkh-K)','b',...
    'LineWidth',2)
hold on
plot(K,(optkl-K)','--r',...
    'LineWidth',2)
xlabel('Current Capital');
ylabel('K`- K');

%Simulation of the evolution of the capital stock over p periods

p=500;
kt=Kstar*ones(p,1);
kti=(N/2)*ones(p,1);

for i=2:p
    if rand(1,1)>0.5
        yt(i)=AH*(kt(i-1))^alpha;
        kti(i)=indH(kti(i-1));
        kt(i)=K(kti(i));
    else
        yt(i)=AL*(kt(i-1))^alpha;
        kti(i)=indL(kti(i-1));
        kt(i)=K(kti(i));
    end
    ct(i)=yt(i)+(1-delta)*kt(i-1)-kt(i);
    it(i)=yt(i)-ct(i);
    
end

t=1:1:500;
figure (3)
plot(t,kt)
xlabel('t');
ylabel('k(t)');

syt=std(yt(10:p));
sct=std(ct(10:p));
si=std(it(10:p));
