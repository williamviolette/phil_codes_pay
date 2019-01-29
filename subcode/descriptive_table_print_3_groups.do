* descriptive_table_print.do





*** Make descriptive table
* global cat1=" "
 global cat1="keep if tcd_max==1 & ar_post<=60" 
 global cat2="keep if tcd_max==1 & ar_post>60"
 global cat3="keep if tcd_max==0"
 global cat_num=3

    file open newfile using "${tables}descriptives_3_groups.tex", write replace
    print_table_start
    file write newfile " & Paid Notice & Unpaid Notice & No Notice \\ " _n  
      print_1 "Number of Notices per Account" total_notices  "mean" "%10.1fc"
      print_1 "Days Delinquent" ar "mean" "%10.1fc"
      print_1 "Usage (m3/month)" c  "mean" "%10.1fc"
      print_1 "Months Disconnected" total_cmiss "mean" "%10.1fc"
      print_1 "Monthly Payment Size (PhP)" pay "mean" "%10.1fc"
        print_blank
      print_1 "HH Size" hhsize  "mean" "%10.1fc"
      print_1 "Age of HoH" age "mean" "%10.1fc"
      print_1 "Low Skilled HoH" low_skill  "mean" "%10.2fc"
        print_blank
      print_1 "Total Accounts " fs "mean" "%10.0fc" 
      print_1 "Total Observations" first "N" "%10.0fc" 
    file write newfile "\end{tabu}" _n
    file close newfile
    * "\bottomrule" _n 