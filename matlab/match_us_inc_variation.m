
%%% CV = 55% = std/mean


% 

clear
rng(1)

folder ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp_pay/moments/';

y_avg     = csvread(strcat(folder,'y_avg.csv'));


sd = .55.*y_avg

n = 1000000;

r = rand(n,1);

gamma = .55

yy = y_avg.*((1+gamma).*(r<.5) + (1-gamma).*(r>=.5));
std(yy)



