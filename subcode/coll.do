




cap program drop load_data_coll
prog define load_data_coll
	odbc exec("DROP TABLE IF EXISTS coll_`1';"), dsn("phil")
	odbc exec("CREATE TABLE coll_`1' ( conacct INTEGER, date INTEGER, pay INTEGER );"), dsn("phil")

	use "${billingdata}`2'_coll_2008_2015.dta", clear 
		keep conacct year month totalpymnt
		
		drop if conacct == .
		drop if totalpymnt < 10
		egen pay = sum(totalpymnt), by(conacct year month)
			drop totalpymnt
		duplicates drop conacct year month, force
		destring year month, replace force
		g date = ym(year,month)
			drop year month
		order conacct date pay
	odbc insert, table("coll_`1'") dsn("phil")
end


load_data_coll 1 tondo 
load_data_coll 2 pasay 
load_data_coll 3 val 
load_data_coll 4 qc_09 
load_data_coll 5 qc_12 
load_data_coll 6 samp 
load_data_coll 7 qc_04 
load_data_coll 8 bacoor 
load_data_coll 9 so_cal 
load_data_coll 10 cal_1000 
load_data_coll 11 muntin 
load_data_coll 12 para


cap program drop addindex_gen
prog define addindex_gen
	odbc exec("CREATE INDEX `2'_`1'_conacct_ind ON `2'_`1' (conacct);"), dsn("phil")	
	odbc exec("CREATE INDEX `2'_`1'_date_ind ON `2'_`1' (date);"), dsn("phil")		
end

forvalues r=1/12 {
	addindex_gen `r' "coll"
}



