* graph_ar.do




cap prog drop print_mean
program print_mean
    qui sum `2', detail 
    local value=string(`=r(mean)*`4'',"`3'")
    file open newfile using "${tables}`1'.tex", write replace
    file write newfile "`value'"
    file close newfile    
end




print_mean disc_prob tcd_id "%10.2fc" 100

cap drop tcd_id_60
g tcd_id_60 = tcd_id if ar_pre>=60
print_mean disc_prob_60 tcd_id_60 "%10.2fc" 100
drop tcd_id_60

cap drop tcd_id_key
g tcd_id_key = tcd_id if key_sample==1
print_mean disc_prob_key tcd_id_key "%10.2fc" 100
drop tcd_id_key





cap drop ar_pre1
g ar_pre1 = ar_pre
replace ar_pre1 = . if c==.

cap drop tcd_id_g
g tcd_id_g=tcd_id if key_sample==1
cap drop m_tcd_id
egen m_tcd_id = mean(tcd_id_g), by(ar_pre)
cap drop arm
bys ar_pre1: g arm=_n
scatter m_tcd_id ar_pre1 if arm==1 & ar_pre1<=400, xtitle("Days Delinquent") ytitle("Probability of Receiving a Disconnection Notice")
graph export "${tables}dc_hazard.pdf", as(pdf) replace

cap drop m_tcd
egen m_tcd = mean(tcd_id), by(ar_pre1)
scatter m_tcd ar_pre if arm==1 & ar_pre1<=400, xtitle("Days Delinquent") ytitle("Probability of Receiving a Disconnection Notice")
graph export "${tables}dc_hazard_full.pdf", as(pdf) replace



*** Predict notice!


sort conacct date
cap drop bal_pre
by conacct: g bal_pre = bal[_n-1]

cap drop cn 
by conacct: g cn = _n

cap drop c_pre
by conacct: g c_pre = c if cn<=5

cap drop tcd_id1
cap drop cn_early
cap drop cn1
by conacct: g cn_early = cn if tcd_id==1
egen cn1=min(cn_early), by(conacct)


g tcd_id1 = tcd_id==1 & cn==cn1




cap drop cmp
egen cmp=mean(c_pre), by(conacct)



sum tcd_id, detail
global tcd_id_sd = `=r(sd)'
global tcd_id_mean=`=r(mean)'

sum tcd_id if key_sample==1, detail
global tcd_id_sd_key = `=r(sd)'
global tcd_id_mean_key=`=r(mean)'


tab ar_pre, matrow(days)

forvalues r=1/16 {
	global f=days[`r',1]
	cap drop dd_$f
	g dd_$f = ar_pre==$f
	lab var dd_$f "$f Days"
}

lab var cmp "Mean Usage"
lab var bal_pre "Outstanding Balance"
lab var house_1 "Single House"
lab var house_2 "Apartment"
lab var hhemp "Employed HH Members"
lab var hhsize "Household Size"
lab var low_skill "HoH Low Skill Employment"
lab var age "Age"

global keep_list = "bal_pre house_1 house_2 age hhemp hhsize low_skill dd_*"

reg tcd_id cmp bal_pre  dd_* house_1 house_2 age hhemp hhsize low_skill i.date  if ar_pre>60 & cn<=cn1, cluster(conacct) robust
matrix define E = e(b)
global bp = E[1,2]
global cp = E[1,1]

global vv=string(`=${tcd_id_mean}',"%10.3fc")

outreg2 using "${tables}dc_hazard_reg.tex", tex(frag) keep( $keep_list )  ///
	replace addtext("Avg. New Conn.","${vv}") label ///
	ctitle("Full Sample") 


reg tcd_id cmp bal_pre house_1 house_2 age hhemp hhsize low_skill dd_* house_1 house_2 age hhemp hhsize low_skill  i.date  if ar_pre>60 & cn<=cn1 & key_sample==1, cluster(conacct) robust

global vv=string(`=${tcd_id_mean_key}',"%10.3fc")

outreg2 using "${tables}dc_hazard_reg.tex", tex(frag) keep( $keep_list )  ///
	append addtext("Avg. New Conn.","${vv}") label ///
	ctitle("Paid Notice Sample") 




sum bal_pre, detail
global bal_pre_sd = `=r(sd)'

sum cmp 
global cmp_sd = `=r(sd)'

disp (${bp}*${bal_pre_sd})/${tcd_id_sd}

disp (${cp}*${cmp_sd})/${tcd_id_sd}


disp (${bp}*${bal_pre_mean})/${tcd_id_mean}

disp (${cp}*${cmp_mean})/${tcd_id_mean}



disp `=`=${bp}'*`=${bal_pre_sd}''




