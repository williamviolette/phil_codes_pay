* export_moments


global bc = 10

clear matrix
matrix define B = J(20,$bc,0)

set seed 10

* save "${temp}preboot.dta", replace

forvalues r=1/$bc { 
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

	global b=`r'
	global mom ""

	*** Price
		cap drop p_avg
		g p_avg = amount/c

		reg p_avg c
		matrix define p_reg=e(b)
		scalar define p_int=p_reg[1,2]
		scalar define p_slope=p_reg[1,1]
		global mom " $mom `=p_int' "
		global mom " $mom `=p_slope' "

	*** Disconnection rate
		sum tcd_id if ar_lag>31
		scalar define prob_caught = `=r(mean)'
		global mom " $mom `=r(mean)' "


	*** Consumption
		sum c, detail
		scalar define c_avg = `=r(mean)'
		global mom " $mom `=r(mean)' "

		egen c_i = mean(c), by(conacct)
		g c_norm = c - c_i
		sum c_norm, detail
		scalar define c_std = `=r(sd)'
		global mom " $mom `=r(sd)' "
			drop c_i c_norm

	*** Balance
		sum bal
		scalar define bal = `=r(mean)'
		global mom " $mom `=r(mean)' "

		egen bal_i = mean(bal), by(conacct)
		g bal_norm = bal - bal_i
		sum bal_norm 
		scalar define bal_std = `=r(sd)'
			global mom " $mom `=r(sd)' "
		drop bal_i bal_norm

		corr bal c
		matrix C = r(C)
		local cv "C[1,2]"
		scalar define bal_corr = `=`cv''
		global mom " $mom `=bal_corr' "

	*** Disconnection rate
		forvalues i=0/5 {
			sort conacct ns date
			cap drop am`i'
			by conacct: g am`i' = am if tcd_id[_n-`i']==1
			sum am`i', detail
			scalar define am`i' = `=r(mean)'
			global mom " $mom `=r(mean)' "
		}
		sum am0
		sum am1
		sum am2
		sum am3
		sum am4
		sum am5


	*** Disconnection rate : big balance
		forvalues i=0/5 {
			sort conacct ns date
			cap drop amar`i'
			by conacct: g amar`i' = am if tcd_id[_n-`i']==1 & ar[_n-`i']>90
			sum amar`i', detail
			scalar define amar`i' = `=r(mean)'
			global mom " $mom `=r(mean)' "
		}
		sum amar0
		sum amar1
		sum amar2
		sum amar3
		sum amar4
		sum amar5

	*disp " $mom "
	*global nvar : word count $mom

	global cc=1
	foreach v in $mom {
		disp "`v'"
		matrix B[$cc,$b] = `=`v''
		global cc = $cc + 1
	}
restore

}


preserve 
	clear
	svmat B
	export delimited "${moments}B.csv", delimiter(",") replace novarnames

restore
