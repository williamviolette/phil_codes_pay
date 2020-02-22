function h= wnum(dir,name,num,fmt)

    fileID = fopen(strcat(dir,name),'w');
    fprintf(fileID,'%s\n',num2str(num,fmt)); 
    fclose(fileID);
 h=1;