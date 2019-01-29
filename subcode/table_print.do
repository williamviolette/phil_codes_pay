
cap prog drop drop_99p
program drop_99p
        qui sum `1', detail
        replace `1'=. if `1'>=`=r(p99)' & `1'<.
end


cap prog drop print_blank
program print_blank
    forvalues r=1/$cat_num {
    file write newfile  " & "
    }    
    file write newfile " \\ " _n
end

cap prog drop print_table_start
program print_table_start
    file write newfile  "\begin{tabu}{l"
    forvalues r=1/$cat_num {
    file write newfile  "c"
    }
    file write newfile "}" _n  
end

cap prog drop in_stat
program in_stat 
    preserve 
        `6' 
        qui sum `2', detail 
        local value=string(`=r(`3')',"`4'")
        if `5'==0 {
            file write `1' " & `value' "
        }
        if `5'==1 {
            file write  `1' " & [`value'] "
        }        
    restore 
end

cap prog drop print_1
program print_1
    file write newfile " `1' "
    forvalues r=1/$cat_num {
        in_stat newfile `2' `3' `4' "0" "${cat`r'}"
        }      
    file write newfile " \\ " _n
end

cap prog drop print_2
program print_2
    file write newfile " `1' "
    forvalues r=1/$cat_num {
        in_stat newfile `2' `3' `4' "0"  "${cat`r'}"
        }          
    file write newfile " \\ " _n
    file write newfile "\rowfont{\footnotesize}"             
    forvalues r=1/$cat_num {   
        in_stat newfile `2' "sd" `4' "1"  "${cat`r'}"        
        }            
    file write newfile " \\ " _n
    *** ADD EMPTY LINE 
    forvalues r=1/$cat_num {   
    file write newfile " & "        
        }            
    file write newfile " \\ " _n
    
end

cap prog drop in_stat_m2
program in_stat_m2 
    preserve 
        `6' 
        qui sum `2', detail 
        local value=string(`=r(`3')',"`4'")
        if `5'==0 {
            file write `1' " & \multicolumn{2}{c}{`value'} "
        }
        if `5'==1 {
            file write  `1' " &  \multicolumn{2}{c}{[`value']} "
        }        
    restore 
end

cap prog drop print_m2
program print_m2
    file write newfile " `1' "
    forvalues r=2(2)$cat_num {
        in_stat_m2 newfile `2' `3' `4' "0" "${cat`r'}"
        }      
    file write newfile " \\ " _n
end


