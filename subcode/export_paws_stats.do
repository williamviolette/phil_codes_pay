* export_paws_stats.do


cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end



use "${temp}temp_descriptives_2.dta", clear
	drop if date==653

*** Single HH's
	keep if SHH==1

*** Missing C : (<=20) drop 5%
	g cmiss = c==.
	egen cms=sum(cmiss), by(conacct)
	keep if cms<=20
	drop cms

*** Measure TCD  %%% ONLY KEEP THOSE THAT GET A DISCONNECTION NOTICE!! (CUS THEY ARE A DIFFERENT SAMPLE... BUT MATTER (OTHERWISE NEED INDIVIDUAL FIXED EFFECTS, WHICH ARE HARD!!))
	sort conacct date
	by conacct: g tcd_id = dc[_n-1]==0 & dc[_n]==1
	replace tcd_id = . if date<=602
	replace tcd_id = 0 if ar==0
	
	egen tcd_max=max(tcd_id), by(conacct)
	keep if tcd_max==1 




use "${data}paws/clean/full_sample_1.dta", clear

g dc_note = 1 if regexm(disc_notice,"Oo")==1
replace dc_note=0 if regexm(disc_notice,"Hindi")==1
sum dc_note
	write "${tables}dc_note.tex" `=100*`=r(mean)'' 0.1 "%12.0g"






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