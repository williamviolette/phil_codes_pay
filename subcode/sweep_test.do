
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



* gegen m_c = mean(c), by(T)
* twoway scatter m_bal T if Ttag==1 & T>=-36 & T<=0 || scatter m_c T if Ttag==1 & T>=-36 & T<=0, yaxis(2)

  

/*

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





/*
use "${temp}pay_day_bacoor.dta", clear
foreach v in  cal_1000 muntin para pasay qc_04 qc_09 qc_12 so_cal tondo val samp  {
	append using "${temp}pay_day_`v'.dta"
}

merge m:1 conacct using  "${temp}mru_total.dta"
keep if _merge==3
drop _merge

g day = day(date_day)

g o=1

gegen day_N=sum(o), by(day mru month year)
gegen day_N_max = max(day_N), by(mru month year)
g date_max_id = day if day_N==day_N_max
gegen date_max = max(date_max_id), by(mru month year)

g d_T = day - date_max
g d_T_abs=abs(d_T)
gegen d_T_m = mean(d_T_abs), by(mru month year)

g dm_ind =  day_N==day_N_max
gegen d_m = mean(dm_ind), by(mru month year)

gegen tagn=tag(mru month year)
keep if tagn==1

keep mru month year d_m d_T_m

g date = ym(year,month)
save "${temp}pay_day_stats.dta", replace

* gegen day_Nt = sum(o), by(day)
* gegen tagnt=tag(day)
* twoway scatter day_Nt day if tagnt==1


use "${temp}dc_mru_full.dta", clear
duplicates drop date mru, force

tsset mru date 
tsfill, full
replace mdc=0 if mdc==.

merge 1:1 mru date using "${temp}pay_day_stats.dta"
	keep if _merge==3
	drop _merge


sum d_m if mdc>5
sum d_m if mdc==0

sum d_T_m if mdc>5
sum d_T_m if mdc==0



