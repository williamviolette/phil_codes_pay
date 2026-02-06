
%%% CV = 55% = std/mean


% 

clear
octave_setup;
rng(1)

folder ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_temp_pay/moments/';
cd_dir ='/Users/williamviolette/Documents/Philippines/phil_analysis/phil_codes_pay/paper/tables/';

   
estimates = csvread(strcat(folder,'estimates.csv')); 
y_avg     = csvread(strcat(folder,'y_avg.csv'));


sd = .55.*y_avg

n = 1000000;

r = rand(n,1);

theta = estimates(2)

yy = y_avg.*((1+theta).*(r<.5) + (1-theta).*(r>=.5));
std(yy)/y_avg


yy = std((1+theta).*(r<.5) + (1-theta).*(r>=.5))


