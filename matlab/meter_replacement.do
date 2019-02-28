* meter_replacement.do


use "/Users/williamviolette/Documents/Philippines/descriptives/output/pasay_mcf_2009_2015.dta", clear

drop if BLK_UTIL == "06" | BLK_UTIL=="6" | BLK_UTIL=="TCD"
drop if BLK_UTIL == "07" | BLK_UTIL=="7" | BLK_UTIL=="PCD"

g rep = regexm(MR_NOTE,"29")==1

keep conacct rep year month

destring year month, replace force
g date=ym(year,month)


sum rep, detail

disp `=r(mean)*7*12'

disp `=1/r(mean)'





