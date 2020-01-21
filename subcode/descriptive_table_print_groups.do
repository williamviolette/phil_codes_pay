* descriptive_table_print.do


cap prog drop print_blank
program print_blank
    forvalues r=1/$cat_num {
    file write newfile  " & "
    }    
    file write newfile " \\ " _n
end



cap prog drop in_stat3
program in_stat3
    *preserve 
        *`6' 
        qui sum `2' `6', detail 
        local value=string(`=r(`3')',"`4'")
        if `5'==0 {
            file write `1' " & `value' "
        }
        if `5'==1 {
            file write  `1' " & [`value'] "
        }        
    *restore 
end

cap prog drop print_1_3
program print_1_3
    file write newfile " `1' "
    forvalues r=1/$cat_num {
        in_stat3 newfile `2' `3' `4' "0" "${cat`r'}"
        }      
    file write newfile " \\ " _n
end


cap drop p0
g p0 = pay>0 & pay<.

cap drop c1
sort conacct date
by conacct: g c1=1 if _n==1

cap drop pays
g pays = pay if pay>0 & pay<.



    * file open newfile using "${tables}descriptives_3_groups.tex", write replace
    * *print_table_start
    * *file write newfile " & Full Sample & Unpaid Notice & No Notice \\ " _n  

    *   print_1_3 "Usage (m3)" c "mean" "%10.1fc"
    *   print_1_3 "Bill" amount "mean" "%10.0fc" 
    *   print_1_3 "Unpaid Balance" bal "mean" "%10.0fc"   
    *   print_1_3 "Share of Months with Payment" p0 "mean" "%10.2fc"       
    *   print_1_3 "Payment Size" pays "mean" "%10.0fc"      
    *   print_1_3 "Days Delinquent" ar "mean" "%10.1fc"
    *   print_1_3 "Delinquency Visits per HH" tcds "mean"  "%10.2fc"
    *   print_1_3 "Months Disconnected" am  "mean" "%10.2fc"

    *   * print_1 "Delinquency Visits per HH" tds  "mean" "%10.1fc"
    *   * print_1 "Days Delinquent" ar "mean" "%10.1fc"
    *   * print_1 "Usage (m3/month)" c  "mean" "%10.1fc"
    *   * print_1 "Months Disconnected" total_cmiss "mean" "%10.1fc"
    *   * print_1 "Monthly Payment Size (PhP)" pay "mean" "%10.1fc"

    *   *** PUT IN HOUSE OR OTHER DEMOGRAPHICS
    *   *  print_blank
    *   print_1_3 "HH Size" hhsize  "mean" "%10.1fc"
    *   print_1_3 "Age of HoH" age "mean" "%10.1fc"
    *   print_1_3 "Low Skilled HoH" low_skill  "mean" "%10.2fc"
    *     print_blank
    *   print_1_3 "Total Households " c1 "N" "%10.0fc" 
    *   print_1_3 "Total Observations" am "N" "%10.0fc" 
    * *file write newfile "\end{tabu}" _n
    * file close newfile
    * * "\bottomrule" _n 


*** Make descriptive table
* global cat1=" "
 global cat1="  " 
 global cat2=" if inc_t==1 "
 global cat3=" if inc_t==2 "
 global cat4=" if inc_t==3 "
 global cat_num=4

    file open newfile using "${tables}descriptives_usage_groups.tex", write replace
    *print_table_start
    *file write newfile " & Full Sample & Unpaid Notice & No Notice \\ " _n  

      print_1_3 "Usage (m3)" c "mean" "%10.1fc"
      print_1_3 "Bill (PhP)" amount "mean" "%10.0fc" 
      print_1_3 "Unpaid Balance (PhP)" bal "mean" "%10.0fc"   
      print_1_3 "Share of Months with Payment" p0 "mean" "%10.2fc"       
      print_1_3 "Payment Size" pays "mean" "%10.0fc"      
      print_1_3 "Days Delinquent" ar "mean" "%10.1fc"
      print_1_3 "Delinquency Visits per HH" tcds "mean"  "%10.2fc"
      print_1_3 "Share of Months Disconnected" am  "mean" "%10.2fc"

  file close newfile  
      * print_1 "Delinquency Visits per HH" tds  "mean" "%10.1fc"
      * print_1 "Days Delinquent" ar "mean" "%10.1fc"
      * print_1 "Usage (m3/month)" c  "mean" "%10.1fc"
      * print_1 "Months Disconnected" total_cmiss "mean" "%10.1fc"
      * print_1 "Monthly Payment Size (PhP)" pay "mean" "%10.1fc"

      *** PUT IN HOUSE OR OTHER DEMOGRAPHICS
      *  print_blank
   file open newfile using "${tables}descriptives_demo_groups.tex", write replace
      print_1_3 "Monthly Income (PhP)" inc "mean" "%10.0fc"
      print_1_3 "HH Size" hhsize  "mean" "%10.1fc"
      print_1_3 "Age of HoH" age "mean" "%10.1fc"
      print_1_3 "Low Skilled HoH" low_skill  "mean" "%10.2fc"
    file close newfile

   file open newfile using "${tables}descriptives_obs_groups.tex", write replace    
        * print_blank
      print_1_3 "Total Households " c1 "N" "%10.0fc" 
      print_1_3 "Total Observations" am "N" "%10.0fc" 
    *file write newfile "\end{tabu}" _n
    file close newfile
    * "\bottomrule" _n 


drop p0 c1 pays