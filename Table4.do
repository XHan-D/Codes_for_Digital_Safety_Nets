/*
********************************************************************************
** This dofile is the code for Table 4 in "Digital Safety Nets: How Social Networks Shape Online Medical Crowdfunding Performance".
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** last update: 2025-7-2
** Created date: 2024-12-6
** Data used: 1. example_total.dta
********************************************************************************
*/

use "Workdata/example_total.dta", clear
capture est drop *

*Table 4: Education, network structure, and medical crowdfunding performance

*Constructing cohorts
*bys age_pat: sum csl_affected
gen cohort=.
gen city_cohort=.
local lb=40
local ub=48
replace cohort=`lb' if age_pat<=`lb' //Age groups with minimum CSL greater than 0.5
replace cohort=`ub' if age_pat>=`ub' //Age groups with maximum CSL less than 0.5 
forvalues i=`=`lb'+1' / `=`ub'-1'{
	replace cohort=`i' if age_pat==`i'
}
ereplace city_cohort=group(citycode_pat cohort)

/* Other possible specifications
replace cohort = 1 if age_pat<18 				//Before college
replace cohort = 2 if age_pat>=18 & age_pat<23 	//College student
replace cohort = 3 if age_pat>=23 & age_pat<42
//Some individuals with full CSL (CSL==1 only if age_pat<42)
replace cohort = 5 if age_pat>=43 & age_pat<46	
//All individuals >0%, no individual=100%
replace cohort = 6 if age_pat>=46
//Some individuals without CSL (CSL==0 only if age_pat>=46)

ereplace city_cohort=group(citycode_pat cohort)
*/

gen cohort2=.
gen city_cohort2=.
replace cohort2 = 0 if age_pat<=23 				//Born after 2000
replace cohort2 = 1 if age_pat>23 & age_pat<=33 //Born between 1990-2000
replace cohort2 = 2 if age_pat>33 & age_pat<=43 //Born between 1980-1990
replace cohort2 = 3 if age_pat>43 & age_pat<=53 //Born between 1970-1980
replace cohort2 = 4 if age_pat>53 & age_pat<=63 //Born between 1960-1970
replace cohort2 = 5 if age_pat>63 				//Born before 1960
ereplace city_cohort2=group(citycode_pat cohort2)



*Panel A
preserve 
drop if age_pat<15 | educ2_avg<2
capture est drop *

foreach measure in $measurements{
	eststo: qui reghdfe `measure' educ2_avg $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)
	qui sum `measure' if e(sample)
	qui estadd scalar mean=r(mean)
	
	qui ivreghdfe `measure' (educ2_avg=csl_affected) $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first
	eststo `measure'_iv
	qui estadd scalar first_stage_F=e(rkf)
	qui sum `measure' if e(sample)
	qui estadd scalar mean=r(mean): `measure'_iv
}

esttab, ///
keep(educ2_avg) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2 first_stage_F, fmt(%9.3fc %15.0fc %9.3fc %9.2fc))

esttab using "Tables/Tabel4_PanelA.tex", replace ///
keep(educ2_avg) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2 first_stage_F, fmt(%9.3fc %15.0fc %9.3fc %9.2fc))

restore


*Panel B
preserve 
drop if age_pat<15 | educ2_avg<2
capture est drop *

*Column 1
eststo: qui reghdfe log_don_amt_nw educ2_avg $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)
qui sum log_don_amt_nw if e(sample)
qui estadd scalar mean=r(mean)

*Column 2
eststo: qui reghdfe log_don_amt_nw educ2_avg user_num_pct_nw1 $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)
qui sum log_don_amt_nw if e(sample)
qui estadd scalar mean=r(mean)

*Column 3
eststo: qui reghdfe log_don_amt_nw educ2_avg hhi $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)
qui sum log_don_amt_nw if e(sample)
qui estadd scalar mean=r(mean)

*Column 4
eststo: qui reghdfe log_don_amt_nw educ2_avg entropy $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)
qui sum log_don_amt_nw if e(sample)
qui estadd scalar mean=r(mean)

*Column 5
eststo: qui reghdfe log_don_amt_nw educ2_avg user_num_total_hundred $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)
qui sum log_don_amt_nw if e(sample)
qui estadd scalar mean=r(mean)

*Column 6
eststo: qui reghdfe log_don_amt_nw educ2_avg share_hy_total_hundred $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)
qui sum log_don_amt_nw if e(sample)
qui estadd scalar mean=r(mean)

*Column 7
eststo: qui reghdfe log_don_amt_nw educ2_avg share_pyq_total_hundred $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)
qui sum log_don_amt_nw if e(sample)
qui estadd scalar mean=r(mean)

*Column 8
eststo: qui reghdfe log_don_amt_nw educ2_avg user_num_total_hundred $shares $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)
qui sum log_don_amt_nw if e(sample)
qui estadd scalar mean=r(mean)

esttab, ///
keep(educ2_avg $measurements user_num_total_hundred $shares) ///
order(educ2_avg $measurements user_num_total_hundred $shares) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))

esttab using "Tables/Tabel4_PanelB.tex", replace ///
keep(educ2_avg $measurements user_num_total_hundred $shares) ///
order(educ2_avg $measurements user_num_total_hundred $shares) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))

restore

*Panel C
preserve 
drop if age_pat<15 | educ2_avg<2
capture est drop *

*Column 1
qui ivreghdfe log_don_amt_nw (educ2_avg=csl_affected) $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first
eststo iv_1
qui estadd scalar first_stage_F=e(rkf)
qui sum log_don_amt_nw if e(sample)
qui estadd scalar mean=r(mean): iv_1

*Column 2
qui ivreghdfe log_don_amt_nw (educ2_avg=csl_affected) user_num_pct_nw1 $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first
eststo iv_2
qui estadd scalar first_stage_F=e(rkf)
qui sum log_don_amt_nw if e(sample)
qui estadd scalar mean=r(mean): iv_2

*Column 3
qui ivreghdfe log_don_amt_nw (educ2_avg=csl_affected) hhi $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first
eststo iv_3
qui estadd scalar first_stage_F=e(rkf)
qui sum log_don_amt_nw if e(sample)
qui estadd scalar mean=r(mean): iv_3

*Column 4
qui ivreghdfe log_don_amt_nw (educ2_avg=csl_affected) entropy $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first
eststo iv_4
qui estadd scalar first_stage_F=e(rkf)
qui sum log_don_amt_nw if e(sample)
qui estadd scalar mean=r(mean): iv_4

*Column 5
qui ivreghdfe log_don_amt_nw (educ2_avg=csl_affected) user_num_total_hundred $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first
eststo iv_5
qui estadd scalar first_stage_F=e(rkf)
qui sum log_don_amt_nw if e(sample)
qui estadd scalar mean=r(mean): iv_5

*Column 6
qui ivreghdfe log_don_amt_nw (educ2_avg=csl_affected) share_hy_total_hundred $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first
eststo iv_6
qui estadd scalar first_stage_F=e(rkf)
qui sum log_don_amt_nw if e(sample)
qui estadd scalar mean=r(mean): iv_6

*Column 7
qui ivreghdfe log_don_amt_nw (educ2_avg=csl_affected) share_pyq_total_hundred $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first
eststo iv_7
qui estadd scalar first_stage_F=e(rkf)
qui sum log_don_amt_nw if e(sample)
qui estadd scalar mean=r(mean): iv_7

*Column 8
qui ivreghdfe log_don_amt_nw (educ2_avg=csl_affected) user_num_total_hundred $shares $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first
eststo iv_8
qui estadd scalar first_stage_F=e(rkf)
qui sum log_don_amt_nw if e(sample)
qui estadd scalar mean=r(mean): iv_8

esttab, ///
keep(educ2_avg $measurements user_num_total_hundred $shares) ///
order(educ2_avg $measurements user_num_total_hundred $shares) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N first_stage_F, fmt(%9.3fc %15.0fc %9.2fc))

esttab using "Tables/Tabel4_PanelC.tex", replace ///
keep(educ2_avg $measurements user_num_total_hundred $shares) ///
order(educ2_avg $measurements user_num_total_hundred $shares) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N first_stage_F, fmt(%9.3fc %15.0fc %9.2fc))

restore
est drop *