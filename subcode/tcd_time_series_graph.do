








use "${temp}ar_temp_pay.dta", clear

g pre = date<610

hist ar, by(pre)

bys conacct: g cN=_N

egen dd=cut(date), at(600(10)650)

tab ar dd if cN>55 & cN<65








/*

use "${temp}bill_temp_pay.dta", clear

 
local years  " 617 621 613 614 617 616 610 623 610 617 621 621 "


g P=.
g date_t=.

forvalues r=1/12 {
	local yr : word `r' of `years'
	replace P=1 if date==`yr' & ba==`r'
	replace date_t = `yr' if ba==`r'
}

g T = date-date_t

keep if c>0 & c<100

bys conacct: g cN=_N
keep if cN>70 & cN<85


cap program drop graph_trend
program define graph_trend
	local cluster_var "conacct"
	local outcome "c"
	local T_high "12"
	local T_low "-12"
	*preserve
		keep if date>=600 & date<=650
		keep if ba<=3 | ba==6

		sum c
		scalar define mc=round(r(mean),.01)

		keep if T>=`=`T_low'' & T<=`=`T_high''

	duplicates drop `cluster_var' date, force
		qui tab T, g(T_)
		qui sum T, detail
		local time_min `=r(min)'
		local time `=r(max)-r(min)'
		areg `outcome' T_* i.date, absorb(`cluster_var') cluster(`cluster_var') r 
	   	parmest, fast
	   	g time = _n
	   	keep if time<=`=`time''
	   	replace time = time + `=`time_min''
	   	lab var time "Time (Months to Program)"
    	*tw (scatter estimate time) || (rcap max95 min95 time)
    	tw (line estimate time, lcolor(black) lwidth(medthick)) ///
    	|| (line max95 time, lcolor(blue) lpattern(dash) lwidth(med)) ///
    	|| (line min95 time, lcolor(blue) lpattern(dash) lwidth(med)), ///
    	 graphregion(color(gs16)) plotregion(color(gs16)) xlabel(`=`T_low''(2)`=`T_high'') ///
    	 ytitle("Usage (m3)") ///
    	 note("Avg. Usage: `=round(mc,.1)' m3 ")
   	*restore
   	graph export  "${temp}cons_trend.pdf", as(pdf) replace
end

graph_trend


/*



preserve
	keep if date>=600 & date<=630
	keep if ba<=3

	egen N=mean(c), by(date ba)
	*bys date ba: g N=_N
	bys date ba: g nn=_n
	keep if nn==1

	egen Nm=max(N), by(ba)
	replace N=N/Nm

	scatter N date, by(ba) || scatter P date, by(ba)





/*



use "${temp}mcf_temp_pay.dta", clear

 
local years  " 617 621 613 614 617 616 610 623 610 617 621 621 "


g P=.

forvalues r=1/12 {
	local yr : word `r' of `years'
	replace P=.5 if date==`yr' & ba==`r'
}



preserve
	keep if dc==1
	keep if date>=600 & date<=630

	bys date ba: g N=_N
	bys date ba: g nn=_n
	keep if nn==1

	egen Nm=max(N), by(ba)
	replace N=N/Nm

	scatter N date, by(ba) || scatter P date, by(ba)





/*

610 613 610 616 617 621 623 614 610 621 617 621

novaliches 	0100	02/2011		613
so_cal 		0200	11/2010		610
val 		0300	02/2011		613
roosevelt 	0400	11/2010		610
samp		0500	05/2011		616
tondo 		0600	06/2011		617
pm			0700	10/2011		621
bacoor		0800	12/2011		623
commonwealth0900	03/2011		614
navotas		1000	11/2010		610
para		1100	10/2011		621
no_cal		1200	06/2011		617
quirino 	1300	11/2010		610
sm 			1500	10/2011		621
fairview	1600	03/2011		614
muntin		1700	10/2011		621


load_data_mcf 1 tondo 	617
load_data_mcf 2 pasay 	621
load_data_mcf 3 val 	613
load_data_mcf 4 qc_09 	614
load_data_mcf 5 qc_12 	617
load_data_mcf 6 samp 	616
load_data_mcf 7 qc_04 	610
load_data_mcf 8 bacoor 	623
load_data_mcf 9 so_cal 	610
load_data_mcf 10 cal_1000 	617
load_data_mcf 11 muntin 	621
load_data_mcf 12 para	 621



BUSINESS AREA

Read and Bill Implementation

Dunning List Implementation

SOUTH CALOOCAN

August 2010

November 2010

QUIRINO ROOSEVELT

September 2010

November 2010

MALABON NAVOTAS

October 2010

November 2010

NOVALICHES VALENZUELA

February 2011

February 2011

FAIRVIEW COMMONWEALTH

March 2011

March 2011

NORTH CALOOCAN

June 2011

June 2011

SAMPALOC

May 2011

May 2011

TONDO

June 2011

June 2011

SOUTH MANILA/PASAY MAKATI

October 2011

October 2011

PARANAQUE

October 2011

October 2011

MUNTINLUPA

October 2011

October 2011

CAVITE

December 2011

December 2011





/*
North 		1200, 0900, 0300			(1600, 0100)

Central A 	0200, 0400, 1000			(1300)

Central B	0500, 0700, 0600			(1500)

South		1100, 1700, 0800	
*/


program define graph_total
quietly {
*	`2' `1' 100 613	
	`2' `1' 200 610
	`2' `1' 300 613
	`2' `1' 400 610
	`2' `1' 500 616
	`2' `1' 600 617
	`2' `1' 700 621
	`2' `1' 800 623
	`2' `1' 900 614
	`2' `1' 1000 610
	`2' `1' 1100 621	
	`2' `1' 1200 617			
*	`2' `1' 1300 610		
*	`2' `1' 1500 621
*	`2' `1' 1600 614
	`2' `1' 1700 621
	}
	graph_combine `1' `2'
end
	
	*** KEY ***

