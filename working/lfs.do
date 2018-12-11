* lfs.do

* 09 10 11 12 


global data_import = 0

if $data_import == 1 {

local yrs "09 10 11 12 13 14 15"
* local yrs "09 10 11"
local months "apr jan jul oct"
foreach v in `yrs' {
	foreach m in `months' {
		import delimited using "${lfs}lfs`m'`v'-puf.csv", clear delimiter(",")
		keep if reg==13
		save "${lfs}lfs`m'`v'.dta", replace
	}
}


local yrs "09 10 11 12 13 14 15"
local months "apr jan jul oct"
foreach v in `yrs' {
	foreach m in `months' {
		if "`v'"=="09" & "`m'"=="apr" {
			use "${lfs}lfs`m'`v'.dta", clear
		}
		else {
			append using "${lfs}lfs`m'`v'.dta", force
		}
	}
}
save "${lfs}lfs.dta", replace


local yrs "16"
local months "jul"
		import delimited using "${lfs}lfs`months'`yrs'-puf.csv", clear delimiter(",")
		keep if pufreg==13
save "${lfs}lfs`months'`yrs'.dta", replace

}




use "${lfs}lfs.dta", clear

	g pst=string(psu)
	g mun=substr(pst,1,2)
	destring mun, replace force
	g date = ym(svyyr,svymo)

	keep if c05_rel == 1
	egen age = cut(c07_age), at(20(10)70)
	drop if age==.

	local outcomes "wage emp hrs"
	** HOURS 
	ren c22_phrs hrs
	replace hrs=. if hrs==0


	** EMPLOYMENT
	g emp = c13_work==1


	** WAGE
	ren c27_pbsc wage
	replace wage=. if wage>2000


	foreach var in `outcomes' {
		egen `var'_m=mean(`var'), by(age mun date)
		drop `var'
		ren `var'_m `var'
	}

	keep `outcomes' age mun date
	duplicates drop age mun date, force

save "${lfs}output.dta", replace




/*

*** CAN'T GET THIS MERGE TO WORK! MAYBE EMAIL?


use "${lfs}lfsjul16.dta", clear
	keep  pufprv pufpsu pufprrcd
	g psu = pufprv*1000 + pufpsu
	*ren pufpsu psu
	duplicates drop psu, force
save "${lfs}psu_temp.dta", replace



use "${lfs}lfsjul16.dta", clear
	keep pufhhnum pufprv pufpsu
	g o=1
	egen hs16=sum(o), by(pufhhnum)
	drop o
	ren pufhhnum hhnum
	duplicates drop hhnum, force
save "${lfs}hhnum_temp.dta", replace




 * use "${lfs}lfs.dta", clear

 *	merge m:1 psu using "${lfs}psu_temp.dta"




/*

use "${lfs}lfs.dta", clear

	merge m:1 hhnum using "${lfs}hhnum_temp.dta"

g o=1
egen hs=sum(o), by(hhnum svyyr svymo)



g psus=string(psu)
g psut = substr(psus,1,2)
destring psut, replace force

corr  hs pufhhsize

corr  hs pufhhsize


/*
   PUFPRRCD |      Freq.     Percent        Cum.
------------+-----------------------------------
       3900 |      1,653        6.48        6.48
       7401 |      1,599        6.26       12.74
       7402 |      1,654        6.48       19.22
       7403 |      1,511        5.92       25.14
       7404 |      1,420        5.56       30.70
       7405 |        456        1.79       32.49
       7501 |      1,718        6.73       39.22
       7502 |      1,754        6.87       46.09
       7503 |      1,834        7.18       53.27
       7504 |      1,605        6.29       59.56
       7600 |        583        2.28       61.84
       7601 |      1,789        7.01       68.85
       7602 |      1,491        5.84       74.69
       7603 |      1,474        5.77       80.47
       7604 |      1,547        6.06       86.53
       7605 |      1,597        6.26       92.78
       7607 |      1,842        7.22      100.00
------------+-----------------------------------
      Total |     25,527      100.00
