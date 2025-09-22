/*
********************************************************************************
** This dofile is the code for Figure 6 in "Digital Safety Nets: How Social Networks Shape Online Medical Crowdfunding Performance".
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** last update: 2025-9-5
** Created date: 2024-12-6
** Data used: 1. example_total.dta
********************************************************************************
*/

use "Workdata/example_total.dta", replace
capture graph drop *

*Figure 6: Correlation between medical crowdfunding performance and schooling years:
*The role of network structure (binscatter plots)
preserve 
drop if age_pat<15 | educ2_avg<2

binscatter log_don_amt_nw educ2_avg,						///
absorb(citycode_pat) 										///
xtitle("Schooling years", size(5))							///
ytitle("Log donation amount", size(5)) 						///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
saving("Figures/Figure6_1",replace)
graph export "Figures/Figure6_1.png", replace

binscatter log_don_amt_nw educ2_avg,						///
control(user_num_pct_nw1)									///
absorb(citycode_pat) 										///
xtitle("Schooling years", size(5))							///
ytitle("Log donation amount", size(5)) 						///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
saving("Figures/Figure6_2",replace)
graph export "Figures/Figure6_2.png", replace

binscatter log_don_amt_nw educ2_avg,						///
control(hhi)												///
absorb(citycode_pat) 										///
xtitle("Schooling years", size(5))							///
ytitle("Log donation amount", size(5)) 						///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
saving("Figures/Figure6_3",replace)
graph export "Figures/Figure6_3.png", replace

binscatter log_don_amt_nw educ2_avg,						///
control(entropy)											///
absorb(citycode_pat) 										///
xtitle("Schooling years", size(5))							///
ytitle("Log donation amount", size(5)) 						///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
saving("Figures/Figure6_4",replace)
graph export "Figures/Figure6_4.png", replace

restore