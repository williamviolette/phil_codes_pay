


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




/*


use "${data}paws/clean/full_sample_1.dta", clear

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
keep conacct leak over_charge disc_count days_rec days_pay enough_time

save "${temp}paws_dc.dta", replace



/*

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




/*
use "/Users/williamviolette/Documents/Philippines/database/clean/mcf/2010/mcf_102010.dta", clear
	keep conacct ba
	g ba1 = substr(ba,1,2)
	destring ba1, replace force
	drop ba
	drop if ba1==. | conacct==.
	duplicates drop conacct, force
save "${temp}mcf_ba.dta", replace





local bill_query " SELECT * FROM paws GROUP BY conacct "

odbc load, exec("`bill_query'")  dsn("phil") clear  

save "${temp}paws_temp.dta", replace





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


/*
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


/*



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









