




use "${data}backup_cbms/2011/pasay_final2011_hh.dta", clear

g datest=string(int_date,"%18.0g")
g month = substr(datest,1,1) if length(datest)==7
replace month = substr(datest,1,2) if length(datest)==8
g year = substr(datest,-4,4)
destring month year, replace
g date=ym(year,month)

duplicates drop hcn, force

keep if source_water == 1

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
replace inc = . if inc>200000
replace inc = . if inc<100
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
replace inc = . if inc>200000
replace inc = . if inc<100
replace bill = . if bill>6000

save "${temp}cbms_temp_2008.dta", replace




