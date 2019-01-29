function h = fit_print(output,output_data,cd_dir)

fileID = fopen(strcat(cd_dir,'fit.tex'),'w');

fprintf(fileID,'%s\n','\begin{tabular}{lcc}');
fprintf(fileID,'%s\n','& Data & Estimated \\');

fprintf(fileID,'%s\n',strcat('Mean Usage (m3) &',num2str(output_data(1),'%5.1f'),'&', num2str(output(1),'%5.1f'),'\\'));
fprintf(fileID,'%s\n',strcat('SD Usage &',num2str(output_data(2),'%5.1f'),'&', num2str(output(2),'%5.1f'),'\\'));
fprintf(fileID,'%s\n',strcat('Mean Water Debt (PhP) &',num2str(output_data(3),'%5.0f'),'&', num2str(output(3),'%5.0f'),'\\'));
fprintf(fileID,'%s\n',strcat('SD Water Debt (PhP) &',num2str(output_data(4),'%5.0f'),'&', num2str(output(4),'%5.0f'),'\\'));
fprintf(fileID,'%s\n',strcat('Corr. Usage and Water Debt &',num2str(output_data(5),'%5.2f'),'&', num2str(output(5),'%5.2f'),'\\'));

fprintf(fileID,'%s\n',strcat('Mean Disc. for 1 month &',num2str(output_data(6),'%5.3f'),'&', num2str(output(6),'%5.3f'),'\\'));
fprintf(fileID,'%s\n',strcat('Mean Disc. for 2 months &',num2str(output_data(7),'%5.3f'),'&', num2str(output(7),'%5.3f'),'\\'));
fprintf(fileID,'%s\n',strcat('Mean Disc. for 3 months &',num2str(output_data(8),'%5.3f'),'&', num2str(output(8),'%5.3f'),'\\'));
fprintf(fileID,'%s\n',strcat('Mean Disc. for 4 months &',num2str(output_data(9),'%5.3f'),'&', num2str(output(9),'%5.3f'),'\\'));

%fprintf(fileID,'%s\n',strcat('Mean Usage Pre-Collect (m3) &',num2str(output_data(6),'%5.1f'),'&', num2str(output(6),'%5.1f'),'\\'));
%fprintf(fileID,'%s\n',strcat('Mean Usage Post-Collect &',num2str(output_data(7),'%5.1f'),'&', num2str(output(7),'%5.1f'),'\\'));
%fprintf(fileID,'%s\n',strcat('Diff. (Pre-Post) (m3) &',num2str(output_data(8),'%5.1f'),'&', num2str(output(8),'%5.1f'),'\\'));

fprintf(fileID,'%s\n','\end{tabular} '); 

h=1;