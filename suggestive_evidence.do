/*
********************************************************************************
** This dofile is the code for for Network Structure and Medical Crowdfunding.
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** last update: 2025-6-23
** Create date: 2025-6-6
** Data used: 1. data_20231120_1124.dta
              2. citycode_pat.dta
			  3. citycode_user.dta
			  4. citycode_econ.dta
********************************************************************************
*/

use "Tempdata/view_total.dta", clear

********************************Pre-processing**********************************
drop if don_amt_total_nw<=0
drop if don_amt_total_nw>81562 //99% in campaign-level dataset

*Patient Gender (with missing data)
rename patient_gender patient_gender_str
gen female_pat=1 if patient_gender_str=="女"
replace female_pat=0 if patient_gender_str=="男"
drop patient_gender_str

*Patient Age
rename luanch_patient_age age_pat

*Insurance (without missing data)
tab is_commercial_insurance
tab is_medical_insurance
gen commercial_insurance=(is_commercial_insurance=="有")
gen medical_insurance=(is_medical_insurance=="有")
drop is_commercial_insurance is_medical_insurance
rename commercial_insurance is_commercial_insurance
rename medical_insurance is_medical_insurance

*Cancer Dummy
gen cancer_dummy =(strpos(normalized_disease, "癌") > 0) | (strpos(normalized_disease, "瘤") > 0) | (strpos(normalized_disease, "白血病") > 0)

*Drop campaigns with missing information on beneficiaries' baseline characteristics
foreach var of varlist $controls citycode_pat{
	drop if `var'>=.
}

*Drop campaigns with singleton citycode_pat
sort citycode_pat case_id_s
egen tmp=tag(citycode_pat case_id_s)
by citycode_pat: egen tmp2=total(tmp)
by citycode_pat: drop if tmp2<=1
drop tmp tmp2

unique case_id_s //aligned with 4,569 campaigns in our main dataset

sort case_id_s time
bys case_id_s: gen order_view = _n
bys case_id_s: gen donate_accum = sum(donate_amt)

gen donate_accum_sh = donate_accum / target_amt
replace donate_accum_sh = 1 if donate_accum_sh>1

save "Workdata/suggestive_evidence.dta", replace

************************Depths and Viewer Characteristics***********************
*Figure A2: Viewer charateristics across different depths
use "Workdata/suggestive_evidence.dta",clear

sort case_id_s share_dv time

foreach var of varlist his_* {
	replace `var'=0 if `var'==.
}
rename his_doante_cnt his_donate_cnt

*reghdfe his_donate_cnt share_dv if share_dv>=1 & share_dv<=10, absorb(case_id_s)
*reghdfe his_pay_amount share_dv if share_dv>=1 & share_dv<=10, absorb(case_id_s)

forvalues i=1/10{
	gen dv_`i'=(share_dv==`i')
}

*Panel A: Historical donation amount
qui reghdfe his_pay_amount o.dv_1 dv_2 dv_3 dv_4 dv_5 dv_6 dv_7 dv_8 ///
dv_9 dv_10 if share_dv>=1 & share_dv<=10, absorb(case_id_s) cluster(case_id_s)

coefplot, keep(dv_*) 									///
omitted baselevel vertical nooffsets 					///
xtitle("Depth", size(5)) 								///
ytitle("Coefficient", size(5)) 							///
xlabel(,labsize(5)) ylabel(,labsize(5))					///
yline(0, lc(gs8) lp(dash))								///
rename( 												///
	dv_1="1" dv_2="2" dv_3="3" dv_4="4" dv_5="5" 		///
	dv_6="6" dv_7="7" dv_8="8" dv_9="9" dv_10="10" 		///
)														///
saving("Figures/Figure6_1",replace)
graph export "Figures/Figure6_1.png", replace

*Panel B: Historical donation count
qui reghdfe his_donate_cnt o.dv_1 dv_2 dv_3 dv_4 dv_5 dv_6 dv_7 dv_8 ///
dv_9 dv_10 if share_dv>=1 & share_dv<=10, absorb(case_id_s) cluster(case_id_s)

coefplot, keep(dv_*) 									///
omitted baselevel vertical nooffsets 					///
xtitle("Depth", size(5)) 								///
ytitle("Coefficient", size(5)) 							///
xlabel(,labsize(5)) ylabel(,labsize(5))					///
yline(0, lc(gs8) lp(dash))								///
rename( 												///
	dv_1="1" dv_2="2" dv_3="3" dv_4="4" dv_5="5" 		///
	dv_6="6" dv_7="7" dv_8="8" dv_9="9" dv_10="10" 		///
)														///
saving("Figures/Figure6_2",replace)
graph export "Figures/Figure6_2.png", replace

/*
reghdfe donate_amt o.dv_1 dv_2 dv_3 dv_4 dv_5 dv_6 dv_7 dv_8 ///
dv_9 dv_10 if share_dv>=1 & share_dv<=10, absorb(case_id_s user_tag_s) cluster(case_id_s)

coefplot, keep(dv_*) 									///
omitted baselevel vertical nooffsets 					///
xtitle("Depth", size(5)) 								///
ytitle("Coefficient", size(5)) 							///
xlabel(,labsize(5)) ylabel(,labsize(5))					///
yline(0, lc(gs8) lp(dash))								///
rename( 												///
	dv_1="1" dv_2="2" dv_3="3" dv_4="4" dv_5="5" 		///
	dv_6="6" dv_7="7" dv_8="8" dv_9="9" dv_10="10" 		///
)														///
saving("Figures/Figure6_3",replace)
graph export "Figures/Figure6_3.png", replace

reghdfe donate_amt o.dv_1 dv_2 dv_3 dv_4 dv_5 dv_6 dv_7 dv_8 ///
dv_9 dv_10 if share_dv>=1 & share_dv<=10 & donate_amt<100 & donate_accum_sh>=0.03, absorb(case_id_s) cluster(case_id_s)
*/

reghdfe donate_amt o.dv_1 dv_2 dv_3 dv_4 dv_5 dv_6 dv_7 dv_8 ///
dv_9 dv_10 if share_dv>=1 & share_dv<=10 & donate_amt<100 & donate_accum_sh>=0.03, absorb(case_id_s) cluster(case_id_s)

*****************************Geographical patterns******************************
merge m:1 city using "Rawdata/citycode_user.dta"
drop if _merge==2
drop _merge

gen prov_user=int(citycode_user/100) //Province code

foreach var in capital* diff*{
	capture drop `var'
}

gen capital_pat=(citycode_pat-prov_pat*100==0 | citycode_pat-prov_pat*100==1)

gen capital=(citycode_user-prov_user*100==0 | citycode_user-prov_user*100==1) ///
if !missing(citycode_user)

gen capital2=(citycode_user-prov_user*100==0 | citycode_user-prov_user*100==1) & (prov_pat==prov_user) ///
if !missing(citycode_user)

gen diff=(prov_pat!=prov_user) ///
if !missing(prov_user)

gen diff2=(citycode_pat!=citycode_user) ///
if !missing(citycode_user)

*reghdfe capital o.dv_1 dv_2 dv_3 dv_4 dv_5 dv_6 dv_7 dv_8 ///
dv_9 dv_10 if share_dv>=1 & share_dv<=10 & capital_pat==0, absorb(case_id_s) cluster(case_id_s)

*reghdfe capital2 o.dv_1 dv_2 dv_3 dv_4 dv_5 dv_6 dv_7 dv_8 ///
dv_9 dv_10 if share_dv>=1 & share_dv<=10 & capital_pat==0, absorb(case_id_s) cluster(case_id_s)

*Panel C: Proportion of viewers from provinces different from the beneficiary's
reghdfe diff if share_dv>=1 & share_dv<=10, absorb(citycode_user) res
predict diff_res, res
reghdfe diff_res o.dv_1 dv_2 dv_3 dv_4 dv_5 dv_6 dv_7 dv_8 ///
dv_9 dv_10 if share_dv>=1 & share_dv<=10, absorb(case_id_s) cluster(case_id_s)

coefplot, keep(dv_*) 									///
omitted baselevel vertical nooffsets 					///
xtitle("Depth", size(5)) 								///
ytitle("Coefficient", size(5)) 							///
xlabel(,labsize(5)) ylabel(,labsize(5))					///
yline(0, lc(gs8) lp(dash))								///
rename( 												///
	dv_1="1" dv_2="2" dv_3="3" dv_4="4" dv_5="5" 		///
	dv_6="6" dv_7="7" dv_8="8" dv_9="9" dv_10="10" 		///
)														///
saving("Figures/FigureA4_3",replace)
graph export "Figures/FigureA4_3.png", replace

*Panel D:Proportion of viewers from prefectures different from the beneficiary's
reghdfe diff2 if share_dv>=1 & share_dv<=10, absorb(citycode_user) res
predict diff2_res, res
reghdfe diff2_res o.dv_1 dv_2 dv_3 dv_4 dv_5 dv_6 dv_7 dv_8 ///
dv_9 dv_10 if share_dv>=1 & share_dv<=10, absorb(case_id_s) cluster(case_id_s)

coefplot, keep(dv_*) 									///
omitted baselevel vertical nooffsets 					///
xtitle("Depth", size(5)) 								///
ytitle("Coefficient", size(5)) 							///
xlabel(,labsize(5)) ylabel(,labsize(5)) 				///
yline(0, lc(gs8) lp(dash))								///
rename( 												///
	dv_1="1" dv_2="2" dv_3="3" dv_4="4" dv_5="5" 		///
	dv_6="6" dv_7="7" dv_8="8" dv_9="9" dv_10="10" 		///
)														///
saving("Figures/Figure4_4",replace)
graph export "Figures/FigureA4_4.png", replace

/*
gen east_user=inlist(prov_user, 11, 12, 31, 32, 33, 35, 44) if !missing(prov_user)
gen east_city_user=inlist(citycode_user, 1100, 3100, 4401, 4403) if !missing(citycode_user)
gen east_pat=inlist(prov_pat, 11, 12, 31, 32, 33, 35, 44)
gen west_pat=inlist(prov_pat, 52, 53, 54, 62, 63, 64, 65)

*reghdfe east_user o.dv_1 dv_2 dv_3 dv_4 dv_5 dv_6 dv_7 dv_8 ///
dv_9 dv_10 if share_dv>=1 & share_dv<=10, absorb(case_id_s) cluster(case_id_s)

*reghdfe east_city_user o.dv_1 dv_2 dv_3 dv_4 dv_5 dv_6 dv_7 dv_8 ///
dv_9 dv_10 if share_dv>=1 & share_dv<=10, absorb(case_id_s) cluster(case_id_s)


gen high_prov=inlist(prov_user, 11, 12, 13, 15, 31, 35, 42, 44, 54, 63, 64, 65) ///
if !missing(prov_user) //high historical amount (avg>=15, 15 is the full sample mean)

gen high_prov_pat=inlist(prov_pat, 11, 12, 13, 15, 31, 35, 42, 44, 54, 63, 64, 65) 

reghdfe high_prov o.dv_1 dv_2 dv_3 dv_4 dv_5 dv_6 dv_7 dv_8 ///
dv_9 dv_10 if share_dv>=1 & share_dv<=10 & high_prov_pat==0, absorb(case_id_s) cluster(case_id_s)

coefplot, keep(dv_*) 									///
omitted baselevel vertical nooffsets 					///
xtitle("Depth", size(5)) 								///
ytitle("Coefficient", size(5)) 							///
xlabel(,labsize(5)) ylabel(,labsize(5)) 				///
yline(0, lc(gs8) lp(dash))								///
rename( 												///
	dv_1="1" dv_2="2" dv_3="3" dv_4="4" dv_5="5" 		///
	dv_6="6" dv_7="7" dv_8="8" dv_9="9" dv_10="10" 		///
)														///
saving("Figures/FigureA2_3",replace)
graph export "Figures/FigureA2_3.png", replace
*/
save, replace

*******************************Decaying Altruism********************************
*Figure A3: Altruism decay across depths
preserve
sort user_tag_s case_id_s
by user_tag_s: egen max_case=max(case_id_s)
by user_tag_s: egen min_case=min(case_id_s)
by user_tag_s: gen tmp=max_case-min_case
drop if tmp==0

ereplace double uid_s=group(case_id_s user_tag_s)

reghdfe donate_amt o.dv_1 dv_2 dv_3 dv_4 dv_5 dv_6 dv_7 dv_8 ///
dv_9 dv_10 if share_dv>=1 & share_dv<=10, absorb(case_id_s user_tag_s) cluster(uid_s)

coefplot, keep(dv_*) 									///
omitted baselevel vertical nooffsets 					///
xtitle("Depth", size(4)) 								///
ytitle("Coefficient", size(4)) 							///
xlabel(,labsize(4)) ylabel(,labsize(4))					///
yline(0, lc(gs8) lp(dash))								///
rename( 												///
	dv_1="1" dv_2="2" dv_3="3" dv_4="4" dv_5="5" 		///
	dv_6="6" dv_7="7" dv_8="8" dv_9="9" dv_10="10" 		///
)														///
saving("Figures/FigureA2",replace)
graph export "Figures/FigureA2.png", replace

restore

*********************Geographical patterns of the fundraiser*********************
*Figure A1: The distribution of GDP per capita in beneficiaries' cities of residence
*Census population in each city
use "Rawdata/census2015.dta",clear
drop if M38=="3"
gen citycode_str=substr(M2,1,4) if M38=="1"
replace citycode_str=substr(M39,1,4) if M38=="2"
destring(citycode_str), gen(citycode_pat)
replace citycode_pat=1100 if int(citycode_pat/100)==11
replace citycode_pat=1200 if int(citycode_pat/100)==12
replace citycode_pat=3100 if int(citycode_pat/100)==31
replace citycode_pat=5000 if int(citycode_pat/100)==50
replace citycode_pat=6321 if citycode_pat==6302 //海东地区
replace citycode_pat=5423 if citycode_pat==5402 //日喀则市
replace citycode_pat=5222 if citycode_pat==5206 //铜仁市
replace citycode_pat=5224 if citycode_pat==5205 //毕节市

bys citycode_pat: gen pop=_N
duplicates drop citycode_pat pop, force
keep citycode_pat pop
save "Tempdata/census_pop.dta", replace

*Calculate the weighted mean and median of gdppc
use "Rawdata/citycode_econ.dta", clear
merge 1:1 citycode_pat using "Tempdata/census_pop.dta"
drop if _merge!=3
drop _merge
mean gdppc [aw=pop] //64258.96
global gdppc_mean=_b[gdppc]
_pctile gdppc [aw=pop]
return list //50760
global gdppc_med=r(r1)
save "Tempdata/citycode_econ_pop.dta",replace

use "Workdata/sample_total.dta", clear

merge m:1 citycode_pat using "Rawdata/citycode_econ.dta"
drop if _merge==2
drop _merge

hist gdppc,																	///
xtitle("GDP per capita of the beneficiary's city of residence (Yuan)") 		///
width(5000)																	///
frequency																	///
xlabel(,format(%9.0gc) nogrid)												///
ylabel(,format(%9.0gc))														///
xline($gdppc_med, lcolor(red) lpattern(solid) lwidth(medthick))				///
xline($gdppc_mean, lcolor(red) lpattern(dash) lwidth(medthick))				///
text(780 `=$gdppc_med-38000' "National median", color(red) placement(e))	///
text(780 `=$gdppc_mean+40000' "National average", color(red) placement(w))	///
saving("Figures/FigureA1",replace)
graph export "Figures/FigureA1.png", replace

clear all