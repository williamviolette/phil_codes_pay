


/*


**** BA event study


foreach r in 1 2 6   7 9 10 12 {

*local r "1"
use "${temp}mib_`r'.dta", clear
	replace dc=0 if dc==.
	drop if date<=600
	drop if date==653

	sort conacct date
	by conacct: g tcd_id = dc[_n-1]==0 & dc[_n]==1
	replace tcd_id = . if date<=602
	replace tcd_id = . if date==654

	g dc_date_id = date if tcd_id==1
	egen dcd = min(dc_date_id), by(conacct)
	replace tcd_id=0 if dcd!=dc_date_id

	sort conacct date
	cap drop dc_l
	g dc_l=.
	forvalues z=0/24 {
		by conacct: replace dc_l = 1 if tcd_id[_n-`z']==1 & c==.
	}
	cap drop dcs
	egen dcs=sum(dc_l), by(conacct)

		keep conacct dcs dcd

	duplicates drop conacct, force
	
	g ba=`r'

save "${temp}mib_dc_`r'.dta", replace

}


*/
**** INDIVIDUAL CHANGES

import delimited using "${mib}tondo_mib_dec2012.csv", clear delimiter(",")

* v80 : reactivation date (often before the letter...)
keep v5 v67 

ren v5 conacct

g month_v = substr(v67,4,3)
replace month_v="2" if month_v=="Feb"
replace month_v="3" if month_v=="Mar"
replace month_v="4" if month_v=="Apr"
replace month_v="5" if month_v=="May"
replace month_v="6" if month_v=="Jun"
replace month_v="7" if month_v=="Jul"
replace month_v="8" if month_v=="Aug"
replace month_v="9" if month_v=="Sep"
destring month_v, replace force

g date_v = ym(2013,month_v)
drop month_v

* g month_a = regexs(1) if regexm(v80,"(^[0-9]+)/")

destring conacct, replace force
keep conacct date_v
keep if date_v!=.
duplicates drop conacct, force

save "${temp}tondo_mib.dta", replace


import delimited using "${mib}samp_2012_can_date.csv", clear delimiter(",")
ren v1 conacct
destring conacct, replace force
g month_v = regexs(1) if regexm(v2,"(^[0-9]+)/")
destring month_v, replace force
g date_v  = ym(2013,month_v)
keep conacct date_v
keep if date_v!=.
duplicates drop conacct, force

save "${temp}samp_mib.dta", replace


import delimited using "${mib}smpm_mib_dec2012.csv", clear delimiter(",")


save "${temp}smpm_mib.dta", replace
keep v5 v67
ren v5 conacct
destring conacct, replace force
g month_v = regexs(1) if regexm(v67,"(^[0-9]+)/")
destring month_v, replace force
g date_v  = ym(2013,month_v)
keep conacct date_v
keep if date_v!=.
duplicates drop conacct, force

append using "${temp}tondo_mib.dta"
append using "${temp}samp_mib.dta"
save "${temp}mib_full.dta", replace


foreach i in 1 2 6 {
	if `i'==1 {
		use "${temp}mib_dc_`i'.dta", clear
	}
	else {
		append using "${temp}mib_dc_`i'.dta"
	}
}

merge 1:1 conacct using "${temp}mib_full.dta"
keep if _merge==3
drop _merge

egen dcdm=mean(dcd), by(date_v)

egen dcsm=mean(dcs), by(date_v)

bys date_v: g dn=_n

scatter dcdm date_v if dn==1

scatter dcsm date_v if dn==1


reg dcs i.date_v i.dcd i.ba , robust


reg dcs date_v i.dcd i.ba if dcs<=22 & dcd<=635 & date_v<=642, robust

reg dcs i.date_v i.dcd i.ba if dcs<=22 & dcd<=635 & date_v<=642, robust


reg dcs i.date_v i.dcd i.ba if  dcd<=635 & dcd>=620  & ba==6, robust



reg dcs i.date_v i.dcd i.ba if  dcd<=635 & dcd>=620 , robust


reg dcs date_v  if  dcd<=635 & dcd>=620 & date_v<=642, robust

reg dcs i.date_v  if  dcd<=635 & dcd>=620 & date_v<=642, robust



reg dcs i.date_v if dcs<=22 & dcd<=635 & date_v<=642, robust


reg dcs i.date_v i.dcd i.ba if dcs<=22, robust





/*

**** here is

foreach i in 1 2 6   7 9 10 12 {
	if `i'==1 {
		use "${temp}mib_dc_`i'.dta", clear
	}
	else {
		append using "${temp}mib_dc_`i'.dta"
	}
}
drop if ba==6

	g treat = ba>=1 & ba<=6


	cap drop dclm
	egen dclm = mean(dcs), by(dcd treat)

	cap drop cn
	bys dcd treat: g cn=_n

	scatter dclm dcd if treat==0 & cn==1, color(red) || scatter dclm dcd if treat==1 & cn==1, color(blue) xline(635)


	scatter dclm dcd if treat==0 & cn==1 & dcd>=620 & dcd<=650 , color(red) ///
	|| scatter dclm dcd if treat==1 & cn==1 & dcd>=620 & dcd<=650 , color(blue) xline(635)




/*

use "${temp}temp_descriptives_2.dta", clear

	drop if date<=600
	drop if date==653

	sort conacct date
	by conacct: g ar_pre = ar[_n-1]
	by conacct: g tcd_id = dc[_n-1]==0 & dc[_n]==1
	by conacct: g ar_post = ar[_n+1]
	replace tcd_id = . if date<=602
	replace tcd_id = . if date==654
	egen tcd_max=max(tcd_id), by(conacct)
	keep if tcd_max==1

	g dc_date_id = date if tcd_id==1
	egen dcd = min(dc_date_id), by(conacct)
	replace tcd_id=0 if dcd!=dc_date_id

	sort conacct date
	cap drop dc_l
	g dc_l=.
	forvalues r=0/12 {
		by conacct: replace dc_l = 1 if tcd_id[_n-`r']==1 & c==.
	}
	cap drop dcs
	egen dcs=sum(dc_l), by(conacct)

	gen date1 = dofm(date)
	g month=month(date1)
	g year=year(date1)

		egen dcl = sum(dc_l), by(conacct)


	cap drop treat
	g treat = ba1>=5 & ba1<=7
	


	cap drop dclm
	egen dclm = mean(dcl), by(dcd treat)

	cap drop cn
	bys dcd treat: g cn=_n

	scatter dclm dcd if treat==0 & cn==1, color(red) || scatter dclm dcd if treat==1 & cn==1, color(blue) xline(635)



	scatter dclm dcd if treat==0 & cn==1 & dcd>=620 & dcd<=650 , color(red) ///
	|| scatter dclm dcd if treat==1 & cn==1 & dcd>=620 & dcd<=650 , color(blue) xline(635)

