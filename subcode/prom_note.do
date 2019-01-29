* prom_note.do


*** PNs ARENT GONNA WORK, NOT ENOUGH NEW ONES, and ONLY FOR BIG ACCOUNTS/DEBTS! 




cap prog drop pn_save
prog define pn_save
import delimited using "${phil_folder}data/pn_bulk_accounts/Promissory Notes/`1'.csv", clear delimiter(",")

	 	destring v6, replace force
		drop if v6==.
	*	duplicates drop v6, force
		
			destring v10-v19, replace force ignore(,)
	
	ren v6 conacct
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
	
	keep conacct pn amount months overdue water inst meter others paid balance pn_ar

	drop if inst>0 & inst<.
	drop if meter>0 & inst<.

	duplicates drop conacct pn, force

save "${temp}`1'.dta", replace
end


pn_save pn_07_2013
pn_save pn_08_2013
pn_save pn_09_2013
pn_save pn_10_2013


global r=0
foreach k in 08 09 10 {
	if $r ==0 {
	use "${temp}pn_`k'_2013.dta", clear
	global r=1
	g yr = "`k'"
	}
	else {
		append using "${temp}pn_`k'_2013.dta"
		replace yr="`k'" if yr==""
	}
}

destring yr, replace force


sort pn yr
by pn: g sn=_n
by pn: g dn=_N

drop if dn==3

tab yr if dn==1

 sum water if water>0 & water<.


 hist water if water>0 & water<.

 hist water if water>0 & water<10000


* ONLY HUGE THINGS IN PNs!! ( and many months... otherwise, doesn't show up in the data!)




/*


* import excel using "${phil_folder}data/pn_bulk_accounts/Promissory Notes/Promissory Note (Jul 2013) _ 360714.xlsx", cellrange(B4:) clear    

* keep G J K L N O P Q R S	


* ren G conacct
* ren J pn
* ren K pn_val
* ren L months
* ren N water
* ren O inst
* ren P meter
* ren Q others
* ren 








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