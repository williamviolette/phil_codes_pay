* export_moments


	write "${tables}est_obs.tex" `=_N' 1 "%12.0fc"

	preserve
		keep conacct
		duplicates drop conacct, force
		write "${tables}est_hhs.tex" `=_N' 1 "%12.0fc"
	restore

*** Price
	g p_avg = amount/c
	sum p_avg
	write "${moments}p_avg.csv" `=r(mean)' 0.1 "%12.0g"
	write "${tables}p_avg.tex" `=r(mean)' 0.1 "%12.0g"

	reg p_avg c
	est sto preg
	matrix define p_reg=e(b)
	scalar define p_int=p_reg[1,2]
	scalar define p_slope=p_reg[1,1]

	write "${moments}p_int.csv" `=p_int' 0.001 "%12.0g"
	write "${moments}p_slope.csv" `=p_slope' 0.001 "%12.0g"

	write "${tables}p_int.tex" `=p_int' 0.1 "%12.1fc"
	write "${tables}p_slope.tex" `=p_slope' 0.1 "%12.1fc"

	lab var c "Usage (m3)"

	estout preg using "${tables}price_reg.tex", replace  ///
	style(tex) ///
	varlabels(_cons "Intercept", el( c "[0.5em]" _cons "[0.5em]")) label noomitted mlabels(,none) collabels(none) ///
    cells( b(fmt(2) star ) se(par fmt(2)) ) ///
     starlevels( ///
    "\textsuperscript{c}" 0.10  ///
    "\textsuperscript{b}" 0.05  ///
    "\textsuperscript{a}" 0.01)  ///
      stats(N , fmt(%9.0fc )   ///
      labels( ///
      "Household-Months" )  ) 


	sum amount if c<5 & amount>0 & amount<200  & amount>50, detail
			write "${tables}f_10.tex" `=r(mean)' 0.01 "%12.2fc"
	sum amount if c==11 & amount>0 & amount<250, detail
	scalar define c11=`=r(mean)'
	sum p_avg if c>11 & c<20 & p_avg>10 & p_avg<200, detail
			write "${tables}f_11.tex" `=c11 - r(mean)' 0.01 "%12.2fc"
			write "${tables}c_12.tex" `=r(mean)' 0.01 "%12.2fc"
	sum p_avg if c>21 & c<40 & p_avg>10 & p_avg<200, detail
			write "${tables}c_21.tex" `=r(mean)' 0.01 "%12.2fc"
	sum p_avg if c>41 & c<60 & p_avg>20 & p_avg<200, detail
			write "${tables}c_41.tex" `=r(mean)' 0.01 "%12.2fc"
	sum p_avg if c>61 & c<80 & p_avg>10 & p_avg<200, detail
			write "${tables}c_61.tex" `=r(mean)' 0.01 "%12.2fc"
	sum p_avg if c>81 & c<100 & p_avg>30 & p_avg<200, detail
			write "${tables}c_81.tex" `=r(mean)' 0.01 "%12.2fc"
	sum p_avg if c>101 & c<150 & p_avg>30 & p_avg<200, detail
			write "${tables}c_101.tex" `=r(mean)' 0.01 "%12.2fc"
	sum p_avg if c>151 & c<200 & p_avg>30 & p_avg<200, detail
			write "${tables}c_151.tex" `=r(mean)' 0.01 "%12.2fc"
			write "${tables}c_200.tex" `=r(mean)*(1+0.042)' 0.01 "%12.2fc"



*** balance 95th percentile bound
	sum bal if bal>=0, detail
	write "${moments}Bb.csv" `=r(p95)' 1 "%12.0g"
	write "${tables}Bb.tex" `=r(p95)' 1 "%12.0fc"

*** Disconnection rate
	sum tcd_id if ar_lag>31
		write "${moments}prob_caught.csv" `=r(mean)' 0.0001 "%12.4g"
		write "${tables}prob_caught.tex" `=r(mean)*100' 0.01 "%12.2fc"


*** Consumption
	sum c, detail
		write "${moments}c_avg.csv" `=r(mean)' 0.1 "%12.0g"
		write "${tables}c_avg.tex" `=r(mean)' 0.1 "%12.0g"

	egen c_i = mean(c), by(conacct)
	g c_norm = c - c_i
	sum c_norm, detail
	write "${moments}c_std.csv" `=r(sd)' 0.1 "%12.0g" 
	write "${tables}c_std.tex" `=r(sd)' 0.1 "%12.0g" 
	drop c_i c_norm

*** Balance
	sum bal
	write "${moments}bal_avg.csv" `=r(mean)' 0.1 "%12.0g"
	write "${tables}bal_avg.tex" `=r(mean)' 0.1 "%12.0g"

	egen bal_i = mean(bal), by(conacct)
	g bal_norm = bal - bal_i
	sum bal_norm 
	write "${moments}bal_std.csv" `=r(sd)' 0.1 "%12.0g"
	write "${tables}bal_std.tex" `=r(sd)' 0.1 "%12.0g"
	drop bal_i bal_norm

	corr bal c
	matrix C = r(C)
	local cv "C[1,2]"
	write "${moments}bal_corr.csv" `cv' 0.001 "%12.0g"
	write "${tables}bal_corr.tex" `cv' 0.001 "%12.0g"


*** Disconnection rate
	forvalues i=0/5 {
		sort conacct date
		by conacct: g am`i' = am if tcd_id[_n-`i']==1
		sum am`i', detail
		write "${moments}am`i'.csv" `=r(mean)' 0.0001 "%12.4g"
	}
	sum am0
	sum am1
	sum am2
	sum am3
	sum am4
	sum am5


*** Disconnection rate : big balance
	forvalues i=0/5 {
		sort conacct date
		by conacct: g amar`i' = am if tcd_id[_n-`i']==1 & ar[_n-`i']>90
		sum amar`i', detail
		write "${moments}amar`i'.csv" `=r(mean)' 0.0001 "%12.4g"
	}
	sum amar0
	sum amar1
	sum amar2
	sum amar3
	sum amar4
	sum amar5




