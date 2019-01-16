* export_paws_stats.do


cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end





use "${data}paws/clean/full_sample_1.dta", clear
 
g dc_note = 1 if regexm(disc_notice,"Oo")==1
replace dc_note=0 if regexm(disc_notice,"Hindi")==1
sum dc_note
	write "${tables}dc_note.tex" `=100*`=r(mean)'' 0.1 "%12.0g"

destring days_to_pay_extra, replace force
sum days_to_pay_extra
	write "${tables}days_pay_average.tex" `=r(mean)' 0.1 "%12.0g"

g dp_30=1 if days_to_pay_extra<=30
replace dp_30=0 if days_to_pay_extra>30 & days_to_pay_extra<.
sum dp_30
	write "${tables}days_pay_under_30.tex" `=100*`=r(mean)'' 0.1 "%12.0g"


g et = 1 if regexm(enough_time,"Oo")==1
replace et=0 if regexm(enough_time,"Hindi")==1
sum et
	write "${tables}enough_time.tex" `=100*`=r(mean)'' 0.1 "%12.0g"





*** WHAT PERCENT ACTUALLY DISCONNECT?!

use "${temp}temp_descriptives_2.dta", clear
	drop if date==653

	keep if SHH==1

*** Missing C : (<=20) drop 5%
	* g cmiss = c==.
	* egen cms=sum(cmiss), by(conacct)
	* keep if cms<=20
	* drop cms

*** Measure TCD  %%% ONLY KEEP THOSE THAT GET A DISCONNECTION NOTICE!! (CUS THEY ARE A DIFFERENT SAMPLE... BUT MATTER (OTHERWISE NEED INDIVIDUAL FIXED EFFECTS, WHICH ARE HARD!!))
	sort conacct date
	by conacct: g tcd_id = dc[_n-1]==0 & dc[_n]==1
	replace tcd_id = . if date<=602
	replace tcd_id = 0 if ar==0
	
	sort conacct date
	by conacct: g post_tcd = tcd_id==1 | tcd_id[_n-1]==1 | tcd_id[_n-2]==1 | tcd_id[_n-3]==1 
	g pt_id=.
	forvalues r = 0/3 {
		replace pt_id = cn[_n-`r'] if tcd_id[_n-`r']==1
	}
	g cmt = c==. & post_tcd==1
	egen pts = sum(post_tcd), by(conacct pt_id)
	egen cmts=sum(cmt), by(conacct pt_id)

	g share=cmts/pts

	tab cmts if pts==4


	tab cmts




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

 	g ar_dc = ar if tcd_id==1
 	sum ar_dc
		write "${tables}ar_dc.tex" `=r(mean)' 0.1 "%12.0g"

	sort conacct date
	by conacct: g cn=_n

	sort conacct date
	by conacct: g post_tcd = tcd_id==1 | tcd_id[_n-1]==1 | tcd_id[_n-2]==1 

	g pt_id=.
	forvalues r = 0/2 {
		replace pt_id = cn[_n-`r'] if tcd_id[_n-`r']==1
	}

	g ar_post = ar if post_tcd==1

	egen ar_min=min(ar_post), by(conacct pt_id)

	g no_pay = pay==.
	g p0 = pay>0 & pay<.
	egen p0_min = min(p0), by(conacct pt_id)

	egen no_pay_min = min(no_pay), by(conacct pt_id)

	g paid=0 if ar_min!=.
	replace paid =1 if  ar_min<=46
 	sum paid
		write "${tables}share_pay_3_months.tex" `=100*r(mean)' 0.1 "%12.0g"



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