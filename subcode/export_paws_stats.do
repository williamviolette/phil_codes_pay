* export_paws_stats.do


cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end


use "${temp}temp_descriptives_2.dta", clear


duplicates drop conacct, force

	write "${tables}paws_accounts.tex" `=_N' 0.1 "%12.0gc"


keep if disc_count!=.

	write "${tables}disc_count.tex" `=_N' 0.1 "%12.0gc"



	preserve
		keep conacct
		save "${temp}paws_stats_conacct.dta", replace
	restore


sum days_pay, detail
	write "${tables}days_pay_average.tex" `=r(mean)' 1 "%12.0g"

g dp_30=1 if days_pay<=30
replace dp_30=0 if days_pay>30 & days_pay<.
sum dp_30
	write "${tables}days_pay_under_30.tex" `=100*`=r(mean)'' 1 "%12.0g"

sum enough_time
	write "${tables}enough_time.tex" `=100*`=r(mean)'' 1 "%12.0g"


sum days_rec, detail
	write "${tables}days_rec_average.tex" `=r(mean)' .1 "%12.0g"





use "${data}paws/clean/full_sample_1.dta", clear

merge m:1 conacct using "${temp}paws_stats_conacct.dta"
keep if _merge==3
drop _merge


g disc_note = 1 if disc_notice == "Hindi"
replace disc_note = 0 if disc_notice == "Hindi Alam"
replace disc_note = 0 if disc_notice == "Oo"

sum disc_note
	write "${tables}disc_notice.tex" `=100*`=r(mean)'' 1 "%12.0g"

tab payment
drop if payment=="" 
g collector = regexm(payment,"Collector ng Maynilad")==1
***drop if collector==1

g atm = regexm(payment,"ATM")==1
sum atm
	write "${tables}atm.tex" `=100*`=r(mean)'' 1 "%12.0g"

g center = regexm(payment,"Bayad Center")==1
sum center
	write "${tables}center.tex" `=100*`=r(mean)'' 1 "%12.0g"

g maynilad = regexm(payment,"Business Center ng Maynilad")==1
sum maynilad
	write "${tables}maynilad.tex" `=100*`=r(mean)'' 1 "%12.0g"

*sum collector
*	write "${tables}collector.tex" `=100*`=r(mean)'' 0.1 "%12.0g"





/*

use "${data}paws/clean/full_sample_1.dta", clear

tab payment
drop if payment=="" 
g collector = regexm(payment,"Collector ng Maynilad")==1
***drop if collector==1

g atm = regexm(payment,"ATM")==1
sum atm
	write "${tables}atm.tex" `=100*`=r(mean)'' 0.1 "%12.0g"

g center = regexm(payment,"Bayad Center")==1
sum center
	write "${tables}center.tex" `=100*`=r(mean)'' 0.1 "%12.0g"

g maynilad = regexm(payment,"Business Center ng Maynilad")==1
sum maynilad
	write "${tables}maynilad.tex" `=100*`=r(mean)'' 0.1 "%12.0g"

sum collector
	write "${tables}collector.tex" `=100*`=r(mean)'' 0.1 "%12.0g"





/*

g leak = regexm(billing_error,"Leak")==1
g over_charge = regexm(billing_error,"Mahal na singil")==1






destring disc_times_extra, replace force
keep if disc_times_extra!=.  // keep only disconnect
drop if disc_times_extra==0
ren disc_times_extra disc_count

g disc_note = 1 if disc_notice == "Hindi"
replace disc_note = 0 if disc_notice == "Hindi Alam"
replace disc_note = 0 if disc_notice == "Oo"

destring days_before_rec_extra, replace
	ren days_before_rec_extra days_rec

destring  days_to_pay_extra, replace
	ren days_to_pay_extra days_pay

g enough_time1 = 1 if enough_time == "Hindi"
replace enough_time1 = 0 if enough_time == "Hindi Alam"
replace enough_time1 = 0 if enough_time == "Oo"
drop enough_time
ren enough_time1 enough_time
duplicates drop conacct, force




/*

keep conacct leak over_charge disc_count days_rec days_pay enough_time