* fies.do


cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end

import delimited using "${fies}FAMILY INCOME AND EXPENDITURE SURVEY (2015) VOLUME 2 - TOTALS OF INCOME AND EXPENDITURE - raw data.csv", delimiter(",") clear

	replace toinc = toinc/12
	sum toinc if toinc<1500000/12 & w_regn=="Region XIII - NCR"
	write "${moments}y_avg.csv" `=r(mean)' 1 "%12.0g"
	write "${tables}y_avg.tex" `=r(mean)' 1 "%12.0fc"


	replace ttotex = ttotex/12
	g ss = toinc - ttotex
	sum ss if toinc<1500000/12 &  ttotex<1500000/12 & w_regn=="Region XIII - NCR"
	write "${moments}save_avg.csv" `=r(mean)' 1 "%12.0g"
	write "${tables}save_avg.tex" `=r(mean)' 1 "%12.0fc"


	g ss_rate = ss/toinc
	sum ss_rate  if toinc<1500000/12 &  ttotex<1500000/12 & w_regn=="Region XIII - NCR"
	write "${moments}save_rate.csv" `=r(mean)' 1 "%12.2g"	
	write "${tables}save_rate.tex" `=r(mean)' 1 "%12.2fc"	

