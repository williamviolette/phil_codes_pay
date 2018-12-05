

use "${lfs}lfs.dta", clear

	g pst=string(psu)
	g mun=substr(pst,1,2)
	destring mun, replace force
	g date = ym(svyyr,svymo)

	keep if c05_rel == 1
	egen age = cut(c07_age), at(20(5)70)
	drop if age==.

	local outcomes "wage emp hrs"
	** HOURS 
	ren c22_phrs hrs
	replace hrs=. if hrs==0

	** EMPLOYMENT
	g emp = c13_work == 1


	** WAGE
	ren c27_pbsc wage
	replace wage=. if wage>2000


	foreach var in `outcomes' {
		egen `var'_m=mean(`var'), by(age mun date)
		drop `var'
		ren `var'_m `var'
	}

	keep `outcomes' age mun date
	duplicates drop age mun date, force

save "${lfs}output.dta", replace




use "${temp}temp_descriptives_2.dta", clear

	replace age = age + (date-590)/12 if wave==3
	replace age = age + (date-602)/12 if wave==4
	replace age = age + (date-614)/12 if wave==5

	ren age age_true
	egen age = cut(age_true), at(20(5)70)
	keep if age!=.


	g bst=string(barangay_id)
	g mun = substr(bst,1,2)
	destring mun, replace force
	drop if mun==21
	drop bst barangay_id


	egen date_q = cut(date), at(600(3)664)
		ren date date_true
		ren date_q date
	merge m:1 age date mun using "${lfs}output.dta"
	keep if _merge==3
	drop _merge
		ren date date_q
		ren date_true date

	g age_mun = mun*1000+age
	replace wage = wage*20
	
	
g del = ar>=61 & ar<720

	* foreach var of varlist c pay del ar {
	* 	egen `var'_m= mean(`var'), by(date mun age)
	* 	drop `var'
	* 	ren `var'_m `var'
	* }
	* duplicates drop mun age date, force

	keep if date==date_q

 	g p=pay!=.

	sort conacct date
	foreach var of varlist c pay del ar emp wage hrs amount p {
		by conacct: g `var'_ch = `var'[_n]-`var'[_n-1]
	}

	gen date1 = dofm(date)
	gen m1    = month(date1)
	gen y1    = year(date1)



	global cond "c_ch<=50 & c_ch>=-50 & emp_ch>=-.5 & emp_ch<=.5 "
	global ctrls "emp_ch hrs_ch i.m1 i.y1"
	global ctrls1 "c_ch ${ctrls}"
	global ctrls2 "c_ch amount_ch ${ctrls}"
		reg amount_ch $ctrls  if $cond, cluster(age_mun) r
		reg c_ch $ctrls  if $cond, cluster(age_mun) r
		reg ar_ch $ctrls1  if $cond, cluster(age_mun) r
		reg del_ch $ctrls1  if $cond, cluster(age_mun) r
		reg ar_ch $ctrls2  if $cond, cluster(age_mun) r
		reg del_ch $ctrls2  if $cond, cluster(age_mun) r


	global cond "c_ch<=50 & c_ch>=-50 & emp_ch>=-.5 & emp_ch<=.5 "
	global ctrls "emp_ch hrs_ch i.date"
	global ctrls1 "c_ch ${ctrls}"
	global ctrls2 "c_ch amount_ch ${ctrls}"
		reg amount_ch $ctrls  if $cond, cluster(age_mun) r
		reg c_ch $ctrls  if $cond, cluster(age_mun) r
		reg ar_ch $ctrls1  if $cond, cluster(age_mun) r
		reg del_ch $ctrls1  if $cond, cluster(age_mun) r
		reg ar_ch $ctrls2  if $cond, cluster(age_mun) r
		reg del_ch $ctrls2  if $cond, cluster(age_mun) r

		reg p_ch $ctrls2  if $cond, cluster(age_mun) r




	global cond "c_ch<=40 & c_ch>=-40  "
	global ctrls "hrs_ch i.date"
	global ctrls1 "c_ch ${ctrls}"
	global ctrls2 "c_ch amount_ch ${ctrls}"
		reg amount_ch $ctrls  if $cond, cluster(age_mun) r
		reg c_ch $ctrls  if $cond, cluster(age_mun) r
		reg ar_ch $ctrls1  if $cond, cluster(age_mun) r
		reg del_ch $ctrls1  if $cond, cluster(age_mun) r
		reg ar_ch $ctrls2  if $cond, cluster(age_mun) r
		reg del_ch $ctrls2  if $cond, cluster(age_mun) r



	global cond "c_ch<=50 & c_ch>=-50 & emp_ch>-.5 & emp_ch<.5 "
	global ctrls "hrs_ch i.date"
	global ctrls1 "c_ch ${ctrls}"
	global ctrls2 "c_ch amount_ch ${ctrls}"
	global ctrls3 "amount_ch ${ctrls}"
	
		reg amount_ch $ctrls  if $cond, cluster(age_mun) r
		reg c_ch $ctrls  if $cond, cluster(age_mun) r
		reg ar_ch $ctrls1  if $cond, cluster(age_mun) r
		reg del_ch $ctrls1  if $cond, cluster(age_mun) r
		reg ar_ch $ctrls3  if $cond, cluster(age_mun) r
		reg del_ch $ctrls3  if $cond, cluster(age_mun) r
		reg p_ch $ctrls3  if $cond, cluster(age_mun) r




	global cond "c_ch>=-25  & c_ch<=25 & emp_ch>=-.25 & emp_ch<=.25 & hrs_ch>=-10 & hrs_ch<=10 & wage_ch>=-5000 & wage_ch<=5000"
	global ctrls "emp_ch hrs_ch i.m1 i.y1"
	global ctrls1 "c_ch ${ctrls}"
	global ctrls2 "c_ch amount_ch ${ctrls}"
		reg amount_ch $ctrls  if $cond, cluster(age_mun) r
		reg c_ch $ctrls  if $cond, cluster(age_mun) r
		reg ar_ch $ctrls1  if $cond, cluster(age_mun) r
		reg del_ch $ctrls1  if $cond, cluster(age_mun) r
		reg ar_ch $ctrls2  if $cond, cluster(age_mun) r
		reg del_ch $ctrls2  if $cond, cluster(age_mun) r






	global cond "c_ch>=-25  & c_ch<=25 & emp_ch>=-.25 & emp_ch<=.25"

		reg c_ch emp_ch         if $cond, cluster(age_mun) r
		reg ar_ch c_ch emp_ch   if $cond, cluster(age_mun) r
		reg del_ch c_ch emp_ch   if $cond, cluster(age_mun) r

	global cond "c_ch>=-25  & c_ch<=25 & emp_ch>=-.25 & emp_ch<=.25 & wage_ch>=-5000 & wage_ch<=5000"

		reg c_ch emp_ch wage_ch if $cond, cluster(age_mun) r
		reg ar_ch c_ch emp_ch wage_ch if $cond, cluster(age_mun) r
		reg del_ch c_ch emp_ch wage_ch if $cond, cluster(age_mun) r
		
	global cond "c_ch>=-25  & c_ch<=25 & emp_ch>=-.25 & emp_ch<=.25 & wage_ch>=-5000 & wage_ch<=5000 & hrs_ch>=-10 & hrs_ch<=10"

		reg c_ch emp_ch wage_ch hrs_ch if $cond, cluster(age_mun) r
		reg ar_ch c_ch emp_ch wage_ch hrs_ch if $cond, cluster(age_mun) r
		reg del_ch c_ch emp_ch wage_ch hrs_ch if $cond, cluster(age_mun) r

		reg c_ch emp_ch wage_ch hrs_ch i.m1 if $cond, cluster(age_mun) r
		reg ar_ch c_ch emp_ch wage_ch hrs_ch i.m1 if $cond, cluster(age_mun) r
		reg del_ch c_ch emp_ch wage_ch hrs_ch i.m1 if $cond, cluster(age_mun) r






	reg ar_ch c_ch emp_ch if c_ch>=-25 & c_ch<=25, cluster(age_mun) r



	reg del_ch emp_ch if c_ch>=-25 & c_ch<=25, cluster(age_mun) r





	
	reg pay_ch emp_ch wage_ch hrs_ch, cluster(age_mun) r

	reg del_ch c_ch emp_ch wage_ch hrs_ch, cluster(age_mun) r

	reg del_ch ar_ch emp_ch wage_ch hrs_ch, cluster(age_mun) r





	reg c emp i.date i.mun i.age , cluster(age_mun) r
	reg pay emp i.date i.mun i.age , cluster(age_mun) r
	reg del emp i.date i.mun i.age , cluster(age_mun) r
	reg ar emp i.date i.mun i.age , cluster(age_mun) r
		

	reg c emp i.date i.mun i.age if emp>.1 , cluster(age_mun) r
	reg pay emp i.date i.mun i.age if emp>.1 , cluster(age_mun) r
	reg del emp i.date i.mun i.age if emp>.1 , cluster(age_mun) r
	reg ar emp i.date i.mun i.age if emp>.1 , cluster(age_mun) r
		





	reg c emp i.date i.mun i.age if emp>.1, cluster(age_mun) r

	reg pay emp i.date i.mun i.age if emp>.1, cluster(age_mun) r


	reg c emp i.date i.mun i.age if emp>.5, cluster(age_mun) r

	reg pay emp i.date i.mun i.age if emp>.5, cluster(age_mun) r


	reg c wage i.date i.mun i.age, cluster(age_mun) r

	reg pay wage i.date i.mun i.age, cluster(age_mun) r





	reg c wage i.date i.mun i.age, cluster(age_mun) r

	reg pay wage i.date i.mun i.age, cluster(age_mun) r


	reg c hrs i.date i.mun i.age, cluster(age_mun) r

	reg pay hrs i.date i.mun i.age, cluster(age_mun) r






