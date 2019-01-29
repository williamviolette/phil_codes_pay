

* test tcd.do

set scheme s1mono

use "${temp}temp_descriptives.dta", clear

	keep if enough_time!=.
	keep if date>=600 & date<=630


	replace dc=0 if dc==.
	replace ar=ar+30
	replace ar=0 if ar==.

	sort conacct date
	by conacct: g ar_pre = ar[_n-1]
	by conacct: g tcd_id = dc[_n-1]==0 & dc[_n]==1
	by conacct: g ar_post = ar[_n+1]
	by conacct: g bal_pre = bal[_n-1]


	cap drop pay_post
	by conacct: g pay_post = pay if tcd_id[_n]==1 | tcd_id[_n-1]==1

	g pay_f = pay_post/bal_pre
	g pay_tot = pay_f>.8 & pay_f<1.5
	g pt1 =pay_post == bal_pre & pay_post!=.
	*  tcd_id[_n+1]==1 | 

	egen tcd_max=max(tcd_id), by(conacct)
	keep if tcd_max==1 

	* tab disc_count tcd_max : picks up a bunch of em

	cap drop ar_id
	cap drop AR 
	g ar_id = ar_post<=61 & tcd_id==1
	egen AR=max(ar_id), by(conacct)


	cap drop ar_pre_id
	cap drop AR_PRE
	g ar_pre_id = ar_pre if tcd_id==1
	egen AR_PRE=max(ar_pre_id), by(conacct)


	cap drop pay_id
	cap drop PR 
	cap drop PRF
	g pay_id = pay_post>800 & pay_post<.
	egen PR=max(pay_id), by(conacct)
	egen PRF=max(pay_tot), by(conacct)
	


	sum days_rec if AR==0 & days_rec<=14
	sum days_rec if AR==1 & days_rec<=14

	sum days_pay if AR==0 & days_rec<=14
	sum days_pay if AR==1 & days_rec<=14



	reg days_pay AR
	reg days_rec AR
	reg days_rec AR if days_rec<10
	reg enough_time AR

	reg days_pay PR
	reg days_rec PR
	reg days_rec PR if days_rec<10

	reg enough_time PR
	reg days_rec PR



*** THESE GUYS ARE ACTUALLY DISCONNECTED!!



global M = 12

cap program drop graph_trend
program define graph_trend

	local fe_var "`3'"
	local outcome "`1'"
	local T_high "${M}"
	local T_low "-${M}"
	preserve
		`5'
		cap drop T
		g T = .
		replace T = 0 if `2'==1
		forvalues v=1/$M {
		qui by conacct: replace T=-`v' if `2'[_n+`v']==1 
		}
		forvalues v=1/$M {
		qui by conacct: replace T=`v' if `2'[_n-`v']==1 
		}
		*** FULL ***
		* replace T=. if T<`=`T_low'' | T>`=`T_high''
		* qui sum T, detail
		* local time_min `=r(min)'
		* local time `=r(max)-r(min)'
		* replace T=99 if T==.
		* qui tab T, g(T_)
		*** NON-FULL ***
		keep if T>=`=`T_low'' & T<=`=`T_high''
		qui tab T, g(T_)
		qui sum T, detail
		local time_min `=r(min)'
		local time `=r(max)-r(min)'
		areg `outcome' T_* `6', absorb(`fe_var') cluster(`fe_var') r 
		*reg `outcome' T_* `6', cluster(`fe_var') r 
	   	parmest, fast
	   	g time = _n
	   	keep if time<=`=`time''
	   	replace time = time + `=`time_min'' - 1
	   	lab var time "Time"
    	*tw (scatter estimate time) || (rcap max95 min95 time)
    	tw (line estimate time, lcolor(black) lwidth(medthick)) ///
    	|| (line max95 time, lcolor(blue) lpattern(dash) lwidth(med)) ///
    	|| (line min95 time, lcolor(blue) lpattern(dash) lwidth(med)), ///
    	 graphregion(color(gs16)) plotregion(color(gs16)) xlabel(`=`T_low''(2)`=`T_high'') ///
    	 ytitle("`outcome'") xline(0)
    	 graph export  "${temp}trend_`4'.pdf", as(pdf) replace
   	restore
end

cap drop cm
g cm=c==.

foreach var of varlist ar ar_post ar_pre {
cap drop `var'_nm
g `var'_nm=`var'
replace `var'_nm=1 if cm==1
}

****** NEED NOTIFICATION!! THAT 

graph_trend cm tcd_id conacct tcd_testing "keep if AR==0"
graph_trend cm tcd_id conacct tcd_testing "keep if AR==1"


graph_trend c tcd_id conacct tcd_testing "" "i.date i.ar i.ar_post i.ar_pre if AR==1"
graph_trend c tcd_id conacct tcd_testing "" "i.date i.ar i.ar_post i.ar_pre if AR==0"

cap drop pay0
g pay0=pay
replace pay0=0 if pay0==.

graph_trend pay0 tcd_id conacct tcd_testing "" "i.date i.ar i.ar_post i.ar_pre if AR==1"

graph_trend pay0 tcd_id conacct tcd_testing "" "i.date i.ar i.ar_post i.ar_pre if AR==0"



graph_trend cm tcd_id conacct tcd_testing "" "i.date if AR==1"
graph_trend cm tcd_id conacct tcd_testing "" "i.date if AR==0"


graph_trend cm tcd_id conacct tcd_testing "" "i.date i.ar_nm i.ar_post_nm i.ar_pre_nm if AR==1"
graph_trend cm tcd_id conacct tcd_testing "" "i.date i.ar_nm i.ar_post_nm i.ar_pre_nm if AR==0"




graph_trend c tcd_id conacct tcd_testing "keep if AR==1" "i.date i.ar i.ar_post i.ar_pre"

graph_trend c tcd_id conacct tcd_testing "keep if AR==0" "i.date i.ar i.ar_post i.ar_pre"



graph_trend c tcd_id conacct tcd_testing "keep if AR==1 & AR_PRE==61" "i.ar_post i.ar_pre"
graph_trend c tcd_id conacct tcd_testing "keep if AR==1 & AR_PRE==61" "i.ar i.ar_post i.ar_pre"
graph_trend c tcd_id conacct tcd_testing "keep if AR==1 & AR_PRE==91" "i.ar i.ar_post i.ar_pre"

graph_trend c tcd_id conacct tcd_testing "keep if AR==1 & AR_PRE==121" "i.ar i.ar_post i.ar_pre"
graph_trend c tcd_id conacct tcd_testing "keep if AR==1 & AR_PRE>=151 & AR_PRE<." 



graph_trend cm tcd_id conacct tcd_testing "keep if days_rec<=1 & AR==1"

graph_trend cm tcd_id conacct tcd_testing "keep if days_rec>1 & AR==1"


graph_trend c tcd_id conacct tcd_testing "keep if days_rec<=1 & AR==1"

graph_trend c tcd_id conacct tcd_testing "keep if days_rec>1 & AR==1"







graph_trend cm tcd_id conacct tcd_testing "keep if enough_time==1"
graph_trend cm tcd_id conacct tcd_testing "keep if enough_time==0"


graph_trend cm tcd_id conacct tcd_testing "keep if AR==0"
graph_trend cm tcd_id conacct tcd_testing "keep if AR==1"



graph_trend c tcd_id conacct tcd_testing "keep if AR==0"
graph_trend c tcd_id conacct tcd_testing "keep if AR==1"




graph_trend cm tcd_id conacct tcd_testing "keep if PR==0"

graph_trend cm tcd_id conacct tcd_testing "keep if PR==1"



graph_trend cm tcd_id conacct tcd_testing "keep if AR==0"

graph_trend cm tcd_id conacct tcd_testing "keep if AR==1"





graph_trend c tcd_id conacct tcd_testing 





	* replace bal=0 if bal<=5
	* replace bal=. if bal>8000

	* g p = pay!=.
	* egen sp = sum(p), by(conacct)
	* keep if sp > 10
	
	* egen mp = max(pay), by(conacct)
	* keep if mp < 10000

	* egen mc = max(c), by(conacct)
	* drop if mc > 200

	* keep if date>=600
	* drop mp mc sp p

	* egen max_class = max(class), by(conacct)
	* keep if max_class==1
	* drop max_class

	* replace ar = ar + 30 if ar<=361
	* * replace ar = ar + 15 if ar <361
	* * 	replace ar = 361 + (541-361)/2 if ar==361
	* * 	replace ar = 541 + (720-540)/2 if ar==541
	* 	replace ar = 0 if ar==.
	* replace dc = 0 if dc==.
	* g cp = c!=.

	* merge  m:1 conacct using "${temp}mcf_ba.dta"
	* drop if _merge==2
	* drop _merge

	* replace amount =. if amount<10 | amount>5000




	/*


use "${temp}temp_descriptives_2.dta", clear
	drop if date==653


*** GET RID OF DISCONNECTED STATS
	replace ar = . if c==.
	replace bal = . if c==.




/*

*** Single HH's
	keep if SHH==1


*** Measure TCD  %%% ONLY KEEP THOSE THAT GET A DISCONNECTION NOTICE!! (CUS THEY ARE A DIFFERENT SAMPLE... BUT MATTER (OTHERWISE NEED INDIVIDUAL FIXED EFFECTS, WHICH ARE HARD!!))
	sort conacct date
	by conacct: g ar_pre = ar[_n-1]
	by conacct: g tcd_id = dc[_n-1]==0 & dc[_n]==1
	replace tcd_id = . if date<=602
	*replace tcd_id = 0 if ar_pre==0
	
	egen tcd_max=max(tcd_id), by(conacct)
	*keep if tcd_max==1 

*** Measure Payments
	global M1=12
 		sort conacct date
 		cap drop cn 
 		cap drop tid 
 		cap drop T1
		g T1 = .
		by conacct: g cn=_n if tcd_id==1
		g tid=cn if tcd_id==1
		replace T1 = 0 if tcd_id==1
		forvalues v=1/$M1 {
		qui by conacct: replace T1=-`v' if tcd_id[_n+`v']==1 
		qui by conacct: replace tid=cn[_n+`v'] if tcd_id[_n+`v']==1 
		}
		forvalues v=1/$M1 {
		qui by conacct: replace T1=`v' if tcd_id[_n-`v']==1 
		qui by conacct: replace tid=cn[_n-`v'] if tcd_id[_n-`v']==1 
		}



*** Testing





global M = 12

global t_ar = 61
		cap drop arT_${t_ar}
		g arT_${t_ar} = .
		replace arT_${t_ar} = 0 if ar==${t_ar}
		forvalues v=1/$M {
		qui by conacct: replace arT_${t_ar}=-`v' if ar[_n+`v']==${t_ar}
		}
		forvalues v=1/$M {
		qui by conacct: replace arT_${t_ar}=`v' if ar[_n-`v']==${t_ar}
		}

tab arT_${t_ar}, g(carT_)


cap program drop graph_trend
program define graph_trend

	local fe_var "`3'"
	local outcome "`1'"
	local T_high "${M}"
	local T_low "-${M}"
	preserve
		`5'
		cap drop T
		g T = .
		replace T = 0 if `2'==1
		forvalues v=1/$M {
		qui by conacct: replace T=-`v' if `2'[_n+`v']==1 
		}
		forvalues v=1/$M {
		qui by conacct: replace T=`v' if `2'[_n-`v']==1 
		}
		*** FULL ***
		* replace T=. if T<`=`T_low'' | T>`=`T_high''
		* qui sum T, detail
		* local time_min `=r(min)'
		* local time `=r(max)-r(min)'
		* replace T=99 if T==.
		* qui tab T, g(T_)
		*** NON-FULL ***
		keep if T>=`=`T_low'' & T<=`=`T_high''
		qui tab T, g(T_)
		qui sum T, detail
		local time_min `=r(min)'
		local time `=r(max)-r(min)'
		*areg `outcome' T_* , absorb(`fe_var') cluster(`fe_var') r 
		reg `outcome' T_* `6', cluster(`fe_var') r 
	   	parmest, fast
	   	g time = _n
	   	keep if time<=`=`time''
	   	replace time = time + `=`time_min'' - 1
	   	lab var time "Time"
    	*tw (scatter estimate time) || (rcap max95 min95 time)
    	tw (line estimate time, lcolor(black) lwidth(medthick)) ///
    	|| (line max95 time, lcolor(blue) lpattern(dash) lwidth(med)) ///
    	|| (line min95 time, lcolor(blue) lpattern(dash) lwidth(med)), ///
    	 graphregion(color(gs16)) plotregion(color(gs16)) xlabel(`=`T_low''(2)`=`T_high'') ///
    	 ytitle("`outcome'") xline(0)
    	 graph export  "${temp}trend_`4'.pdf", as(pdf) replace
   	restore
end


cap drop pp
g pp=pay
replace pp = 0 if pp==.



sort conacct date

cap drop ar_30
g ar_30 = ar==30

cap drop ar_61
by conacct: g ar_61= ar[_n]==61
*  & ar[_n-1]==30

cap drop ar_enter
by conacct: g ar_enter = ar[_n]==61 & ar[_n-1]<61
cap drop ar_leave
by conacct: g ar_leave = ar[_n]==61 & ar[_n-1]>61

tab ar_enter
tab ar_leave

graph_trend ar ar_61 conacct tcd_testing "keep if tcd_max==0"

graph_trend pp ar_61 conacct tcd_testing "keep if tcd_max==0"

graph_trend c ar_61 conacct tcd_testing "keep if tcd_max==0"



cap drop ar_91
by conacct: g ar_91 = ar==91 & ar[_n-1]==61


cap drop ar_121
g ar_121=ar==121

cap drop ar_151
g ar_151=ar==151


graph_trend c tcd_id conacct tcd_testing "keep if tcd_max==1"

graph_trend c tcd_id conacct tcd_testing "keep if tcd_max==1" "carT_*"



graph_trend pay tcd_id conacct tcd_testing "keep if tcd_max==1"


graph_trend pay ar_30 conacct tcd_testing "keep if tcd_max==0"


graph_trend pay ar_61 conacct tcd_testing "keep if tcd_max==0"


graph_trend pay ar_91 conacct tcd_testing "keep if tcd_max==0"


graph_trend pay ar_121 conacct tcd_testing "keep if tcd_max==0"



graph_trend c ar_30 conacct tcd_testing "keep if tcd_max==0"

graph_trend c ar_61 conacct tcd_testing "keep if tcd_max==0"

graph_trend pay ar_61 conacct tcd_testing "keep if tcd_max==0"


graph_trend c ar_91 conacct tcd_testing "keep if tcd_max==0"

graph_trend c ar_121 conacct tcd_testing "keep if tcd_max==0"

graph_trend c ar_151 conacct tcd_testing "keep if tcd_max==0"




