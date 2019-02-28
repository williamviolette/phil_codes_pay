* deaton_graph.do


set scheme s1mono


grstyle init
grstyle set imesh, horizontal

cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end

import delimited using "${temp}moments/p_int.csv", delimiter(",") clear
	scalar define p_int = v1 in 1
import delimited using "${temp}moments/p_slope.csv", delimiter(",") clear
	scalar define p_slope = v1 in 1



import delimited using "${temp}moments/y_avg.csv", delimiter(",") clear

scalar define y_avg = v1 in 1

import delimited using "${temp}moments/estimates.csv", delimiter(",") clear

scalar define theta = v2 in 1

* import delimited using "${temp}moments/sim.csv", delimiter(",") clear
* save "${temp}good_sim.dta"

use "${temp}good_sim.dta", clear
ren v1 c
ren v2 A
ren v3 B
ren v4 D
ren v5 s

g id = _n

g idD = id if D==1
egen midD = max(idD)
keep if id>=midD-50 & id<midD+50

drop id idD midD

g id=_n


g Y = `=y_avg*(1+theta)' if s==1 | s==3
replace Y = `=y_avg*(1-theta)' if s==2 | s==4
replace Y = round(Y,1)

g Yi = Y - `=y_avg'
g Yc = sum(Yi)


g Ys = sum(Y)
g Ysc = Ys[_n]-Ys[_n-1]

label var Yc "Cumulative Inc. Shocks: {{&theta}y, -{&theta}y }"

*twoway line Yc id




g V = s==3 | s==4

global tsize "large"


global gr "graphregion(margin(2 2 -15 2))"
global gr1 "graphregion(margin(2 2 2 2)) "
global gr1 ""
global gr ""

global marginsize "right"
global lw "thick"
global ms "large"


global vspot=40000

replace V=. if V==0
replace D=. if D==0
replace V=${vspot} if V!=.
replace D=${vspot} if D!=.

tab id if V==1, matrow(vt)
* global vtext ""
* foreach j in 



* line Y id, lwidth(${lw}) saving("${temp}Y", replace) xtitle("     ", size(${tsize})) ytitle("y{subscript:t}", margin(${marginsize})) ///
* 	xlabel(0 " " 20 "  " 40 "  " 60 "  " 80 "  " 100 "   ") ${gr}  ylabel(25000 "25k" 40000 "40k", angle(90))

* twoway (scatter V id, msize(${ms}) text(1 6 "Visit" 1 41 "Visit" 1 79 "Visit", place(n) margin(b+3)) ) || line D id, text(1 48 "Disconnect", place(s)  margin(t+3 )) legend(off) lwidth(vthick) saving("${temp}V", replace) xtitle("     ", size(${tsize})) ytitle("c{subscript:t}", margin(${marginsize})) ///
* 	ylabel( 1 "Visit", angle(90))  xlabel(0 " " 20 "  " 40 "  " 60 "  " 80 "  " 100 "   ") ${gr}

* line D id, lwidth(vthick) saving("${temp}D", replace) xtitle("     ", size(${tsize})) ytitle("D{subscript:t}", margin(${marginsize})) ///
* 	ylabel( 1 "Disconnect", angle(90))  xlabel(0 " " 20 "  " 40 "  " 60 "  " 80 "  " 100 "   ") ${gr}

* Cum. ({&theta}y{subscript:t}, -{&theta}y{subscript:t})
twoway line Yc id, lwidth(${lw}) saving("${temp}Y", replace)  ///
|| scatter V id, msize(${ms}) text($vspot 6 "Visit" $vspot 41 "Visit" $vspot 79 "Visit", place(n) margin(b+3))   ///
|| line D id, lwidth(vthick)   text($vspot 50 "Disconnect", place(n)  margin(b+1.5 )) ///
xtitle("     ", size(${tsize})) ytitle("Cum. {&Delta}y{subscript:t}    ", margin(${marginsize})) ///
	xlabel(0 " " 20 "  " 40 "  " 60 "  " 80 "  " 100 "   ") ${gr}  ylabel(-100000 "-100k" 40000 "40k" , angle(90)) legend(off) yscale(range(25000 80000))


* twoway line Y id, lwidth(${lw}) saving("${temp}Y", replace)  ///
* || scatter V id, msize(${ms}) text($vspot 6 "Visit" $vspot 41 "Visit" $vspot 79 "Visit", place(n) margin(b+3))   ///
* || line D id, lwidth(vthick)   text($vspot 50 "Disconnect", place(n)  margin(b+1.5 )) ///
* xtitle("     ", size(${tsize})) ytitle("y{subscript:t}    ", margin(${marginsize})) ///
* 	xlabel(0 " " 20 "  " 40 "  " 60 "  " 80 "  " 100 "   ") ${gr}  ylabel(-25000 "25k" 40000 "40k" 50000 " ", angle(90)) legend(off) yscale(range(25000 60000))

line A id, lwidth(${lw}) saving("${temp}A", replace) xtitle("     ", size(${tsize})) ytitle("A{subscript:t+1}", margin(${marginsize})) ///
	xlabel(0 " " 20 "  " 40 "  " 60 "  " 80 "  " 100 "   ") ${gr}  ylabel(-20000 "-20k" 0 "0" 20000 "20k", angle(90))

line B id, lwidth(${lw}) saving("${temp}B", replace) xtitle("     ", size(${tsize})) ytitle("B{subscript:t+1}", margin(${marginsize}))  ///
	xlabel(0 " " 20 "  " 40 "  " 60 "  " 80 "  " 100 "   ")   ylabel(0 "0" -8000 "-8k", angle(90))  ${gr}
* -2000 "-2000" -4000 "-4000" -6000 "-6000" 
line c id, lwidth(${lw}) saving("${temp}c", replace) xtitle("Months", size(${tsize})) ytitle("Usage{subscript:t}", margin(${marginsize}))  ///
	${gr1} 														   ylabel(20 "20"  40 "40", angle(90)) 

graph combine ${temp}Y.gph ${temp}A.gph ${temp}B.gph ${temp}c.gph, xcommon cols(1)  iscale(*1)  imargin(0 0 0 0) 

graph export  "${tables}new_deaton_graph.pdf", as(pdf) replace




cap drop rev_gen
g rev_gen = B-B[_n-1]

cap drop normal_rev
g normal_rev = (c*`=p_slope' + `=p_int')*c

sum normal_rev, detail
write "${tables}normal_rev.tex" `=r(mean)' 1 "%12.0g"
write "${tables}rev_max.tex" `=r(max)' 1 "%12.0g"









* graph combine ${temp}Y.gph ${temp}V.gph ${temp}D.gph ${temp}A.gph ${temp}B.gph ${temp}c.gph, xcommon cols(1)  iscale(*1)  imargin(0 0 0 0) 


* scatter Y id, saving("${temp}Y", replace) xtitle("     ", size(${tsize})) ytitle("Income:  y{subscript:t}") ///
* 	xlabel(0 " " 20 "  " 40 "  " 60 "  " 80 "  " 100 "   ") ${gr}

* line V id, saving("${temp}V", replace) xtitle("     ", size(${tsize})) ytitle("Delinquency Visit:  c{subscript:t}") ///
* 	ylabel(0 "No Visit" 1 "  Visit")  xlabel(0 " " 20 "  " 40 "  " 60 "  " 80 "  " 100 "   ") ${gr}

* line D id, saving("${temp}D", replace) xtitle("     ", size(${tsize})) ytitle("Disconnect:  D{subscript:t}") ///
* 	ylabel(0 "Connect  " 1 "Disconnect")  xlabel(0 " " 20 "  " 40 "  " 60 "  " 80 "  " 100 "   ") ${gr}

* line A id, saving("${temp}A", replace) xtitle("     ", size(${tsize})) ytitle("Standard Asset:  A{subscript:t+1}") ///
* 	xlabel(0 " " 20 "  " 40 "  " 60 "  " 80 "  " 100 "   ") ${gr}

* line B id, saving("${temp}B", replace) xtitle("Month", size(${tsize})) ytitle("Water Borrowing:  B{subscript:t+1}")  ///
* 	ylabel(0 "0" -2000 "-2000" -4000 "-4000" -6000 "-6000" -8000 "  -8000") ${gr}




* line A id, saving("${temp}A", replace) xtitle("      ", size(large)) xlabel(0 " " 20 " " 40 " " 60 " " 80 " " 100 " ") 

* line B id, saving("${temp}B", replace) xtitle("Month", size(large))

* graph combine ${temp}A.gph ${temp}B.gph, xcommon cols(1) imargin(0 0 0 0)