/*
********************************************************************************
** This dofile is the code for Appendix Table 1 in "Digital Safety Nets: How Social Networks Shape Online Medical Crowdfunding Performance".
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** last update: 2025-7-2
** Created date: 2024-12-6
** Data used: 1. sample_total.dta
********************************************************************************
*/

use "Workdata/sample_total.dta", clear

*Appendix Table 1 Correlation
estpost correlate $measurements user_num_total_nw share_hy_total share_pyq_total, matrix

esttab . , replace ///
unstack nonumber noobs compress ///
cells("b(fmt(%9.3fc))")

esttab . using "Tables/TableA1.tex", replace ///
unstack nonumber noobs compress ///
cells("b(fmt(%9.3fc))")
