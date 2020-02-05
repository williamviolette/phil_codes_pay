




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




use "${temp}cbms_temp_2011.dta", clear

append using "${temp}cbms_temp_2008.dta"

egen sm=max(source_water), by(hcn)

sort hcn date
by hcn: g T=_n

gegen TM=max(T), by(hcn)

replace bill=. if bill==0

sort hcn T
foreach var of varlist hhemp inc bill hhsize {
	by hcn: g `var'_ch =`var'[_n]-`var'[_n-1]
}


reg inc_ch hhemp_ch hhsize_ch  if hhemp_ch>=-5 & hhemp_ch<=5 & hhsize_ch<=10 & hhsize_ch>=-10 & inc_ch>=-100000 & inc_ch<=100000, cluster(hcn) robust


sum inc if TM==2

sum inc_ch if inc_ch>=-100000 & inc_ch<=100000 & TM==2

sum inc_ch if TM==2


gegen inc_m = mean(inc), by(hcn)

g inc_dm = inc-inc_m

sum inc if TM==2
sum inc_dm if TM==2


reg inc_ch hhemp_ch hhsize_ch i.date if hhemp_ch>=-5 & hhemp_ch<=5 & hhsize_ch<=10 & hhsize_ch>=-10 & inc_ch>=-15000 & inc_ch<=15000, cluster(hcn) robust


sum inc
sum inc_ch

egen ic=max(inc_ch), by(hcn)

/*


reg bill_ch hhemp_ch hhsize_ch i.date  if hhemp_ch>=-5 & hhemp_ch<=5 & hhsize_ch<=10 & hhsize_ch>=-10 & bill_ch>=-5000 & bill_ch<=5000, cluster(hcn) robust




reg inc hhemp hhsize




* use "${data}backup_cbms/2011/pasay_final2011_mem.dta", clear


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
replace inc = . if inc>200000
replace inc = . if inc<100
replace bill = . if bill>6000

save "${temp}cbms_temp_2011_p.dta", replace




/*


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

keep hcn water bill hhsize hhemp inc ofw date pci

duplicates drop hcn, force


replace ofw =  ofw/12
replace ofw = . if ofw>60000
replace inc = inc/12
replace inc = . if inc>200000
replace inc = . if inc<100
replace bill = . if bill>6000

save "${temp}cbms_temp_2008_p.dta", replace






use "${temp}cbms_temp_2011_p.dta", clear

append using "${temp}cbms_temp_2008_p.dta"


replace inc=. if inc>100000

sort hcn date
by hcn: g T=_n

sort hcn T
foreach var of varlist hhemp inc bill hhsize {
	by hcn: g `var'_ch =`var'[_n]-`var'[_n-1]
}
by hcn: replace pci=pci[_n-1] if T==2



gegen pg = cut(pci), at(5000(500)40000)

gegen pn = tag(pg)

gegen im = mean(inc_ch), by(pg)

twoway scatter im pg if pn==1, xline(19807) xline(11528)





