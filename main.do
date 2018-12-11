* main.do


global dataprep_1_  = 0
global analysis_2_  = 0
global lfs_3_       = 0

global tcd_series   = 0
global substitutes  = 0


do subcode/setmacros.do

if $dataprep_1_ == 1 {
	****  all subsetted to PAWS  ****
	* do subcode/ar_bal.do // outstanding balance
	* do subcode/coll.do  // payments
	* do subcode/bill_total.do // total bill amount each month
	* do subcode/mcf.do // main disconnection measure!

	* do subcode/data_prep.do // most temporary input datasets

	*** LESS IMPORTANT DATA PREPPING ***
	* do subcode/paws_pay.do  // paws for substitutes (WRS and may_exp) approach 
	* do subcode/data_prep_tcd.do // for the TCD approach, look for time series..
}


if $analysis_2_ == 1 {
	do subcode/data_prep_analysis.do
	do subcode/analysis.do
}

if $lfs_3_ == 1 {
	* do subcode/lfs.do  // import and compile lfs data
}

if $tcd_series == 1 {
	* tcd time series approach [doesn't really work]
	do subcode/tcd_series.do
	do subcode/tcd_time_series_graph.do
}

if $substitutes == 1 {
	* look at WRS and EXP using paws  [doesn't really work]
	do subcode/substitutes.do  // (data prep submacro)
}



