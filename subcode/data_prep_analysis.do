

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
			*g cnn = date if c!=.
			*egen cnn_min=min(cnn), by(conacct)
			*drop if date<cnn_min
			*drop cnn cnn_min
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

			merge m:1 conacct using "${phil_folder}promissory_note/temp/date_c.dta"
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
	keep if date>=602
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
	replace bal=0 if (bal<=5 & bal>=-5) | bal==.

* Outliers
	NN
	drop if c>200 & c<.        
	writeN chigh_drop

	NN
	keep if (amount>=-5000 & amount<=80000) | amount==.
	global amount_N = `=_N'
	writeN amount_drop

	NN
	sum bal if bal<0, detail    
	drop if bal<-5000
	sum bal if bal>0, detail
	drop if bal>80000 & bal<.    
	writeN bal_drop

	NN
	keep if pay>=-80000 & pay<=80000   
	global paylh_N=`=_N'
	writeN paylh_drop

* Adjust ar in line with balance
*// if balance is zero, then AR should be zero
	replace ar = 0 if bal<=0     
	g pay_shr = (pay)/(bal+amount)  
* // if payment exceeds balance and amount, then AR should be zero
	replace ar = 0 if pay_shr>1 & pay_shr<.    
	drop pay_shr

* Observe at least 30 months of data
	NN
	sort conacct date
	by conacct: g cN=_N
	keep if cN>=30
	drop cN  
	writeN month_drop

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

	preserve
		NN
		drop if am12==1
		global am_N = `=_N'
		writeN dc_drop
		write "${tables}am_N.tex" `=${am_N}' 1 "%12.0fc"
	restore

	sort conacct date
	by conacct: g tcd_id=dc[_n-1]!=1 & dc[_n]==1
	replace tcd_id = 0 if date==602
	*** dc's on 654 seem suspicious, given that 653 is removed...

	egen tcd_max=max(tcd_id), by(conacct)

	order conacct date c amount bal pay ar tcd_id dc 

	merge  m:1 conacct using "${temp}mcf_ba.dta"
	drop if _merge==2
	drop _merge

save "${temp}temp_descriptives_2.dta", replace


}





/*


*** Test: the amount measure!
	g dc1=dc
	replace dc1=0 if dc==.

	sum am if dc1==0
	sum am if dc1==1

	sort conacct date
	by conacct: g bal_ch = bal[_n]-bal[_n-1]

	g bal_ch0=bal_ch==0

	sum bal_ch0 if amount==.  // (ONLY A 5% ERROR RATE)
	sum bal_ch0 if amount!=.

	sum bal_ch if cm==1





* GET RID OF yeaR ABSENCES!
	** if more than 12 c==0's

	** IF PAY MOST THEN FIX AR

	** replace ar = 0 if 

	** throw out two disconnections right next to each other?!







*** DISCONNECTION CLEANING

* People who disconnect for a long time


* c == 0 seems ok







	order conacct date c amount  bal bal_ch pay dc pay_shr ar



	sort conacct date
	by conacct: g bal_lead = bal[_n+1]
	by conacct: g bal_ch = bal[_n]-bal[_n-1]
	by conacct: g pm_pr1 = pay[_n-1]==.
	by conacct: g pm_po1 = pay[_n+1]==.
	by conacct: g pm   = pay==.
	by conacct: g bal_lag = bal[_n-1]
	by conacct: g pay_lag = pay[_n-1]
	by conacct: g pay_lead = pay[_n+1]


	by conacct: g tcdid=dc[_n-1]!=1 & dc[_n]==1
	egen tcdmax=max(tcdid), by(conacct)

g d1=dofm(date)
g year = year(d1)
g month = month(d1)

	g bal_alt = amount1 + bal_lag - pay
	replace bal_alt = amount1+ bal_lag if pay==.

	

	order conacct date c amount1  bal pay dc pay_shr bal_alt bal_lead ar   amount   bal_ch  



	order conacct date amount1  bal pay pay_lead  pay_lag bal_alt bal_lead ar   amount   bal_ch  


	*** CREATE MY OWN METRIC!

	* * take first non-missing balance
	** then generate a series from it!

	gen bal1_id =date if  bal>50 & bal<.
	egen bal1 = min(bal1_id), by(conacct)

	cap drop bal_start
	cap drop bn

	g bal_start = bal if date == bal1 

	g bn= bal_start
	forvalues r = 1/20 {
		by conacct: replace bn = bn[_n-1] + amount1 - pay  if date[_n-`r'] == bal1
	}

	g bn_diff = bal-bn

	order conacct date amount amount1  bal bal_ch bal_start bn bn_diff pay bal_alt bal_lead ar


	cap drop bal_neg
	cap drop bal_neg_id


	g bal_neg_id = 0 if bn!=.
	replace bal_neg_id =1 if  bal<-100 &  bn!=.
	egen bal_neg = sum(bal_neg_id), by(conacct)

	g bn_neg_id = 0 if bn!=.
	replace bn_neg_id = 1 if bn<-100 & bn!=.
	egen bn_neg = sum(bn_neg_id), by(conacct)


	sum bal_neg
	sum bn_neg


	 // new balance = total owed next period = amount used (amount1) - paid this period (pay)



	sort conacct date




* 	g b_pm = bal_ch if pm==1 & pm_pr1==1 & pm_po1==1
* g vat = (b_pm - amount)/amount
* browse if vat!=. & year==2012 & month==8
* egen mvat = mean(vat), by(date c)
* bys date c: g dc=_n


* scatter mvat c if dc==1 & year==2010 & month==8 & c<=50 & mvat>0 & mvat<.2 || ///
* scatter mvat c if dc==1 & year==2011 & month==8 & c<=50 & mvat>0 & mvat<.2 || /// 
* scatter mvat c if dc==1 & year==2012 & month==8 & c<=50 & mvat>0 & mvat<.2 || ///
* scatter mvat c if dc==1 & year==2013 & month==8 & c<=50 & mvat>0 & mvat<.2 || /// 
* scatter mvat c if dc==1 & year==2014 & month==8 & c<=50 & mvat>0 & mvat<.2 || ///
* scatter mvat c if dc==1 & year==2015 & month==2 & c<=50 & mvat>0 & mvat<.2

* scatter mvat c if dc==1 & year==2010 & month==8 & c<=50 & mvat>0 & mvat<.2 || ///
* scatter mvat c if dc==1 & year==2011 & month==8 & c<=50 & mvat>0 & mvat<.2 || /// 
* scatter mvat c if dc==1 & year==2012 & month==8 & c<=50 & mvat>0 & mvat<.2 || ///
* scatter mvat c if dc==1 & year==2013 & month==8 & c<=50 & mvat>0 & mvat<.2 










*** LAG APPROACH
	sort conacct date
	by conacct: g bal_lag = bal[_n-1]

	order conacct date amount bal bal_lag pay ar

	g bal_alt = amount + bal_lag - pay

	order conacct date amount bal_lag pay bal_alt bal ar




	replace bal=0 if bal<=5

	replace ar = ar + 30 if ar<=361
	replace ar = 0 if ar==.

	replace ar = 0 if bal<=5 // this fixed the ar (much less missing)


	* should i just use bal and to back out payments?!
		*** look at accounts that have good collections records



	*** question : is the ar missing stuff?  	(when ar is missing, so is bal, always!!!)	
					* why are 43% at 30 and only 15% are at 0!?
				*  is pay missing the same stuff?


	*** follow progression! 





	** 0. pay missing? ** 45% of the time its missing.. but that's probably ok
	g pm=pay==.

	** 1. certain dates?
	g ar0 = ar==0
	tab date ar0  //  yes: 600, 601, 603 and some recent ones (but not a huge deal)

	** 2. when they pay, is there less likely to be a balance and ar?
	sort conacct date
		by conacct: g payl = pay[_n-1]
		by conacct: g balf = bal[_n+1]
	g pl1 = payl>0 & payl<.
		tab pl1 ar0
	g p1 = pay>0 & pay<.
		tab p1  ar0

	g bal_m=bal==.
	
*	write "${moments}p_avg.csv" `=r(mean)' 0.1 "%12.0g"


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


	replace dc = 0 if dc==.
	g cp = c!=.

	merge  m:1 conacct using "${temp}mcf_ba.dta"
	drop if _merge==2
	drop _merge

	replace amount =. if amount<10 | amount>5000

save "${temp}temp_descriptives_2.dta", replace

}



