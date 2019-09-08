function  print_results(cd_dir,erate,popadj,...
    h,U_nl_t,h_nl,U_ppe_t,h_ppe,p1ce,U_pp_t,h_pp,...
    p1,p2,ppinst,lend_cost,visit_cost,delinquency_cost)


    U_nl  = mean(U_nl_t);
    U_ppe = mean(U_ppe_t);
    U_pp  = mean(U_pp_t);

    
    c_h = mean(h(1,:));
    c_nl = mean(h_nl(1,:));
    c_pp = mean(h_pp(1,:));
    c_ppe = mean(h_ppe(1,:));
    
    
    amount_avg     = csvread(strcat(folder,'bill_all.csv'));
    
    
    fileID = fopen(strcat(cd_dir,'total_costs.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(lend_cost+visit_cost+delinquency_cost,'%5.1f')));
    fclose(fileID);
    
    
%%% U ppe
    fileID = fopen(strcat(cd_dir,'U_ppe.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(U_ppe,'%5.1f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'U_ppe_abs.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(abs(U_ppe),'%5.1f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'U_ppe_abs_usd.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(abs(U_ppe)/erate,'%5.1f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'U_ppe_abs_usd_per.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str((abs(U_ppe)/erate)*popadj,'%5.1f')));
    fclose(fileID);
    
    fileID = fopen(strcat(cd_dir,'U_nl_per.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(abs(U_nl/amount_avg)*100,'%5.0f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'U_nl.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(U_nl,'%5.1f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'U_nl_abs.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(abs(U_nl),'%5.1f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'U_nl_abs_usd.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(abs(U_nl)/erate,'%5.1f')));
    fclose(fileID);
    
    fileID = fopen(strcat(cd_dir,'U_pp.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(U_pp,'%5.1f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'U_pp_abs.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(abs(U_pp),'%5.1f')));
    fclose(fileID);
     fileID = fopen(strcat(cd_dir,'U_pp_abs_usd.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(abs(U_pp)/erate,'%5.1f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'U_pp_abs_usd_per.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str((abs(U_pp)/erate)*popadj,'%5.1f')));
    fclose(fileID);  
    
    
    for i=1:3 
        fileID = fopen(strcat(cd_dir,'U_ppe_t',string(i),'.tex'),'w');
            fprintf(fileID,'%s\n',strcat(num2str(U_ppe_t(i),'%5.1f')));
        fclose(fileID);
        fileID = fopen(strcat(cd_dir,'U_ppe_abs_t',string(i),'.tex'),'w');
            fprintf(fileID,'%s\n',strcat(num2str(abs(U_ppe_t(i)),'%5.1f')));
        fclose(fileID);
        fileID = fopen(strcat(cd_dir,'U_ppe_abs_usd_t',string(i),'.tex'),'w');
            fprintf(fileID,'%s\n',strcat(num2str(abs(U_ppe_t(i))/erate,'%5.1f')));
        fclose(fileID);
        
        fileID = fopen(strcat(cd_dir,'U_nl_per_t',string(i),'.tex'),'w');
            fprintf(fileID,'%s\n',strcat(num2str(abs(U_nl_t(i)/amount_avg)*100,'%5.0f')));
        fclose(fileID);
        fileID = fopen(strcat(cd_dir,'U_nl_t',string(i),'.tex'),'w');
            fprintf(fileID,'%s\n',strcat(num2str(U_nl_t(i),'%5.1f')));
        fclose(fileID);
        fileID = fopen(strcat(cd_dir,'U_nl_abs_t',string(i),'.tex'),'w');
            fprintf(fileID,'%s\n',strcat(num2str(abs(U_nl_t(i)),'%5.1f')));
        fclose(fileID);
        fileID = fopen(strcat(cd_dir,'U_nl_abs_usd.tex'),'w');
            fprintf(fileID,'%s\n',strcat(num2str(abs(U_nl_t(i))/erate,'%5.1f')));
        fclose(fileID);

        fileID = fopen(strcat(cd_dir,'U_pp_t',string(i),'.tex'),'w');
            fprintf(fileID,'%s\n',strcat(num2str(U_pp_t(i),'%5.1f')));
        fclose(fileID);
        fileID = fopen(strcat(cd_dir,'U_pp_abs_t',string(i),'.tex'),'w');
            fprintf(fileID,'%s\n',strcat(num2str(abs(U_pp_t(i)),'%5.1f')));
        fclose(fileID);
         fileID = fopen(strcat(cd_dir,'U_pp_abs_usd_t',string(i),'.tex'),'w');
            fprintf(fileID,'%s\n',strcat(num2str(abs(U_pp_t(i))/erate,'%5.1f')));
        fclose(fileID);
         fileID = fopen(strcat(cd_dir,'U_pp_abs_usd_per_t',string(i),'.tex'),'w');
            fprintf(fileID,'%s\n',strcat(num2str((abs(U_pp_t(i))/erate)*popadj,'%5.1f')));
        fclose(fileID);  
        
        fileID = fopen(strcat(cd_dir,'c_ppe_t',string(i),'.tex'),'w');
            fprintf(fileID,'%s\n',strcat(num2str(h_ppe(1,i),'%5.1f')));
        fclose(fileID);
        fileID = fopen(strcat(cd_dir,'c_ppe2_t',string(i),'.tex'),'w');
            fprintf(fileID,'%s\n',strcat(num2str(h_ppe(1,i),'%5.2f')));
        fclose(fileID);    
        
        fileID = fopen(strcat(cd_dir,'c_pp_t',string(i),'.tex'),'w');
            fprintf(fileID,'%s\n',strcat(num2str(h_pp(1,i),'%5.1f')));
        fclose(fileID);
        fileID = fopen(strcat(cd_dir,'c_pp2_t',string(i),'.tex'),'w');
            fprintf(fileID,'%s\n',strcat(num2str(h_pp(1,i),'%5.2f')));
        fclose(fileID);    
        
        fileID = fopen(strcat(cd_dir,'c_h_t',string(i),'.tex'),'w');
            fprintf(fileID,'%s\n',strcat(num2str(h(1,i),'%5.1f')));
        fclose(fileID);
        fileID = fopen(strcat(cd_dir,'c_h2_t',string(i),'.tex'),'w');
            fprintf(fileID,'%s\n',strcat(num2str(h(1,i),'%5.2f')));
        fclose(fileID);    
        
    end
    
    

%%% Change in consumption to ppe
    fileID = fopen(strcat(cd_dir,'c_h_ppe_drop.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(100*abs((c_h-c_ppe)/c_h),'%5.1f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'c_ppe.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(c_ppe,'%5.1f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'c_ppe2.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(c_ppe,'%5.2f')));
    fclose(fileID);    
 
%%% prices
    fileID = fopen(strcat(cd_dir,'p_int_ppe.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(p1ce,'%5.1f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'p_int_ppe2.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(p1ce,'%5.2f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'p_int2.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(p1,'%5.2f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'p_increase_per_ppe.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(100*abs((p1ce-p1)/p1),'%5.1f')));
    fclose(fileID);
     fileID = fopen(strcat(cd_dir,'coste.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(delinquency_cost,'%5.1f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'visit_cost.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(visit_cost,'%5.1f')));
    fclose(fileID);
    
    
    %estimates_c = [0 1 1 ; c_h c_nl c_pp ;  0 U_nl U_pp  ; delinquency_cost delinquency_cost 0;  p1 p1 p1c];
    %fprintf(fileID,'%s\n','\begin{tabular}{lccc}');
    %fprintf(fileID,'%s\n','& Current & No Water Credit & No Water Credit and \\');
    %fprintf(fileID,'%s\n','&         &                  & Revenue Neutral \\');
    
    
 
    
    fileID = fopen(strcat(cd_dir,'c_h.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(c_h,'%5.1f')));
    fclose(fileID);
    
    fileID = fopen(strcat(cd_dir,'c_h2.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(c_h,'%5.2f')));
    fclose(fileID);
    
        fileID = fopen(strcat(cd_dir,'c_nl.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(c_nl,'%5.1f')));
    fclose(fileID);
        fileID = fopen(strcat(cd_dir,'c_nl2.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(c_nl,'%5.2f')));
    fclose(fileID);
        fileID = fopen(strcat(cd_dir,'c_h_nl_drop.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(100*abs((c_h-c_nl)/c_h),'%5.1f')));
    fclose(fileID);
        
    fileID = fopen(strcat(cd_dir,'c_h_pp_drop.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(100*abs((c_h-c_pp)/c_h),'%5.1f')));
    fclose(fileID);
        
    fileID = fopen(strcat(cd_dir,'c_pp.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(c_pp,'%5.1f')));
    fclose(fileID);
    fileID = fopen(strcat(cd_dir,'c_pp2.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(c_pp,'%5.2f')));
    fclose(fileID);    
         
    fileID = fopen(strcat(cd_dir,'del_raised.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(abs(ppinst-delinquency_cost),'%5.1f')));
    fclose(fileID);
  
    
    fileID = fopen(strcat(cd_dir,'ppinst.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(ppinst,'%5.0f')));
    fclose(fileID);
    
    fileID = fopen(strcat(cd_dir,'p_int_pp.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(p1c,'%5.1f')));
    fclose(fileID);
  
    fileID = fopen(strcat(cd_dir,'p_int_pp2.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(p1c,'%5.2f')));
    fclose(fileID);    
    
        
    fileID = fopen(strcat(cd_dir,'p_increase_per.tex'),'w');
        fprintf(fileID,'%s\n',strcat(num2str(100*abs((p1c-p1)/p1),'%5.1f')));
    fclose(fileID);
    
    
    