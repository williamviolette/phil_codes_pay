
* export_moments


sum am if date<dc_date, detail
write "${moments}dc_shr${tag}.csv" `=r(mean)' 0.0001 "%12.4g"

cap drop bal_0
g bal_0 = 0       if bal!=0
replace bal_0 = 1 if bal==0
sum bal_0, detail
write "${moments}bal_0${tag}.csv" `=r(mean)' 0.0001 "%12.4g"

sum bal if dc_date==date
write "${moments}bal_end${tag}.csv" `=r(mean)' 0.1 "%12.0g"

sum c, detail
write "${moments}c_avg${tag}.csv" `=r(mean)' 0.1 "%12.0g"

sum bal, detail
write "${moments}bal_avg${tag}.csv" `=r(mean)' 0.1 "%12.0g"

