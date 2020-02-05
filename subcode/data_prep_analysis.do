

global data_prep   = 1
global data_prep_2 = 1


if $data_prep == 1 {

	* do fies_projection.do

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
			*g cnn = date if c!=.
			*egen cnn_min=min(cnn), by(conacct)
			*drop if date<cnn_min
			*drop cnn cnn_min
		g ts = ba==.
			gegen bam=max(ba), by(conacct)
			replace ba = bam
			drop bam

			fmerge m:1 conacct using "${temp}paws_temp.dta"
			drop if _merge==2
			drop _merge

			fmerge m:1 barangay_id using "${temp}barangay_merge.dta"
			drop if _merge==2
			drop _merge

			fmerge m:1 conacct using "${temp}paws_dc.dta"
			drop if _merge==2
			drop _merge

			fmerge m:1 conacct using "${temp}paws_edu.dta"
			drop if _merge==2
			drop _merge

			fmerge m:1 conacct using "${phil_folder}promissory_note/temp/date_c.dta"
			drop if _merge==2
			drop _merge

			fmerge 1:1 conacct date using "${temp}paws_temp_date.dta"
			drop if _merge==2
			drop _merge


			drop if date<date_c


	save "${temp}temp_descriptives.dta", replace
}



if $data_prep_2 == 1 {

cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end

cap prog drop writeN
prog define writeN
	global NT = `=_N'
	write "${tables}`1'.tex" `=${NN}-${NT}' 1 "%12.0fc"
end

cap prog drop NN
prog define NN
	global NN=`=_N'
end




use "${temp}temp_descriptives.dta", clear

* Keep valid dates 
	keep if date>date_c
	* keep if date>=602
	drop if date==653
	global date_N = `=_N'
	NN
	write "${tables}date_N.tex" `=${date_N}' 1 "%12.0fc"


* Keep residential
	egen max_class = max(class), by(conacct)
	keep if max_class==1
	drop max_class
	writeN class_drop


* Adjust amount for VAT
	g amount1 = amount
	replace amount1 = amount + .12*amount 
	replace amount1 = amount + .013*amount if date<624 & c<=10
	drop amount
	ren amount1 amount

* Keep only accounts with payment records
	g p1 = pay>0 & pay<.
	egen ps=sum(p1), by(conacct)
	NN
	keep if ps>3
	drop ps p1  
	writeN pay_drop
	
* Account for zero payment months
	replace pay = 0 if pay==.

* Missing balance and small balance equal to zero ; keeps negative balances
	* replace bal=0 if (bal<=10 & bal>=-10) | bal==.
	replace bal=0 if (bal<=10 & bal>=-10) | bal==.


	g amount_r = round(amount,50)
	g yr = round(date,12)
	egen amount_r_date = group(amount_r yr)
	g c_low = c if c<=100
	egen c_mean=mean(c_low), by(amount_r_date)
	replace c_mean = round(c_mean,1)

	replace c = c_mean if c>(c_mean+10)  & c<.
	egen c_max=max(c), by(conacct)

* Outliers
	NN
	drop if c_max>200      
	writeN chigh_drop
	drop amount_r yr amount_r_date c_low c_mean c_max


	NN
	egen min_amount = min(amount), by(conacct)
	drop if min_amount<-5000
	egen max_amount = max(amount), by(conacct)
	drop if max_amount>20000
	* keep if (amount>=-5000 & amount<=80000) | amount==.
	global amount_N = `=_N'
	writeN amount_drop
	drop min_amount max_amount

	* NN
	* sum bal if bal<0, detail    
	* drop if bal<-5000
	NN
	egen max_bal =max(bal), by(conacct)
 	egen min_bal = min(bal), by(conacct)
	* sum bal if bal>0, detail
	drop if max_bal>80000  
	drop if min_bal<-10000
	writeN bal_drop
	drop max_bal
 


	*** DON'T NEED PAY FILTER ANYMORE
	* NN
	replace pay =0 if pay<0
	egen max_pay = max(pay), by(conacct)
	keep if max_pay<50000 
	drop max_pay 
	* global paylh_N=`=_N'
	* writeN paylh_drop



* Adjust ar in line with balance
*// if balance is zero, then AR should be zero
	replace ar = ar+30
	replace ar = 0 if ar==.
	replace ar = 0 if bal<=0     
	g pay_shr = (pay)/(bal+amount)  
* // if payment exceeds balance and amount, then AR should be zero
	replace ar = 0 if pay_shr>1 & pay_shr<.    
	drop pay_shr

* Observe at least 30 months of data
	* NN
	* sort conacct date
	* by conacct: g cN=_N
	* keep if cN>=30
	* drop cN  
	* writeN month_drop

* Keep single households
	NN
	keep if SHH==1
	global SHH_N = `=_N'
	write "${tables}SHH_N.tex" `=${SHH_N}' 1 "%12.0fc"
	writeN SHH_drop

* Clean disconnection data   *** address holes
	replace dc = 0 if dc==.
	sort conacct date
	by conacct: g dch = dc[_n-1]==1 & dc==0 & dc[_n+1]==1
		* Tab dch   // only 661 cases, so pretty clean
	replace dc = 1 if dch==1
	drop dch

* Disconnection measure
	g am=amount==.
	g aml = amount==. & date>=652
	egen amls = sum(aml), by(conacct)
	g am12 = amls==12
	drop aml amls

	global am_N = `=_N'
	write "${tables}am_N.tex" `=${am_N}' 1 "%12.0fc"

	* preserve
	* 	NN
	* 	drop if am12==1
	* 	global am_N = `=_N'
	* 	writeN dc_drop
	* 	write "${tables}am_N.tex" `=${am_N}' 1 "%12.0fc"
	* restore

	sort conacct date
	by conacct: g tcd_id=dc[_n-1]!=1 & dc[_n]==1
	replace tcd_id = 0 if date==588
	* replace tcd_id = 0 if date==602

	egen tcd_max=max(tcd_id), by(conacct)

	order conacct date c amount bal pay ar tcd_id dc 

	fmerge  m:1 conacct  using "${temp}mcf_ba.dta"
	drop if _merge==2
	drop _merge


	* cap drop inc
	* est use "${fies}inc_projection"
	* predict inc1, xb
	* g inc=exp(inc1)
	* drop inc1


	* est use "${fies}inc_projection"
	* predict inc1, xb
	* g inc_fies=exp(inc1)
	* drop inc1
	* reg c inc if todisbcashloan!=.
	* reg c inc_fies if todisbcashloan!=.


		*** HOUSEHOLD CORRECTION HERE ***
		
	* replace c = c/SHH 
	* NEED TO ALSO DIVIDE PAYMENTS, AND MAKE ASSUMPTIONS ON CREDIT ACROSS HOUSEHOLDS

save "${temp}temp_descriptives_2.dta", replace


}





