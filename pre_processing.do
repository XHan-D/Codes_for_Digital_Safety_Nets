/*
********************************************************************************
** This dofile is the code for data pre-processing for Network Structure and Medical Crowdfunding.
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** last update: 2025-6-23
** Created date: 2024-12-6
** Data used: 1. data_20231120_1124.dta
			  2. citycode_pat.dta
********************************************************************************
*/

*****************************Simplifying the ids********************************
*tab share_dv
drop if share_dv=="NaN" | share_dv=="]" 
destring share_dv, replace
drop if share_dv>=1000 //We only concern those visits within the sharing network

egen case_id_s=group(case_id)
egen user_tag_s=group(user_tag)
sort case_id_s user_tag_s

egen double uid_s=group(case_id user_tag)
order case_id_s user_tag_s uid_s
drop case_id info_id user_tag

**********************************Citycode*************************************
*Patients' city information
merge m:1 patient_city using "Rawdata/citycode_pat.dta"
drop if _merge==2
drop _merge

nmissing citycode_pat

gen prov_pat=int(citycode_pat/100) //Province code

******************Total donation amount and total views************************
*Total donation amount from sharing network
sum donate_amt, detail
list share_dv donate_amt if donate_amt>2000
//To check extremely high single donation is not correlated with sharing distance.
drop if donate_amt>2000

gen don_amt_tmp=donate_amt
replace don_amt_tmp=0 if share_dv==-1 //We only count donation from dis>=0 (depth>=1)
bys case_id_s: egen don_amt_total_nw=total(don_amt_tmp)
drop don_amt_tmp
gen log_don_amt_nw=log(don_amt_total_nw)

*Total visits from sharing network
gen user_tmp=(share_dv>-1) //We only count views from dis>=0 (depth>=1)
bys case_id_s: egen user_num_total_nw=total(user_tmp)
drop user_tmp
gen log_user_num_nw=log(user_num_total_nw)

********************************Progress Bar************************************
gen complete_pct=don_amt_total_nw*100/target_amt
replace complete_pct = 100 if complete_pct>100

****************Variables about sharing network structure***********************
bys case_id_s share_dv: gen share_dv_num = _N

foreach var of varlist share_to* {
	replace `var'=0 if `var'==.
}
by case_id_s: egen share_hy_total=total(share_to_hy_cnt)
by case_id_s: egen share_pyq_total=total(share_to_pyq_cnt)
//When counting sharing amounts, we need to take dep==0 into consideration

replace share_dv=share_dv+1 //To keep direct friends at depth 1

forvalues i=1/10{
	by case_id_s: gen user_num`i'= share_dv_num if share_dv==`i'
	by case_id_s: ereplace user_num`i' = min(user_num`i')
	replace user_num`i'= 0 if user_num`i'==.
} //Number of views from each depths (only consider distances no more than 10)

forvalues i=1/10{
	by case_id_s: egen don_amt`i'=total( donate_amt ) if share_dv==`i'
	by case_id_s: ereplace don_amt`i' = min(don_amt`i')
	replace don_amt`i'= 0 if don_amt`i'==.
} //Donation amount from each depths

forvalues i=0/10{
	by case_id_s: egen share_hy`i'=total( share_to_hy_cnt ) if share_dv==`i'
	by case_id_s: ereplace share_hy`i' = min(share_hy`i')
	replace share_hy`i'= 0 if share_hy`i'==.
} //Sharing-to-hy amount from each depths

forvalues i=0/10{
	by case_id_s: egen share_pyq`i'=total( share_to_pyq_cnt ) if share_dv==`i'
	by case_id_s: ereplace share_pyq`i' = min(share_pyq`i')
	replace share_pyq`i'= 0 if share_pyq`i'==.
} //Sharing-to-pyq amount from each depths

save "Tempdata/view_total.dta", replace

**********************Keep case-level variables only****************************
duplicates drop case_id_s, force
sort case_id_s
drop uid_s user_tag_s city time share_dv donate_amt share_to_hy_cnt ///
share_to_pyq_cnt share_dv_num