


	use "${temp}ar_temp_pay.dta", clear
		duplicates drop conacct date, force
			merge 1:m conacct date using "${temp}bill_temp_pay.dta"
			drop _merge
		duplicates drop conacct date, force		

			merge 1:m conacct date using "${temp}mcf_temp_pay.dta"
			drop _merge
		duplicates drop conacct date, force

			merge 1:m conacct date using "${temp}coll_temp_pay.dta"
			drop _merge
		duplicates drop conacct date, force		

		tsset conacct date
		tsfill, full
			g cnn = date if c!=.
			egen cnn_min=min(cnn), by(conacct)
			drop if date<cnn_min
			drop cnn cnn_min
		g ts = ba==.
			egen bam=max(ba), by(conacct)
			replace ba = bam
			drop bam

			merge m:1 conacct date using "${temp}paws_temp_wave.dta"
			drop if _merge==2
			drop _merge

	save "${temp}temp_descriptives_wave.dta", replace





use "${temp}temp_descriptives_wave.dta", clear

	g inwave=hhsize!=.

	sort conacct date
	foreach var of varlist hhsize hhemp SHH SHO {
	by conacct: replace `var' = `var'[_n-1] if `var'==.
	}


	*keep if hhsize!=.

	replace pay = 0 if pay==.

	g del = ar>=91 & ar<720
	replace ar = ar + 15
	replace ar = 0 if ar==.
	replace ar = . if c==.

	sort conacct date

	replace job = 0 if job==1


	tab job, g(J_)

	sort conacct date
	foreach var of varlist pay c del ar hhemp hhsize SHH SHO low_skill J_* job {
		by conacct: g `var'_ch= `var'[_n]-`var'[_n-1]
	}

	keep if inwave==1

	keep if hhsize<=8
	keep if hhemp<=4


	preserve 
		keep if hhemp_ch<=3 & hhemp_ch>=-3
		keep if hhsize_ch<=6 & hhsize_ch>=-6
		keep if c_ch<=25 & c_ch>=-25

		reg c_ch hhemp_ch  hhsize_ch  SHH_ch SHO_ch i.wave , cluster(conacct) r 

		reg ar_ch c_ch hhemp_ch  hhsize_ch   SHH_ch SHO_ch i.wave , cluster(conacct) r 

		reg del_ch c_ch hhemp_ch  hhsize_ch  SHH_ch SHO_ch i.wave , cluster(conacct) r

* reg pay_ch c_ch hhemp_ch  hhsize_ch   SHH_ch SHO_ch if pay_ch<=500 & pay_ch>=-500, cluster(conacct) r

	restore







	preserve 
		keep if hhemp_ch<=3 & hhemp_ch>=-3
		keep if hhsize_ch<=6 & hhsize_ch>=-6
		keep if c_ch<=25 & c_ch>=-25
		keep if low_class==1

		reg c_ch hhemp_ch low_skill_ch hhsize_ch SHH_ch SHO_ch, cluster(conacct) r

		reg pay_ch c_ch c hhemp_ch low_skill_ch hhsize_ch SHH_ch SHO_ch if pay_ch<=500 & pay_ch>=-500, cluster(conacct) r

		reg ar_ch c_ch c  hhemp_ch low_skill_ch hhsize_ch SHH_ch SHO_ch, cluster(conacct) r

		reg del_ch c_ch c  hhemp_ch low_skill_ch hhsize_ch SHH_ch SHO_ch, cluster(conacct) r

	restore





	preserve 
		keep if hhemp_ch<=3 & hhemp_ch>=-3
		keep if hhsize_ch<=6 & hhsize_ch>=-6
		keep if c_ch<=25 & c_ch>=-25
		keep if low_class==0

		reg c_ch hhemp_ch low_skill_ch hhsize_ch SHH_ch SHO_ch, cluster(conacct) r

		reg pay_ch hhemp_ch low_skill_ch hhsize_ch SHH_ch SHO_ch if pay_ch<=500 & pay_ch>=-500, cluster(conacct) r

		reg ar_ch hhemp_ch low_skill_ch hhsize_ch SHH_ch SHO_ch, cluster(conacct) r

		reg del_ch hhemp_ch low_skill_ch hhsize_ch SHH_ch SHO_ch, cluster(conacct) r

	restore

	






use "${temp}temp_descriptives_wave.dta", clear

	sort conacct date
	foreach var of varlist hhsize hhemp SHH SHO {
	by conacct: replace `var' = `var'[_n-1] if `var'==.
	}

	g p = pay!=.
	egen sp = sum(p), by(conacct)
	keep if sp > 10

	g cnm= c>0 & c<.
	egen cs=sum(cnm), by(conacct)
	keep if cs>64

	drop if date==592 | date==593 | date==595
	*keep if date<=625 & date>=600
	keep if date<=635
	*keep if SHH<=2
	keep if hhsize<=8
	keep if hhemp<=4

	replace pay = 0 if pay==.
	*drop if c==.

g del = ar>=91 & ar<720
	* by conacct: replace hhsize = hhsize[_n+1] if hhsize==.
replace ar = ar + 15
replace ar = 0 if ar==.
replace ar = . if date<600


	areg c hhemp i.hhsize SHH SHO i.date , absorb(conacct) cluster(conacct) r
	areg ar hhemp i.hhsize SHH SHO i.date, absorb(conacct) cluster(conacct) r




*** can also do with changes, but doesn't work so well.... 

	sort conacct date

	foreach var of varlist c del ar hhemp hhsize SHH SHO {
		by conacct: g `var'_ch= `var'[_n]-`var'[_n-1]
	}


	preserve 
		keep if hhemp_ch<=2 & hhemp_ch>=-2 
		keep if hhsize_ch<=4 & hhsize_ch>=-4
		keep if c_ch<=25 & c_ch>=-25


		reg c_ch hhemp_ch hhsize_ch SHH_ch SHO_ch, cluster(conacct) r


		xi: reg c_ch i.hhemp_ch i.hhsize_ch SHH_ch SHO_ch, cluster(conacct) r



	reg del_ch hhemp_ch hhsize_ch SHH_ch SHO_ch, cluster(conacct) r


	reg del_ch hhemp_ch hhsize_ch SHH_ch SHO_ch  if hhemp_ch<=2 & hhemp_ch>=-2, cluster(conacct) r







