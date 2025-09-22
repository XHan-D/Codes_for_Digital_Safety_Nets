/*
********************************************************************************
** This dofile is the code for Figure 1 in "Digital Safety Nets: How Social Networks Shape Online Medical Crowdfunding Performance".
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** last update: 2025-7-2
** Created date: 2024-12-6
** Data used: 1. sample_total.dta
********************************************************************************
*/

use "Workdata/sample_total.dta", clear
capture graph drop *

*Figure1: The distribution of total donation amounts across campaigns
hist don_amt_total_nw,										///
xtitle("Total donation amount (Yuan)") 						///
width(5000)													///
addlabels addlabopts(mlabformat(%9.0gc))					///
frequency													///
xlabel(,format(%9.0gc) nogrid)								///
ylabel(,format(%9.0gc))										///
saving("Figures/Figure1",replace)
graph export "Figures/Figure1.png", replace