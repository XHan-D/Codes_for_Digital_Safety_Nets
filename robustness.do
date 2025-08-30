/*
********************************************************************************
** This dofile is the main code for Network Structure and Medical Crowdfunding.
** Author: Xu Han, Shen Peng, Yiqing Xing, Junjian Yi, Haochen Zhang, Xueyong Zhang
** Code author: Xu Han
** Last update: 2025-7-3
** Create date: 2025-6-21
** Data used: 1. sample_total.dta
********************************************************************************
*/

use "Workdata/sample_total.dta", clear
*use "Workdata/robustness.dta", clear
******************************Sharing Efficiency********************************

gen share_eff0=user_num1/(share_hy0 + share_pyq0)
replace share_eff0=0 if share_eff0==.

forvalues i=1/9{
	local j=`i'+1
	gen share_eff`i'=user_num`j'/(share_hy`i' + share_pyq`i')
	replace share_eff`i'=0 if share_eff`i'==.
}

forvalues i=1/9{
	gen share_prob`i'=(share_hy`i' + share_pyq`i')/user_num`i'
	replace share_prob`i'=0 if share_prob`i'==.
}

gen cohort=0
replace cohort = 0 if age_pat<=23
replace cohort = 1 if age_pat>23 & age_pat<=43
replace cohort = 2 if age_pat>43 & age_pat<=63
replace cohort = 3 if age_pat>63


forvalues i=1/9{
	egen total_tmp=total(share_prob`i')
	gen count_tmp=_N
	gen share_prob_avg`i'=(total_tmp-share_prob`i')/(count_tmp-1)
	drop total_tmp count_tmp
}
/*
forvalues i=1/9{
	bys prov_pat cohort: egen total_tmp=total(share_prob`i')
	bys prov_pat cohort: gen count_tmp=_N
	bys prov_pat cohort: gen share_prob_avg`i'=(total_tmp-share_prob`i')/(count_tmp-1)
	drop total_tmp count_tmp
}
*/

forvalues i=1/9{
	bys prov_pat cohort: egen total_tmp=total(share_eff`i')
	bys prov_pat cohort: gen count_tmp=_N
	bys prov_pat cohort: gen share_eff_avg`i'=(total_tmp-share_eff`i')/(count_tmp-1)
	drop total_tmp count_tmp
}

/*
forvalues i=1/9{
	egen total_tmp=total(share_eff`i')
	gen count_tmp=_N
	gen share_eff_avg`i'=(total_tmp-share_eff`i')/(count_tmp-1)
	drop total_tmp count_tmp
}
*/

gen user_iv1=user_num1

forvalues i=2/10{
	local j=`i'-1
	gen user_iv`i'=user_iv`j'*share_prob_avg`j'*share_eff_avg`j'
}

gen user_total_iv=user_iv1+user_iv2+user_iv3+user_iv4+user_iv5+user_iv6+user_iv7+user_iv8+user_iv9+user_iv10

gen hhi_iv=0
forvalues i=1/10{
	gen user_pct_iv`i'=user_iv`i'*100/user_total_iv
	replace hhi_iv=hhi_iv+(user_pct_iv`i')^2
}
replace hhi_iv=hhi_iv/10000

gen entropy_iv=0
forvalues i=1/10{
	gen temp=-(user_pct_iv`i'/100)*(log(user_pct_iv`i'/100)/log(2))
	replace temp=0 if temp==.
	replace entropy_iv=entropy_iv+temp
	drop temp
}

*ivreghdfe log_don_amt_nw (user_num_pct_nw1=user_pct_iv1) $controls, absorb(citycode_pat) cluster(citycode_pat) first

ivreghdfe log_don_amt_nw (hhi=hhi_iv) $controls, absorb(citycode_pat) cluster(citycode_pat) first

ivreghdfe log_don_amt_nw (entropy=entropy_iv) $controls, absorb(citycode_pat) cluster(citycode_pat) first

*drop share_eff_avg* share_prob_avg* user_iv* user_pct_iv* user_total_iv hhi_iv entropy_iv

save "Workdata/robustness.dta", replace