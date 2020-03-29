
set scheme s1mono

grstyle init
grstyle set imesh, horizontal


use  "${temp}temp_descriptives_3.dta", clear


g T = date-dc_date

gegen m_bal = mean(bal), by(T)
gegen Ttag= tag(T)

twoway scatter m_bal T if Ttag==1 & T>=-36 & T<=0, ///
xtitle("Months to Permanent Disconnection") ///
ytitle("Average Unpaid Balance (PhP)") xlabel(-36(12)0)

graph export "${tables}pay_to_dc_graph.png", as(png) replace



