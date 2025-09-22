/*
********************************************************************************
** This dofile is the code for Figure 7 in "Digital Safety Nets: How Social Networks Shape Online Medical Crowdfunding Performance".
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** last update: 2025-9-5
** Created date: 2024-12-6
** Data used: 1. example_total.dta
********************************************************************************
*/

use "Workdata/example_total.dta", replace
capture graph drop *

*Figure 7: orrelations between schooling years and measurements of sharing network
*structure (binscatter plots)
preserve 
drop if age_pat<15 | educ2_avg<2

binscatter user_num_pct_nw1 educ2_avg,						///
absorb(citycode_pat) 										///
xtitle("Schooling years", size(5))							///
ytitle("Proportion of views from depth 1 (%)", size(5)) 		///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
saving("Figures/Figure7_1",replace)
graph export "Figures/Figure7_1.png", replace

binscatter hhi educ2_avg,									///
absorb(citycode_pat) 										///
xtitle("Schooling years", size(5))							///
ytitle("HHI", size(5)) 										///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
saving("Figures/Figure7_2",replace)
graph export "Figures/Figure7_2.png", replace

binscatter entropy educ2_avg,								///
absorb(citycode_pat) 										///
xtitle("Schooling years", size(5))							///
ytitle("Entropy", size(5)) 									///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
saving("Figures/Figure7_3",replace)
graph export "Figures/Figure7_3.png", replace

restore