


cap program drop load_data
prog define load_data
	odbc exec("DROP TABLE IF EXISTS bill_total_`1';"), dsn("phil")
	odbc exec("CREATE TABLE bill_total_`1' ( conacct INTEGER, date INTEGER, amount INTEGER );"), dsn("phil")

	use "${billingdata}`2'_billing_2008_2015.dta", clear 
		ren CONTRACT_A conacct
		drop if conacct == .
		keep month year conacct amount

		destring month year, replace force
		g date = ym(year,month)
		drop year month

		replace amount=round(amount,1)

		keep conacct date amount
		order conacct date amount
		duplicates drop conacct date, force

	odbc insert, table("bill_total_`1'") dsn("phil")
	*odbc exec("DELETE FROM billing_`1' WHERE ROWID NOT IN (SELECT min(ROWID) FROM billing_`1' GROUP BY conacct, date);"), dsn("phil")
end

*
load_data 1 tondo 
load_data 2 pasay 
load_data 3 val 
load_data 4 qc_09 
load_data 5 qc_12 
load_data 6 samp 
load_data 7 qc_04 
load_data 8 bacoor 
load_data 9 so_cal 
load_data 10 cal_1000 
load_data 11 muntin 
load_data 12 para
*

cap program drop addindex
prog define addindex
	odbc exec("CREATE INDEX bill_total_`1'_conacct_ind ON billing_`1' (conacct);"), dsn("phil")	
	odbc exec("CREATE INDEX bill_total_`1'_date_ind ON billing_`1' (date);"), dsn("phil")		
end

forvalues r=1/12 {
	addindex `r'
}
