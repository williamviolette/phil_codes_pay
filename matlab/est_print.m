function h = est_print(estimates,cd_out)

fileID = fopen(strcat(cd_out,'est.tex'),'w');

fprintf(fileID,'%s\n','\begin{tabular}{lcc}');
fprintf(fileID,'%s\n','& Estimate & Standard Error \\');
fprintf(fileID,'%s\n',strcat('Interest Rate &',num2str(estimates(1),'%5.3f'),'&', num2str(0,'%5.2f'),'\\'));
fprintf(fileID,'%s\n',strcat('Income Variance &',num2str(estimates(2),'%5.3f'),'&', num2str(0,'%5.2f'),'\\'));
fprintf(fileID,'%s\n',strcat('Water Preference &',num2str(estimates(3),'%5.3f'),'&', num2str(0,'%5.2f'),'\\'));
fprintf(fileID,'%s\n',strcat('Fixed Cost of Non-Piped Water &',num2str(estimates(4),'%5.1f'),'&', num2str(0,'%5.2f'),'\\'));

fprintf(fileID,'%s\n','\end{tabular} '); 

h=1;