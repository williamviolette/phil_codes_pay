






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






