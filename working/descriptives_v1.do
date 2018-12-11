*descriptives.do




global data_prep   = 0 
global data_prep_2 = 0 


if $data_prep == 1 {
	use "${temp}ar_temp_pay.dta", clear
		duplicates drop conacct date, force
			merge 1:m conacct date using "${temp}bill_temp_pay.dta"
			drop _merge
		duplicates drop conacct date, force		

			merge 1:m conacct date using "${temp}mcf_temp_pay.dta"
			drop _merge
		duplicates drop conacct date, force

			merge 1:m conacct date using "${temp}coll_temp_pay.dta"
			drop _merge
		duplicates drop conacct date, force	

			merge 1:m conacct date using "${temp}bill_total_temp_pay.dta"
			drop _merge
		duplicates drop conacct date, force		

		tsset conacct date
		tsfill, full
			g cnn = date if c!=.
			egen cnn_min=min(cnn), by(conacct)
			drop if date<cnn_min
			drop cnn cnn_min
		g ts = ba==.
			egen bam=max(ba), by(conacct)
			replace ba = bam
			drop bam

			merge m:1 conacct using "${temp}paws_temp.dta"
			drop if _merge==2
			drop _merge

			merge m:1 conacct using "${temp}paws_dc.dta"
			drop if _merge==2
			drop _merge

	save "${temp}temp_descriptives.dta", replace
}



if $data_prep_2 == 1 {

use "${temp}temp_descriptives.dta", clear

	g p = pay!=.
	egen sp = sum(p), by(conacct)
	keep if sp > 10
	
	egen mp = max(pay), by(conacct)
	keep if mp < 10000

	egen mc = max(c), by(conacct)
	drop if mc > 200

	keep if date>=600
	drop mp mc sp p

	egen max_class = max(class), by(conacct)
	keep if max_class==1
	drop max_class

	replace ar = ar + 15 if ar <361
		replace ar = 361 + (541-361)/2 if ar==361
		replace ar = 541 + (720-540)/2 if ar==541
		replace ar = 0 if ar==.
	replace dc = 0 if dc==.
	g cp = c!=.

	merge  m:1 conacct using "${temp}mcf_ba.dta"
	drop if _merge==2
	drop _merge

		replace amount =. if amount<10 | amount>5000

save "${temp}temp_descriptives_2.dta", replace

}



use "${temp}temp_descriptives_2.dta", clear
	drop if date==653
*	keep if date>=600


g price = 100 if c<10
replace price = 100+ 20*(c-10) if c>=10 & c<=20
replace price = 100+ 20*(10) + 30*(c-20) if c>=20 & c<=40
replace price = 100+ 20*(10) + 30*(20) + 40*(c-40) if c>=40


g cmiss = c==.

* egen max_cmiss = max(cmiss), by(conacct)

sort conacct date
by conacct: g tcd_id = dc[_n-1]==0 & dc[_n]==1
by conacct: g dc_id = cmiss[_n-1]==0 & cmiss[_n]==1 & cmiss[_n+1]==1  & cmiss[_n+2]==1  & cmiss[_n+3]==1  & cmiss[_n+4]==1  & cmiss[_n+5]==1 

by conacct: g dc_yr = cmiss[_n-1]==0 & cmiss[_n]==1 & cmiss[_n+1]==1  & cmiss[_n+2]==1  & cmiss[_n+3]==1  & cmiss[_n+4]==1  & cmiss[_n+5]==1 & cmiss[_n+6]==1  & cmiss[_n+7]==1  & cmiss[_n+8]==1  & cmiss[_n+9]==1  & cmiss[_n+10]==1   & cmiss[_n+11]==1 
 

replace tcd_id = . if date<=602

g tcd_date = date if tcd_id == 1
egen tcd = min(tcd_date), by(conacct)

g T = date-tcd


g cid = T>=-10 & T<=10 & c>0 & c<.
egen CS = sum(cid), by(conacct)


egen max_ar = max(ar), by(conacct)

egen cmiss_tot=sum(cmiss), by(conacct)

g p=pay!=. & pay!=0

g pay0=pay
replace pay0=0 if pay==.



sum p if cmiss_tot<=4 
sum p if cmiss_tot<=4  & max_ar<=196 

sum pay if cmiss_tot<=4  & pay<3000 
sum pay if cmiss_tot<=4  & pay<3000 & max_ar<=196 

sum ar if cmiss_tot<=4 
sum ar if cmiss_tot<=4  & max_ar<=300
sum ar if cmiss_tot<=4  & max_ar<=196 

sum amount if cmiss_tot<=4  & amount<3000
sum amount if cmiss_tot<=4  & max_ar<=300 & amount<3000
sum amount if cmiss_tot<=4  & max_ar<=196 & amount<3000 



g c_pre = c if  date+4<tcd_date

egen cm_pre=mean(c_pre), by(conacct)
egen sd_pre=sd(c_pre), by(conacct)

g tcdi = tcd>0 & tcd<.


 ** predict key attributes

reg enough_time c low_skill SHH SHO house_1 house_2 age hhemp hhsize, cluster(conacct)

reg days_pay c low_skill SHH SHO house_1 house_2 age hhemp hhsize if days_pay<=60, cluster(conacct)


* reg days_pay c low_skill SHH SHO house_1 house_2 age hhemp hhsize, cluster(conacct)





cap program drop graph_trend
program define graph_trend
	local fe_var "`2'"
	local outcome "`1'"
	local T_high "36"
	local T_low "-36"
	preserve
		`4'
		`5'
		keep if T>=`=`T_low'' & T<=`=`T_high''
		qui tab T, g(T_)
		qui sum T, detail
		local time_min `=r(min)'
		local time `=r(max)-r(min)'
		areg `outcome' T_* i.date, absorb(`fe_var') cluster(`fe_var') r 
	   	parmest, fast
	   	g time = _n
	   	keep if time<=`=`time''
	   	replace time = time + `=`time_min''
	   	lab var time "Time"
    	*tw (scatter estimate time) || (rcap max95 min95 time)
    	tw (line estimate time, lcolor(black) lwidth(medthick)) ///
    	|| (line max95 time, lcolor(blue) lpattern(dash) lwidth(med)) ///
    	|| (line min95 time, lcolor(blue) lpattern(dash) lwidth(med)), ///
    	 graphregion(color(gs16)) plotregion(color(gs16)) xlabel(`=`T_low''(2)`=`T_high'') ///
    	 ytitle("`outcome'") xline(0)
    	 graph export  "${temp}trend_`3'.pdf", as(pdf) replace
   	restore
end

*** TEST FOR LEAKS

* disc_count days_pay days_rec leak over_charge enough_time
graph_trend price conacct price_test_d


graph_trend amount conacct amount_d "keep if max_ar<196 & cm_pre<50 & CS==21 "

graph_trend amount conacct amount_d

graph_trend c conacct c_d

graph_trend dc conacct dc_d

graph_trend pay conacct dc_pay

graph_trend ar conacct ar_d  "keep if max_ar<150"




tab  disc_count tcdi, miss

tab  over_charge tcdi, miss


g tight = max_ar<=150 & CS==21 & cm_pre<50 

egen dc_max=max(dc), by(conacct)






graph_trend c conacct c_desc_leak "keep if max_ar<150"



graph_trend c conacct c_desc_tight " keep if tight==1 "

graph_trend c conacct c_desc_no_tight " keep if tight==0 "

graph_trend c conacct c_desc_dc " keep if CS<=10 "






graph_trend c conacct cc_test "keep if enough_time==1"
graph_trend pay conacct cc_test "keep if enough_time==1"
graph_trend ar conacct cc_test "keep if enough_time==1"

graph_trend c conacct cc_test "keep if enough_time==0"
graph_trend pay conacct cc_test "keep if enough_time==0"


graph_trend c conacct cc_test "keep if days_pay>=0 & days_rec<=5"
graph_trend c conacct cc_test "keep if days_rec>=6 & days_rec<."




graph_trend c conacct cc_test "keep if days_rec>=0 & days_rec<=1"
graph_trend pay conacct cc_test "keep if days_rec>=0 & days_rec<=1"

graph_trend c conacct cc_test "keep if days_rec>=2 & days_rec<=50"
graph_trend pay conacct cc_test "keep if days_rec>=2 & days_rec<=50"


graph_trend c conacct cc_test "keep if enough_time==1"




graph_trend c conacct c_desc_leak "keep if max_ar<196 & CS==21 & cm_pre<50 "



graph_trend c conacct c_desc_leak "keep if max_ar<196 & CS==21 & cm_pre<50 "



graph_trend c conacct c_desc_leak "keep if max_ar<196 & CS==21 & cm_pre<50 "



graph_trend c conacct c_desc_leak "keep if max_ar<196 & CS==21 & cm_pre<30 & c>cm_pre-3*sd_pre & c<cm_pre+3*sd_pre"


graph_trend c conacct c_desc_leak "keep if max_ar<196 & CS==21 & c>cm_pre-3*sd_pre & c<cm_pre+3*sd_pre"

graph_trend c conacct c_desc_leak "keep if max_ar<196 & CS==21 & c>cm_pre-2*sd_pre & c<cm_pre+2*sd_pre"

graph_trend c conacct c_desc_leak "keep if max_ar<196 & CS==21 & c>cm_pre-1.5*sd_pre & c<cm_pre+1.5*sd_pre"


graph_trend dc_id conacct dc_desc

graph_trend dc_yr conacct dc_yr_desc


graph_trend amount conacct amt_desc "keep if max_ar<196 & amount<3000 & CS==21"

graph_trend c conacct c_desc "keep if max_ar<=196 & CS==21"

graph_trend pay conacct pay_desc "keep if max_ar<196 & pay<5000 & CS==21"

graph_trend pay0 conacct pay0_desc "keep if max_ar<196 & pay0<5000 & CS==21"

graph_trend ar conacct ar_desc "keep if max_ar<196 & pay<5000 & CS==21"


graph_trend cmiss conacct cmiss_desc

graph_trend cmiss conacct cmiss_desc "keep if max_ar<=196"

graph_trend c conacct c_desc "drop if c<=10"



graph_trend ar conacct ar_desc "keep if max_ar<=196"



g pay_soon = 1 if days_pay<=5 
replace pay_soon = 0 if days_pay>5 & days_pay<.



g poor = low_skill==1
egen poorm=max(poor), by(conacct)
drop poor
ren poorm poor


cap program drop graph_trend2
program define graph_trend2
	local fe_var "`2'"
	local outcome "`1'"
	local T_high "24"
	local T_low "-24"
	preserve
		`5'
		`6'
		keep if T>=`=`T_low'' & T<=`=`T_high''
		qui tab T, g(T_)
		
		drop T_1
		foreach var of varlist T_* {
			g `var'_no = `var'==1 & `3'==0
			g `var'_yes = `var'==1 & `3'==1
			drop `var'
		}
		qui sum T, detail
		local time_min `=r(min)'
		local time `=r(max)-r(min)'
		qui areg `outcome' *_no *_yes i.date, absorb(`fe_var') cluster(`fe_var') r 
	   	parmest, fast
	   		save "${temp}temp_est.dta", replace

	   		use "${temp}temp_est.dta", clear
				g time = _n
	   			keep if time<=`=`time''	   		
	   			replace time = time + `=`time_min''
	   			keep estimate time max95 min95
	   			ren estimate estimate_no
	   			ren max95 max95_no 
	   			ren min95 min95_no
	   		save "${temp}temp_est_no.dta", replace

	   		use "${temp}temp_est.dta", clear
				g time = _n
	   			drop if time<=`=`time''
	   			drop time
	   			g time = _n
	   			keep if time<=`=`time''   		
	   			replace time = time + `=`time_min''
	   			keep estimate time max95 min95
	   			ren estimate estimate_yes
	   			ren max95 max95_yes 
	   			ren min95 min95_yes
	   		
	   			merge 1:1 time using "${temp}temp_est_no.dta"
	   			drop _merge

	   	lab var time "Time"
    	*tw (scatter estimate time) || (rcap max95 min95 time)
    	tw (line estimate_no time, lcolor(black) lwidth(medthick)) ///
    	|| (line max95_no time, lcolor(blue) lpattern(dash) lwidth(med)) ///
    	|| (line min95_no time, lcolor(blue) lpattern(dash) lwidth(med)) ///
    	(line estimate_yes time, lcolor(red) lwidth(medthick)) ///
    	|| (line max95_yes time, lcolor(green) lpattern(dash) lwidth(med)) ///
    	|| (line min95_yes time, lcolor(green) lpattern(dash) lwidth(med)), ///
    	 graphregion(color(gs16)) plotregion(color(gs16)) xlabel(`=`T_low''(2)`=`T_high'') ///
    	 ytitle("`outcome'")
    	 graph export  "${temp}trend2_`4'.pdf", as(pdf) replace
    	 erase "${temp}temp_est.dta"
    	 erase "${temp}temp_est_no.dta"
    restore
end



graph_trend2 c conacct pay_soon pay_soon "keep if max_ar<196 & CS==21 & cm_pre<50 "


graph_trend2 c conacct pay_soon pay_soon " keep if max_ar<196 & CS>=18 & cm_pre<50"




graph_trend2 c conacct pay_soon pay_soon 


graph_trend2 dc conacct pay_soon pay_soon "keep if max_ar<196 & CS==21 & cm_pre<50 "


graph_trend2  c conacct enough_time enough_time 


graph_trend2  c conacct pay_soon pay_soon



graph_trend2  c conacct enough_time enough_time 




graph_trend2  c conacct poor c_poor "keep if CS==21 & max_ar<196"


graph_trend2  c conacct poor c_poor "keep if CS==21 & max_ar<196"






graph_trend2  c conacct enough_time enough_time 



graph_trend2  pay conacct poor pay_poor "keep if pay<=2000"




