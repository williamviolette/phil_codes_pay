* lfs.do

* 09 10 11 12 


global data_import = 1

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


