* export_scatter.do

grstyle init
grstyle set imesh, horizontal

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


sum am if T1d==2
scalar define am_2 = `=r(mean)'
	write "${tables}am_2.tex" `=am_2*100' 1 "%12.0g"

sum am if T1d==20
scalar define am_20 = `=r(mean)'
	write "${tables}am_20.tex" `=am_20*100' 1 "%12.0g"
	write "${tables}am_2_20.tex" `=(am_2*100) - (am_20*100)' 1 "%12.0g"

sum am if T1d==2 & a6==1
scalar define am6_2 = `=r(mean)'
	write "${tables}am6_2.tex" `=am6_2*100' 1 "%12.0g"

sum am if T1d==20 & a6==1
scalar define am6_20 = `=r(mean)'
	write "${tables}am6_20.tex" `=am6_20*100' 1 "%12.0g"
	write "${tables}am6_2_20.tex" `=(am6_2*100) - (am6_20*100)' 1 "%12.0g"


cap drop amar2
cap drop amar2a
		sort conacct date
		by conacct: g amar2 = am if tcd_id[_n-2]==1 & ar[_n-2]>90 & a6==1
		by conacct: g amar2a = am if  tcd_id[_n-2]==1 & ar[_n-2]<=90 & a6==1
sum amar2
	write "${tables}amar_2.tex" `=r(mean)*100' 1 "%12.0g"
sum amar2a
	write "${tables}amar_2a.tex" `=r(mean)*100' 1 "%12.0g"
	drop amar2 amar2a


cap program drop sp
prog define sp
	preserve
		`4'
		egen mv = mean(`2'), by(`3')
		bys `3': g dn=_n
		`1' mv `3' if dn==1
	restore
end



cap program drop sp2
prog define sp2
	global textsize "large"
	preserve
		`7'
		g `3'_1 = `3' if `5'==1
		egen mv_1 = mean(`3'_1), by(`4')
		g `3'_2 = `3' if `6'==1
		egen mv_2 = mean(`3'_2), by(`4')
		bys `4': g dn=_n
		twoway `2' mv_1 `4' if dn==1, lp(solid) lc(gs0) lw(medthick) || `2' mv_2 `4' if dn==1,     plotr(lw(medthick ))  lp(dash) lc(gs6) lw(medthick)  ytitle("`8'", size(${large})) xtitle("`9'", size(${large})) legend(pos(10) ring(0) col(1) lab(1 "`10'") lab(2 "`11'") size(${large})) xline(0, lw(thin)lp(shortdash))
	    graph export  "${tables}line_`1'.pdf", as(pdf) replace
	restore
end

global fulllab = "All Households"
global templab = "Stayers Only"
global xlab = "Months to First Delinquency Visit"

sp2 "disconnection" "line" am T1d aa a6 "keep if T1d!=."  "Share Disconnected" "${xlab}" "${fulllab}" "${templab}"

sp2 "bal" "line" bal T1d aa a6 "keep if T1d!=."  "Mean Unpaid Balance (PhP)"  "${xlab}" "${fulllab}" "${templab}"

sp2 "ar" "line" ar T1d aa a6 "keep if T1d!=." "Mean Days Overdue" "${xlab}" "${fulllab}" "${templab}"

sp2 "pay" "line" pay T1d aa a6 "keep if T1d!=." "Mean Monthly Payment (PhP)"  "${xlab}" "${fulllab}" "${templab}"

sp2 "c" "line" c T1d aa a6 "keep if T1d!=." "Mean Consumption for Connected HHs (m3)"  "${xlab}" "${fulllab}" "${templab}"


