*descriptives.do




global data_prep   = 0
global data_prep_2 = 0


if $data_prep == 1 {
	use "${temp}ar_temp_pay.dta", clear
		duplicates drop conacct date, force
			merge 1:m conacct date using "${temp}bill_temp_pay.dta"
			drop _merge
		duplicates drop conacct date, force		

			merge 1:m conacct date using "${temp}mcf_temp_pay.dta"
			drop _merge
		duplicates drop conacct date, force

			merge 1:m conacct date using "${temp}coll_temp_pay.dta"
			drop _merge
		duplicates drop conacct date, force		

		tsset conacct date
		tsfill, full
			g cnn = date if c!=.
			egen cnn_min=min(cnn), by(conacct)
			drop if date<cnn_min
			drop cnn cnn_min
		g ts = ba==.
			egen bam=max(ba), by(conacct)
			replace ba = bam
			drop bam

			merge m:1 conacct using "${temp}paws_temp.dta"
			drop if _merge==2
			drop _merge

	save "${temp}temp_descriptives.dta", replace
}



if $datap_prep_2 == 1 {

use "${temp}temp_descriptives.dta", clear


	g p = pay!=.
	egen sp = sum(p), by(conacct)
	keep if sp > 10
	
	egen mp = max(pay), by(conacct)
	keep if mp < 10000

	egen mc = max(c), by(conacct)
	drop if mc > 200

	keep if date>=600
	drop mp mc sp p

	egen max_class = max(class), by(conacct)
	keep if max_class==1
	drop max_class

	replace ar = ar + 15 if ar <361
		replace ar = 361+ (541-361)/2 if ar==361
		replace ar = 541+ (720-540)/2 if ar==541
		replace ar = 0 if ar==.
	replace dc = 0 if dc==.
	g cp = c!=.

	merge m:1 conacct using "${temp}mcf_ba.dta"
	drop if _merge==2
	drop _merge

save "${temp}temp_descriptives_2.dta", replace

}




use "${temp}temp_descriptives_2.dta", clear
	drop if date==653
*	keep if date>=600

g cmiss = c==.

* egen max_cmiss = max(cmiss), by(conacct)

sort conacct date
by conacct: g tcd_id = dc[_n-1]==0 & dc[_n]==1

replace tcd_id = . if date<=602

g tcd_date = date if tcd_id == 1
egen tcd = min(tcd_date), by(conacct)

g T = date-tcd


g cid = T>=-10 & T<=10 & c>0 & c<.
egen CS = sum(cid), by(conacct)


egen max_ar = max(ar), by(conacct)


cap program drop graph_trend
program define graph_trend
	local fe_var "`2'"
	local outcome "`1'"
	local T_high "24"
	local T_low "-24"
	preserve
		`4'
		`5'
		keep if T>=`=`T_low'' & T<=`=`T_high''
		qui tab T, g(T_)
		qui sum T, detail
		local time_min `=r(min)'
		local time `=r(max)-r(min)'
		areg `outcome' T_* i.date, absorb(`fe_var') cluster(`fe_var') r 
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
    	 ytitle("`outcome'")
    	 graph export  "${temp}trend_`3'.pdf", as(pdf) replace
   	restore
end


graph_trend cmiss conacct cmiss_desc


graph_trend c conacct c_desc "keep if max_ar<=196"


graph_trend c conacct c_desc "drop if c<=10"

graph_trend pay conacct pay_desc "keep if pay<2000"



graph_trend ar conacct ar_desc "keep if max_ar<=196"




g poor = low_skill==1
egen poorm=max(poor), by(conacct)
drop poor
ren poorm poor


cap program drop graph_trend2
program define graph_trend2
	local fe_var "`2'"
	local outcome "`1'"
	local T_high "24"
	local T_low "-24"
	preserve
		`5'
		`6'
		keep if T>=`=`T_low'' & T<=`=`T_high''
		qui tab T, g(T_)
		
		drop T_1
		foreach var of varlist T_* {
			g `var'_no = `var'==1 & `3'==0
			g `var'_yes = `var'==1 & `3'==1
			drop `var'
		}
		qui sum T, detail
		local time_min `=r(min)'
		local time `=r(max)-r(min)'
		areg `outcome' *_no *_yes i.date, absorb(`fe_var') cluster(`fe_var') r 
	   	parmest, fast
	   		save "${temp}temp_est.dta", replace

	   		use "${temp}temp_est.dta", clear
				g time = _n
	   			keep if time<=`=`time''	   		
	   			replace time = time + `=`time_min''
	   			keep estimate time max95 min95
	   			ren estimate estimate_no
	   			ren max95 max95_no 
	   			ren min95 min95_no
	   		save "${temp}temp_est_no.dta", replace

	   		use "${temp}temp_est.dta", clear
				g time = _n
	   			drop if time<=`=`time''
	   			drop time
	   			g time = _n
	   			keep if time<=`=`time''   		
	   			replace time = time + `=`time_min''
	   			keep estimate time max95 min95
	   			ren estimate estimate_yes
	   			ren max95 max95_yes 
	   			ren min95 min95_yes
	   		
	   			merge 1:1 time using "${temp}temp_est_no.dta"
	   			drop _merge

	   	lab var time "Time"
    	*tw (scatter estimate time) || (rcap max95 min95 time)
    	tw (line estimate_no time, lcolor(black) lwidth(medthick)) ///
    	|| (line max95_no time, lcolor(blue) lpattern(dash) lwidth(med)) ///
    	|| (line min95_no time, lcolor(blue) lpattern(dash) lwidth(med)) ///
    	(line estimate_yes time, lcolor(red) lwidth(medthick)) ///
    	|| (line max95_yes time, lcolor(green) lpattern(dash) lwidth(med)) ///
    	|| (line min95_yes time, lcolor(green) lpattern(dash) lwidth(med)), ///
    	 graphregion(color(gs16)) plotregion(color(gs16)) xlabel(`=`T_low''(2)`=`T_high'') ///
    	 ytitle("`outcome'")
    	 graph export  "${temp}trend2_`4'.pdf", as(pdf) replace
    	 erase "${temp}temp_est.dta"
    	 erase "${temp}temp_est_no.dta"
   	restore
end



graph_trend2  c conacct poor c_poor "drop if c<=10"


graph_trend2  pay conacct poor pay_poor "keep if pay<=2000"




