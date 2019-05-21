* descriptive_table_print.do


cap prog drop print_blank
program print_blank
    forvalues r=1/$cat_num {
    file write newfile  " & "
    }    
    file write newfile " \\ " _n
end


cap prog drop in_stat_cg
program in_stat_cg
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

cap prog drop print_1_cg
program print_1_cg
    file write newfile " `1' "
    foreach r in $cat_group {
        in_stat_cg newfile `2' `r' `3' "0" 
        }      
    file write newfile " \\ " _n
end

cap prog drop print_obs
program print_obs
    file write newfile " `1' "
        in_stat_cg newfile `2' mean `3' "0" 
    forvalues r=2/$cat_num {
      file write newfile " & "
    }    
    file write newfile " \\ " _n
end



cap prog drop print_mean
program print_mean
    qui sum `2', detail 
    local value=string(`=r(mean)*`4'',"`3'")
    file open newfile using "${tables}`1'.tex", write replace
    file write newfile "`value'"
    file close newfile    
end

cap prog drop print_mean_csv
program print_mean_csv
    qui sum `2', detail 
    local value=string(`=r(mean)*`4'',"`3'")
    file open newfile using "${moments}`1'.csv", write replace
    file write newfile "`value'"
    file close newfile    
end

cap drop p0
g p0 = pay>0 & pay<.

cap drop pays
g pays = pay if pay>0 & pay<.

print_mean usage_${dtable_name} c "%10.0fc" 1
print_mean bill_${dtable_name} amount "%10.0fc" 1
print_mean_csv bill_${dtable_name} amount "%10.0fc" 1
print_mean balance_${dtable_name} bal "%10.0fc" 1
print_mean pay_freq_${dtable_name} p0 "%10.0fc" 100
print_mean pay_size_${dtable_name} pays "%10.0fc" 1
print_mean days_delinquent_${dtable_name} ar "%10.0fc" 1

cap drop bal_y
g bal_y = bal/$y_avg
cap drop bal_s
g bal_s = bal/$save_avg

print_mean balance_inc_${dtable_name} bal_y "%10.1fc" 100
print_mean balance_save_${dtable_name} bal_s "%10.1fc" 100


cap drop bal_y_p20
g bal_y_p20 = bal/$y_p20
print_mean balance_inc_20_${dtable_name} bal_y_p20 "%10.0fc" 100
drop bal_y_p20


cap drop bill_inc
  g bill_inc = amount/$y_avg
print_mean bill_inc_${dtable_name} bill_inc "%10.1fc" 100
  drop bill_inc

cap drop bill_sav
  g bill_sav = amount/$save_avg
print_mean bill_sav_${dtable_name} bill_sav "%10.1fc" 100
  drop bill_sav



print_mean tcd_per_account_${dtable_name} tcds "%10.1fc" 1

cap drop cobs_id
cap drop cobs
sort conacct date
by conacct: g cobs_id = _n==1
egen cobs=sum(cobs_id)
cap drop conN
by conacct: g conN=_N

cap drop tobs
g tobs=_N



print_mean total_hhs_${dtable_name} cobs "%10.0fc" 1
print_mean obs_per_hh_${dtable_name} conN "%10.1fc" 1
print_mean total_obs_${dtable_name} tobs "%10.0fc" 1


 global cat_num=6
 global cat_group = "mean sd min p25 p75 max"

    file open newfile using "${tables}descriptives_${dtable_name}.tex", write replace
*    print_table_start
*    file write newfile " & Mean & SD & Min & 25th & 75th & Max \\ " _n  

      print_1_cg "Usage (m3)" c  "%10.1fc"
      print_1_cg "Bill" amount  "%10.0fc" 
      print_1_cg "Unpaid Balance" bal "%10.0fc"   
      print_1_cg "Share of Months with Payment" p0 "%10.2fc"       
      print_1_cg "Payment Size" pays  "%10.0fc"      
      print_1_cg "Days Delinquent" ar  "%10.1fc"
      print_1_cg "Delinquency Visits per HH" tcds   "%10.2fc"
      print_1_cg "Share of Months Disconnected" am   "%10.2fc"

*      print_blank
*      print_obs "Total Households" cobs "%10.0fc" 
*      print_obs "Mean Obs. per Household" conN "%10.1fc" 
*      print_obs "Total Obs." tobs "%10.0fc" 

*    file write newfile "\end{tabu}" _n
   file close newfile
    * "\bottomrule" _n 


global cat_num=2
 global cat_group = "mean sd"

    file open newfile using "${tables}descriptives_pres_${dtable_name}.tex", write replace
*    print_table_start
*    file write newfile " & Mean & SD & Min & 25th & 75th & Max \\ " _n  

      print_1_cg "Usage (m3)" c  "%10.1fc"
      print_1_cg "Bill" amount  "%10.0fc" 
      print_1_cg "Unpaid Balance" bal "%10.0fc"   
      print_1_cg "Share of Months with Payment" p0 "%10.2fc"       
      * print_1_cg "Payment Size" pays  "%10.0fc"      
      print_1_cg "Days Delinquent" ar  "%10.1fc"
      print_1_cg "Delinquency Visits per HH" tcds   "%10.2fc"
      print_1_cg "Share of Months Disconnected" am   "%10.2fc"

*      print_blank
*      print_obs "Total Households" cobs "%10.0fc" 
*      print_obs "Mean Obs. per Household" conN "%10.1fc" 
*      print_obs "Total Obs." tobs "%10.0fc" 

*    file write newfile "\end{tabu}" _n
   file close newfile
    * "\bottomrule" _n 

drop cobs conN tobs p0 pays bal_y bal_s cobs_id



