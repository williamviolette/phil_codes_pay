* *  delinquency.do



cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end



use  "${temp}temp_descriptives.dta", clear

*** ROUTINE DATA CLEANING
drop if date==653
egen max_class= max(class), by(conacct)
keep if max_class==1
keep if SHH==1               

*** STANDARD DISCONNECTION
sort conacct date
by conacct: g new_dc = dc[_n-1]!=2 & dc[_n]==2
* hist date if new_dc==1 ** KEEP ONLY LATE ONES

keep if date>=618
tab bal if new_dc==1
g dc_end = c==. & date>=652
egen dcs=sum(dc_end), by(conacct)
*** MEASURE DISCONNECTION THROUGH CMISS

sort conacct date
by conacct: g new_c_id = c[_n-1]!=. & c[_n]==.
g date_c_id = date if new_c_id==1 & dcs>=11 & dcs<=12
egen new_c_date =max(date_c_id), by(conacct)
g new_c = date == new_c_date

** KEEP ONLY EARLY ONES
keep if date<=654 

*** AGGREGATE MEASURE
g DC = new_dc==1 | new_c==1
replace bal = 0 if bal<5  | bal==.
replace bal = . if bal>100000 & bal<.
*hist bal if DC==1

sum bal if DC==1
g bal_avg = `=r(mean)'
sum date, detail
g time = `=r(max)'-`=r(min)'
bys conacct: g cn=_n==1
egen tot_acc = sum(cn)
egen DCS=sum(DC) // cost per disconnection comes to 20 PhP which is decent
g bal_dc = bal if DC==1
egen BAL_TOTAL = sum(bal_dc)
g cost = BAL_TOTAL/(time*tot_acc)
tab cost

sum cost
write "${moments}delinquency_cost.csv" `=r(mean)' 0.1 "%12.0g"



*** 32 PhP per month per account ... 
* another maximum cost : disp 100 * 26 P * 6 months = 15,600
* g cost_alt = DCS*15600/(time*tot_acc) // about the same...
* tab cost_alt
	
	*** 
	* g dc_cost = 10000*DCS/(time*tot_acc)
	* sum dc_cost


