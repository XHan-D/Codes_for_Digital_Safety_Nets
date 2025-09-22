/*
********************************************************************************
** This dofile is the code for Figure 5 in "Digital Safety Nets: How Social Networks Shape Online Medical Crowdfunding Performance".
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** last update: 2025-7-2
** Created date: 2024-12-6
** Data used: 1. sample_total.dta
********************************************************************************
*/
use "Workdata/sample_total.dta", clear
capture graph drop *

*Figure5: Correlations between medical crowdfunding performance and measurements of sharing network structure (binscatter plots)

*5.1 P1 binscatter
binscatter log_don_amt_nw user_num_pct_nw1, 				///
xtitle("Proportion of views from depth 1 (%)", size(5))		///
ytitle("Log donation amount", size(5)) 						///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
saving("Figures/Figure5_1",replace)
graph export "Figures/Figure5_1.png", replace

*5.2 HHI binscatter
binscatter log_don_amt_nw hhi, 								///
xtitle("HHI", size(5))										///
ytitle("Log donation amount", size(5)) 						///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
saving("Figures/Figure5_2",replace)
graph export "Figures/Figure5_2.png", replace

*5.3 Entropy binscatter
binscatter log_don_amt_nw entropy, 							///
xtitle("Entropy", size(5))									///
ytitle("Log donation amount", size(5)) 						///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
saving("Figures/Figure5_3",replace)
graph export "Figures/Figure5_3.png", replace

/*
*Combined graph
capture graph drop *

*5.1 P1 binscatter
binscatter log_don_amt_nw user_num_pct_nw1, 				///
xtitle("Proportion of views from depth 1 (%)")				///
ytitle("Log donation amount") 								///
xlabel(,nogrid)												///
name(f5_1)													///
title("Panel A. Proportion of views from depth 1", size(4) position(11) margin(-15 0 2 0))

*5.2 HHI binscatter
binscatter log_don_amt_nw hhi, 								///
xtitle("HHI")												///
ytitle("Log donation amount") 								///
xlabel(,nogrid)												///
name(f5_2)													///
title("Panel B. HHI", size(4) position(11) margin(-15 0 2 0))

*5.3 Entropy binscatter
binscatter log_don_amt_nw entropy, 							///
xtitle("Entropy")											///
ytitle("Log donation amount") 								///
xlabel(,nogrid)												///
name(f5_3)													///
title("Panel C. Entropy", size(4) position(11) margin(-15 0 2 0))

graph combine f5_1 f5_2 f5_3, saving("Figures/Figure5",replace)
graph export "Figures/Figure5.png", replace
*/