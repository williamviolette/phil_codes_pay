* export_paws_stats.do


cap prog drop write
prog define write
	file open newfile using "`1'", write replace
	file write newfile "`=string(round(`2',`3'),"`4'")'"
	file close newfile
end


use "${data}paws/clean/full_sample_1.dta", clear
 
*** NOTE: don't find TCD rec charges much in PNs!
*** BUT: do I find PNs as evidence of notice?! that would be the evidence....
	** No, very few PNs and they are only for BIG delinquencies!

***** Concern:  What if TCD is actually disconnecting people for a little while (a few days?) until they pay?

*** A) date of payment on collection records? date of visitation in MCF? [ more notes in MCF? ]
	* MCF has info on reconnected status, and whether TCD is "found active", good coverage (all years)
		* Pasay total: 100,000 then 30,000 get TCD'd at some point, half reconnect 15,000 BUT: very few documented re-connections (only like 3-6,000) 
		* ALSO: what about illegal activity extending a loan?!?!? (build that in?!)?!?
	* we have the post_date of all the payments, which is cool, possibly...
		* get the day of the month on collection records


*** B) consumption drop at 60 days AR (why does payment look weird there?)


*** C) track patterns of survey respondents who are disconnected, and translate correctly
	* key : find respondents that PAY IMMEDIATELY, then look at when they say they are reconnected!!

	** key, do they pay??


*** D) USE DYNAMICS!

	* D.1 cmiss then not miss (could be partial)
	* D.2 pay a lot!, then never miss?
	* D.3 pay correspond exactly with drop?! NOT REALLY! CORRESPONDS MORE WITH MISSING CONSUMPTION!
		* part of this is the construction of the measure
	*** smoothing argument?! washing clothes, showering...

	***** Use size of balance (paying more means more credit constrained!!) conditioning for missing consumption

	** evidence for this approach:
		* D.a reconnect quickly, especially for quick payers (2 days, not ideal...)
		* D.b do payments and usage line up??

		*** exploit more of the timing??



*** E) USE NEIGHBOR USE!!  those [DC'd] and those [NOT DC'd] !   THIS IS DOABLE...

	** what's the goal: FIND ZERO
	** ugh, can't find anything good... 


*** F) FIND OTHER INCOME SHOCKS!!! look at complaints for billing shocks/errors !!

	*** use generous and non-generous handlers; super not generalizable...

	*** VERY HARD TO DISENTANGLE FROM LEAKS (ALTHOUGH LEAKS ARE SOLID....)

 * disconnection in past year because of non-payment (number of times)
 * if yes, go to days given to pay the amount, enough time
 * if no, go to 

* days given to pay the amount 

*** G) SAME PAYMENT, LENGTH OF delinquency!!


*** half the time, they DC without warning (surprise!)
*** mandated to reconnect in 2 days!  (percentage of the month..)
*** can this account for prompt payers?  how does this story relate to the credit constraints idea?!?!?



 * *** DISCONNECTION 

***** COUNTERNARRATIVE

* households are disconnected, and there's a lag to being reconnected EVEN if they pay for reconnection!

*** if there are NO partial disconnections
	** then NO household should use from a neighbor when cmiss==0
	** this is actually not a bad test!!!
	** show how much DC'd households switch over, then show that non-dc'd households barely switch
	** so then its mostly cutting back!








g dc_note = 1 if regexm(disc_notice,"Oo")==1
replace dc_note=0 if regexm(disc_notice,"Hindi")==1
sum dc_note
	write "${tables}dc_note.tex" `=100*`=r(mean)'' 0.1 "%12.0g"

destring days_to_pay_extra, replace force
sum days_to_pay_extra
	write "${tables}days_pay_average.tex" `=r(mean)' 0.1 "%12.0g"

g dp_30=1 if days_to_pay_extra<=30
replace dp_30=0 if days_to_pay_extra>30 & days_to_pay_extra<.
sum dp_30
	write "${tables}days_pay_under_30.tex" `=100*`=r(mean)'' 0.1 "%12.0g"

g et = 1 if regexm(enough_time,"Oo")==1
replace et=0 if regexm(enough_time,"Hindi")==1
sum et
	write "${tables}enough_time.tex" `=100*`=r(mean)'' 0.1 "%12.0g"


destring days_before_rec_extra, replace force
sum days_before_rec_extra, detail


