*  visit_selection.do


grstyle init
grstyle set imesh, horizontal


cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end


cap prog drop print_mean
program print_mean
    qui sum `2', detail 
    local value=string(`=r(mean)*`4'',"`3'")
    file open newfile using "${tables}`1'.tex", write replace
    file write newfile "`value'"
    file close newfile    
end

sort conacct date

cap drop arl
by conacct: g arl = ar[_n-1]

cap drop ball
by conacct: g ball = bal[_n-1]

cap drop clag
by conacct: g clag = c[_n-1]

cap drop bg
egen bg = cut(ball), at(0(200)10000)



cap program drop sp
prog define sp
	preserve
		`4'
		cap drop mv
		egen mv = mean(`2') , by(`3')
		cap drop dn
		bys `3': g dn=_n
		twoway connected mv `3' if dn==1, lp(dash) lc(gs0) lw(medthick) plotr(lw(medthick )) xlabel(0(60)300 360 "360+") ytitle("Share of Months with Delinquency Visit") xtitle("Days Overdue in Previous Month") 
		graph export  "${tables}connected_`1'.pdf", as(pdf) replace
	restore
end

sp "visit_hazard_all" tcd_id ar_lag "replace ar_lag=360 if ar_lag>360 & ar_lag<."


**** EXPORT AVERAGE
	sum tcd_id 
	write "${tables}tcd_id_mean.tex" `=r(mean)*100' 0.1 "%12.2fc"

	sum tcd_id if ar_lag>31 & ar_lag<500
	write "${tables}tcd_id_ar_cond.tex" `=r(mean)*100' 0.1 "%12.2fc"



sp "visit_hazard" tcd_id ar_lag "keep if tcd_max==1 & a6==1 & ar_lag<500"






*** do the full regression here!!



lab var clag "Usage t-1"
lab var ar_lag "Days Delinquent t-1"
lab var ball "Unpaid Balance t-1"

lab var house_1 "Single House"
lab var house_2 "Apartment"
lab var age "Age of HoH"
lab var hhemp "Employed HH Members"
lab var hhsize "HH Size"
lab var low_skill "HoH Low Skill Empl."


reg tcd_id clag ar_lag ball house_1 house_2 age low_skill hhsize hhemp, cluster(conacct) robust

sum tcd_id if e(sample)==1, detail
estadd scalar tcdm = `=r(mean)'

estadd local area ""
estadd local date ""
estadd local acct ""

eststo tcd_none


reg tcd_id clag ar_lag ball house_1 house_2 age low_skill hhsize hhemp i.ba1 i.date, cluster(conacct) robust

sum tcd_id if e(sample)==1, detail
estadd scalar tcdm = `=r(mean)'

estadd local area "\checkmark"
estadd local date "\checkmark"
estadd local acctfe ""

eststo tcd_ba


areg tcd_id clag ar_lag ball i.date, absorb(conacct) cluster(conacct) robust

sum tcd_id if e(sample)==1, detail
estadd scalar tcdm = `=r(mean)'

estadd local area ""
estadd local date "\checkmark"
estadd local acctfe "\checkmark"

eststo tcd_fe



estout tcd_none tcd_ba tcd_fe using "${tables}tcd_predict.tex", replace  ///
style(tex) ///
  keep( ///
 clag ar_lag ball house_1 house_2 age low_skill hhsize hhemp ///
  ) varlabels(, el( clag "[0.5em]" ar_lag "[0.5em]" ball "[0.5em]" house_1 "[0.5em]" house_2 "[0.5em]" age "[0.5em]" low_skill "[0.5em]" hhsize "[0.5em]" hhemp "[0.5em]")) label noomitted mlabels(,none) collabels(none) ///
    cells( b(fmt(7) star ) se(par fmt(7)) ) ///
     starlevels( ///
    "\textsuperscript{c}" 0.10  ///
    "\textsuperscript{b}" 0.05  ///
    "\textsuperscript{a}" 0.01)  ///
      stats(area date acctfe N tcdm  , fmt(%18s %18s %18s %9.0fc %9.4fc )   ///
      labels( ///
      "Location" ///
      "Year \tim Month \textsc{FE}" ///
      "Household \textsc{FE}" ///
      "N" "Mean Visits Per Month")  ) 







*cap drop ar_up
*g ar_up = arl>61

*cap drop mv
*egen mv = mean(tcd_id), by(bg ar_up)
*cap drop dn
*bys bg ar_up: g dn=_n
* scatter mv bg  if dn==1 & ar_up==0  || ///
* scatter mv bg  if dn==1 & ar_up==1 

* cap drop arg
* by conacct: g arg = ar[_n-1] if ar[_n-1]>ar[_n-2]



