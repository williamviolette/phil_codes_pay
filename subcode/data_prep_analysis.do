

global data_prep   = 0
global data_prep_2 = 0


if $data_prep == 1 {
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

			merge 1:m conacct date using "${temp}bill_total_temp_pay.dta"
			drop _merge
		duplicates drop conacct date, force	

			merge 1:m conacct date using "${temp}ar_bal_temp_pay.dta"
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

			merge m:1 conacct using "${temp}paws_temp.dta"
			drop if _merge==2
			drop _merge

			merge m:1 conacct using "${temp}paws_dc.dta"
			drop if _merge==2
			drop _merge

	save "${temp}temp_descriptives.dta", replace
}



if $data_prep_2 == 1 {

use "${temp}temp_descriptives.dta", clear

	replace bal=0 if bal<=5
	replace bal=. if bal>8000

	g p = pay!=.
	egen sp = sum(p), by(conacct)
	keep if sp > 10
	
	egen mp = max(pay), by(conacct)
	keep if mp < 10000

	egen mc = max(c), by(conacct)
	drop if mc > 200

	keep if date>=600
	drop mp mc sp p

	egen max_class = max(class), by(conacct)
	keep if max_class==1
	drop max_class

	replace ar = ar + 30 if ar<=361
	* replace ar = ar + 15 if ar <361
	* 	replace ar = 361 + (541-361)/2 if ar==361
	* 	replace ar = 541 + (720-540)/2 if ar==541
		replace ar = 0 if ar==.
	replace dc = 0 if dc==.
	g cp = c!=.

	merge  m:1 conacct using "${temp}mcf_ba.dta"
	drop if _merge==2
	drop _merge

	replace amount =. if amount<10 | amount>5000

save "${temp}temp_descriptives_2.dta", replace

}



