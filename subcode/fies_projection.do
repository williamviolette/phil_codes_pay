* fies.do


cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end


global fies_load = 0

if $fies_load == 1 {


import delimited using "${fies}FAMILY INCOME AND EXPENDITURE SURVEY (2015) VOLUME 2 - NONFOOD EXPENDITURE - raw data.csv", delimiter(",") clear

keep if w_regn=="Region XIII - NCR"

destring todisbcashloan, replace force
destring todisbdeposits, replace force
keep if  todisbcashloan!=. | todisbdeposits!=.

replace todisbcashloan = todisbcashloan/6
replace todisbdeposits = todisbdeposits/6

keep w_id w_shsn w_hcn todisbcashloan todisbdeposits

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


use "${fies}fies_merged.dta", clear



g barangay_id_st = string(w_id,"%14.0g")
g barangay_id = substr(barangay_id_st,1,7)


g inc = toinc/12
g hhsize_f = members

destring employed_pay employed_prof, replace force
replace employed_pay =0 if employed_pay==.
replace employed_prof=0 if employed_prof==.

g hhemp_f = employed_pay + employed_prof
g age_f = age


destring barangay_id, replace force
drop if barangay_id==.
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
