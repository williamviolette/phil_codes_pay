



set more off

use "${data}backup_cbms/2011/pasay_final2011_hh.dta", clear
	duplicates drop hcn, force
	merge 1:m hcn using "${data}backup_cbms/2011/pasay_final2011_mem.dta"

	g barangay_id = prov*100000 + mun*1000 + brgy

	preserve 
		keep barangay_id
		duplicates drop barangay_id, force
		save "${temp}cbms_barangays.dta", replace
	restore

	egen age=max(age_yr), by(hcn)
	ren hsize hhsize
	g house="single" if house_type==1
		replace house="duplex" if house_type==2
		replace house="apartment" if house_type==3
		replace house="other" if house==""
	g J=jobind==1
	egen hhemp=sum(J), by(hcn)
	g low_skill=g_occ==9

	replace totin=totin/12
	drop if totin<500  |  totin>200000

	replace ave_water=. if ave_water>6000

	g high_school_ind = (educal<=29 & jobind==1) 
	egen high_school = sum(high_school_ind), by(hcn)
	g college_ind = (educal>29 & educal<. & jobind==1) 
	egen college = sum(college_ind), by(hcn)

	* tab g_occ, g(occ_)
	* foreach var of varlist occ_* {
	* 	replace `var'=0 if `var'==.
	* 	egen `var'_s = sum(`var'), by(hcn)
	* 	drop `var'
	* }

	g house_1= house=="apartment"
	g house_2= house=="single"
		keep barangay_id hcn totin house_1 house_2 low_skill hhemp hhsize age high_school college ave_water 
		* occ*

	duplicates drop hcn, force

	g year=2011

	save "${temp}cbms_2011.dta", replace

	* reg ave_water totin
	* reg ave_water totin i.hhsize i.hhemp 
	* reg ave_water totin i.hhsize i.hhemp i.barangay_id, r

	g ln_inc = log(totin)

	* i.hhsize i.hhemp  i.high_school i.college

	reg ln_inc i.barangay_id  house_1 house_2 i.low_skill  i.age  i.hhsize i.hhemp  i.high_school i.college , r

	est save "${fies}inc_projection_cbms", replace




use "${data}backup_cbms/2008/pasay_hhfinal08.dta", clear
	duplicates drop hcn, force
	merge 1:m hcn using "${data}backup_cbms/2008/pasay_memfinal08.dta"

	g barangay_id = prov*100000 + mun*1000 + brgy

	egen age=max(age_yr), by(hcn)
	ren hsize hhsize
	g house="single" if kind_house==1
		replace house="duplex" if kind_house==2
		replace house="apartment" if kind_house==3
		replace house="other" if house==""
	g J=jobind==1
	egen hhemp=sum(J), by(hcn)
	g low_skill=g_occ==9

	replace totin=totin/12
	drop if totin<500  |  totin>200000

	g ave_water = water_price/12
	replace ave_water=. if ave_water>6000

	g high_school_ind = (educal<=29 & jobind==1) 
	egen high_school = sum(high_school_ind), by(hcn)
	g college_ind = (educal>29 & educal<. & jobind==1) 
	egen college = sum(college_ind), by(hcn)

	* tab g_occ, g(occ_)
	* foreach var of varlist occ_* {
	* 	replace `var'=0 if `var'==.
	* 	egen `var'_s = sum(`var'), by(hcn)
	* 	drop `var'
	* }


	* g uni = prog_unicef==1
	* egen min_age = min(age_yr), by(hcn)
	* areg totin uni i.min_age, a(barangay_id) r
	* areg uni i.min_age if min_age<=40, a(barangay_id) r
	* areg totin i.min_age if min_age<=40, a(barangay_id) r


	g house_1= house=="apartment"
	g house_2= house=="single"
		keep barangay_id hcn totin house_1 house_2 low_skill hhemp hhsize age high_school college ave_water  borrow*

* occ*

		g year=2008
		duplicates drop hcn, force
save "${temp}cbms_2008.dta", replace





use "${temp}cbms_2011.dta", clear
	append using "${temp}cbms_2008.dta"

bys hcn: g hN=_N
keep if hN==2

qui sum totin, detail
global sd_raw = `=r(sd)'
* disp `=r(sd)'
* disp `=r(mean)'
* disp `=r(sd)/r(mean)'

qui areg totin, a(hcn)
cap drop simple_resid
predict simple_resid, resid
qui sum simple_resid, detail
* disp `=r(sd)'

qui areg totin i.hhsize i.hhemp, a(hcn)
cap drop full_resid
predict full_resid, resid
qui sum full_resid, detail
disp `=r(sd)'
global sd_full = `=r(sd)'

disp $sd_full/$sd_raw

write "${moments}sd_ratio.csv" `=$sd_full/$sd_raw' .001 "%12.3g"
write "${tables}sd_ratio.tex" `=$sd_full/$sd_raw' .001 "%12.3fc"


* disp `=`=r(sd)'/$tmean'



* egen inc_mean = mean(totin), by(hcn)
* egen inc_t = cut(inc_mean), group(3)
* replace inc_t= inc_t+1

* reg totin house_1 house_2 i.hhsize i.hhemp i.age i.barangay_id , r
* predict inc_pred, residuals
* egen inc_mean=mean(inc_pred), by(hcn)
* egen inc_t = cut(inc_mean), group(3)
* replace inc_t= inc_t+1



/*


areg totin i.hhsize i.hhemp i.occ_1_s i.occ_2_s i.occ_3_s i.occ_4_s i.occ_5_s i.occ_6_s i.occ_7_s i.occ_8_s i.occ_9_s i.occ_10_s , a(hcn)
cap drop complex_resid
predict complex_resid, resid
sum complex_resid, detail
disp `=`=r(sd)'/$tmean'





* i.low_skill i.occ_1_s i.occ_2_s i.occ_3_s i.occ_4_s i.occ_5_s i.occ_6_s i.occ_7_s i.occ_8_s i.occ_9_s i.occ_10_s  i.high_school i.college 






sort hcn year
by hcn: g totin_lag = totin[_n-1]





g cv = abs(2*(totin - totin_lag) / (totin + totin_lag))

sum cv, detail
write "${tables}cv.tex" `=r(mean)' 0.001 "%12.3fc"




forvalues r=1/3 {
	sum cv if inc_t==`r'
	write "${tables}cv_t`r'.tex" `=r(mean)' 0.001 "%12.3fc"
}



areg totin i.hhsize i.age i.hhemp i.low_skill i.occ_1_s i.occ_2_s i.occ_3_s i.occ_4_s i.occ_5_s i.occ_6_s i.occ_7_s i.occ_8_s i.occ_9_s i.occ_10_s  i.high_school i.college i.year, r a(hcn)
cap drop totin_resid
predict totin_resid, resid

sort hcn year
by hcn: g totin_resid_lag = totin_resid[_n-1]

g cv_resid = abs(2*(totin_resid - totin_resid_lag) / (totin + totin_lag))

sum cv_resid, detail
write "${moments}cv_adj.csv" `=r(mean)' 0.001 "%12.3g"
write "${tables}cv_adj.tex" `=r(mean)' 0.001 "%12.3fc"

forvalues r=1/3 {
	sum cv_resid if inc_t==`r'
	write "${moments}cv_adj_t`r'.csv" `=r(mean)' 0.001 "%12.3g"
	write "${tables}cv_adj_t`r'.tex" `=r(mean)' 0.001 "%12.3fc"
}


count if year==2011
write "${tables}cbms_hhs.tex" `=r(N)' 1 "%12.0fc"







/*




egen inc_sd = sd(totin), by(hcn)
egen inc_mean = mean(totin), by(hcn)
g cv = inc_sd/inc_mean
sum cv, detail


write "${tables}cv.tex" `=r(mean)' 0.001 "%12.3fc"

forvalues r=1/3 {
	sum cv if inc_t==`r'
	write "${tables}cv_t`r'.tex" `=r(mean)' 0.001 "%12.3fc"
}



reg totin i.hhsize i.age i.hhemp i.low_skill i.high_school i.college i.house_1 i.house_2 i.year, r
cap drop totin_resid
predict totin_resid, resid

egen inc_sd_resid = sd(totin_resid), by(hcn)
egen inc_mean_resid = mean(totin), by(hcn)
g cv_alt = inc_sd_resid/inc_mean
sum cv_alt, detail

write "${moments}cv_adj.csv" `=r(mean)' 0.001 "%12.3g"
write "${tables}cv_adj.tex" `=r(mean)' 0.001 "%12.3fc"

forvalues r=1/3 {
	sum cv_alt if inc_t==`r'
	write "${moments}cv_adj_t`r'.csv" `=r(mean)' 0.001 "%12.3g"
	write "${tables}cv_adj_t`r'.tex" `=r(mean)' 0.001 "%12.3fc"
}


count if year==2011
write "${tables}cbms_hhs.tex" `=r(N)' 1 "%12.0fc"


/*


sum totin, detail

g B = 1 if  borrow_money==1
replace B=0 if borrow_money==2

areg B ave_water totin, a(barangay_id) r



sort hcn year
foreach var of varlist totin ave_water hhsize barangay_id age hhemp low_skill high_school college house_1 house_2 {
by hcn: g `var'_lag = `var'[_n-1]
}



reg totin totin_lag, r

reg totin totin_lag hhsize* age* hhemp* low_skill* high_school* college* house_1* house_2*, r 

areg totin totin_lag hhsize* age* hhemp* low_skill* high_school* college* house_1* house_2*, r a(barangay_id)



sum totin
sum totin_lag


g inc_change = totin - totin_lag
sum inc_change
areg inc_change i.hhsize i.hhsize_lag i.age i.age_lag i.hhemp i.hhemp_lag i.low_skill i.low_skill_lag i.high_school i.high_school_lag i.college i.college_lag house_1* house_2*, r a(barangay_id)
predict inc_r, resid


areg totin i.hhsize i.age i.hhemp i.low_skill i.high_school i.college i.house_1 i.house_2 i.year, r a(hcn)

cap drop inc_alt_resid
predict inc_alt_resid, resid
sum inc_alt_resid, detail

sum inc_alt_resid, detail
global var_mean = `=r(sd)'

sum totin, detail
global mean_inc = `=r(mean)'


disp `= $var_mean / $mean_inc '






g ave_water_change = ave_water - ave_water_lag

reg 

sum ave_water

reg ave_water_change inc_change 

areg ave_water_change inc_change hhsize* age* hhemp* low_skill* high_school* college* house_1* house_2*, r a(barangay_id)


sum ave_water_change








/*


use "${data}backup_cbms/2011/pasay_final2011_hh.dta", clear


g 

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






* use "${temp}paws_temp.dta", clear

* use "${temp}paws_edu.dta", clear


** input : census data
** output: savings/temp/RT02_merged.dta

* foreach r in 13761 13762 {
* * local r "13762"
* import delimited using "${censusdata}RT01_`r'.CSV", delimiter(",") clear
* 	egen age=max(cp5_age), by(region prov mun bgy hsnb)
* 	bys region prov mun bgy hsnb: g hhsize=_N


* 		replace s15ap20_occ="-1" if s15ap20_occ=="    "
* 		g occ=substr(s15ap20_occ,1,1)
* 		destring occ, replace force
* 		g emp=occ!=. & occ!=0
* 		egen hhemp=sum(emp), by(region prov mun bgy hsnb)
* 		replace hhemp=. if hhemp>12
* 		egen occupation=max(occ), by(region prov mun bgy hsnb)
	
* 		g move_id=h05ap14m_5yrsago!="" & h05ap14m_5yrsago!="00"
* 		egen move_id1=mean(move_id), by(region prov mun bgy hsnb)
* 		g move=move_id1>.5 & move_id1<.
	

* 	ren ca05ap16r_hgc grade
* 	destring grade, replace force

* 	g high_school_id = (grade<=350 & emp==1)
* 	egen high_school = sum(high_school_id), by(region prov mun bgy hsnb)

* 	g college_id = (grade>350 & grade<. & emp==1)
* 	egen college = sum(college_id), by(region prov mun bgy hsnb)


* 	keep region prov mun bgy hsnb age hhemp occupation move popbwgt high_school college
* 	duplicates drop region prov mun bgy hsnb, force

* save "${temp}RT01_`r'_prep_new.dta", replace


* * local r "13762"
* import delimited using "${censusdata}RT02_`r'.CSV", delimiter(",") clear

* 	ren hsize hhsize	
* 	destring hhsize, replace force
* 	keep region prov mun bgy hsnb hhsize sh3a_drink sh3b_cook sh3c_laundry hb1_bldg
* 	duplicates drop region prov mun bgy hsnb, force
	
* 		merge 1:1 region prov mun bgy hsnb using "${temp}RT01_`r'_prep_new.dta"
* 		keep if _merge==3
* 		drop _merge		
	
* save "${temp}RT02_`r'_prep_new.dta", replace 
* }

* use "${temp}RT02_13761_prep_new.dta", clear
* append using "${temp}RT02_13762_prep_new.dta"

* 		g barangay_id	=prov*100000+mun*1000+bgy
* 		g alt			=sh3c_laundry>2 & sh3c_laundry<.
* 		g house_1		=hb1_bldg==3
* 		g house_2       =hb1_bldg==1
* 		g low_skill     = (occupation>=6 & occupation<=8)
* 		replace age = 100 if age>100
* 		g conacct=_n

* 		keep barangay_id alt house_1 house_2 age hhemp hhsize conacct low_skill move sh3c_laundry  popbwgt high_school college

* save "${temp}census_new.dta", replace		

* use "${temp}census_new.dta", clear

* collapse (mean) hhsize age hhemp college high_school house_1 house_2 low_skill [pweight = popbwgt], by(barangay_id)

* foreach var of varlist  * {
* 	ren `var' `var'_cen
* }
* ren barangay_id_cen barangay_id
* save "${temp}census_pasay.dta", replace





* use "${temp}cbms_2011.dta", clear

* 	append using "${temp}cbms_2008.dta"

* bys hcn: g hN=_N
* keep if hN==2
* keep if year==2011


* merge m:1 barangay_id using "${temp}census_pasay.dta"
* keep if _merge==3
* drop _merge

* collapse (mean) hhsize* age* hhemp* house_1* house_2* low_skill* high_school* college*, by(barangay_id)

* sum hhsize
* sum hhsize_cen

* sum age
* sum age_cen

* sum hhemp
* sum hhemp_cen

* sum high_school
* sum high_school_cen

* sum college
* sum college_cen

* sum house_1
* sum house_1_cen

* sum house_2
* sum house_2_cen


