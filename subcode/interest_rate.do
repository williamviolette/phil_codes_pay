* interest_rate.do

cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end

import delimited using "${irate}world_bank_rate.csv", delimiter(",") clear
destring * , replace force


keep if v1>=2010 & v1<=2015
replace v2=v2/100
sum v2
write "${moments}irate.csv" `=r(mean)' 0.0001 "%12.4g"


write "${tables}irate.tex" `=r(mean)*100' 0.1 "%12.1g"

