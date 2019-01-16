* prom_note.do



import excel using "${phil_folder}data/pn_bulk_accounts/Promissory Notes/Promissory Note (Jul 2013) _ 360714.xlsx", cellrange(B4:) clear    

keep G J K L N O P Q R S	


ren G conacct
ren J pn
ren K pn_val
ren L months
ren N water
ren O inst
ren P meter
ren Q others
ren 




import delimited using "${phil_folder}data/pn_bulk_accounts/Promissory Notes/pn_06_2015.csv", clear delimiter(",")

	 	destring v6, replace force
		drop if v6==.
		duplicates drop v6, force
		
			destring v10-v19, replace force ignore(,)
	
	ren v1 ba
	ren v2 zone
	ren v3 zone_sp
	ren v4 mru
	ren v5 class
	ren v6 conacct
	drop v7 v8
	ren v9 pn
	ren v10 amount
	ren v11 months
	ren v12 overdue
	ren v13 water
	ren v14 inst
	ren v15 meter
	ren v16 others
	ren v17 paid
	ren v18 balance
	ren v19 pn_ar
	

bys inst: g IN=_N


tab inst if IN>5000


tab inst if inst>0 & inst<300

bys others: g ON=_N

tab others if ON>700