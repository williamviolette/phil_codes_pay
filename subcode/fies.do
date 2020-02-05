* fies.do


cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end



* use "${fies}micro_world.dta", clear

* g dev = regexm(regionwb,"OECD")==1


* account  // has account
* q5  // has credict card 
* q6  // has used credit card in last 12 months

* q8a  // why don't you have a bank account?

* q30  // have you paid utility bills in the past 12 months

* borrowed  // any borrowing


*** 2014 CFS


** with bank account 18.7%  reason: 88 don't have enough money , 5.9 service charges are too high
* 3.9% have loans to others (averaging around 20,000 PhP)


* HOME LOANS:
* 62.8% own their home, 11.4% of them took out loans to buy their homes (otherwise cash or inheritance)
** 6.1% have loans on their houses!
* loan size is 243,461 avg (100,000 median) ; 63.7% from the government
* monthly payments 3,727 avg (1,083 median)
* interest rate: avg 9% (median 6%)


* AUTO LOANS:
* 20.4% have them ; 60% motorcycle, 16% tricycle, 34% cars
* of those that have them, 15.4% have outstanding loans or mortgages
** 3.1% have loans
* 45.4% in-house financing, 16.2% financing institution, 21.9% commercial bank, 5.9% money lender
* monthly payments 7,534.2 average (3,500 median)
* interest rate: avg 10% (median 5%)

** 81.3% don't have bank accounts
** 0.4% have financial assets like stocks and bonds

** 3.9% have loans to other people


** RETIREMENT INSURANCE LOANS :
** 36.4% have retirement insurance
** 20.9% of them have loans against insurance
** 7.6% have loans against retirement insurance

** size : 
* 10000*.7 + 30000*.168 + 50000*.032 + 70000*.023 + 90000*.023 + 150000*.053
* 25270 PhP

* average monthly payments
* 250*.305 + 750*.238 + 1250*.211 + 1750*.10 + 3750*.146
* 1241 PhP
** total over monthly = 20


** CREDIT CARDS :
* credit cards 3.9% of population
* outstanding debt : average 18,676.5, median 6,000


** OTHER LOANS :
* 10.5% have other loans (salary, person to person, all purpose, business) average 25,736 ; median 4,400
* 51.2% of them are person to person loans
* 11.3% of them are loans on salaries

** means 5.4% have person to person loans
* collateral : salary, land, house

* average amount still owed 25,736 (median 4,400)
*** assume yearly = 2,145

* 50% take out loans on their retirement insurance..  small-ish payments on retirement loans

* exclude home and car loans?!


*disp .06*25000 + .182*75000 + .372*150000 + .177*250000 + .081*350000 + .045*450000 + .057*750000  + .024*2000000
*disp (.06*25000 + .182*75000 + .372*150000 + .177*250000 + .081*350000 + .045*450000 + .057*750000  + .024*2000000)/12


* average is 243,000 / 12



** SUMMARY : TOTAL CREDIT 

* 	 HOME 		   AUTO          RETIREMENT    CREDIT CARDS     OTHER MONTHLY
** .061*3727  +  .0391*7534.2  +  1241*.076  +  18676*.039   +  .1*2,145

** total : 1,559 PhP  ** ** ** BUT! this goes against the model dumbass...


import delimited using  "${fies}FAMILY INCOME AND EXPENDITURE SURVEY (2015) VOLUME 2 - INCOME AND OTHER RECEIPTS - raw data.csv", delimiter(",") clear

import delimited using  "${fies}FAMILY INCOME AND EXPENDITURE SURVEY (2015) VOLUME 2 - NONFOOD EXPENDITURE - raw data.csv", delimiter(",") clear

	* 					* 6 months
keep w_regn w_id w_shsn w_hcn  twatersupply   todisbcashloan
ren twater w
ren todis loan

destring  w loan, replace force

replace loan = loan/6
replace w = w/6

keep if w_regn=="Region XIII - NCR"
drop w_regn

duplicates drop w_id w_shsn w_hcn, force

save "${fies}temp1.dta", replace


import delimited using "${fies}FAMILY INCOME AND EXPENDITURE SURVEY (2015) VOLUME 2 - NONFOOD EXPENDITURE - raw data.csv", delimiter(",") clear

keep if w_regn=="Region XIII - NCR"

destring todisbcashloan, replace force
destring todisbdeposits, replace force

* sum todisbdeposits, detail

*** THIS IS RIGHT
replace todisbdeposits = todisbdeposits/6
sum todisbdeposits, detail
global deposits = `=r(p95)'

*** THIS IS PARTIALLY RIGHT?! THIS IS PAYING LOANS BACK! 
replace todisbcashloan = todisbcashloan/6
sum todisbcashloan, detail 
global cashloan= `=r(p95)'


	write "${moments}Ab.csv" `=$deposits + $cashloan' 1 "%12.0g"
	write "${tables}Ab.tex" `=$deposits + $cashloan' 1 "%12.0fc"



import delimited using  "${fies}FAMILY INCOME AND EXPENDITURE SURVEY (2015) VOLUME 2 - INCOME AND OTHER RECEIPTS - raw data.csv", delimiter(",") clear




* preserve
* keep w_regn w_id w_shsn w_hcn
* save "${fies}id2015.dta", replace
* restore


import delimited using  "${fies}FAMILY INCOME AND EXPENDITURE SURVEY (2015) VOLUME 2 - HOUSEHOLD DETAILS AND HOUSING CHARACTERISTICS - raw data.csv", delimiter(",") clear

keep if w_regn=="Region XIII - NCR"

save "${fies}water1.dta", replace



import delimited using "${fies}FAMILY INCOME AND EXPENDITURE SURVEY (2015) VOLUME 2 - TOTALS OF INCOME AND EXPENDITURE - raw data.csv", delimiter(",") clear

keep if w_regn=="Region XIII - NCR"

merge 1:1 w_id w_shsn w_hcn using "${fies}temp1.dta"
	keep if _merge==3
	drop _merge

merge 1:1 w_id w_shsn w_hcn using "${fies}water1.dta"
	keep if _merge==3
	drop _merge


	replace toinc = toinc/12


g wm=w==.
g loanm=loan==.

sum loan

sum w if toinc<10000

sum w if toinc>10000 & toinc<20000

sum w if toinc>20000 & toinc<30000

reg w toinc


g wat_own = regexm(water,"Own use")==1
replace wat_own = 2 if regexm(water,"Share")==1


sum toinc
sum toinc if wat_own==1


	sum toinc if toinc<1500000/12 & w_regn=="Region XIII - NCR" , detail

	sum toinc if toinc<1500000/12 & w_regn=="Region XIII - NCR" & wat_own==1, detail
	write "${moments}y_avg.csv" `=r(mean)' 1 "%12.0g"
	write "${tables}y_avg.tex" `=r(mean)' 1 "%12.0fc"


	_pctile toinc if toinc<1500000/12 & w_regn=="Region XIII - NCR", p(20)

	write "${moments}y_p20.csv" `=r(r1)' 1 "%12.0g"
	write "${tables}y_p20.tex" `=r(r1)' 1 "%12.0fc"


	replace ttotex = ttotex/12
	g ss = toinc - ttotex
	sum ss if toinc<1500000/12 &  ttotex<1500000/12 & w_regn=="Region XIII - NCR", detail
	write "${moments}save_avg.csv" `=r(mean)' 1 "%12.0g"
	write "${tables}save_avg.tex" `=r(mean)' 1 "%12.0fc"



	g ss_rate = ss/toinc
	sum ss_rate  if toinc<1500000/12 &  ttotex<1500000/12 & w_regn=="Region XIII - NCR", detail
	write "${moments}save_rate.csv" `=r(mean)' 1 "%12.2g"	
	write "${tables}save_rate.tex" `=r(mean)' 1 "%12.2fc"	

