



gegen c_tag = tag(conacct)
g paws_id = hhsize_paws!=.
gegen paws= sum(paws_id), by(conacct)

tab paws if c_tag==1 & paws>0


tab date if hhsize_paws!=.

g round_paws = 1 if date<590 & hhsize_paws!=.
replace round_paws = 2 if date>=590 & date<600 & hhsize_paws!=.
replace round_paws = 3 if date>=600 & hhsize_paws!=.

tab round_paws

*** who takes part in the panel?!
* g paws_id = hhsize_paws!=.
* gegen paws= sum(paws_id), by(conacct)
* g paws_1 = paws>1 & paws<.
* gegen c_tag = tag(conacct)
* areg paws_1 hhsize hhemp house_1 house_2 age low_skill if paws>0 & paws<. & c_tag==1, robust a(barangay_id)
 
 




preserve
	sort conacct date
	by conacct: replace amount = amount[_n-1] if date==595
	by conacct: replace amount = amount[_n-1] if date==593
	by conacct: replace am = am[_n-1] if date==595
	by conacct: replace am = am[_n-1] if date==593

	keep if hhsize_paws!=.
	sort conacct date
	foreach var of varlist hhemp_paws hhsize_paws amount pay am enough_time  {
		by conacct: g `var'_ch=`var'[_n]-`var'[_n-1]
	}

	lab var hhemp_paws_ch "Working Members"
	lab var hhsize_paws_ch "Total Members"

	reg amount_ch hhsize_paws_ch hhemp_paws_ch  , cluster(conacct) robust
	eststo amount_ch
	sum amount if e(sample)==1, detail
	estadd scalar varmean = `r(mean)'

	reg pay_ch hhsize_paws_ch hhemp_paws_ch  , cluster(conacct) robust
	eststo pay_ch
	sum pay if e(sample)==1, detail
	estadd scalar varmean = `r(mean)'

	reg am_ch hhsize_paws_ch hhemp_paws_ch  , cluster(conacct) robust
	eststo am_ch
	sum am if e(sample)==1, detail
	estadd scalar varmean = `r(mean)'

	* reg amount_ch hhsize_paws_ch hhemp_paws_ch if hhsize_paws_ch>=-5 & hhsize_paws_ch<=5 & hhemp_paws_ch>=-5 & hhemp_paws_ch<=5, cluster(conacct) robust
	* reg pay_ch    hhsize_paws_ch hhemp_paws_ch if hhsize_paws_ch>=-5 & hhsize_paws_ch<=5 & hhemp_paws_ch>=-5 & hhemp_paws_ch<=5, cluster(conacct) robust
restore



preserve
	use "${temp}cbms_temp_2011.dta", clear

	append using "${temp}cbms_temp_2008.dta"

	egen sm=max(source_water), by(hcn)

	sort hcn date
	by hcn: g T=_n

	gegen TM=max(T), by(hcn)

	keep if TM==2
	replace bill=. if bill==0

	sort hcn T
	foreach var of varlist hhemp inc bill hhsize {
		by hcn: g `var'_paws_ch =`var'[_n]-`var'[_n-1]
	}

	sum inc_paws_ch, detail
	replace inc_paws_ch=. if inc_paws_ch<`=r(p1)'
	replace inc_paws_ch=. if inc_paws_ch>`=r(p99)'

	reg inc_paws_ch hhemp_paws_ch hhsize_paws_ch , cluster(hcn) robust
	eststo inc_ch
	sum inc if e(sample)==1, detail
	estadd scalar varmean = `r(mean)'
	* reg inc_ch hhemp_ch hhsize_ch  if hhemp_ch>=-5 & hhemp_ch<=5 & hhsize_ch<=10 & hhsize_ch>=-10 & inc_ch>=-100000 & inc_ch<=100000, cluster(hcn) robust

	sum inc, detail
	global ymean = `=r(mean)'

	write "${moments}y_avg.csv" `=r(mean)' 1 "%12.0g"
	write "${tables}y_avg.tex" `=r(mean)' 1 "%12.0fc"

	gegen inc_m = mean(inc), by(hcn)
	g inc_dev = inc-inc_m

	sum inc_dev, detail
	global ysd = `=r(sd)'
	write "${moments}y_sd.csv" `=r(sd)' .00001 "%12.4g"
	write "${tables}y_sd.tex" `=r(sd)' .00001 "%12.2fc"

	write "${moments}y_theta.csv" `=$ysd/$ymean' .00001 "%12.4g"
	write "${tables}y_theta.tex" `=$ysd/$ymean'  .00001 "%12.2fc"

	write "${moments}y_cv.csv" `=$ysd/$ymean'  .00001 "%12.4g"
	write "${tables}y_cv.tex" `=$ysd/$ymean'  .00001 "%12.2fc"

restore




estout amount_ch pay_ch inc_ch using "${tables}table_panel_analysis.tex", replace  style(tex) ///
	keep( hhemp_paws_ch hhsize_paws_ch   ) order(hhemp_paws_ch hhsize_paws_ch) ///
		varlabels(hhemp_paws_ch "$\Delta$ Working Members" hhsize_paws_ch "$\Delta$ Total Members", el(  hhemp_paws_ch "[0.5em]" hhsize_paws_ch "[0.5em]") )  label noomitted ///
		  mlabels(,none)   collabels(none)  cells( b(fmt(2) star ) se(par fmt(2)) ) ///
		  stats( varmean r2 N , labels( "Mean" "$\text{R}^{2}$" "N"  )   fmt( %12.2fc %12.3fc %12.0fc  )   ) ///
		  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 








