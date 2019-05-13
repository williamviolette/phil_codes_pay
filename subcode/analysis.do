*descriptives.do


set scheme s1mono

cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end

* do "${subcode}table_print.do"

	import delimited using "${moments}y_avg.csv", clear delimiter(",")
	sum v1
	global y_avg = `r(mean)'

	import delimited using "${moments}save_avg.csv", clear delimiter(",")
	sum v1
	global save_avg = `r(mean)'

	import delimited using "${moments}y_p20.csv", clear delimiter(",")
	sum v1
	global y_p20 = `r(mean)'



**** DO A BETTER JOB OF ROOTING OUT PERMANENT DISCONNECTIONS?!

use "${temp}temp_descriptives_2.dta", clear

g l6_id = amount!=. & date>=659
egen l6=sum(l6_id), by(conacct)

sort conacct date
by conacct: g ar_lag = ar[_n-1]

egen ams=sum(am), by(conacct)	
egen tcds=sum(tcd_id), by(conacct)

g pcd_id = dc==2
egen pcd = max(pcd_id), by(conacct)
drop pcd_id

*** count PCD'd HOUSEHOLDS!
	cap drop cnn
	sort conacct date
	by conacct: g cnn=_n
	count if l6==6 & pcd==1 & cnn==1
	write "${tables}pcd_hh.tex" `=r(N)' 1 "%12.0g"
	drop cnn


g a6= l6==6 & pcd!=1
g leaver = a6!=1
g aa=1


cap drop del_id
g del_id = ar>31 & ar<.
sum del_id 
write "${tables}share_del.tex" `=r(mean)*100' 1 "%12.0g"


do "${subcode}descriptive_table_print_3_groups.do"

global dtable_name "all"
do "${subcode}descriptive_table_print.do"
	
/*
	preserve
		keep if tcd_max==1 & a6==1

		 do "${subcode}export_moments.do"
	     
	     global dtable_name "stayers"
		 do "${subcode}descriptive_table_print.do"
	
	restore




	
	
/*


global M = 24

cap program drop graph_trend
program define graph_trend

	local fe_var "`3'"
	local outcome "`1'"
	local T_high "${M}"
	local T_low "-${M}"
	preserve
		`5'
		cap drop T
		g T = .
		replace T = 0 if `2'==1
		forvalues v=1/$M {
		qui by conacct: replace T=-`v' if `2'[_n+`v']==1 
		}
		forvalues v=1/$M {
		qui by conacct: replace T=`v' if `2'[_n-`v']==1 
		}
		*** FULL ***
		* replace T=. if T<`=`T_low'' | T>`=`T_high''
		* qui sum T, detail
		* local time_min `=r(min)'
		* local time `=r(max)-r(min)'
		* replace T=99 if T==.
		* qui tab T, g(T_)

		*** NON-FULL ***
		keep if T>=`=`T_low'' & T<=`=`T_high''
		qui tab T, g(T_)
		qui sum T, detail
		local time_min `=r(min)'
		local time `=r(max)-r(min)'

		areg `outcome' T_* `6', absorb(`fe_var') cluster(`fe_var') r 
		* reg `outcome' T_* `6', cluster(`fe_var') r 
	   	parmest, fast
	   	g time = _n
	   	keep if time<=`=`time''
	   	replace time = time + `=`time_min'' - 1
	   	lab var time "Time"
    	*tw (scatter estimate time) || (rcap max95 min95 time)
    	tw (line estimate time, lcolor(black) lwidth(medthick)) ///
    	|| (line max95 time, lcolor(blue) lpattern(dash) lwidth(med)) ///
    	|| (line min95 time, lcolor(blue) lpattern(dash) lwidth(med)), ///
    	 graphregion(color(gs16)) plotregion(color(gs16)) xlabel(`=`T_low''(2)`=`T_high'') ///
    	 ytitle("`outcome'") xline(0)
    	 graph export  "${temp}trend_`4'.pdf", as(pdf) replace
   	restore
end




graph_trend am tcd_id conacct aa " keep if T1!=. & l12==12 & tcds==1 " "i.date"
