/*
********************************************************************************
** This dofile is the code for Table 1 in "Digital Safety Nets: How Social Networks Shape Online Medical Crowdfunding Performance".
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** last update: 2025-7-2
** Created date: 2024-12-6
** Data used: 1. sample_total.dta
********************************************************************************
*/

use "Workdata/sample_total.dta", clear
capture est drop *

*Tabel1: Summary Statistics
estpost tabstat don_amt_total_nw log_don_amt_nw complete_pct ///
user_num_pct_nw1 hhi entropy ///
user_num_total_nw share_hy_total share_pyq_total $controls, ///
stat(count mean median sd min max) columns(statistics)

esttab . using "Tables/Tabel1.tex", ///
cells((count(fmt(%9.0gc)) mean(fmt(%12.3fc)) p50(fmt(%9.0gc)) ///
sd(fmt(%12.3fc)) min(fmt(%9.0gc)) max(fmt(%9.0gc)))) ///
replace