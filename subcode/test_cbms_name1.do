



* use "${temp}paws_temp.dta", clear

* use "${temp}paws_edu.dta", clear


use "${database}clean/mcf/2011/mcf_112011.dta", clear
	keep if ba=="0700" | ba=="1100"
	keep if billclass=="0001"
	keep conacct lastname firstname
	duplicates drop conacct, force
save "${temp}pasay_names.dta", replace



global mergelist = "  brgy hhsize hhemp age  "

global mergelist = "  brgy FI lastname "

global ab = 1



******** NEW NAME ANALYSIS! 


use "${data}paws/clean/full_sample_with_edu.dta", clear

	g bar_st = string(barangay_id,"%20.0g")

	g bar4 = substr(bar_st,1,4)
	keep if bar4=="7605"
	g year = substr(interview_completion_date,1,4)
	keep if year=="2011"

	g brgy = substr(bar_st,-3,3)
	destring brgy, replace force

	merge 1:1 conacct using "${temp}pasay_names.dta"
	keep if _merge==3
	drop _merge

replace firstname=strtrim(firstname)
replace lastname=strtrim(lastname)
g name = lastname + " " + firstname
keep  brgy conacct name
save "${temp}pasay_name.dta", replace


use "${data}backup_cbms/2011/pasay_final2011_mem.dta", clear

ren msname lastname
ren mfname firstname
replace firstname=strtrim(firstname)
replace lastname=strtrim(lastname)


g name = lastname + " " + firstname
keep hcn name brgy

save "${temp}cbms_name.dta", replace



forvalues r=1/199 {
use "${temp}cbms_name.dta", clear
	keep if brgy==`r'
save "${temp}cbms_name_temp.dta", replace

use "${temp}pasay_name.dta", clear
	keep if brgy==`r'
save "${temp}pasay_name_temp.dta", replace

matchit conacct name using "${temp}cbms_name_temp.dta", idusing(hcn) txtusing(name) threshold(.8)
g brgy=`r'
save "${temp}matched_`r'.dta", replace

}

forvalues r=1/199 {
	if `r'==1 {
		use "${temp}matched_`r'.dta", clear
	}
	else {
		append using "${temp}matched_`r'.dta"
	}
	erase "${temp}matched_`r'.dta"
}
save "${temp}matched.dta", replace



use "${temp}matched.dta", clear

egen max_match= max(similscore), by(conacct)

keep if similscore==max_match

duplicates drop conacct, force


duplicates tag hcn, g(D)

keep conacct hcn

save "${temp}match_list.dta", replace





use "${data}paws/clean/full_sample_with_edu.dta", clear

duplicates drop conacct, force

	merge m:1 conacct using "${temp}match_list.dta"
	keep if _merge==3
	drop _merge

g amount = may_exp_extra
drop age
g age    = age_extra

destring amount hhsize hhemp age job, replace

keep conacct hcn amount hhsize hhemp age job 

ren (amount hhsize hhemp age job) (amount_paws hhsize_paws hhemp_paws age_paws job_paws)

duplicates drop hcn, force

	merge 1:m hcn using "${data}backup_cbms/2011/pasay_final2011_hh.dta"
	keep if _merge==3
	drop _merge

replace ave_water=. if ave_water>3000
replace amount_paws = . if amount_paws>3000


replace totin = totin/12
sum totin, detail

replace totin=. if totin>55000


areg ave_water totin , a(brgy)



areg ave_water totin hsize if totin<20000, a(brgy)



reg hsize hhsize if hsize<10 & hhsize<10


reg ave_water hsize totin if hsize<10 & hhsize<10


reg ave_water hhsize if hsize<10 & hhsize<10

reg amount_paws hsize if hsize<10 & hhsize<10
reg amount_paws hhsize if hsize<10 & hhsize<10



reg amount_paws ave_water


reg ave_water totin  if totin<30000
reg amount_paws totin  if totin<30000


reg ave_water totin if ave_water<3000 & totin<50000


