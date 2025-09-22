/*
********************************************************************************
** This dofile is the code for Figure 4 in "Digital Safety Nets: How Social Networks Shape Online Medical Crowdfunding Performance".
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** last update: 2025-7-2
** Created date: 2024-12-6
** Data used: 1. sample_total.dta
********************************************************************************
*/

use "Workdata/sample_total.dta", clear
capture graph drop *

*Figure4: Distributions of measurements of sharing network structure

*4.1 P1 histogram
hist user_num_pct_nw1,										///
frac														///
xtitle("Proportion of views from depth 1 (%)", size(5)) 	///
ytitle(,size(5))											///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
name(f4_1)													///
saving("Figures/Figure4_1",replace)
graph export "Figures/Figure4_1.png", replace

*4.2 HHI histogram
hist hhi,													///
frac														///
xtitle("HHI", size(5)) 										///
ytitle(,size(5))											///
xlabel(,nogrid labsize(5))									///
ylabel(0(0.02)0.12,labsize(5))								///
name(f4_2)													///
saving("Figures/Figure4_2",replace)
graph export "Figures/Figure4_2.png", replace

*4.3 Entropy histogram
hist entropy,												///
frac														///
xtitle("Entropy", size(5)) 									///
ytitle(,size(5))											///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
name(f4_3)													///
saving("Figures/Figure4_3",replace)
graph export "Figures/Figure4_3.png", replace

graph combine f4_1 f4_2 f4_3, saving("Figures/Figure4",replace)
graph export "Figures/Figure4.png", replace