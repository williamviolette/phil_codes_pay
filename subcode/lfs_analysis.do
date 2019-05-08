

global mergevars = "age mun date"


use "${lfs}lfs.dta", clear

	g pst=string(psu)
	g mun=substr(pst,1,2)
	destring mun, replace force
	g date = ym(svyyr,svymo)

	keep if c05_rel == 1
	egen age = cut(c07_age), at(20(5)70)
	drop if age==.

	local outcomes "wage emp hrs want_more look_for_hrs look_for_work"
	** HOURS 
	* ren c22_phrs hrs * primary occupation hours
	* total hours 
	ren a04_thrs hrs
	replace hrs=. if hrs==0

	** EMPLOYMENT
	g emp = c13_work == 1

	** WAGE
	ren c27_pbsc wage
	replace wage=. if wage>2000

	** WANT MORE 
	g want_more = 0 if c23_pwmr==2
	replace want_more = 1 if c23_pwmr==1

	g look_for_hrs = 0 if c24_plaw == 2
	replace look_for_hrs = 1 if  c24_plaw == 1

	g look_for_work = 0 if c37_avil == 2
	replace look_for_work = 1 if c37_avil == 1

	** HHsize!
	g o=1
	egen hhsize = sum(o), by(psu hhnum)
	replace hhsize = 12 if hhsize>12

	*** only look at head of household!!
	* keep if c05_rel==1 

	foreach var in `outcomes' {
		egen `var'_m=mean(`var'), by( $mergevars )
		drop `var'
		ren `var'_m `var'
	}

	keep `outcomes' $mergevars 
	duplicates drop $mergevars  , force

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
	merge m:1 $mergevars  using "${lfs}output.dta"
	keep if _merge==3
	drop _merge
		ren date date_q
		ren date_true date

	g age_mun = mun*1000+age
	replace wage = wage*20
	
	
g del = ar>=61 & ar<720

	* foreach var of varlist c pay del ar {
	*  	egen `var'_m= mean(`var'), by(date_q conacct)
	*  	drop `var'
	*  	ren `var'_m `var'
	*  }
	* duplicates drop mun age date, force



	keep if date==date_q

 	g p=pay>0 & pay<.

	sort conacct date
	foreach var of varlist c pay del ar amount p wage emp hrs want_more look_for_hrs look_for_work {
		by conacct: g `var'_ch = `var'[_n]-`var'[_n-1]
	}

	gen date1 = dofm(date)
	gen m1    = month(date1)
	gen y1    = year(date1)



	* cap drop c_ch1
	* g c_ch1 = c_ch if c_ch>-30 & c_ch<30
	* sum c, detail
	* replace c_ch1 = c_ch1/`=r(sd)'


	cap prog drop demeaning
	prog def demeaning
		cap drop `1'_ch1
		g `1'_ch1 = `1'_ch `2'
		sum `1'_ch, detail
		replace `1'_ch1 = `1'_ch1/`=r(sd)'
	end


*	demeaning c "if c_ch>-50 & c_ch<50"

	demeaning c
	demeaning p
	demeaning ar
	demeaning del
	demeaning hrs
	demeaning emp
	demeaning want_more


	global X "{\tim}"

* cap drop age_mun_q
* egen age_mun_q = group(age mun date)

lab var emp_ch1 "$\Delta$ Employed"
lab var hrs_ch1 "$\Delta$ Hours worked"
lab var want_more_ch1 "$\Delta$ Want more hours"

est clear
foreach o in c_ch1 p_ch1 del_ch1 {
	*  want_more_ch1 leave out for now...
		reg `o'  emp_ch1 hrs_ch1 i.date, r cluster(age_mun)
		*sum `o' if e(sample)==1 , detail
	  	*estadd scalar Mean = `=r(mean)'
		eststo `o'
}


	estout using "${tables}table_lfs_analysis.tex", replace  style(tex) ///
	keep(  emp_ch1 hrs_ch1   )  ///
		varlabels(,  el(  emp_ch1 "[0.1em]" hrs_ch1 "[0.1em]"  ))  label noomitted ///
		  mlabels(,none)   collabels(none)  cells( b(fmt(4) star ) se(par fmt(4)) ) ///
		  stats(  N , labels(   "N"  )   fmt(   %12.0fc  )   ) ///
		  starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 


	
* reg c_ch1 emp_ch hrs_ch want_more_ch look_for_hrs_ch look_for_work_ch i.date , r cluster(age_mun)
* reg p_ch1 emp_ch hrs_ch want_more_ch look_for_hrs_ch look_for_work_ch i.date , r cluster(age_mun)
* reg del_ch1 emp_ch hrs_ch want_more_ch look_for_hrs_ch look_for_work_ch i.date , r cluster(age_mun)

** use more 

* lab var c_ch1 "$\Delta$ Usage"
* lab var p_ch1 "$\Delta$ Payments"
* lab var del_ch1 "$\Delta$ Delinquency"




		* estout using "`1'.tex", replace  style(tex) ///
		* keep(  proj_con_post spill1_con_post  proj_post spill1_post  ///
		*     con_post proj_con spill1_con  proj spill1  con $add_post  )  ///
		* varlabels(,  el(     proj_con_post "[0.01em]" spill1_con_post "[0.05em]"  ///
		*    proj_post "[0.01em]"  spill1_post "[0.05em]"  ///
		*     con_post "[0.5em]" proj_con "[0.01em]" spill1_con  "[0.05em]"  ///
		*      proj "[0.01em]" spill1 "[0.01em]"  con "[0.1em]" $add_post  ))  label ///
		*   noomitted ///
		*   mlabels(,none)  ///
		*   collabels(none) ///
		*   cells( b(fmt(3) star ) se(par fmt(3)) ) ///
		*   stats( Mean2001 Mean2011 r2 projcount hhproj hhspill N ,  ///
	 * 	labels(  "Mean Outcome 2001"    "Mean Outcome 2011" "R$^2$"   "\# projects"  `"N project areas"'    `"N spillover areas"'     "N"  ) ///
		*     fmt( %9.2fc   %9.2fc  %12.3fc   %12.0fc  %12.0fc  %12.0fc  %12.0fc  )   ) ///
		*   starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 

		* lab_var_top

		* estout using "`1'_top.tex", replace  style(tex) ///
		* keep(  proj_con_post spill1_con_post )  ///
		* varlabels(, el( proj_con_post "[0.55em]" spill1_con_post "[0.5em]"  )) ///
		* label ///
		*   noomitted ///
		*   mlabels(,none)  ///
		*   collabels(none) ///
		*   cells( b(fmt(3) star ) se(par fmt(3)) ) ///
		*   stats( Mean2001 Mean2011 r2 projcount hhproj hhspill N ,  ///
	 * 	labels(  "Mean Outcome 2001"    "Mean Outcome 2011" "R$^2$"   "\# projects"  `"N project areas"'    `"N spillover areas"'     "N"  ) ///
		*     fmt( %9.2fc   %9.2fc  %12.3fc   %12.0fc  %12.0fc  %12.0fc  %12.0fc  )   ) ///
		*   starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 


		* estout using "`1'_top_lonely.tex", replace  style(tex) ///
		* keep(  proj_con_post spill1_con_post )  ///
		* varlabels(,bl( proj_con_post "${all_label}") el( proj_con_post "[0.5em]" spill1_con_post "[0.5em]"  )) ///
		* label ///
		*   noomitted ///
		*   mlabels(,none)  ///
		*   collabels(none) ///
		*   cells( b(fmt(3) star ) se(par fmt(3)) ) ///
		*   stats( r2 , labels( "R$^2$"  ) fmt(%12.3fc   )) ///
		*   starlevels(  "\textsuperscript{c}" 0.10    "\textsuperscript{b}" 0.05  "\textsuperscript{a}" 0.01) 


*** MAKE THIS TABLE! 


/* 

	reg c_ch1 emp_ch i.date, r cluster(age_mun)
	reg p_ch1 emp_ch i.date, r cluster(age_mun)

	reg c_ch1 hrs_ch i.date, r cluster(age_mun)
	reg p_ch1 hrs_ch i.date, r cluster(age_mun)

** positive demand shock! (pretty nice?!)
	reg c_ch1 want_more_ch i.date, r cluster(age_mun)
	reg p_ch1 want_more_ch i.date, r cluster(age_mun)

	reg c_ch1 look_for_hrs_ch i.date, r cluster(age_mun)
	reg p_ch1 look_for_hrs_ch i.date, r cluster(age_mun)
	
	reg c_ch1 look_for_work_ch i.date, r cluster(age_mun)
	reg p_ch1 look_for_work_ch i.date, r cluster(age_mun)





/*

	cap drop e_g
* 	egen e_g = cut(emp_ch), at(-.30(.05).15)
*	egen e_g = cut(emp_ch), at(-.5(.1).5)

	global out_var = "wage_ch"
	sum $out_var, detail
	*egen e_g = cut(), at(`=r(p5)'(.1)`=r(p95)')
	egen e_g = cut($out_var), group(10)

	cap drop e_n
	bys e_g: g e_n=_n

	cap drop c_g
	egen c_g = mean(c_ch1), by(e_g)

	cap drop p_g
	egen p_g = mean(p_ch1), by(e_g)

	cap drop a_g
	egen a_g = mean(ar_ch1), by(e_g)


	scatter  c_g  e_g if e_n==1 || ///
	scatter  p_g  e_g if e_n==1



/*

	scatter  c_g  e_g if e_n==1, yaxis(1) || ///
	scatter  p_g  e_g if e_n==1, yaxis(2) 




	scatter  c_g  e_g if e_n==1 || ///
	scatter  p_g  e_g if e_n==1, ylabel(-.03(.05).04) yscale(r(-.03 .03))



	lowess c_ch1 emp_ch if emp_ch>-.3 & emp_ch<.15



	scatter  c_g  e_g if e_n==1 || ///
	scatter  a_g  e_g if e_n==1




	scatter  c_g  e_g if e_n==1, yaxis(1) ylabel(-.05(.05).05) || ///
	scatter  a_g  e_g if e_n==1, yaxis(2)  ylabel(-.05(.05).05, axis(2))




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






