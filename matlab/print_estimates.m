function [h]=print_estimates(cd_dir,r,rb,ver)

%     if boot==1
%         rb=zeros(size(rb,1),size(rb,2));
%     end

    wnum(cd_dir,strcat('est_alpha_',ver,'.tex'),r(1),'%5.1f');
        wnum(cd_dir,strcat('est_sd_alpha_',ver,'.tex'),std(rb(:,1)),'%5.2f');
        
    wnum(cd_dir,strcat('est_fc_',ver,'.tex'),r(2),'%5.1f');
        wnum(cd_dir,strcat('est_sd_fc_',ver,'.tex'),std(rb(:,2)),'%5.1f');
     
    wnum(cd_dir,strcat('est_pc_',ver,'.tex'),r(3),'%5.2f');
        wnum(cd_dir,strcat('est_sd_pc_',ver,'.tex'),std(rb(:,3)),'%5.2f');
     
    wnum(cd_dir,strcat('est_pc_per_',ver,'.tex'),100*r(2),'%5.0f');
     
h=0;
