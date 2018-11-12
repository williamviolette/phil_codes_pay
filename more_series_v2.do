

* global data_prep = 0

* if $data_prep == 1 {
* 	use "${temp}ar_temp_pay.dta", clear
* 		duplicates drop conacct date, force
* 			merge 1:m conacct date using "${temp}bill_temp_pay.dta"
* 			drop _merge
* 		duplicates drop conacct date, force		

* 			merge 1:m conacct date using "${temp}mcf_temp_pay.dta"
* 			drop _merge
* 		duplicates drop conacct date, force	
* 		tsset conacct date
* 		tsfill, full
* 			g cnn = date if c!=.
* 			egen cnn_min=min(cnn), by(conacct)
* 			drop if date<cnn_min
* 			drop cnn cnn_min
* 		g ts = ba==.
* 			egen bam=max(ba), by(conacct)
* 			replace ba = bam
* 			drop bam
* 	save "${temp}full_temp_pay.dta", replace
* }



*** NOW USE ba1 FOR TIME

use "${temp}temp_descriptives_2.dta", clear


drop barangay_id-low_skill

replace ar = ar + 15 if ar <361
replace ar = 361+ (541-361)/2 if ar==361
replace ar = 541+ (720-540)/2 if ar==541
replace ar = 0 if ar==.

replace dc = 0 if dc==.

* g cp = c!=.

bys conacct: g cN=_N
bys conacct: g cn=_n

sort conacct date
by conacct: g tcd = dc[_n-2]==0 & dc[_n-1]==0 & dc[_n]==1 & dc[_n+1]==1
replace tcd = 0 if date==588 | date==601
by conacct: g dcc = cp[_n-2]==0 & cp[_n-1]==0 & cp[_n]==1 & cp[_n+1]==1
replace dcc = . if date == 597 | date== 602 | date==645 | date== 654


g tcd_date = date if tcd==1

egen tcd_d = min(tcd_date), by(conacct)

* hist tcd_date, discrete


*local years  " 617 621 613 614 617 616 610 623 610 617 621 621 "

local years "610 613 610 616 617 621 623 614 610 621 617 621"


g P=.
g date_t=.

local badate " 2 3 4 5 6 7 8 9 10 11 12 17 "
foreach r in `badate' {
	local yr : word `r' of `years'
	replace P=1 if date==`yr' & ba1==`r'
	replace date_t = `yr' if ba1==`r'
}

g T = date-date_t

g bp = pay!=.

g cnm= c!=.
egen cnms=sum(cnm), by(conacct)



cap program drop graph_trend
program define graph_trend
	preserve
		drop ba
		ren ba1 ba
		`3'
		`4'
		keep if date>=602 & date<=650
		*keep if ba<=3

		egen N=mean(`1'), by(date ba)
		bys date ba: g nn=_n
		keep if nn==1

		egen Nm=max(N), by(ba)
		replace N=N/Nm

		scatter N date, by(ba) || scatter P date, by(ba)

	   	graph export  "${temp}`2'_trend.pdf", as(pdf) replace
	restore
end


graph_trend tcd tcd 






g cat = ar if ar == 0 | ar==15 | ar==136 | ar==226

replace ar = . if date<600



cap program drop graph_trend_plus
program define graph_trend_plus
	preserve
		keep if `1'==1

		keep if ba<=3 | ba==6
		keep if date>=602 & date<=650

		local make_graph " scatter P date, by(ba) "

		levelsof `2', local(lev)

		foreach j in `lev' {
			g `1'_`j'_id = `1' if `2'==`j'
			egen `1'_`j' = sum(`1'_`j'_id), by(date ba)
				egen Nm=max(`1'_`j'), by(ba)
				replace `1'_`j'=`1'_`j'/Nm
				drop Nm
			local make_graph "`make_graph' || scatter `1'_`j' date, by(ba) "
		}

		bys date ba: g nn=_n
		keep if nn==1

		`make_graph'

	   	graph export  "${temp}`3'_trend.pdf", as(pdf) replace
	restore
end


* graph_trend_plus tcd cat tcd_plus






cap program drop graph_trend
program define graph_trend
	local fe_var "`2'"
	*local cluster_var "`3'"
	local outcome "`1'"
	local T_high "24"
	local T_low "-16"
	preserve
	*	keep if date>602

		*keep if date>=600 & date<=650
		*keep if ba<=3 | ba==6

		`4'
		`5'

	*	keep if T>=`=`T_low'' & T<=`=`T_high''

	replace T=`=`T_high'' if T<`=`T_low'' | T>`=`T_high''

	egen `outcome'_1 = mean(`outcome'), by(`fe_var' date)
	drop `outcome'
	ren `outcome'_1 `outcome'

	duplicates drop `fe_var' date, force
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
    	tw (line estimate time, lcolor(black) lwidth(medthick)), ///
    	 graphregion(color(gs16)) plotregion(color(gs16)) xlabel(`=`T_low''(2)`=`T_high'') ///
    	 ytitle("`outcome'") 
    	 graph export  "${temp}trend_`3'_noci.pdf", as(pdf) replace
   	restore
end


graph_trend ar ba1 ar_ba1 "keep if cnms>=60 & date>602  & ba1>=5 & ba1<=7 "
graph_trend ar conacct ar_conacct "keep if cnms>=60 & date>602  & ba1>=5 & ba1<=7 "


graph_trend bp ba1 bp_ba1 "keep if cnms>=60 & date>602 "
graph_trend bp conacct bp_conacct "keep if cnms>=60 & date>602"




graph_trend tcd ba1 tcd_ba1 "keep if cnms>=60 & date>=600 "
graph_trend tcd conacct tcd_conacct "keep if cnms>=60 & date>=600"





graph_trend tcd ba1 tcd_ba1_smpm "keep if cnms>=60 & date>=600 & ba1>=5 & ba1<=7 "
graph_trend tcd conacct tcd_conacct_smpm "keep if cnms>=60 & date>=600 & ba1>=5 & ba1<=7"





graph_trend bp ba1 bp_ba1 "keep if cnms>=60 & date>=602"
graph_trend bp conacct bp_conacct "keep if cnms>=60 & date>=602"


graph_trend bp ba bp_testing  "keep if cnms>=65 & date>600"
graph_trend bp conacct bp_testing_conacct "keep if cnms>=65 & date>600"


graph_trend bp ba bp_smpm  "keep if cnms>=65 & date>600 & (ba<=3 | ba==6)"
graph_trend bp conacct bp_smpm_conacct "keep if cnms>=65 & date>600 & (ba<=3 | ba==6)"


* adjust window for 24 months

graph_trend ar ba      ar_ba_smpm  		  "keep if cnms>=65 & date>600 & (ba<=3 | ba==6)"
graph_trend ar conacct ar_conacct_smpm   "keep if cnms>=65 & date>600 & (ba<=3 | ba==6)"







cap program drop graph_trend
program define graph_trend
	local fe_var "`2'"
	*local cluster_var "`3'"
	local outcome "`1'"
	local T_high "24"
	local T_low "-12"
	preserve
	*	keep if date>602

		*keep if date>=600 & date<=650
		*keep if ba<=3 | ba==6

		`4'
		`5'

		keep if T>=`=`T_low'' & T<=`=`T_high''

	egen `outcome'_1 = mean(`outcome'), by(`fe_var' date)
	drop `outcome'
	ren `outcome'_1 `outcome'

	duplicates drop `fe_var' date, force
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
    	tw (line estimate time, lcolor(black) lwidth(medthick)), ///
    	 graphregion(color(gs16)) plotregion(color(gs16)) xlabel(`=`T_low''(2)`=`T_high'') ///
    	 ytitle("`outcome'") 
    	 graph export  "${temp}trend_`3'_noci.pdf", as(pdf) replace
   	restore
end



graph_trend ar ba testing "keep if c!=. & ar<300"
graph_trend ar conacct testing_conacct "keep if c!=. & ar<300"





graph_trend tcd ba testing_smpm  "keep if ba<=3 | ba==6"
graph_trend tcd conacct testing_conacct_smpm  "keep if ba<=3 | ba==6"


graph_trend c ba 	  c_smpm  "keep if ba<=3 | ba==6" "keep if c<100"
graph_trend c conacct c_conacct_smpm  "keep if ba<=3 | ba==6" "keep if c<100"

graph_trend cp ba 	   cp_smpm  "keep if ba<=3 | ba==6"
graph_trend cp conacct cp_conacct_smpm  "keep if ba<=3 | ba==6" 

graph_trend dcc ba 	   dcc_smpm  "keep if ba<=3 | ba==6"
graph_trend dcc conacct dcc_conacct_smpm  "keep if ba<=3 | ba==6" 

graph_trend dcc ba 	   dcc_all 
graph_trend dcc conacct dcc_conacct_all 


graph_trend ar ba 	   ar_smpm  "keep if ba<=3 | ba==6" "drop if ar>90"
graph_trend ar conacct ar_conacct_smpm  "keep if ba<=3 | ba==6"   "drop if ar>90"

graph_trend ar ba 	   ar_all  "drop if ar>90"
graph_trend ar conacct ar_conacct_all  "drop if ar>90"



* graph_trend ar ar 
 
* graph_trend cp cp "keep if cN>=60" "keep if ba<=3 | ba==6"







* sum ar if dc==0
* sum ar if dc==1
* sum ar if dc==2

* sum ar if cp==1 
* sum ar if cp==0


* tab ar cp




/*
g pre = date<610

hist ar, by(pre)

bys conacct: g cN=_N

tab cN

egen dd=cut(date), at(600(10)650)

tab ar dd if cN>55 & cN<65

