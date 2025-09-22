/*
********************************************************************************
** This dofile is the code for Figure 8 in "Digital Safety Nets: How Social Networks Shape Online Medical Crowdfunding Performance".
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** last update: 2025-6-21
** Created date: 2024-12-6
** Data used: 1. example_total.dta
********************************************************************************
*/

use "Workdata/example_total.dta", replace
capture graph drop *

*Figure 8: The impact of exposure to the Compulsory Schooling Law: Event-study results

/*
gen cohort=.
local lb=40
local ub=48
replace cohort=`lb' if age_pat<=`lb' //Age groups with minimum CSL greater than 0.5
replace cohort=`ub' if age_pat>=`ub' //Age groups with maximum CSL less than 0.5 
forvalues i=`=`lb'+1' / `=`ub'-1'{
	replace cohort=`i' if age_pat==`i'
}
egen city_cohort=group(citycode_pat cohort)
*/

gen event_time = csl_affected_age-age_pat+1

forvalues i=0/30{
	capture drop a_`i'
	capture drop b_`i'
}
local w=3
foreach t of numlist 0/8 {
    gen a_`t' = (event_time>=`w'*`t' & event_time<=`w'*`t'+`w'-1)
}
foreach t of numlist 1/5 {
    gen b_`t' = (event_time>=-`w'*`t' & event_time<=-`w'*`t'+`w'-1)
}
replace a_8=1 if event_time>=`w'*8
replace b_5=1 if event_time<=-`w'*5

eststo: reghdfe educ2_avg b_5 b_4 b_3 b_2 o.b_1 a_0 a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 $controls_iv, absorb(citycode_pat age_pat) cluster(citycode_pat)

coefplot, 																///
    keep(b_5 b_4 b_3 b_2 b_1 a*) 										///
	omitted baselevel vertical nooffsets 								///
	xtitle("Age when CSL was implemented") 								///
	ytitle("Coefficient") 												///
	yline(0, lc(gs12) lp(dash))				  							///
	xline(5.5, lc(red) lp(dash))				 						///
	xline(8.5, lc(red) lp(dash))				 						///
	text(1.8 2.25 "Eligibility=0", color(red) placement(e))				///
	text(1.8 5.85 "Partial eligibility", color(red) placement(e))		///
	text(1.8 10.6 "Eligibility=1", color(red) placement(e))				///
	coeflabels(,labsize(small) angle(45))								///
	rename( 															///
	  b_5=">=28" b_4="[25,27]" b_3="[22,24]" 							///
	  b_2="[19,21]" b_1="[16,18]" a_0="[13,15]" 						///
	  a_1="[10,12]" a_2="[7,9]" a_3="[4,6]" a_4="[1,3]" a_5="[-2,0]" 	///
	  a_6="[-5,-3]" a_7="[-8,-6]" a_8="<=-9" 							///
	) 																	///
	saving("Figures/Figure8_1", replace)
graph export "Figures/Figure8_1.png", replace

eststo: reghdfe log_don_amt_nw b_5 b_4 b_3 b_2 o.b_1 a_0 a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 $controls_iv, absorb(citycode_pat age_pat) cluster(citycode_pat)

coefplot, 																///
    keep(b_5 b_4 b_3 b_2 b_1 a*) 										///
	omitted baselevel vertical nooffsets 								///
	xtitle("Age when CSL was implemented") 								///
	ytitle("Coefficient")												///
	yline(0, lc(gs12) lp(dash))				  							///
	yscale(range(-1 2.5))												///
	ylabel(-1(0.5)2.5)													///
	xline(5.5, lc(red) lp(dash))				 						///
	xline(8.5, lc(red) lp(dash))				 						///
	text(2.35 2.25 "Eligibility=0", color(red) placement(e))				///
	text(2.35 5.85 "Partial eligibility", color(red) placement(e))		///
	text(2.35 10.6 "Eligibility=1", color(red) placement(e))			///
	coeflabels(,labsize(small) angle(45))								///
	rename( 															///
	  b_5=">=28" b_4="[25,27]" b_3="[22,24]" 					        ///
	  b_2="[19,21]" b_1="[16,18]" a_0="[13,15]" 						///
	  a_1="[10,12]" a_2="[7,9]" a_3="[4,6]" a_4="[1,3]" a_5="[-2,0]" 	///
	  a_6="[-5,-3]" a_7="[-8,-6]" a_8="<=-9" 							///
	) 																	///
	saving("Figures/Figure8_2", replace)
graph export "Figures/Figure8_2.png", replace

/*
Dependent variable: measures of network structure
eststo: reghdfe user_num_pct_nw1 b_5 b_4 b_3 b_2 o.b_1 a_0 a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 $controls_iv, absorb(citycode_pat age_pat) cluster(citycode_pat)

coefplot, 																///
    keep(b_5 b_4 b_3 b_2 b_1 a*) 										///
	omitted baselevel vertical nooffsets 								///
	xtitle("Age when CSL was implemented") 								///
	ytitle("Coefficient (Y= Proportion of viewers from depth 1)")		///
	yline(0, lc(gs12) lp(dash))				  							///
	xline(5, lc(gs12) lp(dash))				 							///
	coeflabels(,labsize(small) angle(45))								///
	rename( 															///
	  b_5=">=28" b_4="[25,27]" b_3="[22,24]" 							///
	  b_2="[19,21]" b_1="[16,18]" a_0="[13,15]" 						///
	  a_1="[10,12]" a_2="[7,9]" a_3="[4,6]" a_4="[1,3]" a_5="[-2,0]" 	///
	  a_6="[-5,-3]" a_7="[-8,-6]" a_8="<=-9" 							///
	) 																	///
	saving("Figures/event_studyC", replace)
graph export "Figures/event_studyC.png", replace

eststo: reghdfe hhi b_5 b_4 b_3 b_2 o.b_1 a_0 a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 $controls_iv, absorb(citycode_pat age_pat) cluster(citycode_pat)

coefplot, 																///
    keep(b_5 b_4 b_3 b_2 b_1 a*) 										///
	omitted baselevel vertical nooffsets 								///
	xtitle("Age when CSL was implemented") 								///
	ytitle("Coefficient (Y=HHI)") 										///
	yline(0, lc(gs12) lp(dash))				  							///
	xline(5, lc(gs12) lp(dash))				 							///
	coeflabels(,labsize(small) angle(45))								///
	rename( 															///
	  b_5=">=28" b_4="[25,27]" b_3="[22,24]" 							///
	  b_2="[19,21]" b_1="[16,18]" a_0="[13,15]" 						///
	  a_1="[10,12]" a_2="[7,9]" a_3="[4,6]" a_4="[1,3]" a_5="[-2,0]" 	///
	  a_6="[-5,-3]" a_7="[-8,-6]" a_8="<=-9" 							///
	) 																	///
	saving("Figures/event_studyD", replace)
graph export "Figures/event_studyD.png", replace

eststo: reghdfe entropy b_5 b_4 b_3 b_2 o.b_1 a_0 a_1 a_2 a_3 a_4 a_5 a_6 a_7 a_8 $controls_iv, absorb(citycode_pat age_pat) cluster(citycode_pat)

coefplot, 																///
    keep(b_5 b_4 b_3 b_2 b_1 a*) 										///
	omitted baselevel vertical nooffsets 								///
	xtitle("Age when CSL reform is effective") 							///
	ytitle("Coefficient (Y=Entropy") 									///
	yline(0, lc(gs12) lp(dash))				  							///
	xline(5, lc(gs12) lp(dash))				 							///
	coeflabels(,labsize(small) angle(45))								///
	rename( 															///
	  b_5=">=28" b_4="[25,27]" b_3="[22,24]" 							///
	  b_2="[19,21]" b_1="[16,18]" a_0="[13,15]" 						///
	  a_1="[10,12]" a_2="[7,9]" a_3="[4,6]" a_4="[1,3]" a_5="[-2,0]" 	///
	  a_6="[-5,-3]" a_7="[-8,-6]" a_8="<=-9" 							///
	) 																	///
	saving("Figures/event_studyE", replace)
graph export "Figures/event_studyE.png", replace
*/