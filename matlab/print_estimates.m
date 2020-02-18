function [h]=print_estimates(folder,estimate_file)



 %%% Estimates table
    if given_sim==0
        estimates = csvread(strcat(folder,estimate_file));
        res_out = given;
        res_out(option)=estimates;
    else
        estimates = csvread(strcat(folder,'given.csv'));
    end
    
%     est_boot=[];
%     for h=br_est(1):br_est(2)
%         e_temp = csvread(strcat(folder,'estimates_',num2str(h),'.csv'));
%         est_boot = [est_boot; e_temp];
%     end
        
%     est_var = std(est_boot);
%     
    %%% PRINT ESTIMATES
    %[~]=est_print(estimates,cd_dir);
    fileID = fopen(strcat(cd_dir,'est_alpha.tex'),'w');
        fprintf(fileID,'%s\n',num2str(estimates(1),'%5.1f')); 
        fclose(fileID);
%         fileID = fopen(strcat(cd_dir,'est_sd_irate.tex'),'w');
%             fprintf(fileID,'%s\n',num2str(est_var(1),'%5.4f')); 
%             fclose(fileID);
        
    fileID = fopen(strcat(cd_dir,'est_beta.tex'),'w');
        fprintf(fileID,'%s\n',num2str(estimates(2),'%5.4f')); 
        fclose(fileID);
        
        
    fileID = fopen(strcat(cd_dir,'est_alpha.tex'),'w');
        fprintf(fileID,'%s\n',num2str(estimates(3),'%5.3f')); 
        fclose(fileID);
    fileID = fopen(strcat(cd_dir,'est_fc.tex'),'w');
        fprintf(fileID,'%s\n',num2str(estimates(4),'%5.1f')); 
        fclose(fileID);
    

    fileID = fopen(strcat(cd_dir,'est_sd_theta.tex'),'w');
        fprintf(fileID,'%s\n',num2str(est_var(2),'%5.4f')); 
        fclose(fileID);
    fileID = fopen(strcat(cd_dir,'est_sd_alpha.tex'),'w');
        fprintf(fileID,'%s\n',num2str(est_var(3),'%5.5f')); 
        fclose(fileID);
    fileID = fopen(strcat(cd_dir,'est_sd_fc.tex'),'w');
        fprintf(fileID,'%s\n',num2str(est_var(4),'%5.4f')); 
        fclose(fileID);
    
    %%% print percentages %%%    
        fileID = fopen(strcat(cd_dir,'est_theta_per.tex'),'w');
            fprintf(fileID,'%s\n',num2str(estimates(2)*100,'%5.1f')); 
            fclose(fileID);
            
         fileID = fopen(strcat(cd_dir,'est_irate_per.tex'),'w');
            fprintf(fileID,'%s\n',num2str(estimates(1)*100,'%5.1f')); 
            fclose(fileID);   
         
         fileID = fopen(strcat(cd_dir,'est_irate_annual_per.tex'),'w');
            fprintf(fileID,'%s\n',num2str( ((1+estimates(1))^(12) - 1)*100,'%5.1f')); 
            fclose(fileID);   
         
            
       
            
            

h=0
