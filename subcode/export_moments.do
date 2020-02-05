* export_moments





	*** THIS IS RIGHT


	* sum inc if inc_t==1
	* global inc_t1 = `=r(max)'
	* sum inc if inc_t==2
	* global inc_t2 = `=r(max)'

	* preserve 

	* 	use "${fies}fies_merged.dta", clear

	* 	g inc = toinc/12

	* 	sum inc, detail
	* 	global inc_mean = `=r(mean)'

	* 	* g 		inc_t = 1 if inc<=$inc_t1
	* 	* replace inc_t = 2 if inc>$inc_t1 & inc<=$inc_t2
	* 	* replace inc_t = 3 if inc>$inc_t2 

	* 	sum todisbdeposits, detail
	* 	global deposits = `=r(p95)'
	* 	sum todisbcashloan, detail 
	* 	global cashloan= `=r(p95)'

	* 	g loan = (todisbdeposits>100  & todisbdeposits<.) | (todisbcashloan>100 & todisbcashloan<.)

	* 	global mult= `=(${deposits} + ${cashloan})/ ${inc_mean}'

	* 	disp $mult

	* restore


	* 	sum inc, detail
	* 	global inc_m = `=r(mean)'
	* 	write "${moments}Ab.csv" `=$mult*$inc_m'  1 "%12.0g"
	* 	write "${tables}Ab.tex" `=$mult*$inc_m'  1 "%12.0fc"

	* 	forvalues r=1/3 {
	* 		sum inc if inc_t==`r', detail
	* 		global inc_m = `=r(mean)'
	* 		write "${moments}Ab_t`r'.csv" `=$mult*$inc_m' 1 "%12.0g"
	* 		write "${tables}Ab_t`r'.tex" `=$mult*$inc_m' 1 "%12.0fc"
	* 	}


		sum todisbdeposits, detail
		global deposits = `=r(p95)'
		sum todisbcashloan, detail 
		global cashloan= `=r(p95)'

		sum inc, detail
		global inc_m = `=r(mean)'
		write "${moments}Ab.csv" `=$deposits + $cashloan'  1 "%12.0g"
		write "${tables}Ab.tex" `=$deposits + $cashloan' 1 "%12.0fc"

		forvalues r=1/3 {
			sum todisbdeposits if inc_t==`r', detail
			global deposits = `=r(p95)'
			sum todisbcashloan if inc_t==`r', detail 
			global cashloan= `=r(p95)'
			write "${moments}Ab_t`r'.csv" `=$deposits + $cashloan' 1 "%12.0g"
			write "${tables}Ab_t`r'.tex" `=$deposits + $cashloan'  1 "%12.0fc"
		}



	forvalues r=1/3 {
	sum inc if inc_t==`r', detail
	write "${moments}y_avg_t`r'.csv" `=r(mean)' 0.1 "%12.0g"
	write "${tables}y_avg_t`r'.tex" `=r(mean)' 0.1 "%12.0g"
	}

	write "${tables}est_obs.tex" `=_N' 1 "%12.0fc"

	preserve
		keep conacct
		duplicates drop conacct, force
		write "${tables}est_hhs.tex" `=_N' 1 "%12.0fc"
	restore

*** Price
	cap drop p_avg
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
	sum bal if bal>0, detail
	write "${moments}Bb.csv" `=r(p95)' 1 "%12.0g"
	write "${tables}Bb.tex" `=r(p95)' 1 "%12.0fc"

	forvalues r=1/3 {
		sum bal if bal>0 & inc_t==`r', detail
		write "${moments}Bb_t`r'.csv" `=r(p95)' 1 "%12.0g"
		write "${tables}Bb_t`r'.tex" `=r(p95)' 1 "%12.0fc"
	}



*** Disconnection rate by income
	sum tcd_id if ar_lag>31
		write "${moments}prob_caught.csv" `=r(mean)' 0.0001 "%12.4g"
		write "${tables}prob_caught.tex" `=r(mean)*100' 0.1 "%12.1fc"
	
	forvalues r=1/3 {
		sum tcd_id if ar_lag>31 & inc_t==`r'
		write "${moments}prob_caught_t`r'.csv" `=r(mean)' 0.0001 "%12.4g"
		write "${tables}prob_caught_t`r'.tex" `=r(mean)*100' 0.01 "%12.2fc"
	}


cap drop tcd_id_31
g tcd_id_31 = tcd_id if ar_lag>31

cap drop tcd_id_31m
gegen tcd_id_31m = mean(tcd_id_31), by(ba)
sum tcd_id_31m, detail

		write "${tables}prob_caught_min.tex" `=r(min)*100' 0.1 "%12.1g"
		write "${tables}prob_caught_max.tex" `=r(max)*100' 0.1 "%12.1g"

drop tcd_id_31 tcd_id_31m


sum tcd_max, detail

		write "${tables}tcd_max.tex" `=r(mean)*100' 1 "%12.0g"


* sum tcd_id if ar_lag>31  & bal_lag>2000
* sum tcd_id if ar_lag>31  & bal_lag<2000





*** Consumption
	sum c, detail
		write "${moments}c_avg.csv" `=r(mean)' 0.1 "%12.0g"
		write "${tables}c_avg.tex" `=r(mean)' 0.1 "%12.0g"

	forvalues r=1/3 {
		sum c if inc_t==`r', detail
		write "${moments}c_avg_t`r'.csv" `=r(mean)' 0.1 "%12.0g"
		write "${tables}c_avg_t`r'.tex" `=r(mean)' 0.1 "%12.0g"
	}



	egen c_i = mean(c), by(conacct)
	g c_norm = c - c_i
	sum c_norm, detail
	write "${moments}c_std.csv" `=r(sd)' 0.1 "%12.0g" 
	write "${tables}c_std.tex" `=r(sd)' 0.1 "%12.0g" 
	forvalues r=1/3 {
		sum c_norm if inc_t==`r', detail
		write "${moments}c_std_t`r'.csv" `=r(sd)' 0.1 "%12.0g" 
		write "${tables}c_std_t`r'.tex" `=r(sd)' 0.1 "%12.0g" 		
	}
	drop c_i c_norm

*** Balance
	sum bal
	write "${moments}bal_avg.csv" `=r(mean)' 0.1 "%12.0g"
	write "${tables}bal_avg.tex" `=r(mean)' 0.1 "%12.0g"
	forvalues r=1/3 {
		sum bal if inc_t==`r'
		write "${moments}bal_avg_t`r'.csv" `=r(mean)' 0.1 "%12.0g"
		write "${tables}bal_avg_t`r'.tex" `=r(mean)' 0.1 "%12.0g"
	}

	sum bal, detail
	write "${moments}bal_med.csv" `=r(p50)' 0.1 "%12.0g"
	write "${tables}bal_med.tex" `=r(p50)' 0.1 "%12.0g"
	forvalues r=1/3 {
		sum bal if inc_t==`r', detail
		write "${moments}bal_med_t`r'.csv" `=r(p50)' 0.1 "%12.0g"
		write "${tables}bal_med_t`r'.tex" `=r(p50)' 0.1 "%12.0g"
	}

	egen bal_i = mean(bal), by(conacct)
	g bal_norm = bal - bal_i
	sum bal_norm 
	write "${moments}bal_std.csv" `=r(sd)' 0.1 "%12.0g"
	write "${tables}bal_std.tex" `=r(sd)' 0.1 "%12.0g"
	forvalues r=1/3 {
		sum bal_norm if inc_t==`r'
		write "${moments}bal_std_t`r'.csv" `=r(sd)' 0.1 "%12.0g"
		write "${tables}bal_std_t`r'.tex" `=r(sd)' 0.1 "%12.0g"
	}
	drop bal_i bal_norm


	corr bal c
	matrix C = r(C)
	local cv "C[1,2]"
	write "${moments}bal_corr.csv" `cv' 0.001 "%12.0g"
	write "${tables}bal_corr.tex" `cv' 0.001 "%12.0g"

	forvalues r=1/3 {
		corr bal c if inc_t==`r'
		matrix C = r(C)
		local cv "C[1,2]"
		write "${moments}bal_corr_t`r'.csv" `cv' 0.001 "%12.0g"
		write "${tables}bal_corr_t`r'.tex" `cv' 0.001 "%12.0g"
	}






* g tnn = tn
* by conacct: replace tnn=tnn[_n-1] if tnn==.

* g amg_ind = am if tcd_id[_n-1]==1 | tcd_id[_n-2]==1
* gegen amg = max(amg_ind), by(conacct tnn)
* replace amg = . if tnn!=tn
* gegen AMM = mean(amg), by(ar_lag)

* g amg_ind6 = am if tcd_id[_n-11]==1 | tcd_id[_n-12]==1
* gegen amg6 = max(amg_ind6), by(conacct tnn)
* replace amg6 = . if tnn!=tn
* gegen AMM6 = mean(amg6), by(ar_lag)

* sum amg if ar_lag>0
* sum amg if ar_lag>91

* gegen arn = tag(ar_lag)

* scatter AMM ar_lag if arn==1 & ar_lag>0 || scatter AMM6 ar_lag if arn==1 & ar_lag>0, 

* drop tn_*
* drop am_*


* drop am_d am_d4 tn_g0 tn_g4 tn_0 tn_4 tn

sort conacct tcd_id date
by conacct tcd_id: g tn=_n if tcd_id==1

g tnn = tn
sort conacct date
by conacct: replace tnn=tnn[_n-1] if tnn==.
by conacct: g amg_ind = am if tcd_id[_n-1]==1 | tcd_id[_n-2]==1
gegen amg = max(amg_ind), by(conacct tnn)
gegen dce = max(dc_enter), by(conacct tnn)

sort conacct tnn date
by conacct tnn: g t_n = _n if tnn!=. & am==1
by conacct tnn: g t_n0 = _n if tnn!=. & am==0

gegen t_n_dc = min(t_n), by(conacct tnn)
replace t_n0 = . if t_n0 < t_n_dc
gegen t_n_rec = min(t_n0), by(conacct tnn)

g dc_months = t_n_rec - t_n_dc

g NO_DC = amg==0             if tcd_id==1 & ar_lag>31 & date<664
g DC_TEMP = amg==1 & dce==0  if tcd_id==1 & ar_lag>31 & date<664
g DC_PERM = amg==1 & dce==1  if tcd_id==1 & ar_lag>31 & date<664

g NO_DC_3 = amg==0             if tcd_id==1 & ar_lag>91 & date<664
g DC_TEMP_3 = amg==1 & dce==0  if tcd_id==1 & ar_lag>91 & date<664
g DC_PERM_3 = amg==1 & dce==1  if tcd_id==1 & ar_lag>91 & date<664

g NO_DC_3l = amg==0             if tcd_id==1 & ar_lag>31 & ar_lag<91 & date<664
g DC_TEMP_3l = amg==1 & dce==0  if tcd_id==1 & ar_lag>31 & ar_lag<91 & date<664
g DC_PERM_3l = amg==1 & dce==1  if tcd_id==1 & ar_lag>31 & ar_lag<91 & date<664


sum NO_DC, detail
write "${tables}tcd_share_pay.tex" `=r(mean)*100' .1 "%12.0g"
sum DC_TEMP, detail
write "${tables}tcd_share_rec.tex" `=r(mean)*100' .1 "%12.0g"
write "${moments}tcd_share_rec.csv" `=r(mean)' 0.0001 "%12.4g"
sum DC_PERM, detail
write "${tables}tcd_share_dc.tex" `=r(mean)*100' .1 "%12.0g"

sum NO_DC_3, detail
write "${tables}tcd_share_pay_3.tex" `=r(mean)*100' .1 "%12.0g"
sum DC_TEMP_3, detail
write "${tables}tcd_share_rec_3.tex" `=r(mean)*100' .1 "%12.0g"
write "${moments}tcd_share_rec_3.csv" `=r(mean)' 0.0001 "%12.4g"
sum DC_PERM_3, detail
write "${tables}tcd_share_dc_3.tex" `=r(mean)*100' .1 "%12.0g"

sum NO_DC_3l, detail
write "${tables}tcd_share_pay_3l.tex" `=r(mean)*100' .1 "%12.0g"
sum DC_TEMP_3l, detail
write "${tables}tcd_share_rec_3l.tex" `=r(mean)*100' .1 "%12.0g"
sum DC_PERM_3l, detail
write "${tables}tcd_share_dc_3l.tex" `=r(mean)*100' .1 "%12.0g"


sum dc_months if DC_TEMP==1, detail
write "${tables}t_rec.tex" `=r(mean)' .1 "%12.0g"
sum dc_months if DC_TEMP_3==1, detail
write "${tables}t_rec_3.tex" `=r(mean)' .1 "%12.0g"
sum dc_months if DC_TEMP_3l==1, detail
write "${tables}t_rec_3l.tex" `=r(mean)' .1 "%12.0g"





* reg dc_months ar_lag i.date if DC_TEMP==1,  cluster(conacct) r
* areg dc_months ar_lag i.date if DC_TEMP==1,  cluster(conacct) r a(conacct)



* lab var ar_lag "Days Delinquent"

* reg DC_TEMP ar_lag i.date if tcd_id==1 & ar_lag>31 & date<664 & leaver==0,  cluster(conacct) r

* est sto dc_temp
* estadd local ctrl1 ""
* estadd local ctrl2 "\checkmark"
* sum DC_TEMP if e(sample)==1, detail
* estadd scalar Mean=`=r(mean)'

* areg DC_TEMP ar_lag  i.date if tcd_id==1 & ar_lag>31 & date<664 & leaver==0, absorb(conacct) cluster(conacct) r

* est sto dc_temp_fe
* estadd local ctrl1 "\checkmark"
* estadd local ctrl2 "\checkmark"
* sum DC_TEMP if e(sample)==1, detail
* estadd scalar Mean=`=r(mean)'

* estout dc_temp dc_temp_fe using "${tables}dc_reg.tex", replace  style(tex) ///
*     order( ar_lag  )   keep( ar_lag )     label ///
*       noomitted     mlabels(none)    collabels(none) ///
*       cells( b(fmt(5) star ) se(par fmt(5)) ) ///
*       stats( Mean ctrl1 ctrl2 r2 N,  ///
*     labels(  "Mean Temp. Disc." "Household FE" "Year-Month FE" "R$^2$"   "N"  ) ///
*         fmt( %9.2fc   %18s %18s %12.3fc   %12.0fc  )   ) ///
*     starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 





* sum amg if ar_lag>31 & tcd_id==1
* sum amg if ar_lag>91 & tcd_id==1

* sort conacct date
* g tn_0  = tn if ar_lag>31 & dc_enter!=1
* g tn_4 = tn if ar_lag>91 & dc_enter!=1

* g tn_g0=.
* g tn_g4=.

* 	forvalues i=1/2 {
* 		by conacct: replace tn_g0 = tn_0[_n-`i'] if tcd_id[_n-`i']==1
* 		by conacct: replace tn_g4 = tn_4[_n-`i'] if tcd_id[_n-`i']==1
* 	}

* egen am_d = max(am) if tn_g0!=., by(tn_g0 conacct)
* egen am_d4 = max(am) if tn_g4!=., by(tn_g4 conacct)


* sum am_d , detail
* write "${moments}am_d.csv" `=r(mean)' 0.0001 "%12.4g"

* 	forvalues r=1/3 {
* 	sum am_d if inc_t==`r', detail
* 	write "${moments}am_d_t`r'.csv" `=r(mean)' 0.0001 "%12.4g"
* 	}

* sum am_d4 , detail
* write "${moments}am_d4.csv" `=r(mean)' 0.0001 "%12.4g"

* 	forvalues r=1/3 {
* 	sum am_d4 if inc_t==`r', detail
* 	write "${moments}am_d4_t`r'.csv" `=r(mean)' 0.0001 "%12.4g"
* 	}






	

		* by conacct: g tcd_time`i' = am if tcd_id[_n-`i']==1 

*** Disconnection rate
	forvalues i=0/5 {
		sort conacct date
		by conacct: g am`i' = am if tcd_id[_n-`i']==1 
		sum am`i' , detail
		write "${moments}am`i'.csv" `=r(mean)' 0.0001 "%12.4g"
		
		forvalues r=1/3 {
			sum am`i' if inc_t==`r', detail
			write "${moments}am`i'_t`r'.csv" `=r(mean)' 0.0001 "%12.4g"
		}
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
		sum amar`i' , detail
		write "${moments}amar`i'.csv" `=r(mean)' 0.0001 "%12.4g"

		forvalues r=1/3 {
		sum amar`i' if inc_t==`r'  , detail
		write "${moments}amar`i'_t`r'.csv" `=r(mean)' 0.0001 "%12.4g"
		}
	}
	sum amar0
	sum amar1
	sum amar2
	sum amar3
	sum amar4
	sum amar5


egen am_t = rowmax(am0 am1 am2)



* preserve
* 	keep if leaver==1
* 	sum amar0
* 	sum amar1
* 	sum amar2
* 	sum amar3
* 	sum amar4
* 	sum amar5
* restore


