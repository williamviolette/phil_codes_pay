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

cap drop p0
g p0 = pay>0 & pay<.

print_mean usage c "%10.1fc" 1
print_mean bill amount "%10.1fc" 1
print_mean balance bal "%10.1fc" 1
print_mean pay_size pay "%10.1fc" 1
print_mean pay_freq p0 "%10.0fc" 100
print_mean days_delinquent ar "%10.1fc" 1

cap drop bal_y
g bal_y = bal/$y_avg
cap drop bal_s
g bal_s = bal/$save_avg

print_mean balance_inc bal_y "%10.1fc" 100
print_mean balance_save bal_s "%10.1fc" 100


print_mean tcd_per_account tcds "%10.1fc" 1

cap drop cobs_id
cap drop cobs
sort conacct date
by conacct: g cobs_id = _n==1
egen cobs=sum(cobs_id)
cap drop conN
by conacct: g conN=_N

cap drop tobs
g tobs=_N

cap drop pay_dc
g pay_dc = pay if tcd_id==1

cap drop cmiss
g cmiss=c==.
replace cmiss=. if date==600 | date==601

*** Make descriptive table
* global cat1=" "
 * global cat1="keep if tcd_max==1 & ar_post<=60" 
 * global cat2="keep if tcd_max==1 & ar_post>60"
 * global cat3="keep if tcd_max==0"

 global cat_num=6
 global cat_group = "mean sd min p25 p75 max"

    file open newfile using "${tables}descriptives.tex", write replace
    print_table_start
    file write newfile " & Mean & SD & Min & 25th & 75th & Max \\ " _n  

      print_1_cg "Usage (m3)" c  "%10.1fc"
      print_1_cg "Bill" amount  "%10.0fc" 
      print_1_cg "Unpaid Bill" bal "%10.0fc"     
      print_1_cg "Payment Size" pay  "%10.0fc"      
      print_1_cg "\% Months with Payment" p0 "%10.2fc"     
      print_1_cg "Days Delinquent" ar  "%10.1fc"
      print_blank
      print_1_cg "Disc. Visit" tcds   "%10.3fc"
      print_1_cg "Payment Size in Disc. Month" pay_dc   "%10.1fc"
      print_1_cg "Mean Months Disc." cmiss   "%10.3fc"
      * print_1_cg "Share Disc. 1 month After Visit" cm1  "%10.3fc"  // put this in a graph please~!!~
      * print_1_cg "Share Disc. 2 months After Visit" cm2  "%10.3fc"
      * print_1_cg "Share Disc. 3 months After Visit" cm3  "%10.3fc"
      * print_1_cg "Share Disc. 4 months After Visit" cm4  "%10.3fc"
      print_blank
      print_obs "Total Households" cobs "%10.0fc" 
      print_obs "Mean Obs. per Household" conN "%10.1fc" 
      print_obs "Total Obs." tobs "%10.0fc" 

    file write newfile "\end{tabu}" _n
    file close newfile
    * "\bottomrule" _n 

