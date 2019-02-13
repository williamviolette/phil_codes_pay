* export_moments


*** Price
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
	drop p_avg


*** Disconnection rate
	sum tcd_id if ar_lag>31
		write "${moments}prob_caught.csv" `=r(mean)' 0.0001 "%12.4g"
		write "${tables}prob_caught.tex" `=r(mean)' 0.0001 "%12.4g"


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




