




cap program drop load_data_mcf
prog define load_data_mcf
	odbc exec("DROP TABLE IF EXISTS mcf_`1';"), dsn("phil")
	odbc exec("CREATE TABLE mcf_`1' ( conacct INTEGER, date INTEGER, dc INTEGER );"), dsn("phil")

	use "${billingdata}`2'_mcf_2009_2015.dta", clear 
		keep conacct year month BLK_UTIL
		
		drop if conacct == .
		g dc = 1 if BLK_UTIL == "6" | BLK_UTIL=="06" | BLK_UTIL=="TCD"
		replace dc = 2 if BLK_UTIL == "7" | BLK_UTIL=="07" | BLK_UTIL=="PCD"
		drop if dc==.
		duplicates drop conacct year month, force
		destring year month, replace force
		drop BLK_UTIL
		g date = ym(year,month)
			drop year month
		order conacct date dc
	odbc insert, table("mcf_`1'") dsn("phil")
end


load_data_mcf 1 tondo 
load_data_mcf 2 pasay 
load_data_mcf 3 val 
load_data_mcf 4 qc_09 
load_data_mcf 5 qc_12 
load_data_mcf 6 samp 
load_data_mcf 7 qc_04 
load_data_mcf 8 bacoor 
load_data_mcf 9 so_cal 
load_data_mcf 10 cal_1000 
load_data_mcf 11 muntin 
load_data_mcf 12 para


cap program drop addindex_gen
prog define addindex_gen
	odbc exec("CREATE INDEX `2'_`1'_conacct_ind ON `2'_`1' (conacct);"), dsn("phil")	
	odbc exec("CREATE INDEX `2'_`1'_date_ind ON `2'_`1' (date);"), dsn("phil")		
end

forvalues r=1/12 {
	addindex_gen `r' "mcf"
}



