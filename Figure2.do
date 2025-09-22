/*
********************************************************************************
** This dofile is the code for Figure 2 in "Digital Safety Nets: How Social Networks Shape Online Medical Crowdfunding Performance".
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** last update: 2025-7-2
** Created date: 2024-12-6
** Data used: 1. sample_total.dta
********************************************************************************
*/

use "Workdata/sample_total.dta", clear
capture graph drop *

*Figure2: Depth distributions of campaigns with different fundraising outcomes
keep case_id user_num_pct_nw* high_don_amt_nw
save "Tempdata/Figure2.dta", replace

use "Tempdata/Figure2.dta", clear
reshape long user_num_pct_nw, i(case_id) j(distance)

graph bar (mean) user_num_pct_nw 							///
if high_don_amt_nw==0,										///
ytitle("Proportion of views (%)", size(3) margin(0 5)) 		///
ylabel(0(5)35, labsize(3))				 					///
over(distance, gap(20) label(labsize(3)))			 		///
text(-2.55 50 "Depth", size(3))								///
saving("Figures/Figure2_1",replace)	
graph export "Figures/Figure2_1.png", width(3600) height(4800) replace

graph bar (mean) user_num_pct_nw 							///
if high_don_amt_nw==1,										///
ytitle("Proportion of views (%)", size(3) margin(0 5)) 		///
ylabel(0(5)35, labsize(3))				 					///
over(distance, gap(20) label(labsize(3)))			 		///
text(-2.55 50 "Depth", size(3))								///
saving("Figures/Figure2_2",replace)	
graph export "Figures/Figure2_2.png", width(3600) height(4800) replace

clear
erase "Tempdata/Figure2.dta"