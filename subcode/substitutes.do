* substitutes.do


global data_prep_alt = 0

if $data_prep_alt == 1 {
use  "${temp}paws_alt.dta", clear

tsset conacct date
tsfill, full

	merge 1:1 conacct date using "${temp}mcf_temp_pay.dta"
	drop if _merge==2
	drop _merge

replace dc=0 if dc==.

sort conacct date
by conacct: g tcd_id = dc[_n-1]==0 & dc[_n]==1

replace tcd_id = . if date==588

g tcd_date = date if tcd_id == 1
egen tcd = min(tcd_date), by(conacct)

g T = date-tcd

keep if wrs!=.

save "${temp}paws_alt_analysis.dta", replace

}


use "${temp}paws_alt_analysis.dta", clear

drop if wrs>250 | wrs<20

drop if exp>1500 | exp<20


cap program drop graph_trend
program define graph_trend
	local fe_var "`2'"
	local outcome "`1'"
	local T_high "12"
	local T_low "-13"
	preserve
		`5'
		*keep if T>=`=`T_low'' & T<=`=`T_high''
		replace T=. if T<`=`T_low'' | T>`=`T_high''
		qui sum T, detail
		local time_min `=r(min)'
		local time `=r(max)-r(min)'
		replace T=99 if T==.
		qui tab T, g(T_)
		if `4'==1 {
			areg `outcome' T_* i.date, absorb(`fe_var') cluster(`fe_var') r 
		}
		else {
			reg `outcome' T_* i.date, cluster(`fe_var') r 
		}
	   	parmest, fast
	   	g time = _n
	   	keep if time<=`=`time''
	   	replace time = time + `=`time_min''
	   	lab var time "Time"
    	*tw (scatter estimate time) || (rcap max95 min95 time)
    	tw (line estimate time, lcolor(black) lwidth(medthick)) ///
    	|| (line max95 time, lcolor(blue) lpattern(dash) lwidth(med)) ///
    	|| (line min95 time, lcolor(blue) lpattern(dash) lwidth(med)), ///
    	 graphregion(color(gs16)) plotregion(color(gs16)) xlabel(`=`T_low''(2)`=`T_high'') ///
    	 ytitle("`outcome'") xline(0)
    	 graph export  "${temp}trend_`3'.pdf", as(pdf) replace
   	restore
end


graph_trend wrs conacct wrs_alt 0
	graph_trend wrs conacct wrs_alt 1

graph_trend exp conacct exp_alt 0
	graph_trend exp conacct exp_alt 1


