




	* stnd_address street, g(street1) patpath("${subcode}")
	* drop street
	* ren street1 street


global mlist = " brgy address street hnum lastname firstname"

cap prog drop hnum_gen
prog define hnum_gen
	replace address = regexs(1) if regexm(address,"0 (.+)")

	replace address = subinstr(address,"BLK","B",.)
	replace address = subinstr(address,"LOT","L",.)

	replace address = subinstr(address,"UNIT","",.)
	replace address = subinstr(address,"COMPOUND","",.)

	g 		hnum = regexs(1) if regexm(address,"^([0-9]+)")
	replace hnum = regexs(1) if regexm(address,"^([0-9]+[A-Z])")
	replace hnum = regexs(1) if regexm(address,"^([A-Z][0-9]+)") 
	replace hnum = regexs(1) if regexm(address,"^([A-Z][0-9]+ [A-Z][0-9]+)") 
	replace hnum = regexs(1) if regexm(address,"^([A-Z] [0-9]+ [A-Z][0-9]+)") 
	replace hnum = regexs(1) if regexm(address,"^([A-Z][0-9]+ [A-Z] [0-9]+)") 
	replace hnum = regexs(1) if regexm(address,"^([A-Z] [0-9]+ [A-Z] [0-9]+)") 
	replace hnum = regexs(1) if regexm(hnum,"^0(.+)") 
	replace hnum = subinstr(hnum," ","",.)

end 


cap prog drop hnum_gen_cbms
prog define hnum_gen_cbms

	foreach var of varlist hnum street {
	replace `var' = subinstr(`var',".","",.)
	replace `var' = subinstr(`var',"-","",.)
	}

	g id = regexm(street,"^[0-9ABC]+$") & regexm(hnum,"^[A-Z]+$")
	g hnum1 = hnum
	g street1 = street

	replace street = hnum1 if id==1
	replace hnum = street1 if id==1
	drop id hnum1 street1

	* stnd_address hnum, g(hnum1) patpath("${subcode}")
	* drop hnum
	* ren hnum1 hnum

	replace hnum = subinstr(hnum,"BLK","B",.)
	replace hnum = subinstr(hnum,"LOT","L",.)
	replace hnum = subinstr(hnum,"UNIT","",.)
	replace hnum = subinstr(hnum,"COMPOUND","",.)

	g 		hnum2 = regexs(1) if regexm(hnum,"^([0-9]+)")
	replace hnum2 = regexs(1) if regexm(hnum,"^([0-9]+[A-Z])")
	replace hnum2 = regexs(1) if regexm(hnum,"^([A-Z][0-9]+)") 
	replace hnum2 = regexs(1) if regexm(hnum,"^([A-Z] [0-9]+ )") 
	replace hnum2 = regexs(1) if regexm(hnum,"^([A-Z][0-9]+ [A-Z][0-9]+)") 
	replace hnum2 = regexs(1) if regexm(hnum,"^([A-Z] [0-9]+ [A-Z][0-9]+)") 
	replace hnum2 = regexs(1) if regexm(hnum,"^([A-Z][0-9]+ [A-Z] [0-9]+)") 
	replace hnum2 = regexs(1) if regexm(hnum,"^([A-Z] [0-9]+ [A-Z] [0-9]+)")
	replace hnum2 = regexs(1) if regexm(hnum2,"^0(.+)")
	replace hnum2 = subinstr(hnum2," ","",.)

	drop hnum
	ren hnum2 hnum
end 





cap prog drop cleaning
prog define cleaning

	foreach var of varlist street address {
	replace `var' = subinstr(`var',"ST","",.)
	replace `var' = subinstr(`var',"RD","",.)
	replace `var' = subinstr(`var',".","",.)
	replace `var' = subinstr(`var',"-","",.)
	replace `var' = subinstr(`var',"PASAY CITY","",.)
	replace `var' = subinstr(`var',"PASAY C","",.)
	stnd_specialchar street, patpath("${subcode}")
	stnd_specialchar address, patpath("${subcode}")
	}

	stnd_specialchar firstname, patpath("${subcode}")
	stnd_specialchar lastname, patpath("${subcode}")
end



cap prog drop list_bill
prog define list_bill
	keep conacct $mlist
	* ren * *_bill
end

cap prog drop list_cbms
prog define list_cbms
	keep hcn $mlist
	* ren * *_cbms
end



* use "${database}clean/mcf/2011/mcf_112011.dta", clear
* 	* keep if ba=="0700" | ba=="1100"

* 	keep if city=="PASAY CITY"
* 	keep if billclass=="0001"
* 	sample 20
* 	stnd_address street, g(street1) patpath("${subcode}")




use "${database}clean/mcf/2011/mcf_112011.dta", clear
	keep if billclass=="0001"
	keep conacct lastname firstname street  address

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

cleaning

bys street: g SN=_N

preserve 
	keep if SN>20 & SN<.
	keep street
	g idm=_n
	save "${temp}street_master.dta", replace
restore


* reclink2 street using "${temp}street_master.dta", gen(match) idm(conacct) idu(idm) 
* ren street street1
* ren address street
* ren match match1
* ren Ustreet Ustreet1
* ren idm idm1
* drop _merge
* reclink2 street using "${temp}street_master.dta", gen(match) idm(conacct) idu(idm) 




hnum_gen
list_bill
duplicates drop conacct, force
duplicates drop lastname firstname street hnum address brgy, force

save "${temp}pasay_name.dta", replace













use "${data}backup_cbms/2008/pasay_hhfinal08.dta", clear

g hnum = regexs(1) if regexm(addr_l1,"(^[0-9]+)")
g street = regexs(1) if regexm(addr_l1,"^[0-9]+ (.+)")
ren addr_l1 address
keep hcn street hnum address
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
* duplicates drop hcn, force
g cbms_id=_n
save "${temp}cbms_name_08.dta", replace



use "${data}backup_cbms/2011/pasay_final2011_hh.dta", clear
keep hcn street hnum
g address=hnum+" "+street
* destring hnum, replace force
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
hnum_gen_cbms
g cbms_id=_n
save "${temp}cbms_name_11.dta", replace




* use "${temp}pasay_name.dta", clear 
* reclink2 address using "${temp}cbms_name_11.dta", gen(match) idm(conacct) idu(cbms_id) wmatch(10)   minscore(.7)


* st hhnum
use "${temp}pasay_name.dta", clear 

reclink2 brgy street hnum lastname firstname using "${temp}cbms_name_11.dta", gen(match) idm(conacct) idu(cbms_id) wmatch(10 10 7 10 5) req(brgy)  minscore(.7)



bys conacct: g CN=_N

save "${temp}rlink_11.dta", replace




/*



use "${temp}pasay_name.dta", clear 

reclink2 brgy address lastname firstname using "${temp}cbms_name_08.dta", gen(match) idm(conacct) idu(cbms_id) wmatch(10 10 10 5) req(brgy)  minscore(.7)

bys conacct: g CN=_N

save "${temp}rlink_08.dta", replace




use "${temp}rlink_08.dta", clear

duplicates drop conacct, force

keep conacct Ubrgy Ulastname Ufirstname Uaddress match cbms_id
 
ren (Ubrgy Ulastname Ufirstname Uaddress match cbms_id) (Ubrgy_08 Ulastname_08 Ufirstname_08 Uaddress_08 match_08 cbms_id_08)

save "${temp}rlink_08_m.dta", replace




use "${temp}rlink_11.dta", clear

duplicates drop conacct, force

keep conacct brgy lastname firstname address Ubrgy Ulastname Uaddress match cbms_id

merge 1:1 conacct using "${temp}rlink_08_m.dta"
	keep if _merge==3
	drop _merge

egen merge_max = rowmax(match match_08)

sort merge_max
keep if merge_max!=.

save "${temp}rlink_full.dta", replace



*** PREP CBMS DATA! 

* use "${data}backup_cbms/2011/pasay_final2011_mem.dta", clear
* ren source_water source_water_2011
* ren water water_2011
* ren ave_water bill_2011
* ren hsize hhsize_2011
* ren freq_wage hhemp_2011
* ren totin inc_2011
* g ofw_2011 = ofwcsh + ofwknd


use "${temp}rlink_full.dta", clear

	merge m:1 cbms_id using "${temp}cbms_name_11.dta"
	drop if _merge==2
	drop _merge

ren hcn hcn_11
drop cbms_id

ren cbms_id_08 cbms_id
	merge m:1 cbms_id using "${temp}cbms_name_08.dta"
	drop if _merge==2
	drop _merge

replace hcn = hcn_11 if match==merge_max

keep hcn conacct merge_max

save "${temp}rlink_con_full.dta", replace



use "${data}backup_cbms/2011/pasay_final2011_hh.dta", clear

g datest=string(int_date,"%18.0g")
g month = substr(datest,1,1) if length(datest)==7
replace month = substr(datest,1,2) if length(datest)==8
g year = substr(datest,-4,4)
destring month year, replace
g date=ym(year,month)

duplicates drop hcn, force

ren source_water source_water
ren water water
ren ave_water bill
ren hsize hhsize
ren freq_wage hhemp
ren totin inc
g ofw = ofwcsh + ofwknd

keep hcn source_water water bill hhsize hhemp inc ofw date

replace ofw =  ofw/12
replace ofw = . if ofw>60000
replace inc = inc/12
replace inc = . if inc>50000
replace bill = . if bill>6000

save "${temp}cbms_temp_2011.dta", replace





use "${data}backup_cbms/2008/pasay_hhfinal08.dta", clear

g datest=string(int_date,"%18.0g")
g month = substr(datest,1,1) if length(datest)==7
replace month = substr(datest,1,2) if length(datest)==8
g year = substr(datest,-4,4)
destring month year, replace
g date=ym(year,month)

ren water water
	replace water_price=. if water_price==0
	replace water_price= water_price/100

ren water_price bill
ren hsize hhsize
ren freq_wage hhemp
ren totin inc
g ofw = ofwcsh + ofwknd

keep hcn water bill hhsize hhemp inc ofw date

duplicates drop hcn, force


replace ofw =  ofw/12
replace ofw = . if ofw>60000
replace inc = inc/12
replace inc = . if inc>50000
replace bill = . if bill>6000

save "${temp}cbms_temp_2008.dta", replace


use "${temp}cbms_temp_2011.dta", clear

append using "${temp}cbms_temp_2008.dta"

save "${temp}cbms.dta", replace







* merge hcn using "${temp}rlink_con_full.dta"


* bys hcn: g CN=_N

* sum inc, detail

* sort hcn year
* by hcn: g inc_ch = inc[_n]-inc[_n-1]
* by hcn: g bill_ch = bill[_n]-bill[_n-1]
* by hcn: g ofw_ch = ofw[_n]-ofw[_n-1]
* by hcn: g hhsize_ch= hhsize[_n]-hhsize[_n-1]
* by hcn: g hhemp_ch = hhemp[_n]-hhemp[_n-1]


* xi: reg bill_ch inc_ch i.hhsize_ch i.hhemp_ch, cluster(hcn) robust









use "${data}paws/clean/full_sample_with_edu.dta", clear

duplicates drop conacct, force

	merge m:1 conacct using "${temp}rlink_full.dta"
	keep if _merge==3
	drop _merge

g amount = may_exp_extra
drop age
g age    = age_extra

destring amount hhsize hhemp age job, replace

keep conacct cbms_id cbms_id_08 amount hhsize hhemp age job match match_08 merge_max

ren (amount hhsize hhemp age job) (amount_paws hhsize_paws hhemp_paws age_paws job_paws)


	merge m:1 cbms_id using "${temp}cbms_name_11.dta"
	drop if _merge==2
	drop _merge
	drop lastname firstname street hnum address

	merge m:1 hcn using  "${temp}cbms_temp_2011.dta"
	drop if _merge==2
	drop _merge


replace amount_paws=. if amount_paws>5000
* corr hhsize hsize if match>.9


corr bill amount_paws
corr bill amount_paws if match>.9


/*


reg amount_paws inc

reg amount_paws inc if match>.9



reg amount_paws inc


corr ave_water amount_paws if match>.90 & match<.

corr ave_water amount_paws if match<.90


reg ave_water amount_paws if match>.9

reg ave_water totin if match>.9

reg amount_paws totin if match>.9

* use "${temp}cbms_name_11.dta", clear

* merge 1:m using 





* reclink2 brgy address lastname firstname using "${temp}cbms_name_11.dta", gen(match) idm(conacct) idu(hcn) wmatch(10 10 10 5) req(brgy)  minscore(.8)


* reclink2 brgy street hnum lastname firstname using "${temp}cbms_name_11.dta", gen(match) idm(conacct) idu(hcn) wmatch(10 10 2 10 5) req(brgy)  minscore(.8)





/*




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


