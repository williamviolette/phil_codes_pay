*descriptives.do


set scheme s1mono

grstyle init
grstyle set imesh, horizontal

cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end

* do "${subcode}table_print.do"
* do "${subcode}delinquency_graph_stats.do"

import delimited using "${moments}y_avg.csv", clear
global y_avg=v1[1]

import delimited using "${moments}save_avg.csv", clear
global save_avg=v1[1]

import delimited using "${moments}y_p20.csv", clear
global y_p20=v1[1]

import delimited using "${moments}disc_per_month.csv", clear
global disc_per_month = v1[1]


import delimited using "${moments}account_length.csv", clear
global account_length = v1[1]




use "${temp}temp_descriptives_2.dta", clear




cap drop inc 

*** Income definition
* egen inc_t = cut(inc), group(3)
* replace inc_t=inc_t+1

cap drop am_end
g am_end = am ==1 & date==664
sort conacct date 
by conacct: g c_lag = c[_n-1]
by conacct: g ar_lag = ar[_n-1]
by conacct: g bal_lag = bal[_n-1]

forvalues r=1/60 {
	replace am_end = 1 if am==1 & am_end[_n+1]==1
}

gegen leaver = max(am_end), by(conacct)

sort conacct date
by conacct: g dc_enter = am_end[_n-1]==0 & am_end[_n]==1
g dc_date_id = date if dc_enter==1
gegen dc_date = max(dc_date_id), by(conacct)
	replace amount = . if date>dc_date
	replace c      = . if date>dc_date
	replace bal    = . if date>dc_date
	replace ar     = . if date>dc_date
drop dc_date_id




* do smoothing_test.do  // THERE IS AN ISSUE WITH HOW MEANS ARE CALCULATED!! (USE R(sample!))



*** KEY KEEP! ***	
keep if date>=603

save  "${temp}temp_descriptives_3.dta", replace


*** DISCONNECTION RATE!

cap drop dc_enter1
cap drop dc_m
cap drop datet
g dc_enter1 = dc_enter if date_c>=`=tm(2007m1)' & date_c<=`=tm(2011m12)'
gegen dc_m = mean(dc_enter1), by(date)
gegen datet = tag(date)

* scatter dc_m date if datet==1

* scatter dc_m date if datet==1 & date>=`=tm(2012m1)' & date<=`=tm(2014m5)'
sum dc_enter1 		if date>=`=tm(2012m1)' & date<=`=tm(2014m5)'
corr dc_enter1 date if date>=`=tm(2012m1)' & date<=`=tm(2014m5)'





do export_moments.do

set seed 10
forvalues r = 1/10 {
	global tag = "_`r'"
	preserve
		keep conacct
		duplicates drop conacct, force
		bsample
		duplicates tag conacct, g(D)
		duplicates drop conacct, force
		replace D = D+1 
		save "${temp}boot_temp.dta", replace
	restore

	preserve
		merge m:1 conacct using "${temp}boot_temp.dta"
		keep if _merge==3
		drop _merge

		expand D
		sort conacct date	
		by conacct date: g ns = _n

		sort conacct ns date
		order conacct ns date

		do export_essential.do
	restore

}




g TD = date-dc_date


gegen balTD = mean(bal), by(TD)
gegen tagTD = tag(TD)



scatter balTD TD if tagTD==1 & TD<=0 & TD>=-36


* g DC = date>=dc_date

* cap drop post_dc

*** OLD TCD SHARE DEFINITIONS
* sort conacct date
* by conacct: g post_dc = tcd_id==1 & ( dc_enter[_n]==1 | dc_enter[_n+1]==1 | dc_enter[_n+2]==1 | dc_enter[_n+3]==1 | dc_enter[_n+4]==1  | dc_enter[_n+5]==1 )
* by conacct: g post_td = tcd_id==1 & ( am[_n+1]==1 | am[_n+2]==1   )
* replace post_dc = 0 if post_td==0

* count if tcd_id==1
* global tcd_total = `r(N)'

* count if post_dc==1
* global post_dc = `r(N)'

* count if post_td==1
* global post_td = `r(N)'

* disp $post_dc/$tcd_total
* write "${tables}tcd_share_dc.tex" `=100*$post_dc/$tcd_total'  1  "%12.0g"

* disp ($post_td-$post_dc)/$tcd_total
* write "${tables}tcd_share_rec.tex" `=100*($post_td-$post_dc)/$tcd_total' 1 "%12.0g"

* disp 1-($post_td/$tcd_total)
* write "${tables}tcd_share_pay.tex" `=100*(1-($post_td/$tcd_total))' 1 "%12.0g"

* sum tcd_max, detail
* write "${tables}tcd_max.tex" `=100*`=r(mean)'' 1 "%12.0g"






*** TEST DUNNING ***
* by conacct: g ar_lag2 = ar[_n-2]
* by conacct: g ar_lag3 = ar[_n-3]
* by conacct: g bal_lag2 = bal[_n-2]
* by conacct: g bal_lag3 = bal[_n-3]
* g td = tcd_id if ar_lag>60 & ar_lag<.
* gegen tdm = mean(td), by(ba date)
* bys ba date: g bam = _n
* twoway scatter tdm date if bam==1, by(ba, rescale)
* egen balg= cut(bal_lag), group(100)
* egen balg2= cut(bal_lag2), group(100)
* egen balg3= cut(bal_lag3), group(100)
* reg tcd_id house_1 house_2 age hhemp hhsize low_skill i.date i.ba i.ar_lag i.ar_lag2 i.ar_lag3 i.balg i.balg2 i.balg3, cluster(conacct) r



/*


	global M1 = 24

	sort conacct date
 		cap drop cn 
 		cap drop tid 
 		cap drop T1
 		cap drop dt_id
  		cap drop dt
 		cap drop T1d
 		g T1d= .
		g T1 = .
		by conacct: g cn=_n if tcd_id==1
		g dt_id = date if tcd_id==1
		egen dt = min(dt_id), by(conacct)

		g tid=cn if tcd_id==1
		replace T1 = 0 if tcd_id==1
		replace T1d = 0 if tcd_id==1 & date==dt
		forvalues v=1/$M1 {
		qui by conacct: replace T1=-`v' if tcd_id[_n+`v']==1 
		qui by conacct: replace T1d=-`v' if tcd_id[_n+`v']==1 & date[_n+`v']==dt[_n+`v']
		qui by conacct: replace tid=cn[_n+`v'] if tcd_id[_n+`v']==1 
		}
		forvalues v=1/$M1 {
		qui by conacct: replace T1=`v' if tcd_id[_n-`v']==1 
		qui by conacct: replace T1d=`v' if tcd_id[_n-`v']==1 & date[_n-`v']==dt[_n-`v']
		qui by conacct: replace tid=cn[_n-`v'] if tcd_id[_n-`v']==1 
		}



cap program drop sp
prog define sp
	global textsize "large"
	preserve
		`4'
		gegen mv = mean(`2'), by(`3')
		bys `3': g dn=_n
		twoway line mv `3' if dn==1, lp(solid) lc(gs0) lw(thick)  ///
		plotr(lw(medthick ))  xlabel(, labsize(${textsize})) ylabel(, labsize(${textsize})) ///
		ytitle("`5'", size(${textsize})) xtitle("`6'", size(${textsize}))  ///
		legend(off) xline(0, lw(thin)lp(shortdash))

	    graph export  "${tables}line1_`1'.pdf", as(pdf) replace
	restore
end

sp "disconnection" am T1d  "keep if dc_date==."  "Share Disconnected" "Months to First Delinquency Visit" 


cap drop am1
sort conacct date
g am1 = 0 if tcd_id==1
by conacct: replace am1 = 1 if  tcd_id==1 & (am[_n+1]==1 | am[_n+2]==1)



g ar_lag1 = ar_lag
replace ar_lag1=360 if ar_lag>=360 & ar_lag<.

sp "tcd_ar" am1 ar_lag1 "keep if dc_date==. & ar_lag1>=61"  "Share Disc. 1 or 2 Months Post Visit" "Days Delinquent When Visited" 


* tab tcds  if ar_lag1>=61 & ar_lag1<. & dc_date==.

global rl1 = "Household FE"
global rl2 = "Year-Month FE"


g ar_lag1m = ar_lag1/30

lab var ar_lag1m "Months Delinquent"

reg am1 ar_lag1m if ar_lag1>=61 & ar_lag1<. & dc_date==., r
 eststo ar_1
 estadd local ctrl1 ""
 estadd local ctrl2 ""
 sum am1 if e(sample)==1
 estadd local smean = `=round(r(mean),.001)'

areg am1 ar_lag1m i.date if ar_lag1>=61 & dc_date==., a(conacct) r
 eststo ar_2
 estadd local ctrl1 "\checkmark"
 estadd local ctrl2 "\checkmark"
 sum am1 if e(sample)==1
 estadd local smean = `=round(r(mean),.001)'

	estout  ar_1 ar_2  using "${tables}ar_robust.tex", replace  style(tex) ///
	keep(   ar_lag1m )  ///
	varlabels(, el( ar_lag1m "[0.5em]"   )) ///
	label ///
	  noomitted ///
	  mlabels(,none)  ///
	  collabels(none) ///
	  cells( b(fmt(3) star ) se(par fmt(3)) ) ///
	  stats( ctrl1 ctrl2 smean r2 N ,  ///
 	labels( "$rl1" "$rl2" "Mean" "R2"  "N"  ) /// 
	    fmt( %18s %18s %12.2fc %12.2fc  %12.0fc  )   ) ///
	  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 







* parmest, fast

* keep if regexm(parm,"ar")==1
* g ar = regexs(1) if regexm(parm,"^([0-9]+)")
* destring ar, replace force

* twoway line estimate ar, lp(solid) lc(gs0) lw(thick) ///
*     	|| (line max95 ar, lcolor(blue) lpattern(dash) lwidth(med)) ///
*     	|| (line min95 ar, lcolor(blue) lpattern(dash) lwidth(med)), /// 
* 		plotr(lw(medthick ))  xlabel(, labsize(${textsize})) ylabel(, labsize(${textsize})) ///
* 		ytitle("`5'", size(${textsize})) xtitle("`6'", size(${textsize}))  ///
* 		legend(off) xline(0, lw(thin)lp(shortdash))



* g tcd_id_date_id = date if tcd_id==1
* gegen tcd_id_date = max(tcd_id_date_id), by(conacct)
* drop tcd_id_date_id
* cap drop tcd_dc
* g tcd_dc = dc_date<3+tcd_id_date & tcd_id_date!=.
* g left =  (date>=dc_date-3)

** either being flagged 


*** Data definitions
sort conacct date
by conacct: g ar_lag = ar[_n-1]

egen ams=sum(am), by(conacct)	
egen tcds=sum(tcd_id), by(conacct)






*** count PCD'd HOUSEHOLDS!
	* cap drop cnn
	* sort conacct date
	* by conacct: g cnn=_n
	* count if l6==6 & pcd==1 & cnn==1
	* write "${tables}pcd_hh.tex" `=r(N)' 1 "%12.0g"
	* drop cnn


sum amount, detail
write "${moments}bill_all.csv" `=r(mean)' 1 "%12.0g"
forvalues r=1/3 {
	sum amount if inc_t==`r', detail
	write "${moments}bill_all_t`r'.csv" `=r(mean)' 1 "%12.0g"
}



* cap drop del_id
* g del_id = ar>31 & ar<.
* sum del_id 
* write "${tables}share_del.tex" `=r(mean)*100' 1 "%12.0g"


* do "${subcode}descriptive_table_print_3_groups.do"

global dtable_name "all"
do "${subcode}descriptive_table_print.do"
	




* do "${subcode}descriptive_table_print_groups.do"

	* preserve
	  drop if date>=dc_date-12  &  leaver==1

		 do "${subcode}export_moments.do"
	     
	  *    global dtable_name "stayers"
		 * do "${subcode}descriptive_table_print.do"
	
	* restore




	
	
/*


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

		areg `outcome' T_* `6', absorb(`fe_var') cluster(`fe_var') r 
		* reg `outcome' T_* `6', cluster(`fe_var') r 
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




graph_trend am tcd_id conacct aa " keep if T1!=. & l12==12 & tcds==1 " "i.date"



	* import delimited using "${moments}y_avg.csv", clear delimiter(",")
	* sum v1
	* global y_avg = `r(mean)'

	* import delimited using "${moments}save_avg.csv", clear delimiter(",")
	* sum v1
	* global save_avg = `r(mean)'

	* import delimited using "${moments}y_p20.csv", clear delimiter(",")
	* sum v1
	* global y_p20 = `r(mean)'



* sum amount 

* sort conacct date
* by conacct: g ach=amount[_n]-amount[_n-1]

* preserve
* 	g d36 = round(date,36)
* 	duplicates drop d36 conacct, force
* 	sort conacct d36
* 	by conacct: g ach36=amount[_n]-amount[_n-1]
* 	sum ach36
* restore

* gegen ams = sum(am_end), by(conacct)

* g bal_o = date if bal!=.
* gegen bal_d = max(bal_o), by(conacct)
* g bal_dc_id = bal if bal_d == bal_o
* gegen bal_dc = max(bal_dc_id), by(conacct)

* gegen mean_c = mean(c), by(conacct)

* sum bal_dc  if  mean_c>35 & ams>5 & ams<20
* sum bal_dc  if  mean_c<20 & ams>5 & ams<20
* sum leaver  if  mean_c>35
* sum leaver  if  mean_c<20 

* sum bal if  mean_c>30 & ams>5 & ams<20
* sum bal if  mean_c<15 & ams>5 & ams<20
* sum bal_dc
* sum bal_dc if leaver==1
* reg bal_dc mean_c house_1 house_2 age hhemp hhsize low_skill if leaver==1 & ams>5
* reg bal_dc house_1 house_2 age hhemp hhsize low_skill if leaver==1 & ams>5
* reg mean_c leaver i.date_c if date<620
* reg date_c c if date<620
* reg leaver date_c if date_c>550
* hist bal_dc if leaver==1 & ams>5 & bal_dc<20000
* g bal_dc0 = bal_dc<=0
* reg bal_dc0 c if leaver==1 & ams>5 & date_c<620
