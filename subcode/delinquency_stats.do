* *  delinquency.do

grstyle init
grstyle set imesh, horizontal



cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end

* g b_per_account = BAL_TOTAL/tot_acc
* sum b_per_account

sum bal if date==dc_date
global out_bal = `=r(mean)'
write "${tables}out_bal.tex" $out_bal 1 "%12.0fc"


* g dcs_time = DCS/(time*tot_acc)
* sum dcs_time
* write "${moments}dc_per_month_account.csv" `=r(mean)' 0.0001 "%12.4g"
* write "${tables}dc_per_month_account.tex" `=r(mean)' 0.0001 "%12.4fc"

write "${moments}delinquency_cost.csv" `=$out_bal*$disc_per_month' 0.1 "%12.0g"
write "${tables}delinquency_cost.tex" `=$out_bal*$disc_per_month' 0.1 "%12.0g"


* g date_tcd_id= date if tcd_id==1
* gegen date_tcd=min(date_tcd_id), by(conacct)
* g T_alt = date-date_tcd
* replace T_alt=. if dc_date!=.

* g alt = T_alt!=.


g T = date-dc_date
* replace T = T_alt if alt==1


global textsize "large"


cap program drop sp
prog define sp
	preserve
		keep if T<=-1 & T>=-25 & dc_date<664-24  & c!=0
		egen mv = mean(c), by(T)
		bys T: g dn=_n
		twoway line mv T if dn==1, lp(solid) lc(gs0) lw(medthick)  plotr(lw(medthick )) ///
		 lc(gs6) lw(medthick)  ytitle("Average Usage (m3)", size(${large})) xtitle("Months to Permanent Disconnection", size(${textsize})) ///
		  legend(off) 
	    graph export  "${tables}line_`1'.pdf", as(pdf) replace
	restore
end

sp disc_graph



* cap program drop sp
* prog define sp
* 	preserve
* 		keep if T<=-1 & T>=-25  &  c!=0 & ((dc_date<664-24 & alt==0) | alt==1)
* 		egen mv = mean(c), by(T alt)
* 		bys T alt: g dn=_n
* 		twoway line mv T if dn==1 & alt==0, lp(solid) lc(gs0) lw(medthick)  plotr(lw(medthick )) || ///
* 		line mv T if dn==1 & alt==1, lp(dash) lc(gs0) lw(medthick)  plotr(lw(medthick )) ///
* 		 lc(gs6) lw(medthick)  ytitle("Average Usage (m3)", size(${large})) xtitle("Months to Permanent Disconnection", size(${textsize})) ///
* 		  legend(off) 
* 	    graph export  "${tables}line_`1'.pdf", as(pdf) replace
* 	restore
* end

* sp disc_graph


* tab T, g(TT)
* tab T_alt, g(TC)




* areg c TT39-TT62 i.date if  dc_date<664-12 & c>5, a(conacct)

* coefplot, vertical keep(TT*)


* areg c TC38-TC60 i.date if c!=0, a(conacct)

* coefplot, vertical keep(TC*)



* reg c TT30-TT60 i.date,





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


