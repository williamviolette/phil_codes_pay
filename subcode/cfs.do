


cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end



* usespss using "${data}cfs/2014_CFS_PUF.sav", clear

* set maxvar 30000

* import delimited using "${data}cfs/2014_CFS_PUF.csv", clear
* save "${data}cfs/cfs.dta", replace

global cfs_data_import =0

if $cfs_data_import == 1 {

use "${data}cfs/cfs.dta", clear

keep if reg == 13

* e is savings account
* f is vehicle loan
* g1 is credit cards
* g19 is other loans


keep hnum e2 e4a e4b e4c   e6a e6b e6c   e7a e7b e7c  ///
 		e7a_amount  e7b_amount  e7c_amount  ///
  		e9a e9b e9c  e10a e10b e10c  e11a e11b e11c  e12a e12b e12c  ///
  		f11a f11b f11c  f15a f15b f15c   f17a f17b f17c ///
  		   l2 l3   g*   i*

* g1 g20  g21a g21b g21c   g22a g22b g22c    ///
*   		g31a g31a_percent g31b g31b_percent g31c g31c_percent ///
*   		g32a  g32b  g32c  

save "${data}cfs/cfs_temp.dta", replace

}


* use "${data}cfs/cfs_temp.dta", clear

use "${data}cfs/cfs.dta", clear

 destring g21a g21b g21c g31a_percent g31b_percent g31c_percent g20 e11a, replace force


* tab  g31a_percent g32a

cap drop srate
g srate = .
replace srate = (1 + (e11a/100))^(1/6)-1     if regexm(e12a,"6 mos")==1
replace srate = (1 + (e11a/100))^(1/2)-1     if regexm(e12a,"60 days")==1
replace srate = (1 + (e11a/100))^(1/3)-1     if regexm(e12a,"90 days")==1
replace srate = (1 + (e11a/100))^(1/1)-1     if regexm(e12a,"Per month")==1
replace srate = (1 + (e11a/100))^(1/12)-1     if regexm(e12a,"Yearly")==1
sum srate, detail
replace srate=. if srate>=`=r(p99)'

replace srate = 0 if e10a!="Yes"

sum srate if reg==13

		write "${moments}save_rate.csv" `=r(mean)'  .00001 "%12.5g"
		write "${tables}save_rate.tex" `=`=r(mean)'*100'   .00001 "%12.2fc"


g no_savings= e10a=="NA"
sum no_savings if reg==13, detail
		write "${tables}no_savings.tex" `=`=r(mean)'*100'   .00001 "%12.0fc"



foreach v in a b c {
cap drop irate`v'
g irate`v' =.
replace irate`v' = (1 + (g31`v'_percent/100))^(1/24)-1     if regexm(g32`v',"2 years")==1
replace irate`v' = (1 + (g31`v'_percent/100))^(1/12)-1     if regexm(g32`v',"Yearly")==1
replace irate`v' = (1 + (g31`v'_percent/100))^(1/2)-1      if regexm(g32`v',"2 months")==1
replace irate`v' = (1 + (g31`v'_percent/100))^(1/6)-1      if regexm(g32`v',"6 months")==1
replace irate`v' = (1 + (g31`v'_percent/100))^(1/4)-1      if regexm(g32`v',"4 mos")==1
replace irate`v' = (1 + (g31`v'_percent/100))^(1/5)-1      if regexm(g32`v',"5 mos")==1
replace irate`v' = (1 + (g31`v'_percent/100))^(1/(1/30))-1 if regexm(g32`v',"Per day")==1
replace irate`v' = (1 + (g31`v'_percent/100))^(1/1)-1      if regexm(g32`v',"Per month")==1
replace irate`v' = (1 + (g31`v'_percent/100))^(1/3)-1      if regexm(g32`v',"Per quarter")==1
replace irate`v' = (1 + (g31`v'_percent/100))^(1/.25)-1    if regexm(g32`v',"Per week")==1
replace irate`v' = (1 + (g31`v'_percent/100))^(1/.5)-1     if regexm(g32`v',"15 days")==1

replace irate`v' =  . if irate`v'>=1
}

destring  g26a_year g26a_month g26b_year g26b_month g26c_year g26c_month g27a g21b_a g21b_b g21b_c , replace force

g loan_v = g21a

destring k13 k14 k15 k16 k17, replace force
g tot_exp = k13+k14+k15+k16+k17 
replace tot_exp = . if tot_exp>50000



sum iratea if reg==13, detail

		write "${moments}irate.csv" `=r(mean)'  .00001 "%12.5g"
		write "${tables}irate.tex" `=`=r(mean)'*100'   .00001 "%12.1fc"


corr iratea loan_v if loan_v<=150000
mat define CC = r(C)
		write "${tables}irate_lv_corr.tex" `=CC[1,2]'   .00001 "%12.3fc"

corr iratea tot_exp
mat define CC = r(C)
		write "${tables}irate_te_corr.tex" `=CC[1,2]'   .00001 "%12.3fc"




/*






g loan_v_b = g21b
g loan_v_c = g21c

* sum iratea if irateb!=. & iratec!=. & iratea!=.
* sum irateb if irateb!=. & iratec!=. & iratea!=.
* sum iratec if irateb!=. & iratec!=. & iratea!=.

* sum iratea if irateb!=. & iratec!=. & iratea!=. & reg==13
* sum irateb if irateb!=. & iratec!=. & iratea!=. & reg==13
* sum iratec if irateb!=. & iratec!=. & iratea!=. & reg==13

* foreach v in "2 years" "Yearly" "2 months" "6 months" "4 mos" "5 mos" "Per day" "Per month" "Per quarter" "Per week" "15 days" {
* sum g31a_percent if regexm(g32a,"Per month")==1, detail
* sum g31a_percent if regexm(g32a,"Per day")==1, detail
* }
* size of loan  g21a * deduction    g21b_a  (just subtract)  * payment   g21d_a  * interval  g21e_a







g payments =.
replace payments =  g27a  		if g28a == "Per month"
replace payments =  g27a*30  	if g28a == "Per day"
replace payments =  g27a*4  	if g28a == "Per week"
replace payments =  g27a/3  	if g28a == "Per quarter"
replace payments =  g27a/4  	if g28a == "4 mos"
replace payments =  g27a/5  	if g28a == "5 mos"

g l_time = g26a_year*12 
replace l_time = g26a_month if l_time==.
g l_time_b = g26b_year*12 
replace l_time_b = g26b_month if l_time_b==.
g l_time_c = g26c_year*12 
replace l_time_c = g26c_month if l_time_c==.

g pay = l_time * payments


g collateral = 0 if g21f_a=="No"
replace collateral = 1 if g21f_a=="Yes"


* i48a_amount

g sal =.
destring i13a_amount , replace force

replace sal = i13a_amount/4 if regexm(i14a,"4 mos")==1
replace sal = i13a_amount/1.5 if regexm(i14a,"45 days")==1
replace sal = i13a_amount/5 if regexm(i14a,"5 mos")==1
replace sal = i13a_amount/(1/20) if regexm(i14a,"Per day")==1
replace sal = i13a_amount/6 if regexm(i14a,"Per harvest")==1
replace sal = i13a_amount/1 if regexm(i14a,"Per month")==1
replace sal = i13a_amount/3 if regexm(i14a,"Per quarter")==1
replace sal = i13a_amount/(1/4) if regexm(i14a,"Per week")==1
replace sal = i13a_amount/12 if regexm(i14a,"Yearly")==1
replace sal = i13a_amount/(1/2) if regexm(i14a,"15 days")==1




g hhsize=0
foreach var of varlist b101-b119 {
	replace hhsize = hhsize+1 if `var'=="Yes"
}





g over_pay = pay - loan_v


g ln_lv = log(loan_v)
g ln_te = log(tot_exp)

areg iratea  ln_lv ln_te hhsize if loan_v<=200000, absorb(l_time) r







reg iratea  loan_v l_time hhsize tot_exp i.reg if loan_v<=100000 & tot_exp<100000 & l_time<=12





reg over_pay i.l_time if l_time<=6 & over_pay>0

reg iratea i.l_time if l_time<=3


      

sum loan_v if irateb!=. & iratec!=. & iratea!=. & l_time<=6 & l_time_b<=6 & l_time_c<=6 
sum loan_v_b if irateb!=. & iratec!=. & iratea!=. & l_time<=6 & l_time_b<=6 & l_time_c<=6 
sum loan_v_c if irateb!=. & iratec!=. & iratea!=. & l_time<=6 & l_time_b<=6 & l_time_c<=6 


sum iratea if irateb!=. & iratec!=. & iratea!=. & l_time<=6 & l_time_b<=6 & l_time_c<=6 
sum irateb if irateb!=. & iratec!=. & iratea!=. & l_time<=6 & l_time_b<=6 & l_time_c<=6 
sum iratec if irateb!=. & iratec!=. & iratea!=. & l_time<=6 & l_time_b<=6 & l_time_c<=6 



reg iratea l_time loan_v collateral sal if loan_v<100000 & sal<60000


g loan_v_per = loan_v/sal
g loan_v_per_2 = loan_v_per*loan_v_per


g lvexp = loan_v/tot_exp


g ln_loan_v = log(loan_v)


reg iratea lvexp i.hhsize  if l_time<=6 & lvexp<4


reg iratea loan_v sal i.hhsize  if l_time<=6 & loan_v<100000 & sal<=50000



reg iratea loan_v tot_exp if lvexp<=4 & l_time<=6


reg iratea loan_v_per if loan_v_per<=5 & l_time<=6



reg iratea loan_v_per sal i.l_time if loan_v_per<=5 & l_time<=6

reg iratea loan_v_per loan_v_per_2 i.l_time if loan_v_per<=5 & l_time<=6


sum iratea if gap_1!=. & iratea<1

sum iratea 
sum iratea if l_time<=6
sum iratea if l_time<=1

reg iratea loan_v if l_time<=1 & loan_v<=20000

hist gap if loan_v<50000





g interest = (pay - loan_v)/loan_v

global counter = 0

forvalues r=.001(.005).2 {
global interest = `r'
cap drop pv1
cap drop gap_$counter
g pv1 = loan_v*($interest*((1+$interest)^l_time))/(  ((1+$interest)^l_time) - 1  ) if pay>=loan_v & l_time<=36
g gap_$counter = pv1 - payments if loan_v<50000
global counter=$counter + 1
}

foreach var of varlist gap_* {
	sum `var'
}





* sum interest if interest>0 & interest<1, detail




* g26a g26a_year g26a_month



destring g25a g25b g25c, replace force

g rec_a = g25a >=2012 & g25a<.
g rec_b = g25b >=2012 & g25b<.
g rec_c = g25c >=2012 & g25c<.







** length 
*   


*** when taken out!
* g25a g25a_codes g25b g25b_codes g25c g25c_codes



* g26a g26a_year g26a_month g26b g26b_year g26b_month g26c g26c_year g26c_month


sum irate if irate2!=. & irate3!=. 
sum irate2 if irate2!=. & irate3!=. 
sum irate3 if irate2!=. & irate3!=.  


sum g21a if irate2!=. & irate3!=.  & irate!=.

sum g21b if irate2!=. & irate3!=. 

sum g21c if irate2!=. & irate3!=. 

g rate_diff = 


sum irate if irate<.5 & reg==13, detail 

		write "${moments}borrow_rate.csv" `= `=r(mean)''  .00001 "%12.5g"
		write "${tables}borrow_rate.tex" `= `=r(mean)'*100'   .00001 "%12.2fc"


replace irate = . if irate>100 


reg irate g20

reg  irate g21a  if g21a<=100000 & irate<20


reg irate g21a if regexm(g22a,"Personal")==1 & g21a<=60000


destring g27a, replace force


* xi: reg irate g21a g27a i.g28a if g21a<=60000
* xi: reg irate g21a sal i.g22a





g sal2=sal*sal


reg irate  sal sal2 if g21a<=60000


g g21a2 = g21a*g21a


xi:  reg irate g21a i.g22a if  g21a<=20000


reg irate g21a g21a2 if  g21a<=60000


g g21a_sal = g21a/sal

reg irate  g21a_sal if g21a<=60000


reg irate g21a if g21a<=60000

xi: reg irate g21a  i.b12_1_slice  i.b12_2_slice if g21a<=60000



**** basically no correlation! ****

reg irate sal if irate<40
reg srate sal

* r_lend      = ((1+r_lend)^(1/12)) - 1