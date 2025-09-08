/*
********************************************************************************
** This dofile is the main code for Network Structure and Medical Crowdfunding.
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** Last update: 2025-9-6
** Create date: 2025-6-21
** Data used: 1. sample_total.dta
********************************************************************************
*/

use "Workdata/sample_total.dta", clear

*********************************Table A3: CEM**********************************
local cem_var "age_pat target_amt picture_num female_pat (#2) cancer_dummy (#2)"
capture est drop *

foreach indep in $measurements{
	qui sum `indep', detail
	scalar median_`indep'=r(p50)
	gen high_`indep'=(`indep'>=median_`indep')
	
	**Baseline result
	cem `cem_var', treatment(high_`indep') show
	
	qui reghdfe log_don_amt_nw high_`indep' $controls, absorb(citycode_pat) cluster(citycode_pat)
	eststo `indep'_1
	qui sum log_don_amt_nw if e(sample)
	estadd scalar mean=r(mean): `indep'_1
	
	qui reghdfe log_don_amt_nw high_`indep' $controls [aw=cem_weights], absorb(citycode_pat) cluster(citycode_pat)
	eststo `indep'_2
	qui sum log_don_amt_nw if e(sample)
	estadd scalar mean=r(mean): `indep'_2
	
	qui reghdfe log_don_amt_nw `indep' $controls [aw=cem_weights], absorb(citycode_pat) cluster(citycode_pat)
	eststo `indep'_3
	qui sum log_don_amt_nw if e(sample)
	estadd scalar mean=r(mean): `indep'_3
	
	**Network controls
	cem `cem_var' user_num_total_hundred, treatment(high_`indep') show
	
	qui reghdfe log_don_amt_nw high_`indep' $controls2, absorb(citycode_pat) cluster(citycode_pat)
	eststo `indep'_1_nw
	qui sum log_don_amt_nw if e(sample)
	estadd scalar mean=r(mean): `indep'_1_nw
	
	qui reghdfe log_don_amt_nw high_`indep' $controls2 [aw=cem_weights], absorb(citycode_pat) cluster(citycode_pat)
	eststo `indep'_2_nw
	qui sum log_don_amt_nw if e(sample)
	estadd scalar mean=r(mean): `indep'_2_nw
	
	qui reghdfe log_don_amt_nw `indep' $controls2 [aw=cem_weights], absorb(citycode_pat) cluster(citycode_pat)
	eststo `indep'_3_nw
	qui sum log_don_amt_nw if e(sample)
	estadd scalar mean=r(mean): `indep'_3_nw
	
	esttab `indep'*, keep(high_`indep' `indep') ///
	b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))
	
	esttab `indep'* using Tables/TableA3_`indep'.tex, replace ///
	keep(high_`indep' `indep') ///
	b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))
	
	drop high_*
}

est drop *

********************************Table A4: IV************************************
**Sharing efficiency
gen share_eff0=user_num1/(share_hy0 + share_pyq0)
replace share_eff0=0 if share_eff0==.

forvalues i=1/9{
	local j=`i'+1
	gen share_eff`i'=user_num`j'/(share_hy`i' + share_pyq`i')
	replace share_eff`i'=0 if share_eff`i'==.
}

**Sharing probability
forvalues i=1/9{
	gen share_prob`i'=(share_hy`i' + share_pyq`i')/user_num`i'
	replace share_prob`i'=0 if share_prob`i'==.
}

**Cohort
gen cohort=0
replace cohort = 0 if age_pat<=23
replace cohort = 1 if age_pat>23 & age_pat<=43
replace cohort = 2 if age_pat>43 & age_pat<=63
replace cohort = 3 if age_pat>63

**Average share_prob and share_eff
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

**Imputed sharing network
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

capture est drop *

**IV regressions
qui ivreghdfe log_don_amt_nw (hhi=hhi_iv), cluster(citycode_pat)
eststo hhi_1
estadd scalar first_stage_F=e(rkf): hhi_1
qui sum log_don_amt_nw if e(sample)
estadd scalar mean=r(mean): hhi_1

qui ivreghdfe log_don_amt_nw (hhi=hhi_iv) $controls, absorb(citycode_pat) cluster(citycode_pat)
eststo hhi_2
estadd scalar first_stage_F=e(rkf): hhi_2
qui sum log_don_amt_nw if e(sample)
estadd scalar mean=r(mean): hhi_2

qui ivreghdfe log_don_amt_nw (entropy=entropy_iv) if hhi_iv<., cluster(citycode_pat)
eststo entropy_1
estadd scalar first_stage_F=e(rkf): entropy_1
qui sum log_don_amt_nw if e(sample)
estadd scalar mean=r(mean): entropy_1

qui ivreghdfe log_don_amt_nw (entropy=entropy_iv) $controls if hhi_iv<., absorb(citycode_pat) cluster(citycode_pat)
eststo entropy_2
estadd scalar first_stage_F=e(rkf): entropy_2
qui sum log_don_amt_nw if e(sample)
estadd scalar mean=r(mean): entropy_2

*drop share_eff_avg* share_prob_avg* user_iv* user_pct_iv* user_total_iv hhi_iv entropy_iv

esttab hhi* entropy*, ///
	keep(hhi entropy) ///
	b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(mean N first_stage_F, fmt(%9.3fc %15.0fc %9.2fc))

esttab hhi* entropy* using "Tables/TableA4.tex" , replace ///
	keep(hhi entropy) ///
	b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(mean N first_stage_F, fmt(%9.3fc %15.0fc %9.2fc))

	
**********Table A5: Network structure and average donation per viewer***********
gen log_don_avg=log(don_amt_total_nw/user_num_total_nw)
gen only_direct=(hhi==1)
capture est drop *
foreach indep in $measurements{
	qui reghdfe log_don_avg `indep' only_direct, absorb(citycode_pat) cluster(citycode_pat)
	eststo `indep'_1
	qui sum log_don_avg if e(sample)
	estadd scalar mean=r(mean): `indep'_1

	qui reghdfe log_don_avg `indep' $controls $shares only_direct, absorb(citycode_pat) cluster(citycode_pat)
	eststo `indep'_2
	qui sum log_don_avg if e(sample)
	estadd scalar mean=r(mean): `indep'_2
	
	*reghdfe log_don_avg user_num_pct_nw1 $controls only_direct, a(citycode_pat) cluster(citycode_pat)
}

esttab user_num_pct_nw* hhi* entropy*, ///
	keep($measurements $shares) order($measurements $shares) ///
	b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))
	
esttab user_num_pct_nw* hhi* entropy* using "Tables/TableA5.tex", replace ///
	keep($measurements $shares) order($measurements $shares) ///
	b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))

est drop *
	
********************************************************************************
save "Workdata/robustness.dta", replace