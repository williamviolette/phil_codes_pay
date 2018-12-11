




cap program drop load_data_ar_bal
prog define load_data_ar_bal
	odbc exec("DROP TABLE IF EXISTS ar_bal_`1';"), dsn("phil")
	odbc exec("CREATE TABLE ar_bal_`1' ( conacct INTEGER, date INTEGER, bal REAL );"), dsn("phil")

	use "${billingdata}`2'_ar_2009_2015.dta", clear 
		keep conacct year month amount
			drop if conacct == .
			egen bal = sum(amount), by(conacct year month)
		keep conacct year month bal
		sort conacct year month bal
			by conacct year month: g id1=_n
			keep if id1==1
			drop id1
		destring month year, replace force
		g date = ym(year,month)
			drop year month
		order conacct date bal

	odbc insert, table("ar_bal_`1'") dsn("phil")
end


load_data_ar_bal 1 tondo 
load_data_ar_bal 2 pasay 
load_data_ar_bal 3 val 
load_data_ar_bal 4 qc_09 
load_data_ar_bal 5 qc_12 
load_data_ar_bal 6 samp 
load_data_ar_bal 7 qc_04 
load_data_ar_bal 8 bacoor 
load_data_ar_bal 9 so_cal 
load_data_ar_bal 10 cal_1000 
load_data_ar_bal 11 muntin 
load_data_ar_bal 12 para


cap program drop addindex_gen
prog define addindex_gen
	odbc exec("CREATE INDEX `2'_`1'_conacct_ind ON `2'_`1' (conacct);"), dsn("phil")	
	odbc exec("CREATE INDEX `2'_`1'_date_ind ON `2'_`1' (date);"), dsn("phil")		
end

forvalues r=1/12 {
	addindex_gen `r' "ar_bal"
}



