






#delimit;
local bill_query "";
forvalues r = 1/12 {;
	local bill_query "`bill_query' 
	SELECT A.conacct, A.date, A.dc, `r' AS ba
	FROM (SELECT * FROM mcf_`r' WHERE dc==1) AS A
	LEFT JOIN (SELECT conacct AS conacct1, date-1 AS date1, dc AS dc1 FROM mcf_`r' WHERE dc1==1) AS B 
	ON A.conacct = B.conacct1 AND A.date = B.date1
	WHERE dc1 IS NULL
	";
	if `r'!=12{;
		local bill_query "`bill_query' UNION ALL";
	};
};
clear;
#delimit cr;

odbc load, exec("`bill_query'")  dsn("phil") clear  

drop if date==664
drop if date==588

save "${temp}mcf_temp_tcd.dta", replace



use  "${temp}mcf_temp_tcd.dta", clear

odbc insert, table("mcf_temp_tcd")  dsn("phil") create 
	
	odbc exec("CREATE INDEX mcf_temp_tcd_conacct_ind ON mcf_temp_tcd (conacct);"), dsn("phil")	
	odbc exec("CREATE INDEX mcf_temp_tcd_date_ind ON mcf_temp_tcd (date);"), dsn("phil")		



forvalues r = 1/12 {
	odbc load, exec("SELECT * FROM ar_`r'")  dsn("phil") clear  
		merge 1:m conacct date using "${temp}mcf_temp_tcd.dta"
		keep if _merge==3
		drop _merge dc
	duplicates drop conacct date, force
	save "${temp}ar_tcd_`r'.dta", replace
}

forvalues r=1/12 {
	if `r'==1 {
		use "${temp}ar_tcd_`r'.dta", clear
	}
	else {
		append using "${temp}ar_tcd_`r'.dta"
	}
}
save "${temp}ar_temp_tcd.dta", replace

* forvalues r=1/12 {
* 	erase "${temp}ar_tcd_`r'.dta"
* }

* local bill_query ""
* forvalues r = 1/12 {
* 	local bill_query "`bill_query' SELECT A.*, `r' AS ba FROM ar_`r' AS A JOIN (SELECT conacct, date FROM mcf_temp_tcd) AS B  ON A.conacct = B.conacct AND A.date = B.date"
* 	if `r'!=12{
* 		local bill_query "`bill_query' UNION ALL"
* 	}
* }
* odbc load, exec("`bill_query'")  dsn("phil") clear  






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









