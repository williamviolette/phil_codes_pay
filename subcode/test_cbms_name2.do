

	* g year = substr(interview_completion_date,1,4)
	* keep if year=="2011"
******** NEW NAME ANALYSIS! 



global mlist = " lastname_firstname street_hnum street_lastname street_lastname_firstname full "

cap prog drop cleaning
prog define cleaning

	replace street = subinstr(street,".","",.)
	replace street = subinstr(street,"ST","",.)

	tostring hnum, replace force
	g lastname_firstname= lastname+" " +firstname
	g street_hnum = street+" "+hnum
	g street_lastname = street+" "+lastname
	g street_lastname_firstname=  lastname+" "+street+" "+firstname
	g full=  lastname+" "+street+" "+firstname+ " "+hnum
end

cap prog drop list_bill
prog define list_bill
	keep brgy conacct $mlist
end

cap prog drop list_cbms
prog define list_cbms
	keep brgy hcn $mlist
end

cap prog drop matching
prog define matching

	forvalues r=1/199 {
	use "${temp}cbms_name_`3'.dta", clear
		keep if brgy==`r'
	save "${temp}cbms_name_temp.dta", replace

	use "${temp}pasay_name.dta", clear
		keep if brgy==`r'
	save "${temp}pasay_name_temp.dta", replace

	matchit conacct `2' using "${temp}cbms_name_temp.dta", idusing(hcn) txtusing(`2') threshold(.8)
	g brgy=`r'
	egen max_match= max(similscore), by(conacct)
	keep if similscore==max_match
	drop max_match
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
	save "${temp}matched_`1'.dta", replace

end 




use "${database}clean/mcf/2011/mcf_112011.dta", clear
	keep if ba=="0700" | ba=="1100"
	keep if billclass=="0001"
	g hnum = regexs(1) if regexm(address,"(^[0-9]+)")
	destring hnum, replace force
	replace hnum = . if hnum==0 | hnum==9999
	keep conacct lastname firstname street hnum

	duplicates drop conacct, force
save "${temp}pasay_names.dta", replace


use "${data}paws/clean/full_sample_with_edu.dta", clear

	g bar_st = string(barangay_id,"%20.0g")
	g bar4 = substr(bar_st,1,4)
	keep if bar4=="7605"

	g brgy = substr(bar_st,-3,3)
	destring brgy, replace force

	duplicates drop conacct, force

	merge 1:1 conacct using "${temp}pasay_names.dta"
	keep if _merge==3
	drop _merge

replace firstname=strtrim(firstname)
replace lastname=strtrim(lastname)
g name = lastname + " " + firstname

duplicates drop brgy conacct lastname firstname street hnum, force

cleaning
list_bill

save "${temp}pasay_name.dta", replace



use "${data}backup_cbms/2008/pasay_hhfinal08.dta", clear

g hnum = regexs(1) if regexm(addr_l1,"(^[0-9]+)")
g street = regexs(1) if regexm(addr_l1,"^[0-9]+ (.+)")

keep hcn street hnum
destring hnum, replace force
duplicates drop hcn, force
save "${temp}cbms_address_08.dta", replace


use "${data}backup_cbms/2008/pasay_memfinal08.dta", clear
ren msname lastname
ren mfname firstname
replace firstname=strtrim(firstname)
replace lastname=strtrim(lastname)

merge m:1 hcn using "${temp}cbms_address_08.dta"
	drop if _merge!=3
	drop _merge

cleaning
list_cbms

save "${temp}cbms_name_08.dta", replace



use "${data}backup_cbms/2011/pasay_final2011_hh.dta", clear
keep hcn street hnum
destring hnum, replace force
duplicates drop hcn, force
save "${temp}cbms_address_11.dta", replace


use "${data}backup_cbms/2011/pasay_final2011_mem.dta", clear
ren msname lastname
ren mfname firstname
replace firstname=strtrim(firstname)
replace lastname=strtrim(lastname)

merge m:1 hcn using "${temp}cbms_address_11.dta"
	drop if _merge!=3
	drop _merge

cleaning
list_cbms

save "${temp}cbms_name_11.dta", replace


foreach v in $mlist {
	matching `v'_08 `v' "08"
	matching `v'_11 `v' "11"
}


/*



foreach v in $mlist {
	if "`v'"=="lastname_firstname" {
		use "${temp}matched_`v'.dta", clear
		g mlist = ""
	}
	else {
		append using "${temp}matched_`v'.dta"
	}
	replace mlist="`v'" if mlist ==""

}

g mq=.
replace mq = 5 if mlist=="full"
replace mq = 4 if mlist=="street_lastname_firstname"
replace mq = 3 if mlist=="street_lastname"
replace mq = 2 if mlist=="lastname_firstname"
replace mq = 1 if mlist=="street_hnum"

egen mq_max=max(mq), by(conacct)
keep if mq==mq_max

duplicates drop conacct, force

save "${temp}matched_total.dta", replace





use "${data}paws/clean/full_sample_with_edu.dta", clear

duplicates drop conacct, force

	merge m:1 conacct using "${temp}matched_total.dta"
	keep if _merge==3
	drop _merge

g amount = may_exp_extra
drop age
g age    = age_extra

destring amount hhsize hhemp age job, replace

keep conacct hcn amount hhsize hhemp age job mq

ren (amount hhsize hhemp age job) (amount_paws hhsize_paws hhemp_paws age_paws job_paws)

gegen mq_max = max(mq), by(hcn)
keep if mq==mq_max

duplicates drop hcn, force

	merge 1:m hcn using "${data}backup_cbms/2011/pasay_final2011_hh.dta"
	keep if _merge==3
	drop _merge


replace ave_water=. if ave_water>3000
replace amount_paws = . if amount_paws>3000

corr ave_water amount_paws

forvalues r=1/5 {
corr ave_water amount_paws if mq==`r'
}


count if mq!=1

/*


use "${temp}matched.dta", clear

egen max_match= max(similscore), by(conacct)

keep if similscore==max_match

* keep if max_match==1

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

corr ave_water amount_paws




/*




reg ave_water i.hsize i.hhemp totin 
reg amount_paws i.hsize i.hhemp totin 

	


corr hsize hhsize_paws

corr ave_water amount_paws

corr ave_water amount_paws if hsize==hhsize_paws


corr age_paws age


/*


corr ave_water amount_paws



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


