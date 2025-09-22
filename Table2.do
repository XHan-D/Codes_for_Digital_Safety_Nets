/*
********************************************************************************
** This dofile is the code for Table 2 in "Digital Safety Nets: How Social Networks Shape Online Medical Crowdfunding Performance".
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** last update: 2025-7-2
** Created date: 2024-12-6
** Data used: 1. sample_total.dta
********************************************************************************
*/

use "Workdata/sample_total.dta", clear
capture est drop *

*Table2 Relationships between medical crowdfunding performance and measurements of sharing network structure

foreach measure in $measurements{
	eststo: qui reg log_don_amt_nw `measure', cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
	
	eststo: qui reghdfe log_don_amt_nw `measure' $controls, absorb(citycode_pat) cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)

	eststo: qui reghdfe log_don_amt_nw `measure' $controls2, absorb(citycode_pat) cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
}

esttab, ///
keep($measurements user_num_total_hundred $shares) ///
order($measurements user_num_total_hundred $shares) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))

esttab using "Tables/Tabel2.tex", replace ///
keep($measurements user_num_total_hundred $shares) ///
order($measurements user_num_total_hundred $shares) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))
