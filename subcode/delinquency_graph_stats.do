* *  delinquency.do

grstyle init
grstyle set imesh, horizontal



cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end

global data_load_dc = 0 


if $data_load_dc ==1 {

foreach v in pasay para qc_09 qc_04 qc_12 cal_1000 bacoor muntin tondo val {
use "${billingdata}`v'_billing_2008_2015.dta", clear
ren CONTRACT_A conacct
keep if year=="2014" | year=="2015"
keep conacct year month volume
destring volume, replace force
drop if conacct==. | volume==.

duplicates drop conacct year month, force

bys conacct: g cN=_N

keep conacct cN
duplicates drop conacct, force

save "${temp}`v'_cn.dta", replace


use "${billingdata}`v'_mcf_2009_2015.dta", clear

keep if RATE_TYPE=="RESRATE"
keep conacct acctcreat

g year_c = substr(acctcreat,-4,4)
g month_c = substr(acctcreat,1,2) if length(acctcreat)==8
replace month_c = substr(acctcreat,1,1) if length(acctcreat)==7

replace month_c = substr(acctcreat,6,2) if regexm(acctcreat,"/")==1
replace year_c = substr(acctcreat,1,4) if regexm(acctcreat,"/")==1

destring month_c year_c, replace force
g date_c = ym(year_c,month_c)

destring date_c, replace
keep conacct date_c
duplicates drop conacct, force

save "${temp}`v'_date_c.dta", replace

}

}



**** RUN DATA ****

foreach v in pasay para qc_09 qc_04 qc_12 cal_1000 bacoor muntin tondo val {
	if "`v'"=="pasay" {
		use "${temp}`v'_cn.dta", clear
	}
	else {
	append using "${temp}`v'_cn.dta"
	} 
	* erase "${temp}`v'_cn.dta"
}
gegen cNM=max(cN), by(conacct)
drop cN
ren cNM cN
duplicates drop conacct, force

save "${temp}cn.dta", replace


foreach v in pasay para qc_09 qc_04 qc_12 cal_1000 bacoor muntin tondo val {
	if "`v'"=="pasay" {
		use "${temp}`v'_date_c.dta", clear
	    g ba="`v'"
	}
	else {
	append using "${temp}`v'_date_c.dta"
	replace ba="`v'" if ba==""
	} 
	* erase "${temp}`v'_date_c.dta"
}
gegen date_cM=max(date_c), by(conacct)
drop date_c
ren date_cM date_c
duplicates drop conacct, force
save "${temp}date_c.dta", replace




use "${temp}date_c.dta", clear

merge 1:1 conacct using "${temp}cn.dta"
drop if _merge==2
drop _merge

g dc = cN==.
g con = dc==0


* replace conm=. if conm>.25

egen conm=mean(con), by(date_c)

format date_c %tm

bys date_c: g cn=_n

replace conm=. if  conm<.9 & date_c>620


reg conm date_c if date_c<=645 & date_c>=588 & cn==1

mat define b=e(b)

disp (((1/b[1,1])+1)*(1/b[1,1])/2)*b[1,1]
global acct_time =  (((1/b[1,1])+1)*(1/b[1,1])/2)*b[1,1]
global coef = round(b[1,1],.00001)

lab var conm    "Share Connected in 2014"
lab var date_c  "Date Created"
twoway scatter conm date_c if cn==1 & date_c<648 & date_c>=588 ///
 || lfit conm date_c if cn==1 & date_c<648  & date_c>=588, note("Linear Coefficient: 0$coef ")

graph export "${tables}disconnection_hazard.pdf", as(pdf) replace


write "${moments}disc_per_month.csv" $coef .000001 "%12.5g"

write "${moments}account_length.csv" $acct_time .01 "%12.2g"
write "${tables}account_length.tex" $acct_time 1 "%12.0fc"




