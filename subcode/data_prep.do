



***** GENERATE NEIGHBOR MEASURES

* #delimit;
* local bill_query "";
* forvalues r = 1/12 {;
* 	local bill_query "`bill_query' 
* 	SELECT A.*, `r' AS ba
* 	FROM mcf_`r' AS A
* 	JOIN (SELECT DISTINCT conacct FROM neighborp) AS B 
* 		ON A.conacct = B.conacct
* 	";
* 	if `r'!=12{;
* 		local bill_query "`bill_query' UNION ALL";
* 	};
* };
* clear;
* #delimit cr;
* odbc load, exec("`bill_query'")  dsn("phil") clear  
* save "${temp}mcf_temp_neighbor.dta", replace


#delimit;
local bill_query "";
forvalues r = 1/12 {;
	local bill_query "`bill_query' 
	SELECT A.*
	FROM mcf_`r' AS A
	";
	if `r'!=12{;
		local bill_query "`bill_query' UNION ALL";
	};
};
clear;
#delimit cr;


odbc load, exec("`bill_query'")  dsn("phil") clear  

sort conacct date 
by conacct: g id = date[_n-1]+1==date[_n]
drop if id==1
drop id
drop if date<603

merge m:1 conacct using "${temp}mru_total.dta"
	keep if _merge==3
	drop _merge

bys date mru: g mdc = _N
bys date mru: g mdcn= _n
keep if mdcn==1

keep date mru mdc

save "${temp}dc_mru_full.dta", replace







/*

*** CREATE COMPREHENSIVE DC MRU LIST ***

foreach v in bacoor cal_1000 muntin para pasay qc_04 qc_09 qc_12 so_cal tondo val samp {

	* local v "pasay"
	use "${billingdata}`v'_mcf_2009_2015.dta", clear
	keep conacct mru
	drop if conacct==.
	destring mru, replace force
	drop if mru==.
	duplicates drop conacct, force
	save "${temp}mru_`v'.dta", replace
}

use "${temp}mru_bacoor.dta", clear
foreach v in  cal_1000 muntin para pasay qc_04 qc_09 qc_12 so_cal tondo val samp  {
	append using "${temp}mru_`v'.dta"
}
duplicates drop conacct, force

save "${temp}mru_total.dta", replace








/*






#delimit;
local bill_query "";
forvalues r = 1/12 {;
	local bill_query "`bill_query' 
	SELECT A.*,  B.conacctp, B.rank, `r' AS ba
	FROM mcf_`r' AS A
	JOIN (SELECT * FROM neighborp_50) AS B 
		ON A.conacct = B.conacct
	";
	if `r'!=12{;
		local bill_query "`bill_query' UNION ALL";
	};
};
clear;
#delimit cr;

odbc load, exec("`bill_query'")  dsn("phil") clear  

save "${temp}mcf_temp_neighbor_big.dta", replace



use "${temp}mcf_temp_neighbor_big.dta", clear

sort conacctp conacct date 
by conacctp conacct: g id = date[_n-1]+1==date[_n]
drop if id==1
drop id

merge m:1 conacct using "${temp}mcf_mru.dta"
	drop if _merge==2
	drop _merge
ren conacct conacct_store
ren mru mru_store
ren conacctp conacct
merge m:1 conacct using "${temp}mcf_mru.dta"
	drop if _merge==2
	drop _merge
ren conacct conacctp
ren mru mrup
ren mru_store mru
ren conacct_store conacct

g mru_no_match = mru!=mrup & mru!=. & mrup!=.

forvalues r=1/50 {
	g r_`r'_id = 1 if rank==`r'
	gegen r_`r' = sum(r_`r'_id), by(conacctp date)
	drop r_`r'_id

	g r_`r'_mru_id = 1 if rank==`r' & mru_no_match==1
	gegen r_`r'_no_mru = sum(r_`r'_mru_id), by(conacctp date)
	drop r_`r'_mru_id
}

keep conacctp date r_*
duplicates drop conacctp date, force
ren conacctp conacct

save "${temp}neighbor_dc_full.dta", replace 



/*

*** GENERATE MORE NEIGHBOR MEASURES

use  "${temp}mcf_temp_neighbor.dta", clear
	keep if dc==1
	gegen min_date = min(date), by(conacct)
	keep if date==min_date
	drop min_date
	keep date conacct
	duplicates drop conacct, force
	drop if date<600

save "${temp}mcf_temp_neighbor_date.dta", replace




**** **** **** 

	replace dc = 0 if dc==.
	sort conacct date
	by conacct: g dch = dc[_n-1]==1 & dc==0 & dc[_n+1]==1
		* Tab dch   // only 661 cases, so pretty clean
	replace dc = 1 if dch==1
	drop dch


use  "${temp}mcf_temp_neighbor.dta", clear
	keep if dc==1
	gegen min_date = min(date), by(conacct)
	keep if date==min_date
	drop min_date
	keep date conacct
	duplicates drop conacct, force
	drop if date<600

save "${temp}mcf_temp_neighbor_date_full.dta", replace




local bill_query " SELECT * FROM neighborp "
odbc load, exec("`bill_query'")  dsn("phil") clear 

	merge m:1 conacct using "${temp}mcf_temp_neighbor_date.dta"
	keep if _merge==3
	drop _merge

g date_5_id= date if rank<=5
g date_10_id = date if rank>5
ren date date_id

gegen date_dc    = min(date_id), by(conacctp)
gegen date_5_dc  = min(date_5_id), by(conacctp)
gegen date_10_dc = min(date_10_id), by(conacctp)

forvalues r=1/10 {
	g date_`r'r_id = date_id if rank==`r'
	gegen date_`r'r_dc = min(date_`r'r_id), by(conacctp)
}

keep conacctp date_dc date_5_dc date_10_dc date_*r_dc
ren conacctp conacct
duplicates drop conacct, force

save "${temp}neighbor_dc.dta", replace




local bill_query " SELECT * FROM neighborp"
odbc load, exec("`bill_query'")  dsn("phil") clear 

	merge m:1 conacct using "${temp}mcf_temp_neighbor_date.dta"
	keep if _merge==3
	drop _merge
drop conacct
drop 
forvalues r=1/10 {
	g `r'_id = rank==`r'
	gegen date_`r'r_dc = sum(`r'_id), by(conacct date)
}

keep conacctp date_*r_dc
ren conacctp conacct
duplicates drop conacct, force

save "${temp}neighbor_dc_date.dta", replace




**** MAKE PAY DATE ! ****
**** MAKE PAY DATE ! ****
**** MAKE PAY DATE ! ****
* foreach v in bacoor cal_1000 muntin para pasay qc_04 qc_09 qc_12 so_cal tondo val samp {

* 	* local v "pasay"
* 	use "${billingdata}`v'_coll_2008_2015.dta", clear

* 	keep conacct postdate month year totalpymnt
* 	drop if year=="2008" | year=="2009"
* 	drop if conacct==.

* 	gegen mt=max(totalpymnt), by(conacct month year)
* 	keep if totalpymnt==mt
* 	drop mt
* 	duplicates drop conacct month year, force

* 	g pd=postdate
* 	destring pd, replace force
* 	format pd %td

* 	g pd_year = substr(postdate,1,4) if pd==.
* 	g pd_month = substr(postdate,6,2) if pd==.
* 	g pd_day   = substr(postdate,9,2) if pd==.
* 	destring pd_year pd_month pd_day year month, replace force

* 	g pd_date = mdy(pd_month,pd_day,pd_year)
* 	format pd_date %td
* 	replace pd_date = pd if pd_date==.
* 	ren pd_date date_day

* 	keep conacct year month date_day
* 	save "${temp}pay_day_`v'.dta", replace
* }

* use "${temp}pay_day_bacoor.dta", clear
* foreach v in  cal_1000 muntin para pasay qc_04 qc_09 qc_12 so_cal tondo val samp  {
* 	append using "${temp}pay_day_`v'.dta"
* }





/*

*** ADD MRNOTE AS A MEASURE FOR DISCONNECTION (DOESNT WORK WELL BUT BACKS UP OTHER MEASURE)
foreach v in bacoor cal_1000 muntin para pasay qc_04 qc_09 qc_12 so_cal tondo val samp {

	* local v "pasay"
	use "${billingdata}`v'_mcf_2009_2015.dta", clear

	drop if MR_NOTE==""
	keep year month conacct MR_NOTE
	g mr=regexs(1) if regexm(MR_NOTE,"^([0-9]+)")
	destring mr year month, replace force
	keep if mr!=.
	g date=ym(year,month)
	duplicates drop conacct date, force
	keep conacct date mr
	save "${temp}mr_`v'.dta", replace
}

global NN = 0
foreach v in bacoor cal_1000 muntin para pasay qc_04 qc_09 qc_12 so_cal tondo val samp  {
	if $NN==0 {
		use "${temp}mr_`v'.dta", clear
	}
	else {
		append using "${temp}mr_`v'.dta"
	}
	global NN=$NN+1
}
duplicates drop conacct date, force
save "${temp}mr.dta", replace


**** MISSING ON 3 of 2013!! ****




*  01 - Mother Meter/Official Meter |         21        0.10        0.10
*           03 - Obstructed Meter | 
*          04 - Meter Reversibly Connecte |         40        0.18        0.28
*         04 - Meter Reversibly Connected |        245        1.12        1.40
*          07 - Can t Locate Meter / Addr |         15        0.07        1.47
*       07 - Can't Locate Meter / Address |        115        0.53        2.00
*                  10 - With Illegalities |
*                           11 - No Water |         26        0.12        2.12
*               12 - Closed Water Service |      3,241       14.86       16.97
* 13 - vacant lot
*                       14 - Vacant House |          8        0.04       17.01
*        15 - Building Under Construction |          4        0.02       17.03
*          19 - Suspected W/ Illegalities |
*              20 - Backward Registration |        139        0.64       17.67
*                           21 - No Meter |      1,486        6.81       24.48
*                    22 - Defective Meter |      5,275       24.18       48.65
*          26 - Interchange Meter / Readi |        168        0.77       49.42
*        26 - Interchange Meter / Reading |      1,073        4.92       54.34
*                          29 - New Meter |      8,609       39.46       93.80
*           32 - Inappropriate Batch (Out |          9        0.04       93.84
* 32 - Inappropriate Batch (Out Of Route) |         69        0.32       94.16
*                        33 - Reconnected |         11        0.05       94.21
*                       52 - Not Existing |      1,070        4.90       99.12
*                   53 - TCD Found Active |        160        0.73       99.85
* 99 - Present Rdg is less than Previou..




/*



use "${data}paws/clean/full_sample_with_edu.dta", clear

* keep conacct edu*extra

g high_school = 0
g college = 0
foreach var of varlist edu*extra {
	destring `var', replace force
	replace `var'=. if `var'>15
	replace high_school = high_school+1 if `var'<=11
	replace college = college+1 if `var'>11 & `var'<.
}

ren shr_hh_extra SHH
ren shr_num_extra SNUM

g year = substr(interview,1,4)
g month = substr(interview,6,2)

ren may_exp_extra may
ren wrs_exp_extra wrs

destring hhemp hhsize SHH SNUM year month may wrs, replace force
g date= ym(year,month)

g bar=string(barangay,"%18.0g")
g pasay = regexm(bar,"^7605")

keep conacct college high_school hhemp hhsize date SHH SNUM may wrs pasay

ren * *_paws
ren conacct_paws conacct
ren date_paws date

duplicates drop conacct date, force

save "${temp}paws_temp_date.dta", replace


/*


use "${data}paws/clean/full_sample_with_edu.dta", clear

keep conacct edu*extra

g high_school = 0
g college = 0
foreach var of varlist edu*extra {
	destring `var', replace force
	replace `var'=. if `var'>15
	replace high_school = high_school+1 if `var'<=11
	replace college = college+1 if `var'>11 & `var'<.
}

egen edu_max = rowmax(edu*)

egen edu=max(edu_max), by(conacct)
keep conacct edu high_school college
duplicates drop conacct, force

save "${temp}paws_edu.dta", replace

/*

#delimit;
local bill_query "";
forvalues r = 1/12 {;
	local bill_query "`bill_query' 
	SELECT A.*, `r' AS ba
	FROM coll_`r' AS A
	JOIN (SELECT DISTINCT conacct FROM paws) AS B 
		ON A.conacct = B.conacct
	";
	if `r'!=12{;
		local bill_query "`bill_query' UNION ALL";
	};
};
clear;
#delimit cr;

odbc load, exec("`bill_query'")  dsn("phil") clear  

save "${temp}coll_temp_pay.dta", replace




* SELECT SUM(B.c) AS c, B.date, N.conacctn AS conacct
* FROM (SELECT conacct, conacctn, rank, distance FROM neighbor WHERE rank<=5 & distance<=2) AS N
* JOIN (SELECT DISTINCT conacct from paws) AS P
* ON N.conacctn = P.conacct
* JOIN (SELECT * FROM billing_1 WHERE c<200) AS B
* ON B.conacct = N.conacct
* GROUP BY N.conacctn, B.date


/*
forvalues r = 1/12 {
#delimit;
local bill_query "
	SELECT B.c, B.date, N.conacctn, N.conacct
	FROM (SELECT conacct, conacctn, rank, distance FROM neighbor WHERE rank<=4 & distance<=2) AS N
	JOIN (SELECT DISTINCT conacct from paws) AS P
	ON N.conacctn = P.conacct
	JOIN (SELECT * FROM billing_`r' WHERE c<200) AS B
	ON B.conacct = N.conacct
	";
#delimit cr;
odbc load, exec("`bill_query'")  dsn("phil") clear  

save "${temp}bill_temp_pay_neighbor_`r'.dta", replace
}



forvalues r = 1/12 {
*local r "1"
use "${temp}bill_temp_pay_neighbor_`r'.dta", clear
egen cs = sum(c), by(conacctn date)
keep conacctn date cs
duplicates drop conacctn date, force
ren conacctn conacct
ren cs c
save "${temp}bill_temp_pay_neighbor_`r'_s.dta", replace
}


forvalues r = 1/12 {
if `r'==1 {
use "${temp}bill_temp_pay_neighbor_`r'_s.dta", clear
}
else {
	append using "${temp}bill_temp_pay_neighbor_`r'_s.dta"
}
}
ren c cs
duplicates drop conacct date, force
save "${temp}neighbor_c.dta", replace



/*




use "${data}paws/clean/full_sample_1.dta", clear

g wrs = wrs_exp_extra
replace wrs = alt_src_extra if  wrs_exp_extra=="" &  alt_src_extra!=""

destring wrs, replace force
keep if wrs!=.

g year=substr(interview_,1,4)
	destring year, replace force
	drop if year<2007
g month= substr(interview_,6,2)
	destring month, replace force
g date=ym(year,month)
g exp= may_exp_extra
destring exp, replace force
ren wave wave_wrs

g alt= 1 if regexm(alt_src,"refill")==1
replace alt = 2 if regexm(alt_src,"Pribado")==1
replace alt = 3 if regexm(alt_src,"Deep")==1

keep wrs exp alt conacct wave_wrs date
	duplicates drop conacct date, force

save "${temp}paws_alt.dta", replace






use "${data}paws/clean/full_sample_1.dta", clear

g leak = regexm(billing_error,"Leak")==1
g over_charge = regexm(billing_error,"Mahal na singil")==1

destring disc_times_extra, replace force
keep if disc_times_extra!=.  // keep only disconnect
* drop if disc_times_extra==0
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
keep conacct leak over_charge disc_count days_rec days_pay enough_time

save "${temp}paws_dc.dta", replace




#delimit;
local bill_query "";
forvalues r = 1/12 {;
	local bill_query "`bill_query' 
	SELECT A.*, `r' AS ba
	FROM bill_total_`r' AS A
	JOIN (SELECT DISTINCT conacct FROM paws) AS B 
		ON A.conacct = B.conacct
	";
	if `r'!=12{;
		local bill_query "`bill_query' UNION ALL";
	};
};
clear;
#delimit cr;

odbc load, exec("`bill_query'")  dsn("phil") clear  

save "${temp}bill_total_temp_pay.dta", replace



use "/Users/williamviolette/Documents/Philippines/database/clean/mcf/2010/mcf_102010.dta", clear
	keep conacct ba
	g ba1 = substr(ba,1,2)
	destring ba1, replace force
	drop ba
	drop if ba1==. | conacct==.
	duplicates drop conacct, force
save "${temp}mcf_ba.dta", replace


use "/Users/williamviolette/Documents/Philippines/database/clean/mcf/2010/mcf_102010.dta", clear
	keep conacct mru
	destring mru, replace force
	drop if mru==. | conacct==.
	duplicates drop conacct, force
save "${temp}mcf_mru.dta", replace





local bill_query " SELECT * FROM paws GROUP BY conacct "

odbc load, exec("`bill_query'")  dsn("phil") clear  

save "${temp}paws_temp.dta", replace





#delimit;
local bill_query "";
forvalues r = 1/12 {;
	local bill_query "`bill_query' 
	SELECT A.*, `r' AS ba
	FROM ar_`r' AS A
	JOIN (SELECT DISTINCT conacct FROM paws) AS B 
		ON A.conacct = B.conacct
	";
	if `r'!=12{;
		local bill_query "`bill_query' UNION ALL";
	};
};
clear;
#delimit cr;

odbc load, exec("`bill_query'")  dsn("phil") clear  

save "${temp}ar_temp_pay.dta", replace





#delimit;
local bill_query "";
forvalues r = 1/12 {;
	local bill_query "`bill_query' 
	SELECT A.*, `r' AS ba
	FROM mcf_`r' AS A
	JOIN (SELECT DISTINCT conacct FROM paws) AS B 
		ON A.conacct = B.conacct
	";
	if `r'!=12{;
		local bill_query "`bill_query' UNION ALL";
	};
};
clear;
#delimit cr;

odbc load, exec("`bill_query'")  dsn("phil") clear  

save "${temp}mcf_temp_pay.dta", replace





#delimit;
local bill_query "";
forvalues r = 1/12 {;
	local bill_query "`bill_query' 
	SELECT A.*, `r' AS ba
	FROM billing_`r' AS A
	JOIN (SELECT DISTINCT conacct FROM paws) AS B 
		ON A.conacct = B.conacct
	";
	if `r'!=12{;
		local bill_query "`bill_query' UNION ALL";
	};
};
clear;
#delimit cr;

odbc load, exec("`bill_query'")  dsn("phil") clear  

save "${temp}bill_temp_pay.dta", replace









#delimit;
local bill_query "";
forvalues r = 1/12 {;
	local bill_query "`bill_query' 
	SELECT A.*, `r' AS ba
	FROM ar_bal_`r' AS A
	JOIN (SELECT DISTINCT conacct FROM paws) AS B 
		ON A.conacct = B.conacct
	";
	if `r'!=12{;
		local bill_query "`bill_query' UNION ALL";
	};
};
clear;
#delimit cr;

odbc load, exec("`bill_query'")  dsn("phil") clear  

save "${temp}ar_bal_temp_pay.dta", replace




#delimit;
local bill_query "";
forvalues r = 1/12 {;
	local bill_query "`bill_query' 
	SELECT A.*, `r' AS ba
	FROM bill_total_`r' AS A
	JOIN (SELECT DISTINCT conacct FROM paws) AS B 
		ON A.conacct = B.conacct
	";
	if `r'!=12{;
		local bill_query "`bill_query' UNION ALL";
	};
};
clear;
#delimit cr;

odbc load, exec("`bill_query'")  dsn("phil") clear  

save "${temp}bill_total_temp_pay.dta", replace


