function h = counter_print(estimates_c,cd_dir)

fileID = fopen(strcat(cd_dir,'counter.tex'),'w');

fprintf(fileID,'%s\n','\begin{tabular}{lccc}');
fprintf(fileID,'%s\n','& Current & No Water Credit & No Water Credit and \\');
fprintf(fileID,'%s\n','&         &                  & Revenue Neutral \\');
fprintf(fileID,'%s\n',strcat('Water Credit Interest Rate &',num2str(estimates_c(1,1),'%5.1f'),'&', num2str(estimates_c(1,2),'%5.1f'),'&', num2str(estimates_c(1,3),'%5.1f'),'\\'));

fprintf(fileID,'%s\n',strcat('Mean Usage (m3) &',num2str(estimates_c(2,1),'%5.1f'),'&', num2str(estimates_c(2,2),'%5.1f'),'&', num2str(estimates_c(2,3),'%5.1f'),'\\'));
fprintf(fileID,'%s\n',strcat('Compensating Variation  &',' & ',num2str(estimates_c(3,2),'%5.1f'),'&', num2str(estimates_c(3,3),'%5.1f'),'\\'));
fprintf(fileID,'%s\n',strcat('Delinquency Savings  &',num2str(estimates_c(4,1),'%5.1f'),'&', num2str(estimates_c(4,2),'%5.1f'),'&', num2str(estimates_c(4,3),'%5.1f'),'\\'));
fprintf(fileID,'%s\n',strcat('Price Intercept  &',num2str(estimates_c(5,1),'%5.1f'),'&', num2str(estimates_c(5,2),'%5.1f'),'&', num2str(estimates_c(5,3),'%5.1f'),'\\'));

fprintf(fileID,'%s\n','\end{tabular} '); 

h=1;