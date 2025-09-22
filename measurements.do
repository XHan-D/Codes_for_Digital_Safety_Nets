/*
********************************************************************************
** This dofile is the code to create measurements of sharing network structure
for "Digital Safety Nets: How Social Networks Shape Online Medical Crowdfunding Performance".
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** last update: 2025-7-2
** Created date: 2024-12-6
** Data used: 1. sample_total.dta
********************************************************************************
*/

use "Workdata/sample_total.dta", clear

*Calculate the median of don_amt_total_nw
egen median=median(don_amt_total_nw)
gen high_don_amt_nw=(don_amt_total_nw>=median)
drop median
label define median 1 "Campaigns with Donation Amounts above Median" ///
 0 "Campaigns with Donation Amounts below Median"
label variable high_don_amt_nw "donate amount above median dummy"
label values high_don_amt_nw median

*Percentage of visits from each depths
forvalues i=1/10{
	gen user_num_pct_nw`i'=user_num`i' *100/user_num_total_nw
}

*Percentage of donation amount from each depths
forvalues i=1/10{
	gen don_amt_pct_nw`i'=don_amt`i' *100/don_amt_total_nw
}

*Percentage of share_hy from each depths
forvalues i=0/10{
	gen share_hy_pct`i'=share_hy`i' *100/share_hy_total
}

*Percentage of share_pyq from each depths
forvalues i=0/10{
	gen share_pyq_pct`i'=share_pyq`i' *100/share_pyq_total
}

*HHI
gen hhi=((user_num_pct_nw1)^2 + (user_num_pct_nw2)^2 ///
 + (user_num_pct_nw3)^2 + (user_num_pct_nw4)^2 + (user_num_pct_nw5)^2 ///
 + (user_num_pct_nw6)^2 + (user_num_pct_nw7)^2 + (user_num_pct_nw8)^2 ///
 + (user_num_pct_nw9)^2 + (user_num_pct_nw10)^2)/10000

gen hhi_don=((don_amt_pct_nw1)^2 + (don_amt_pct_nw2)^2 ///
 + (don_amt_pct_nw3)^2 + (don_amt_pct_nw4)^2 + (don_amt_pct_nw5)^2 ///
 + (don_amt_pct_nw6)^2 + (don_amt_pct_nw7)^2 + (don_amt_pct_nw8)^2 ///
 + (don_amt_pct_nw9)^2 + (don_amt_pct_nw10)^2)/10000

*Entropy
gen entropy=0
forvalues i=1/10{
	gen temp=-(user_num_pct_nw`i'/100)*(log(user_num_pct_nw`i'/100)/log(2))
	replace temp=0 if temp==.
	replace entropy=entropy+temp
	drop temp
}
gen entropy_don=0
forvalues i=1/10{
	gen temp=-(don_amt_pct_nw`i'/100)*(log(don_amt_pct_nw`i'/100)/log(2))
	replace temp=0 if temp==.
	replace entropy_don=entropy_don+temp
	drop temp
}

sort case_id
save,replace