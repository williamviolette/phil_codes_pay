



* use "${temp}paws_temp.dta", clear

* use "${temp}paws_edu.dta", clear




global mergelist = "  brgy hhsize hhemp age  "
global ab = 1
global cb = "0,2,4,10"


use "${data}paws/clean/full_sample_with_edu.dta", clear

	g bar_st = string(barangay_id,"%20.0g")

	g bar4 = substr(bar_st,1,4)
	keep if bar4=="7605"
	g year = substr(interview_completion_date,1,4)
	keep if year=="2011"

	g brgy = substr(bar_st,-3,3)
	destring brgy, replace force

	* g elementary = 0
	g high_school = 0
	g college = 0
	* g grad_school = 0

	foreach var of varlist edu*_extra {
		destring `var', replace force
		* replace elementary = elementary+1 if `var'<=7
		replace high_school = high_school+1 if  `var'<=11
		replace college = college+1 if `var'>11 & `var'<.
		* replace grad = grad+1 if `var'>15 & `var'<.
	}

	destring age_extra, replace force
	destring hhemp hhsize, replace force

	duplicates drop conacct, force

	drop age
	ren age_extra age

	cap drop age_bin
	gegen age_bin = cut(age), at(10($ab)100)


g college_1 = college==1
g college_2 = college>=2

g high_school_1 = high_school==1
g high_school_2 = high_school==2
g high_school_3 = high_school>=3

g college_D = college>0 & college<.	
g high_school_D = high_school>0 & high_school<.


	cap drop D
	duplicates tag  $mergelist , g(D)
	tab D

	keep if D==0

	keep conacct $mergelist
save "${temp}paws_temp_merge", replace




use "${data}backup_cbms/2011/pasay_final2011_hh.dta", clear

g date_string = string(int_date,"%20.0g")

g yr = substr(date_string,-4,.)
g day = substr(date_string,-6,2)
g month = substr(date_string,1,1) if length(date_string)==7
replace month = substr(date_string,1,2) if length(date_string)==8

destring yr day month, replace force

g date_int = mdy(month,day,yr)

g month_int = month
g day_int = day
g year_int = yr

keep date_int month_int day_int year_int hcn
duplicates drop hcn, force

save "${temp}date_int.dta", replace




use "${data}backup_cbms/2011/pasay_final2011_mem.dta", clear

merge m:1 hcn using  "${temp}date_int.dta"
keep if _merge==3
drop _merge

drop if year_int<2011
drop if age_yr>92

replace age_mo=0 if age_mo==.


g date_string = string(birth_date,"%20.0g")

g yr = substr(date_string,-4,.)
g day = substr(date_string,-6,2)
g month = substr(date_string,1,1) if length(date_string)==7
replace month = substr(date_string,1,2) if length(date_string)==8

*** birthday! ***
destring yr day month, replace force

g bday = mdy(month,day,yr)

g age_days = (age_yr*365.2425 + age_mo*30.44 + 15.22)
g bday_alt = date_int - age_days

replace bday = bday_alt if bday==.

g new_int_date = mdy(3,1,2011)

g new_age = (new_int_date-bday)/365.2425
drop if new_age<0

g new_age_st = string(new_age,"%20.4g")
g new_age_r = regexs(1) if regexm(new_age_st,"([0-9]+)\.")
destring new_age_r, replace force
replace new_age_r=0 if new_age_r==.
drop if new_age_r>92



g age_hoh = new_age_r if reln==1

gegen age = max(age_hoh), by(hcn)

gegen age_bin = cut(age_hoh), at(10($ab)100)

g emp = jobind==1
gegen hhemp=sum(emp), by(hcn)
g o=1
gegen hhsize = sum(o), by(hcn)


g high_school_ind = (educal<=29 & jobind==1) 
egen high_school = sum(high_school_ind), by(hcn)
g college_ind = (educal>29 & educal<. & jobind==1) 
egen college = sum(college_ind), by(hcn)

g college_D = college>0 & college<.	
g high_school_D = high_school>0 & high_school<.

g college_1 = college==1
g college_2 = college>=2

g high_school_1 = high_school==1
g high_school_2 = high_school==2
g high_school_3 = high_school>=3


duplicates drop hcn, force

	cap drop D
	duplicates tag $mergelist, g(D)
	tab D

keep if D<=10
duplicates drop $mergelist, force

keep hcn $mergelist

merge 1:1 $mergelist using "${temp}paws_temp_merge"
keep if _merge==3
drop _merge







