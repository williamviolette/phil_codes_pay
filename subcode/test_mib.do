

* smpm_mib_dec2012.csv
* mcf_samp_dec2012 - MIB for encoding.csv : not a lot of reactivations...

import delimited using "${mib}sampba_mib2.csv", clear delimiter(",")

import delimited using "${mib}tondo_mib_dec2012.csv", clear delimiter(",")



use "${temp}temp_descriptives_2.dta", clear