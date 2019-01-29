*descriptives.do

*** SET UP

set scheme s1mono

cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end

do "${subcode}table_print.do"

import delimited using "${moments}y_avg.csv", clear delimiter(",")
sum v1
global y_avg = `r(mean)'

import delimited using "${moments}save_avg.csv", clear delimiter(",")
sum v1
global save_avg = `r(mean)'



use "${temp}temp_descriptives_2.dta", clear
	drop if date==653


*** GET RID OF DISCONNECTED STATS
	replace ar = . if c==.
	replace bal = . if c==.

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


* cap drop pay_post_id
* cap drop pay_post
* g pay_post_id = pay>0 & pay<. & T1==1
* egen pay_post=max(pay_post_id), by(conacct tid)

cap drop ar_post_id
cap drop ar_post
g ar_post_id = ar if T1==1
egen ar_post=max(ar_post_id), by(conacct)  

global ar_thresh = 31

*** THIS IS THE CRUCIAL SAMPLE!
g key_sample = tcd_max==1 & ar_post<=$ar_thresh




*** Descriptives measures
	egen total_notices = sum(tcd_id), by(conacct)
	g cm = c==.
	egen total_cmiss = sum(cm), by(conacct)
	sort conacct date
	by conacct: g first=_n==1
	g o=1
		g fcat=1 if tcd_max==1 & ar_post<= $ar_thresh
		replace fcat=2 if tcd_max==1 & ar_post> $ar_thresh
		replace fcat=3 if tcd_max==0
	egen fs=sum(first), by(fcat)

	g p0 = pay>0 & pay<.

	egen os = sum(o)
	egen tfs = sum(first)



* do "${subcode}descriptive_table_print_3_groups.do"

* do "${subcode}descriptive_table_print_3_groups.do"

*** Export average disconnection








tab ar if tcd_id==1

*** Report overall rate!
* sum tcd_id

* sum tcd_id if


*** Missing C : (<=20) drop 5%
	* g cmiss = c==.
	* egen cms=sum(cmiss), by(conacct)
	* keep if cms<=20
	* drop cms



		*** this is important ! 

		** TCD DISTRIBUTION
		* egen tcd_m_ar= mean(tcd_id), by(ar)
		* bys ar: g arn=_n
		* scatter tcd_m_ar ar if arn==1
		*** looks really good!!!

*** Loan Max : (<=451) drop 5%
	* egen ar_max=max(ar), by(conacct) 
	* keep if ar_max<=451
	* drop ar_max	
*** Keep only accounts with pre-106 disconnections
	* g ar_dc = ar if tcd_id==1
	* egen arm = max(ar_dc), by(conacct)
	* drop if arm>106 & arm<.
*** EXPORT SIMPLE MOMENTS !!! ***
	* browse conacct date ar pay c dc amount bal




*** SET UP 
	g p_avg = amount/c
	sum p_avg
	write "${moments}p_avg.csv" `=r(mean)' 0.1 "%12.0g"
	write "${tables}p_avg.tex" `=r(mean)' 0.1 "%12.0g"

	reg p_avg c
	matrix define p_reg=e(b)
	scalar define p_int=p_reg[1,2]
	scalar define p_slope=p_reg[1,1]

	write "${moments}p_int.csv" `=p_int' 0.001 "%12.0g"
	write "${moments}p_slope.csv" `=p_slope' 0.001 "%12.0g"

	write "${tables}p_int.tex" `=p_int' 0.001 "%12.0g"
	write "${tables}p_slope.tex" `=p_slope' 0.001 "%12.0g"

	sum tcd_id if ar>0
	write "${moments}prob_caught.csv" `=r(mean)' 0.0001 "%12.4g"
	write "${tables}prob_caught.tex" `=r(mean)' 0.0001 "%12.4g"


	*** TRUE MOMENTS 


	sum c
	write "${moments}c_avg.csv" `=r(mean)' 0.1 "%12.0g"
	write "${tables}c_avg.tex" `=r(mean)' 0.1 "%12.0g"

	egen c_i = mean(c), by(conacct)
	g c_norm = c -c_i
	sum c_norm 
	write "${moments}c_std.csv" `=r(sd)' 0.1 "%12.0g" 
	write "${tables}c_std.tex" `=r(sd)' 0.1 "%12.0g" 

	*** need to have future balance!  ( also need to correct for price appreciation and non-linear tariff )
	sort conacct date 
	by conacct: g bal_t1 = bal[_n+1]
	replace bal_t1 = 0 if bal_t1==. 
	* yes, but think carefully... (no because we need to realize that earlier there's stuff going on)

	sum bal_t1
	write "${moments}bal_avg.csv" `=r(mean)' 0.1 "%12.0g"
	write "${tables}bal_avg.tex" `=r(mean)' 0.1 "%12.0g"

	egen bal_i = mean(bal_t1), by(conacct)
	g bal_norm = bal_t1 - bal_i
	sum bal_norm 
	write "${moments}bal_std.csv" `=r(sd)' 0.1 "%12.0g"
	write "${tables}bal_std.tex" `=r(sd)' 0.1 "%12.0g"

	corr bal_t1 c
	matrix C = r(C)
	local cv "C[1,2]"
	write "${moments}bal_corr.csv" `cv' 0.001 "%12.0g"
	write "${tables}bal_corr.tex" `cv' 0.001 "%12.0g"


	global M = 6
		g T = .
		replace T = 0 if tcd_id==1
		forvalues v=1/$M {
		qui by conacct: replace T=-`v' if tcd_id[_n+`v']==1 
		sum c if T==-`v'
		}
		forvalues v=1/$M {
		qui by conacct: replace T=`v' if tcd_id[_n-`v']==1 
		sum c if T==`v'
		}

	sum c if T==-2 
	write "${moments}c_avg_pre.csv" `=r(mean)' 0.1 "%12.0g"	
	write "${tables}c_avg_pre.tex" `=r(mean)' 0.1 "%12.0g"	

	sum c if T==1
	write "${moments}c_avg_dc.csv" `=r(mean)' 0.1 "%12.0g"	
	write "${tables}c_avg_dc.tex" `=r(mean)' 0.1 "%12.0g"	

	g cz=c
	replace cz=0 if c==.




	* egen tcds = sum(tcd_id), by(conacct) 
	*  **  this is good! (repeat TCDs)
	*  tab ar if tcd_id==1
	*  tab ar date if tcd_id==1
	* tab tcd_id if ar>=15
	* replace tcd_id = 0 if ar>76
	* tab tcd_id
	* tab tcd_id if ar>=15
	* tab tcd_id if ar>=46
	* tab tcd_id if ar>=76 // bit of a threshold here
	* tab tcd_id if ar>=106
	* tab tcd_id if ar>=136

	** why don't we see anything for ar 46??

	*** heterogeneity by debt


global M = 12

cap program drop graph_trend
program define graph_trend

	local fe_var "`2'"
	local outcome "`1'"
	local T_high "${M}"
	local T_low "-${M}"
	preserve
		`4'
		`5'
		`6'
		cap drop T
		g T = .
		replace T = 0 if tcd_id==1
		forvalues v=1/$M {
		qui by conacct: replace T=-`v' if tcd_id[_n+`v']==1 
		}
		forvalues v=1/$M {
		qui by conacct: replace T=`v' if tcd_id[_n-`v']==1 
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
		reg `outcome' T_* , cluster(`fe_var') r 
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




 sum bal if tcd_id==1

cap drop cmiss
g cmiss=c==.


graph_trend c     conacct c_nopay "keep if key_sample==1"
graph_trend c     conacct c_pay "keep if key_sample==0"


graph_trend pay   conacct pp

graph_trend pay   conacct c_nopay "keep if key_sample==1"
graph_trend pay   conacct c_pay "keep if key_sample==0"

graph_trend cmiss conacct c_nopay "keep if key_sample==1"
graph_trend cmiss conacct c_pay "keep if key_sample==0"




graph_trend c conacct c_nopay "keep if key_sample==1"
graph_trend c conacct c_pay "keep if pay_post ==1"


graph_trend cmiss conacct cmissing_nopay "keep if pay_post ==0"
graph_trend cmiss conacct cmissing_pay "keep if pay_post ==1"

graph_trend cmiss conacct cmissing_ar "keep if ar_post<=60"
graph_trend cmiss conacct cmissing_noar "keep if ar_post>60 & ar_post<."


graph_trend c conacct c_nopay "keep if pay_post ==0"
graph_trend c conacct c_pay "keep if pay_post ==1"

graph_trend cz conacct cz_nopay "keep if pay_post ==0"
graph_trend cz conacct cz_pay "keep if pay_post ==1"




graph_trend cmiss conacct cmissing

graph_trend ar conacct ar


graph_trend c conacct c_dcleanall 

graph_trend cz conacct cz_dcleanall 


graph_trend c conacct c_dclean0   "drop if tcd_id==1 & ar!=0"
graph_trend c conacct c_dclean15  "drop if tcd_id==1 & ar!=15"
graph_trend c conacct c_dclean46  "drop if tcd_id==1 & ar!=46"
graph_trend c conacct c_dclean76  "drop if tcd_id==1 & ar!=76"
graph_trend c conacct c_dclean106 "drop if tcd_id==1 & ar!=106"


graph_trend c conacct c_bal_5_200   "drop if tcd_id==1     & (bal<5 | bal>200)"
graph_trend c conacct c_bal_400_800  "drop if tcd_id==1    & (bal<400 | bal>800)"
graph_trend c conacct c_bal_800_1200  "drop if tcd_id==1   & (bal<800 | bal>1200)"
graph_trend c conacct c_bal_1200_2400   "drop if tcd_id==1 & (bal<1200 | bal>2400)"
graph_trend c conacct c_bal_2400_5000  "drop if tcd_id==1  & (bal<2400 | bal>7000)"



*** scales pretty dramatically with the extent of 



preserve
		g T = .
		g ar_id = ar if tcd_id==1
		replace T = 0 if tcd_id==1
		forvalues v=1/$M {
		qui by conacct: replace T=-`v' if tcd_id[_n+`v']==1 
		qui by conacct: replace ar_id = ar_id[_n+`v']  if tcd_id[_n+`v']==1 
		}
		forvalues v=1/$M {
		qui by conacct: replace T=`v' if tcd_id[_n-`v']==1 
		qui by conacct: replace ar_id=ar_id[_n-`v']  if tcd_id[_n-`v']==1 
		}

	tab ar_id, g(AR)
	*drop AR1

	g T_pre = T
	replace T_pre = 0 if T>0
	g T_post = T
	replace T_post = 0 if T<=2 

	g TREAT = T>0 & T<=2

	foreach var of varlist AR*  {
		g TREAT_A_`var' = `var'*TREAT
		g T_pre_A_`var' = `var'*T_pre
		g T_post_A_`var' = `var'*T_post
	}

	areg c TREAT_A_* T_pre_A_* T_post_A_* i.date, absorb(conacct)  cluster(conacct) r
restore







*** Frequency of disconnection

g pt = amount/c
sum pt if pt<45

 * generate and export moments ! *





