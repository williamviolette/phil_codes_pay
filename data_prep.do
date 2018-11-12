


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









