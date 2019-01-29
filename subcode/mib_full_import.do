

* smpm_mib_dec2012.csv
* mcf_samp_dec2012 - MIB for encoding.csv : not a lot of reactivations...
*   import delimited using "${mib}sampba_mib2.csv", clear delimiter(",")
*   import delimited using "${mib}tondo_mib_dec2012.csv", clear delimiter(",")
* use "${temp}temp_descriptives_2.dta", clear


* treat : 1,2,6
* control : north : 12, 9, 7, 10

foreach r in 1 2 6   7 9 10 12 {

#delimit;
local bill_query "
SELECT B.conacct, B.date, B.c
FROM billing_`r' AS B
JOIN (SELECT DISTINCT conacct FROM mcf_`r' WHERE dc==1) AS M
ON M.conacct = B.conacct
	";
#delimit cr;
odbc load, exec("`bill_query'")  dsn("phil") clear  

tsset conacct date
tsfill, full
save "${temp}bill_mib_`r'.dta", replace

#delimit;
local bill_query "
SELECT * 
FROM mcf_`r' WHERE dc==1
	";
#delimit cr;
odbc load, exec("`bill_query'")  dsn("phil") clear  

save "${temp}dc_mib_`r'.dta", replace


use "${temp}bill_mib_`r'.dta", clear

	merge 1:1 conacct date using "${temp}dc_mib_`r'.dta"
	drop if _merge==2
	drop _merge

g dnm=date if c!=.
egen dn=min(dnm), by(conacct)
drop if date<dn
drop dnm dn

save "${temp}mib_`r'.dta", replace
erase "${temp}bill_mib_`r'.dta"
erase "${temp}dc_mib_`r'.dta"

}



/*

load_data_coll 1 tondo 
load_data_coll 2 pasay 
load_data_coll 3 val 
load_data_coll 4 qc_09 
load_data_coll 5 qc_12 
load_data_coll 6 samp 
load_data_coll 7 qc_04 
load_data_coll 8 bacoor 
load_data_coll 9 so_cal 
load_data_coll 10 cal_1000 
load_data_coll 11 muntin 
load_data_coll 12 para

			*** KEY ***
novaliches 	0100	02/2011		613
so_cal 		0200	11/2010		610
val 		0300	02/2011		613
roosevelt 	0400	11/2010		610
samp		0500	05/2011		616
tondo 		0600	06/2011		617
pm			0700	10/2011		621
bacoor		0800	12/2011		623
commonwealth0900	03/2011		614
navotas		1000	11/2010		610
para		1100	10/2011		621
no_cal		1200	06/2011		617
quirino 	1300	11/2010		610
sm 			1500	10/2011		621
fairview	1600	03/2011		614
muntin		1700	10/2011		621

North 		1200, 0900, 0300			(1600, 0100)
Central A 	0200, 0400, 1000			(1300)
Central B	0500, 0700, 0600			(1500)
South		1100, 1700, 0800

*/


