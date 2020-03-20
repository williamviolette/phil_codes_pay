

use "${temp}pay_day_bacoor.dta", clear
foreach v in  cal_1000 muntin para pasay qc_04 qc_09 qc_12 so_cal tondo val samp  {
	append using "${temp}pay_day_`v'.dta"
}

merge m:1 conacct using  "${temp}mru_total.dta"
keep if _merge==3
drop _merge

g day = day(date_day)

g o=1

gegen day_N=sum(o), by(day mru month year)
gegen day_N_max = max(day_N), by(mru month year)
g date_max_id = day if day_N==day_N_max
gegen date_max = max(date_max_id), by(mru month year)

g d_T = day - date_max
g d_T_abs=abs(d_T)
gegen d_T_m = mean(d_T_abs), by(mru month year)

g dm_ind =  day_N==day_N_max
gegen d_m = mean(dm_ind), by(mru month year)

gegen tagn=tag(mru month year)
keep if tagn==1

keep mru month year d_m d_T_m

g date = ym(year,month)
save "${temp}pay_day_stats.dta", replace

* gegen day_Nt = sum(o), by(day)
* gegen tagnt=tag(day)
* twoway scatter day_Nt day if tagnt==1


use "${temp}dc_mru_full.dta", clear
duplicates drop date mru, force

tsset mru date 
tsfill, full
replace mdc=0 if mdc==.

merge 1:1 mru date using "${temp}pay_day_stats.dta"
	keep if _merge==3
	drop _merge


sum d_m if mdc>5
sum d_m if mdc==0

sum d_T_m if mdc>5
sum d_T_m if mdc==0



