* fies.do


cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end


* (( .482*(0 + 9.9)/2  ) +  ( .188*(10 + 19.9)/2  ) +  ( .077*(20 + 29.9)/2  )  +  ( .089*(30 + 39.9)/2  ) +  ( .015*(50 + 59.9)/2  ) )/(.482+.188+.077+.089+.015)

* ( .5*5 + .2*15+.075*25 + .089*35 )/(.5+.2+.075+.089)

* ( .5*5 + .2*1+.075*1   + .089*1  )/(.5+.2+.075+.089)


global fies_load = 0

if $fies_load == 1 {


* import delimited using "${fies}FAMILY INCOME AND EXPENDITURE SURVEY (2015) VOLUME 2 - INCOME AND OTHER RECEIPTS - raw data.csv", delimiter(",") clear

* keep if w_regn=="Region XIII - NCR"


import delimited using "${fies}FAMILY INCOME AND EXPENDITURE SURVEY (2015) VOLUME 2 - NONFOOD EXPENDITURE - raw data.csv", delimiter(",") clear

keep if w_regn=="Region XIII - NCR"

destring twatersupply, replace force
destring todisbcashloan, replace force
destring todisbdeposits, replace force
keep if  todisbcashloan!=. | todisbdeposits!=.

replace todisbcashloan = todisbcashloan/6
replace todisbdeposits = todisbdeposits/6

keep w_id w_shsn w_hcn todisbcashloan todisbdeposits twatersupply rfact

save "${fies}hh_loans.dta", replace


import delimited using  "${fies}FAMILY INCOME AND EXPENDITURE SURVEY (2015) VOLUME 2 - HOUSEHOLD DETAILS AND HOUSING CHARACTERISTICS - raw data.csv", delimiter(",") clear

keep if w_regn=="Region XIII - NCR"

* house_1 house_2 age hhemp hhsize
* house_1 = 

save "${fies}hh_char.dta", replace


import delimited using "${fies}FAMILY INCOME AND EXPENDITURE SURVEY (2015) VOLUME 2 - TOTALS OF INCOME AND EXPENDITURE - raw data.csv", delimiter(",") clear

keep if w_regn=="Region XIII - NCR"

merge 1:1 w_id w_shsn w_hcn using "${fies}hh_char.dta"
	keep if _merge==3
	drop _merge

merge 1:1 w_id w_shsn w_hcn using "${fies}hh_loans.dta"
	drop if _merge==2
	drop _merge

save "${fies}fies_merged.dta", replace

}


use "${fies}fies_merged.dta", clear



* sum todisbdeposits, detail

* *** THIS IS RIGHT
* replace todisbdeposits = todisbdeposits/6
* sum todisbdeposits, detail
* global deposits = `=r(p95)'

* *** THIS IS PARTIALLY RIGHT?! THIS IS PAYING LOANS BACK! 
* replace todisbcashloan = todisbcashloan/6
* sum todisbcashloan, detail 
* global cashloan= `=r(p95)'


* 	write "${moments}Ab.csv" `=$deposits + $cashloan' 1 "%12.0g"
* 	write "${tables}Ab.tex" `=$deposits + $cashloan' 1 "%12.0fc"


import delimited using "${moments}sd_ratio.csv", clear
global sd_ratio = v1[1]

use "${fies}fies_merged.dta", clear

g barangay_id_st = string(w_id,"%14.0g")
g barangay_id = substr(barangay_id_st,1,7)
destring barangay_id, replace force

* merge m:1 barangay_id using "${temp}barangay_full.dta"

g inc = toinc/12
g hhsize = members


destring employed_pay employed_prof, replace force
replace employed_pay =0 if employed_pay==.
replace employed_prof=0 if employed_prof==.

g house_1 = regexm(bldg_type,"Multi-unit")==1
g house_2 = regexm(bldg_type,"Single house")==1

g hhemp = employed_pay + employed_prof

g ln_inc = log(inc)

* reg ln_inc house_1 house_2 i.hhsize i.hhemp i.age i.barangay_id, r
est save "${fies}inc_projection", replace

* sum inc if inc>500 & inc<200000, detail
* sum inc if inc>=`=r(p1)' & inc<=`=r(p99)', detail

g exp = ttotex/12
replace exp=. if exp<500 | exp>200000
replace inc=. if inc<500 | inc>200000

g save = inc - exp


mean inc [pweight = rfact] if regexm(water,"Own use, faucet")==1
* mean inc [pweight = rfact]
estat sd

mat def mm = r(mean)
mat def vv = r(sd)
mat list mm
mat list vv

write "${moments}y_avg.csv" `=mm[1,1]' .1 "%12.0g"
write "${tables}y_avg.tex"  `=mm[1,1]' .1 "%12.0fc"

write "${moments}cv_single.csv" `=vv[1,1]*$sd_ratio/mm[1,1]' .001 "%12.3g"
write "${tables}cv_single.tex"  `=vv[1,1]*$sd_ratio/mm[1,1]' .001 "%12.3fc"


	_pctile inc [pweight=rfact], p(20)

	write "${moments}y_p20.csv" `=r(r1)' 1 "%12.0g"
	write "${tables}y_p20.tex" `=r(r1)' 1 "%12.0fc"

	mean save [pweight = rfact]
	mat def M=e(b)
	write "${moments}save_avg.csv" `=M[1,1]' 1 "%12.0g"
	write "${tables}save_avg.tex" `=M[1,1]' 1 "%12.0fc"

	g ss_rate = save/inc
	mean ss_rate [pweight = rfact]
	mat def M=e(b)
	write "${moments}save_rate.csv" `=M[1,1]' 1 "%12.2g"	
	write "${tables}save_rate.tex" `=M[1,1]' 1 "%12.2fc"	


/*

destring tspecocc, replace force
replace tspecocc=0 if tspecocc==.

egen empc = group(cw)


* cap drop inc_c
* g inc_c = inc if inc>6000 & inc<150000


reg inc house_1 house_2 i.hhsize i.hhemp i.age i.barangay_id, r
predict inc_pred, residuals
egen inc_t = cut(inc_pred), group(3)
replace inc_t= inc_t+1





forvalues r=1/3 {
	preserve
	keep if inc_t==`r'

cap drop inc_c
g inc_c = inc if inc>6000 & inc<150000
sum inc_c, detail

disp `=r(mean)'
disp `=r(sd)'
disp `=r(sd)/r(mean)'
restore
}





/*


global extra_controls=""
foreach var of varlist roof walls tenure num_bed toilet electric water  {
	cap drop gg_`var'
	egen gg_`var' = group(`var')
	global extra_controls = " $extra_controls i.gg_`var' "
}

global extra_controls_2=""
foreach var of varlist radio_qty tv_qty cd_qty stereo_qty ref_qty wash_qty aircon_qty car_qty landline_qty cellphone_qty pc_qty oven_qty motor_banca_qty motorcycle_qty  {
	cap drop gg_`var'
	gen gg_`var' = `var' 
	destring gg_`var', replace force
	replace gg_`var'=0 if gg_`var'==.
	global extra_controls_2 = " $extra_controls_2 gg_`var' "
}



reg inc i.empc i.house_1 i.house_2 i.hhsize i.hhemp i.age $extra_controls $extra_controls_2 i.barangay_id, r


reg inc i.empc i.hhsize i.hhemp i.age , r

* reg inc i.empc i.house_1 i.house_2 i.hhsize i.hhemp i.age  i.barangay_id, r









cap drop inc_resid
predict inc_resid, residuals

qui sum inc, detail
global inc_m = `=r(mean)'
qui sum inc_resid, detail
global inc_sd = `=r(sd)'
disp " CV : "
disp `=$inc_sd/$inc_m'




forvalues r=1/3 {
qui sum inc if inc_t==`r', detail
global inc_m = `=r(mean)'
qui sum inc_resid  if inc_t==`r', detail
global inc_sd = `=r(sd)'
disp " CV : "
disp `=$inc_sd/$inc_m'
}


* i.hhsize i.hhemp i.age 



/*


areg inc i.hhsize_f i.hhemp_f i.age_f , r  a(barangay_id)




* g edu_f = hgc 
* g edu=3
* replace edu = 1 if ///
* 			regexm(hgc,"No Grade")==1 | ///
* 			regexm(hgc,"Primary")==1 | ///
* 			regexm(hgc,"Elementary")==1 | ///
* 			regexm(hgc,"High School")==1 | ///
* 			regexm(hgc,"Grade ")==1 | ///
* 			regexm(hgc,"Preschool ")==1 
* replace edu = 2 if ///
* 			regexm(hgc,"First Year College")==1 | ///
* 			regexm(hgc,"Second Year College")==1 | ///
* 			regexm(hgc,"Third Year College ")==1 | ///
* 			regexm(hgc,"Fourth Year College")==1 



g twa12 = twatersupply/12
replace twa12 = . if twa12>5000

g twa6 = twatersupply/6
g tw0 = twa6

replace twa6 = . if twa6>5000

replace tw0=0 if tw0==.
replace tw0=. if tw0>5000 & tw0<.


destring barangay_id, replace force
drop if barangay_id==.


reg twa12 inc  if inc<=50000, r



areg inc i.hhemp_f i.age_f [pweight = rfact], r a(barangay_id)



reg twa12 inc  i.hhsize_f  i.hhemp_f age_f [pweight = rfact] if inc<=50000, r

areg twa12 inc  i.hhsize_f  i.hhemp_f age_f [pweight = rfact] if inc<=50000, r a(barangay_id)


reg inc i.hhsize_f i.hhemp_f i.age_f  [pweight = rfact] if inc<=100000, r


areg inc i.hhsize_f i.hhemp_f i.age_f  [pweight = rfact] if inc<=100000, r a(barangay_id)


reg twa6 inc  i.hhsize_f  i.hhemp_f age_f [pweight = rfact] if inc<=50000, r


reg tw0 inc  i.hhsize_f  i.hhemp_f age_f [pweight = rfact] if inc<=50000, r


reg twa6 inc  i.hhsize_f  i.hhemp_f age_f if inc<=50000, r


reg twa6 inc if inc<=80000, r



areg twa6 inc  i.hhsize_f  i.hhemp_f age_f if inc<=50000, a(barangay_id) r


areg twa6 inc  i.hhsize_f  i.hhemp_f age_f if inc<=50000, a(barangay_id) r


fcollapse inc  todisbcashloan todisbdeposits, by(barangay_id)


save "${temp}barangay_merge.dta", replace




/*

use  "${temp}temp_descriptives.dta", clear

merge m:1 barangay_id using "${temp}barangay_merge.dta"
keep if _merge==3
drop _merge


g exp = 
g ln_inc = log(inc)
g ln_c = log(c)

g ln_amount = log(amount)

reg ln_amount ln_inc 





use  "${fies}fies_merged.dta", clear


	replace toinc = toinc/12


g wm=w==.
g loanm=loan==.

sum loan

sum w if toinc<10000

sum w if toinc>10000 & toinc<20000

sum w if toinc>20000 & toinc<30000

reg w toinc


/*
	sum toinc if toinc<1500000/12 & w_regn=="Region XIII - NCR", detail
	write "${moments}y_avg.csv" `=r(mean)' 1 "%12.0g"
	write "${tables}y_avg.tex" `=r(mean)' 1 "%12.0fc"


	_pctile toinc if toinc<1500000/12 & w_regn=="Region XIII - NCR", p(20)

	write "${moments}y_p20.csv" `=r(r1)' 1 "%12.0g"
	write "${tables}y_p20.tex" `=r(r1)' 1 "%12.0fc"


	replace ttotex = ttotex/12
	g ss = toinc - ttotex
	sum ss if toinc<1500000/12 &  ttotex<1500000/12 & w_regn=="Region XIII - NCR", detail
	write "${moments}save_avg.csv" `=r(mean)' 1 "%12.0g"
	write "${tables}save_avg.tex" `=r(mean)' 1 "%12.0fc"



	g ss_rate = ss/toinc
	sum ss_rate  if toinc<1500000/12 &  ttotex<1500000/12 & w_regn=="Region XIII - NCR", detail
	write "${moments}save_rate.csv" `=r(mean)' 1 "%12.2g"	
	write "${tables}save_rate.tex" `=r(mean)' 1 "%12.2fc"	

