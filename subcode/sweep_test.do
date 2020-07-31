
set scheme s1mono

grstyle init
grstyle set imesh, horizontal


use  "${temp}temp_descriptives_3.dta", clear


g T = date-dc_date

gegen m_bal = mean(bal), by(T)
gegen Ttag= tag(T)

twoway scatter m_bal T if Ttag==1 & T>=-36 & T<=0, ///
xtitle("Months to Permanent Disconnection") ///
ytitle("Average Unpaid Balance (PhP)") xlabel(-36(12)0)

graph export "${tables}pay_to_dc_graph.png", as(png) replace




use  "${temp}temp_descriptives_3.dta", clear

merge m:1 conacct using "${temp}mru_total.dta"
	keep if _merge==3
	drop _merge
merge m:1 mru date using "${temp}dc_mru_full.dta"
	drop if _merge==2
	drop _merge
replace mdc=0 if mdc==.
replace mdc=. if date==664


merge m:1 conacct date using "${temp}neighbor_dc_full.dta"
	drop if _merge==2
	g m1= _merge==3
	drop _merge
	gegen nd = max(m1), by(conacct)
	drop m1
	foreach var of varlist r_* {
		replace `var'=0 if `var'==. & nd==1
	}
	drop nd



replace r_1 = 0 if r_1_no_mru==1
replace r_2 = 0 if r_2_no_mru==1
replace r_3 = 0 if r_3_no_mru==1

areg pay tcd_id r_1 r_1_no_mru r_2 r_2_no_mru  r_3 r_3_no_mru i.date, a(conacct) cluster(conacct) 


eststo pay
	sum pay if e(sample)==1, detail
	estadd scalar varmean = `r(mean)'

	lab var tcd_id "Own Warning"
	lab var r_1 "\hspace{.5em}1st Nearest Household"
	lab var r_1_no_mru "\hspace{.5em}1st Nearest Household"
	lab var r_2 "\hspace{.5em}2nd Nearest Household"
	lab var r_2_no_mru "\hspace{.5em}2nd Nearest Household"
	lab var r_3 "\hspace{.5em}3rd Nearest Household"
	lab var r_3_no_mru "\hspace{.5em}3rd Nearest Household"



estout pay using "${tables}table_visit_pay_robust.tex", replace  style(tex) ///
	keep( tcd_id r_1 r_2 r_3   r_1_no_mru r_2_no_mru  r_3_no_mru ) ///
	order(tcd_id r_1 r_2 r_3   r_1_no_mru r_2_no_mru  r_3_no_mru) ///
		varlabels(, el(  tcd_id "[0.5em]"  r_1 "[0.1em]" r_2 "[0.1em]" r_3 "[0.1em]" ///
		   r_1_no_mru "[0.1em]" r_2_no_mru "[0.1em]" r_3_no_mru "[0.1em]") ///
		bl( r_1 "Warning in Same Neighborhood for: \\[.5em] " r_1_no_mru "Warning in Different Neighborhood for:  \\[.5em] " ) ///
		)  label noomitted ///
		  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
		  stats( varmean r2 N , labels( "Mean" "$\text{R}^{2}$" "N"  )   fmt( %12.2fc %12.3fc %12.0fc  )   ) ///
		  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 

