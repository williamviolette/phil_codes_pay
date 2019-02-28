* *  delinquency.do

grstyle init
grstyle set imesh, horizontal



cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end



use  "${temp}temp_descriptives.dta", clear

*** ROUTINE DATA CLEANING
drop if date==653
egen max_class= max(class), by(conacct)
keep if max_class==1
keep if SHH==1               

*** STANDARD DISCONNECTION
sort conacct date
by conacct: g new_dc = dc[_n-1]!=2 & dc[_n]==2
* hist date if new_dc==1 ** KEEP ONLY LATE ONES
g new_dc_date_id=date if new_dc==1
egen new_dc_date = max(new_dc_date_id), by(conacct)

keep if date>=618
tab bal if new_dc==1
g dc_end = c==. & date>=652
egen dcs=sum(dc_end), by(conacct)
*** MEASURE DISCONNECTION THROUGH CMISS

sort conacct date
by conacct: g new_c_id = c[_n-1]!=. & c[_n]==.
g date_c_id = date if new_c_id==1 & dcs>=11 & dcs<=12
egen new_c_date =max(date_c_id), by(conacct)
g new_c = date == new_c_date

** KEEP ONLY EARLY ONES
keep if date<=654 

g DC_date = new_c_date
replace DC_date = new_dc_date if DC_date==.

g T = date-DC_date


*** AGGREGATE MEASURE
*g DC = new_dc==1 | new_c==1

g DC = DC_date == date
replace bal = 0 if bal<5  | bal==.
replace bal = . if bal>100000 & bal<.
*hist bal if DC==1

sum bal if DC==1
g bal_avg = `=r(mean)'
sum date, detail
g time = `=r(max)'-`=r(min)'
bys conacct: g cn=_n==1
egen tot_acc = sum(cn)
egen DCS=sum(DC) // cost per disconnection comes to 20 PhP which is decent
g bal_dc = bal if DC==1
egen BAL_TOTAL = sum(bal_dc)
g cost = BAL_TOTAL/(time*tot_acc)
tab cost



* g b_per_account = BAL_TOTAL/tot_acc
* sum b_per_account

sum bal_dc 
write "${tables}out_bal.tex" `=r(mean)' 1 "%12.0fc"


g dcs_time = DCS/(time*tot_acc)
sum dcs_time
write "${tables}dc_per_month_account.tex" `=r(mean)' 0.0001 "%12.4fc"



sum cost
write "${moments}delinquency_cost.csv" `=r(mean)' 0.1 "%12.0g"
write "${tables}delinquency_cost.tex" `=r(mean)' 0.1 "%12.0g"



global textsize "large"

cap program drop sp
prog define sp
	preserve
		keep if T<=-1 & T>=-30
		egen mv = mean(c), by(T)
		bys T: g dn=_n
		twoway line mv T if dn==1, lp(solid) lc(gs0) lw(medthick)  plotr(lw(medthick )) ///
		 lc(gs6) lw(medthick)  ytitle("Average Usage (m3)", size(${large})) xtitle("Months to Permanent Disconnection", size(${textsize})) ///
		  legend(off) 
	    graph export  "${tables}line_`1'.pdf", as(pdf) replace
	restore
end

sp disc_graph




/*


global M = 30

cap program drop graph_trend
program define graph_trend

	local fe_var "`2'"
	local outcome "`1'"
	local T_high "0"
	local T_low "-${M}"
	preserve
		`4'
		`5'
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

graph_trend c conacct delinq_c



*** 32 PhP per month per account ... 
* another maximum cost : disp 100 * 26 P * 6 months = 15,600
* g cost_alt = DCS*15600/(time*tot_acc) // about the same...
* tab cost_alt
	
	*** 
	* g dc_cost = 10000*DCS/(time*tot_acc)
	* sum dc_cost


