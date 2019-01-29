* test tcd.do

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



**** DO A BETTER JOB OF ROOTING OUT PERMANENT DISCONNECTIONS?!

use "${temp}temp_descriptives_2.dta", clear
	drop if date==653

*** Single HH's
	keep if SHH==1

*** Measure TCD  %%% ONLY KEEP THOSE THAT GET A DISCONNECTION NOTICE!! (CUS THEY ARE A DIFFERENT SAMPLE... BUT MATTER (OTHERWISE NEED INDIVIDUAL FIXED EFFECTS, WHICH ARE HARD!!))
	sort conacct date
	by conacct: g ar_pre = ar[_n-1]
	by conacct: g tcd_id = dc[_n-1]==0 & dc[_n]==1
	by conacct: g ar_post = ar[_n+1]
	by conacct: g bal_pre = bal[_n-1]
	replace tcd_id = . if date<=602

	egen tcd_max=max(tcd_id), by(conacct)
	egen tcds=sum(tcd_id), by(conacct)
	keep if tcd_max==1 



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

		forvalues v=0/10 {
			by conacct: g cm`v'_id = c==. & tcd_id[_n-`v']==1
			egen cm`v' = max(cm`v'_id), by(conacct tid)
			drop cm`v'_id
		}

	egen AR = max(ar_pre), by(conacct tid)
	egen BAL = max(bal_pre), by(conacct tid)

*** 1) GET RID OF DISCONNECTORS
	global dc_cond = ""
	global dc_c = 0
	forvalues r=6/10 {
		global dc_c= $dc_c + 1
		if $dc_c==1 {
			global dc_cond = " ${dc_cond}  cm`r'==1  "
		}
		else {
			global dc_cond = " ${dc_cond}  &  cm`r'==1 "
		}
	}

	g dc_var_id = $dc_cond
	egen dc_var = max(dc_var_id), by(conacct)
	drop if dc_var==1

*** get rid of those that are over 5 disconnected at the end *** this might be key!!!
	cap drop cN
	cap drop cn6
	sort conacct date
	by conacct: g cN=_n>=(_N-6) & c==.
	egen cn6=sum(cN), by(conacct)
	drop if cn6>=5

	g cm=c==.
	egen cms=sum(cm), by(conacct)

*** get rid of those that spend over a year disconnected in the sample instead?!
	*** NEED THE 600 correction!!!!!!!


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

	sum c, detail
	write "${moments}c_avg.csv" `=r(mean)' 0.1 "%12.0g"
	write "${tables}c_avg.tex" `=r(mean)' 0.1 "%12.0g"

	egen c_i = mean(c), by(conacct)
	g c_norm = c -c_i
	sum c_norm, detail
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


	forvalues i=1/5 {
		sum cm`i', detail
		write "${moments}cm`i'.csv" `=r(mean)' 0.0001 "%12.4g"
	}
	*sum cm0
	sum cm1
	sum cm2
	sum cm3
	sum cm4
	sum cm5


	* do "${subcode}descriptive_table_print.do"
	* do "${subcode}descriptive_table_print_3_groups.do"





/*



** lag it a bit because of how the D works in the matlab code?

	sum cm1 if BAL>500 & BAL<.
	sum cm2 if BAL>500 & BAL<.
	sum cm3 if BAL>500 & BAL<.
	sum cm4 if BAL>500 & BAL<.

	sum cm1 if AR>121 & AR<.
	sum cm2 if AR>121 & AR<.
	sum cm3 if AR>121 & AR<.
	sum cm4 if AR>121 & AR<.

	* only like 10%?



	g c0 = cm0==1 & cm1==0
	g c1 = cm0==1 & cm1==1 & cm2==0



	g cm12 = cm1==1 & cm2==1
	g cm123 = cm1==1 & cm2==1


	sum 

	g dc = cm5==


	g m_id = c==. & (T1==0 | T1==1 | T1==2)
	egen ms=max(m_id), by(conacct)




*** Testing

	cap drop ar_id
	cap drop AR 
	g ar_id = ar_post<=31 & tcd_id[_n]==1
	egen AR=max(ar_id), by(conacct)



sort conacct date
global M = 24


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

		*areg `outcome' T_* `6', absorb(`fe_var') cluster(`fe_var') r 
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

cap drop pay0
g pay0=pay
replace pay0=0 if pay0==.


* count dc

cap drop cmc
cap drop cmt_id
cap drop cmt
cap drop cmci
g cmt_id = .
g cmc = .
forvalues r=0/10 {
	by conacct: replace cmt_id=1 if tcd_id[_n-`r']==1 & c==.
	by conacct: replace cmc = `r' if tcd_id[_n-`r']==1 & c==.
}
egen cmt=sum(cmt_id), by(conacct)
egen cmci = max(cmc), by(conacct)


by conacct: g nn = _n

global post_cond = ""
forvalues r=5/10 {
	global post_cond = " ${post_cond} & cm`r'==0 "
}

global full_cond = ""
forvalues r=0/10 {
	global full_cond = " ${full_cond} & cm`r'==0 "
}

global dc_cond = ""
forvalues r=7/10 {
	global dc_cond = " ${dc_cond} & cm`r'==1 "
}

count if nn==1 & tcds>1 & tcds<.
* 2600 ish tcd more than once

count if nn==1 & tcds==1
global tot = `r(N)'
* 6535 tcd just once

count if nn==1 & tcds==1 $full_cond
global neverdc = `r(N)'
* 3744 never dc

disp $neverdc / $tot
* 57% always reconnect

count if nn==1 & tcds==1 $dc_cond
global fulldc = `r(N)'
* 1068
disp $fulldc / $tot
* 16% fully disconnect

disp 1 - (($neverdc + $fulldc)/$tot)
* leaves 26% less that disconnect briefly


** for ones that reconnect, where are the missing values?! definitely in the beginning!
tab cmt if nn==1 & tcds==1 $post_cond

hist cmt if nn==1 & tcds==1 $post_cond


tab cmc if cmt==1 & tcds==1 $post_cond



count if nn==1 & tcds==1 & cm0==0 $full_cond


count if nn==1 & tcds==1 & cm0==0 $post_cond


count if nn==1 & tcds==1
count if nn==1 & tcds==1 & cm0==1
count if nn==1 & tcds==1 & cm1==1

count if nn==1 & tcds==1 & cm2==0
count if nn==1 & tcds==1 & cm0==1 & cm2==0
count if nn==1 & tcds==1 & cm1==1 & cm2==0


 tab cmci if cmt==1 & nn==1 & tcds==1 $post_cond


graph_trend pay0 tcd_id conacct tt_pay "keep if tcds==1 & cmt==1 & cmci==1 "

graph_trend pay0 tcd_id conacct tt_pay "keep if tcds==1 & cmt==1 & cmci==0 "

graph_trend pay0 tcd_id conacct tt_pay "keep if tcds==1 & cmt==1 & cmci==2 "


*** YESSSSSS THIS WORKS!!!!!!!!




graph_trend pay0 tcd_id conacct tt_pay "keep if cm1==1 & cm2==0 & tcds==1"

graph_trend pay0 tcd_id conacct tt_pay "keep if cm1==0 & cm2==1 & tcds==1"






cap drop pp
g pp=pay
replace pp = 0 if pp==.

cap drop cmiss
g cmiss=c==.


foreach var of varlist ar ar_post ar_pre {
cap drop `var'_nm
g `var'_nm=`var'
replace `var'_nm=1 if cm==1
}


cap drop ARP
cap drop arp_id
g arp_id = ar_pre if tcd_id==1
egen ARP=max(arp_id), by(conacct)


sort conacct date
by conacct: g cnm = cmiss==1 & (T1==-3 | T1==-2 | T1==-1 | T1==0 | T1==1 | T1==2 | T1==3 )

egen CNM = max(cnm), by(conacct)

egen cmiss_s=sum(cmiss), by(conacct)

sort conacct date
by conacct: g cnm_s = cmiss==1 & (T1==-5 | T1==-4 | T1==-3 | T1==-2 | T1==-1 | T1==0 | T1==1 | T1==2 | T1==3 | T1==4 | T1==5 )
egen CNM_S = max(cnm_s), by(conacct)
g CML = cmiss_s<=2 & CNM_S==0


cap drop dd_id
cap drop drec
cap drop DDs
cap drop DR

sort conacct date
by conacct: g dd_id = c==. & (T1==1 | T1==2)
by conacct: g drec = c!=. & (T1==3 | T1==4 | T1==5)
egen DDs=sum(dd_id), by(conacct)
egen DR =max(drec), by(conacct)

*** PARTIAL SHUTDOWN ON C!


graph_trend pay0 tcd_id conacct testing_pay0_all "keep if DDs==2 & DR>=1 & DR<."


graph_trend pay0 tcd_id conacct testing_pay0_all ""
graph_trend cmiss tcd_id conacct testing_cm_all ""


graph_trend cmiss tcd_id conacct testing_cm_all "keep if ARP>120 & ARP<."

graph_trend cmiss tcd_id conacct testing_cm_all "keep if ARP<120 "

graph_trend cmiss tcd_id conacct testing_cm_all "keep if ARP<61 "






graph_trend pay0 tcd_id conacct testing_pay0_all "" "i.date i.ar i.ar_post i.ar_pre "



graph_trend c tcd_id conacct testing_c_cnms "" "i.date i.ar i.ar_post i.ar_pre if CML==1" 
graph_trend cmiss tcd_id conacct testing_cm_cnms "" "i.date i.ar i.ar_post i.ar_pre if CML==1"
graph_trend pay0 tcd_id conacct testing_pay0_cnms "" "i.date i.ar i.ar_post i.ar_pre if CML==1"






graph_trend c tcd_id conacct testing_c_cnm "" "i.date i.ar i.ar_post i.ar_pre if CNM==0" 
graph_trend cmiss tcd_id conacct testing_cm_cnm "" "i.date i.ar i.ar_post i.ar_pre if CNM==0"
graph_trend pay0 tcd_id conacct testing_pay0_cnm "" "i.date i.ar i.ar_post i.ar_pre if CNM==0"


graph_trend c tcd_id conacct testing_c "" "i.date i.ar i.ar_post i.ar_pre if AR==1" 
graph_trend cmiss tcd_id conacct testing_cm "" "i.date i.ar i.ar_post i.ar_pre if AR==1"
graph_trend pay0 tcd_id conacct testing_pay0 "" "i.date i.ar i.ar_post i.ar_pre if AR==1"

graph_trend c tcd_id conacct testing_c_np "" "i.date i.ar i.ar_post i.ar_pre if AR==0" 
graph_trend cmiss tcd_id conacct testing_cm_np "" "i.date i.ar i.ar_post i.ar_pre if AR==0"
graph_trend pay0 tcd_id conacct testing_pay0_np "" "i.date i.ar i.ar_post i.ar_pre if AR==0"




graph_trend c tcd_id conacct testing_c "" "i.date i.ar i.ar_post i.ar_pre if AR==1" 

graph_trend c tcd_id conacct tcd_testing "" "i.date i.ar i.ar_post i.ar_pre if AR==0" 


graph_trend cmiss tcd_id conacct tcd_testing "" "i.date i.ar i.ar_post i.ar_pre if AR==1"
graph_trend cmiss tcd_id conacct tcd_testing "" "i.date i.ar i.ar_post i.ar_pre if AR==0"


graph_trend cmiss tcd_id conacct tcd_testing "keep if AR==0"  


graph_trend cs tcd_id conacct tcd_testing "keep if AR==1"
graph_trend cs tcd_id conacct tcd_testing "keep if AR==0"





graph_trend c tcd_id conacct tcd_testing "keep if ms==0"

graph_trend c tcd_id conacct tcd_testing "keep if ms==1"


graph_trend cmiss tcd_id conacct tcd_testing "keep if ms==0"
graph_trend cmiss tcd_id conacct tcd_testing "keep if ms==1"


graph_trend cs tcd_id conacct tcd_testing "keep if ms==0"

graph_trend cs tcd_id conacct tcd_testing "keep if ms==1"


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




