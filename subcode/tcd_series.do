


use "${temp}mcf_temp_tcd.dta", clear

cap program drop graph_trend
program define graph_trend
	preserve
		`2'
		`3'
		g o=1
		egen N=sum(o), by(date ba)
		bys date ba: g nn=_n
		keep if nn==1

		egen Nm=max(N), by(ba)
		drop if N==Nm
		drop Nm
		egen Nm=max(N), by(ba)
		replace N=N/Nm

		scatter N date, by(ba)

	   	* graph export  "${temp}`1'_trend.pdf", as(pdf) replace
	restore
end

graph_trend




/*

use "${temp}ar_temp_tcd.dta", clear

drop if date==664
g o = 1

g ar1= ar<=91


cap program drop graph_trend
program define graph_trend
	preserve
		`2'
		`3'
		egen N=sum(o), by(date ba)
		bys date ba: g nn=_n
		keep if nn==1

		egen Nm=max(N), by(ba)
		drop if N==Nm
		drop Nm
		egen Nm=max(N), by(ba)
		replace N=N/Nm

		scatter N date, by(ba)

	   	graph export  "${temp}`1'_trend.pdf", as(pdf) replace
	restore
end


cap program drop graph_trend
program define graph_trend
	preserve
		`2'
		`3'
		egen N=sum(o), by(date ba ar1)
		bys date ba ar1: g nn=_n
		keep if nn==1

		egen Nm=max(N), by(ba ar1)
		drop if N==Nm
		drop Nm
		egen Nm=max(N), by(ba ar1)
		replace N=N/Nm

		scatter N date, by(ba ar1)

	   	graph export  "${temp}`1'_trend.pdf", as(pdf) replace
	restore
end


graph_trend testing_this

