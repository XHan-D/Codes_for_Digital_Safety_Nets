/*
********************************************************************************
** This dofile is the main code for "Digital Safety Nets: How Social Networks Shape Online Medical Crowdfunding Performance".
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** Last update: 2025-7-2
** Create date: 2024-12-6
** Data used: 1. data_20231120_1124.dta
              2. citycode_pat.dta
			  3. census2015.dta
			  4. citycode_user.dta
			  5. citycode_econ.dta
** Dofiles used: 1. processing.do
			     2. measurements.do
				 3. suggestive_evidence.do
				 4. edu_example_processing.do
				 5. robustness.do
********************************************************************************
*/

clear all
cap log close
set more off
global root = "E:\研究与助研\Network_Structure_and_Medical_Crowdfunding\Codes_and_Results"
cd $root

global controls "age_pat target_amt picture_num content_num title_num female_pat cancer_dummy is_commercial_insurance is_medical_insurance"
global controls2 "user_num_total_hundred share_hy_total_hundred share_pyq_total_hundred $controls"

global controls_iv "target_amt picture_num content_num title_num female_pat cancer_dummy is_commercial_insurance is_medical_insurance"

global shares "share_hy_total_hundred share_pyq_total_hundred"
global measurements "user_num_pct_nw1 hhi entropy"

*===============================================================================
*					           Data Processing
*===============================================================================

use "Rawdata/data_20231120_1124.dta", clear
drop channel his_pv verify_cnt wx_sex wx_city property_num property_total_value is_living_security is_gov_relief home_income is_poverty

do "Codes/processing.do"

*===============================================================================
*				  Measurements of Sharing Network Structure
*===============================================================================

do "Codes/measurements.do"

*===============================================================================
*				            Section III Data
*===============================================================================
use "Workdata/sample_total.dta", clear

*Tabel1: Summary Statistics
estpost tabstat don_amt_total_nw log_don_amt_nw complete_pct user_num_pct_nw1 ///
hhi entropy user_num_total_nw share_hy_total share_pyq_total $controls, stat(count mean median sd min max) columns(statistics)
esttab . using "Tables/Tabel1.tex", cells((count(fmt(%9.0gc)) mean(fmt(%12.3fc)) p50(fmt(%9.0gc)) sd(fmt(%12.3fc)) min(fmt(%9.0gc)) max(fmt(%9.0gc)))) replace


*Figure1: Histogram of total donation amounts
hist don_amt_total_nw,										///
xtitle("Total donation amount (Yuan)") 						///
width(5000)													///
addlabels addlabopts(mlabformat(%9.0gc))					///
frequency													///
xlabel(,format(%9.0gc) nogrid)								///
ylabel(,format(%9.0gc))										///
saving("Figures/Figure1",replace)
graph export "Figures/Figure1.png", replace


*Figure2: Comparison of depth distributions between campaigns with donation amounts below and above median
keep case_id user_num_pct_nw* high_don_amt_nw
save "Tempdata/Figure2.dta", replace
use "Tempdata/Figure2.dta", clear
reshape long user_num_pct_nw, i(case_id) j(distance)

graph bar (mean) user_num_pct_nw 							///
if high_don_amt_nw==0,										///
ytitle("Proportion of views (%)", size(3) margin(0 5)) 		///
ylabel(0(5)35, labsize(3))				 					///
over(distance, gap(20) label(labsize(3)))			 		///
text(-2.55 50 "Depth", size(3))								///
saving("Figures/Figure2_1",replace)	
graph export "Figures/Figure2_1.png", width(3600) height(4800) replace

graph bar (mean) user_num_pct_nw 							///
if high_don_amt_nw==1,										///
ytitle("Proportion of views (%)", size(3) margin(0 5)) 		///
ylabel(0(5)35, labsize(3))				 					///
over(distance, gap(20) label(labsize(3)))			 		///
text(-2.55 50 "Depth", size(3))								///
saving("Figures/Figure2_2",replace)	
graph export "Figures/Figure2_2.png", width(3600) height(4800) replace

/*
graph bar (mean) user_num_pct_nw, 							///
ytitle("Proportion of views (%)", margin(0 -3)) 			///
ylabel(0(10)30)				 								///
by(high_don_amt_nw,note("")) 								///
over(distance, gap(20))			 							///
subtitle("")			 									///
text(-2.55 50 "Depth")										///
saving("Figures/Figure2",replace)	
graph export "Figures/Figure2.png", replace
*/

clear
erase "Tempdata/Figure2.dta"


*Figure4: Histograms of P1, HHI, and Entropy
use "Workdata/sample_total.dta", clear
capture graph drop *
*4.1 P1 histogram
hist user_num_pct_nw1,										///
frac														///
xtitle("Proportion of views from depth 1 (%)", size(5)) 	///
ytitle(,size(5))											///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
name(f2_1)													///
saving("Figures/Figure4_1",replace)
graph export "Figures/Figure4_1.png", replace

*4.2 HHI histogram
hist hhi,													///
frac														///
xtitle("HHI", size(5)) 										///
ytitle(,size(5))											///
xlabel(,nogrid labsize(5))									///
ylabel(0(0.02)0.12,labsize(5))								///
name(f2_2)													///
saving("Figures/Figure4_2",replace)
graph export "Figures/Figure4_2.png", replace

*4.3 Entropy histogram
hist entropy,												///
frac														///
xtitle("Entropy", size(5)) 									///
ytitle(,size(5))											///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
name(f2_3)													///
saving("Figures/Figure4_3",replace)
graph export "Figures/Figure4_3.png", replace

graph combine f2_1 f2_2 f2_3, saving("Figures/Figure4",replace)
graph export "Figures/Figure4.png", replace

*Appendix Table 1 Correlation
pwcorr user_num_pct_nw1 hhi entropy user_num_total_nw share_hy_total share_pyq_total, sig

*===============================================================================
*			Section IV Network structure and crowdfunding outcomes
*===============================================================================

*Figure5: Correlations between medical crowdfunding performance and measurements of sharing network structure (binscatter plots)
use "Workdata/sample_total.dta", clear

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
*Combination
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


*Table2 Relationships between medical crowdfunding performance and measurements of sharing network structure
capture est drop *
*Column 1
eststo: qui reg log_don_amt_nw user_num_pct_nw1, cluster(citycode_pat)

*Column 2
eststo: qui reghdfe log_don_amt_nw user_num_pct_nw1 $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 3
eststo: qui reghdfe log_don_amt_nw user_num_pct_nw1 $controls2, absorb(citycode_pat) cluster(citycode_pat)

*Column 4
eststo: qui reg log_don_amt_nw hhi, cluster(citycode_pat)

*Column 5
eststo: qui reghdfe log_don_amt_nw hhi $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 6
eststo: qui reghdfe log_don_amt_nw hhi $controls2, absorb(citycode_pat) cluster(citycode_pat)

*Column 7
eststo: qui reg log_don_amt_nw entropy, cluster(citycode_pat)

*Column 8
eststo: qui reghdfe log_don_amt_nw entropy $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 9
eststo: qui reghdfe log_don_amt_nw entropy $controls2, absorb(citycode_pat) cluster(citycode_pat)

esttab, ///
keep($measurements user_num_total_hundred $shares) ///
order($measurements user_num_total_hundred $shares) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))

esttab using "Tables/Tabel2.tex", replace ///
keep($measurements user_num_total_hundred $shares) ///
order($measurements user_num_total_hundred $shares) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))


*Appendix Table2 Robustness Check
*Panel A
capture est drop *
*Column 1
eststo: qui reg log_user_num_nw user_num_pct_nw1, cluster(citycode_pat)

*Column 2
eststo: qui reghdfe log_user_num_nw user_num_pct_nw1 $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 3
eststo: qui reg log_user_num_nw hhi, cluster(citycode_pat)

*Column 4
eststo: qui reghdfe log_user_num_nw hhi $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 5
eststo: qui reg log_user_num_nw entropy, cluster(citycode_pat)

*Column 6
eststo: qui reghdfe log_user_num_nw entropy $controls, absorb(citycode_pat) cluster(citycode_pat)

sum log_user_num_nw if e(sample)

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelA.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))


*Panel B
capture est drop *
*Column 1
eststo: qui reg complete_pct user_num_pct_nw1, cluster(citycode_pat)

*Column 2
eststo: qui reghdfe complete_pct user_num_pct_nw1 $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 3
eststo: qui reg complete_pct hhi, cluster(citycode_pat)

*Column 4
eststo: qui reghdfe complete_pct hhi $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 5
eststo: qui reg complete_pct entropy, cluster(citycode_pat)

*Column 6
eststo: qui reghdfe complete_pct entropy $controls, absorb(citycode_pat) cluster(citycode_pat)

sum complete_pct if e(sample)

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelB.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))


*Panel C
capture est drop *
*Column 1
eststo: qui reg log_don_amt_nw don_amt_pct_nw1, cluster(citycode_pat)

*Column 2
eststo: qui reghdfe log_don_amt_nw don_amt_pct_nw1 $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 3
eststo: qui reg log_don_amt_nw hhi_don, cluster(citycode_pat)

*Column 4
eststo: qui reghdfe log_don_amt_nw hhi_don $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 5
eststo: qui reg log_don_amt_nw entropy_don, cluster(citycode_pat)

*Column 6
eststo: qui reghdfe log_don_amt_nw entropy_don $controls, absorb(citycode_pat) cluster(citycode_pat)

esttab, ///
keep(don_amt_pct_nw1 hhi_don entropy_don) ///
order(don_amt_pct_nw1 hhi_don entropy_don) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelC.tex", replace ///
keep(don_amt_pct_nw1 hhi_don entropy_don) ///
order(don_amt_pct_nw1 hhi_don entropy_don) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))


*Panel D
preserve
winsor2 don_amt_total_nw, trim cuts(5 95) replace
drop if don_amt_total_nw>=.
sum don_amt_total_nw, detail

foreach var of varlist $controls citycode_pat{
	drop if `var'>=.
}
bys citycode_pat: drop if _N==1
sort case_id

capture est drop *
*Column 1
eststo: qui reg log_don_amt_nw user_num_pct_nw1, cluster(citycode_pat)

*Column 2
eststo: qui reghdfe log_don_amt_nw user_num_pct_nw1 $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 3
eststo: qui reg log_don_amt_nw hhi, cluster(citycode_pat)

*Column 4
eststo: qui reghdfe log_don_amt_nw hhi $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 5
eststo: qui reg log_don_amt_nw entropy, cluster(citycode_pat)

*Column 6
eststo: qui reghdfe log_don_amt_nw entropy $controls, absorb(citycode_pat) cluster(citycode_pat)

sum log_don_amt_nw if e(sample)

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelD.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))
restore


*Panel E
capture est drop *

foreach nv in user_num_pct_nw1 hhi entropy{
	preserve
	winsor2 `nv', trim cuts(5 95) replace
	drop if `nv'>=.
	sum `nv', detail
	foreach var of varlist $controls citycode_pat{
		drop if `var'>=.
	}
	bys citycode_pat: drop if _N==1
	sort case_id
	
	eststo: qui reg log_don_amt_nw `nv', cluster(citycode_pat)

	eststo: qui reghdfe log_don_amt_nw `nv' $controls, absorb(citycode_pat) cluster(citycode_pat)

	sum log_don_amt_nw if e(sample)
	
	restore
}

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelE.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))


*Panel F
preserve
drop if age_pat<18 | age_pat>70
sum age_pat, detail

foreach var of varlist $controls citycode_pat{
	drop if `var'>=.
}
bys citycode_pat: drop if _N==1
sort case_id

capture est drop *
*Column 1
eststo: qui reg log_don_amt_nw user_num_pct_nw1, cluster(citycode_pat)

*Column 2
eststo: qui reghdfe log_don_amt_nw user_num_pct_nw1 $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 3
eststo: qui reg log_don_amt_nw hhi, cluster(citycode_pat)

*Column 4
eststo: qui reghdfe log_don_amt_nw hhi $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 5
eststo: qui reg log_don_amt_nw entropy, cluster(citycode_pat)

*Column 6
eststo: qui reghdfe log_don_amt_nw entropy $controls, absorb(citycode_pat) cluster(citycode_pat)

sum log_don_amt_nw if e(sample)

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelF.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))
restore


*Panel G
preserve
drop if inlist(citycode_pat, ///
1200, /// 天津
1302, /// 唐山
1303, /// 秦皇岛
1309, /// 沧州
2102, /// 大连
2106, /// 丹东
2107, /// 锦州
2108, /// 营口
2111, /// 盘锦
2114, /// 葫芦岛
3100, /// 上海
3206, /// 南通
3207, /// 连云港
3209, /// 盐城
3302, /// 宁波
3303, /// 温州
3304, /// 嘉兴
3309, /// 舟山
3310, /// 台州
3501, /// 福州
3502, /// 厦门
3503, /// 莆田
3505, /// 泉州
3506, /// 漳州
3509, /// 宁德
3702, /// 青岛
3705, /// 东营
3706, /// 烟台
3707, /// 潍坊
3710, /// 威海
3711, /// 日照
3716, /// 滨州
4401, /// 广州
4403, /// 深圳
4404, /// 珠海
4405, /// 汕头
4407, /// 江门
4408, /// 湛江
4409, /// 茂名
4413, /// 惠州
4415, /// 汕尾
4417, /// 阳江
4419, /// 东莞
4420, /// 中山
4451, /// 潮州
4452, /// 揭阳
4505, /// 北海
4506, /// 防城港
4507, /// 钦州
4601, /// 海口
4602, /// 三亚
4603, /// 三沙
4604, /// 儋州
4690 /// 海南省直辖县
)

foreach var of varlist $controls citycode_pat{
	drop if `var'>=.
}
bys citycode_pat: drop if _N==1
sort case_id

capture est drop *
*Column 1
eststo: qui reg log_don_amt_nw user_num_pct_nw1, cluster(citycode_pat)

*Column 2
eststo: qui reghdfe log_don_amt_nw user_num_pct_nw1 $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 3
eststo: qui reg log_don_amt_nw hhi, cluster(citycode_pat)

*Column 4
eststo: qui reghdfe log_don_amt_nw hhi $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 5
eststo: qui reg log_don_amt_nw entropy, cluster(citycode_pat)

*Column 6
eststo: qui reghdfe log_don_amt_nw entropy $controls, absorb(citycode_pat) cluster(citycode_pat)

sum log_don_amt_nw if e(sample)

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelG.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))
restore


*Panel H
preserve
drop if citycode_pat-prov_pat*100==0 | citycode_pat-prov_pat*100==1
tab citycode_pat

foreach var of varlist $controls citycode_pat{
	drop if `var'>=.
}
bys citycode_pat: drop if _N==1
sort case_id

capture est drop *
*Column 1
eststo: qui reg log_don_amt_nw user_num_pct_nw1, cluster(citycode_pat)

*Column 2
eststo: qui reghdfe log_don_amt_nw user_num_pct_nw1 $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 3
eststo: qui reg log_don_amt_nw hhi, cluster(citycode_pat)

*Column 4
eststo: qui reghdfe log_don_amt_nw hhi $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 5
eststo: qui reg log_don_amt_nw entropy, cluster(citycode_pat)

*Column 6
eststo: qui reghdfe log_don_amt_nw entropy $controls, absorb(citycode_pat) cluster(citycode_pat)

sum log_don_amt_nw if e(sample)

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelH.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))
restore


*Panel I
preserve
drop if is_commercial_insurance==1

foreach var of varlist $controls citycode_pat{
	drop if `var'>=.
}
bys citycode_pat: drop if _N==1
sort case_id

capture est drop *
*Column 1
eststo: qui reg log_don_amt_nw user_num_pct_nw1, cluster(citycode_pat)

*Column 2
eststo: qui reghdfe log_don_amt_nw user_num_pct_nw1 $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 3
eststo: qui reg log_don_amt_nw hhi, cluster(citycode_pat)

*Column 4
eststo: qui reghdfe log_don_amt_nw hhi $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 5
eststo: qui reg log_don_amt_nw entropy, cluster(citycode_pat)

*Column 6
eststo: qui reghdfe log_don_amt_nw entropy $controls, absorb(citycode_pat) cluster(citycode_pat)

sum log_don_amt_nw if e(sample)

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelI.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))
restore


*Panel J
preserve
sum target_amt, detail
drop if target_amt<=20000

foreach var of varlist $controls citycode_pat{
	drop if `var'>=.
}
bys citycode_pat: drop if _N==1
sort case_id

capture est drop *
*Column 1
eststo: qui reg log_don_amt_nw user_num_pct_nw1, cluster(citycode_pat)

*Column 2
eststo: qui reghdfe log_don_amt_nw user_num_pct_nw1 $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 3
eststo: qui reg log_don_amt_nw hhi, cluster(citycode_pat)

*Column 4
eststo: qui reghdfe log_don_amt_nw hhi $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 5
eststo: qui reg log_don_amt_nw entropy, cluster(citycode_pat)

*Column 6
eststo: qui reghdfe log_don_amt_nw entropy $controls, absorb(citycode_pat) cluster(citycode_pat)

sum log_don_amt_nw if e(sample)

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelJ.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))
restore

*Panel K

capture est drop *
*Column 1
eststo: qui reg log_don_amt_nw user_num_pct_nw1 if user_num_pct_nw1<100, cluster(citycode_pat)

*Column 2
eststo: qui reghdfe log_don_amt_nw user_num_pct_nw1 $controls if user_num_pct_nw1<100, absorb(citycode_pat) cluster(citycode_pat)

*Column 3
eststo: qui reg log_don_amt_nw hhi if user_num_pct_nw1<100, cluster(citycode_pat)

*Column 4
eststo: qui reghdfe log_don_amt_nw hhi $controls if user_num_pct_nw1<100, absorb(citycode_pat) cluster(citycode_pat)

*Column 5
eststo: qui reg log_don_amt_nw entropy if user_num_pct_nw1<100, cluster(citycode_pat)

*Column 6
eststo: qui reghdfe log_don_amt_nw entropy $controls if user_num_pct_nw1<100, absorb(citycode_pat) cluster(citycode_pat)

sum log_don_amt_nw if e(sample)

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelK.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))

*===============================================================================
*			                 Section V Mechanism
*===============================================================================
*Figure6: Viewers characteristics at different depths
clear
do "Codes/suggestive_evidence.do"
clear

*===============================================================================
*			               Section VI An Application
*===============================================================================
*Table 4: Associations between education, network structure, and medical crowdfunding performance
do "Codes/edu_example_processing.do"
use "Workdata/example_total.dta", clear

*Constructing cohorts
*bys age_pat: sum csl_affected
gen cohort=.
gen city_cohort=.
local lb=40
local ub=48
replace cohort=`lb' if age_pat<=`lb' //Age groups with minimum CSL greater than 0.5
replace cohort=`ub' if age_pat>=`ub' //Age groups with maximum CSL less than 0.5 
forvalues i=`=`lb'+1' / `=`ub'-1'{
	replace cohort=`i' if age_pat==`i'
}
ereplace city_cohort=group(citycode_pat cohort)

/* Other possible specifications
replace cohort = 1 if age_pat<18 				//Before college
replace cohort = 2 if age_pat>=18 & age_pat<23 	//College student
replace cohort = 3 if age_pat>=23 & age_pat<42
//Some individuals with full CSL (CSL==1 only if age_pat<42)
replace cohort = 5 if age_pat>=43 & age_pat<46	
//All individuals >0%, no individual=100%
replace cohort = 6 if age_pat>=46
//Some individuals without CSL (CSL==0 only if age_pat>=46)

ereplace city_cohort=group(citycode_pat cohort)
*/

gen cohort2=.
gen city_cohort2=.
replace cohort2 = 0 if age_pat<=23 				//Born after 2000
replace cohort2 = 1 if age_pat>23 & age_pat<=33 //Born between 1990-2000
replace cohort2 = 2 if age_pat>33 & age_pat<=43 //Born between 1980-1990
replace cohort2 = 3 if age_pat>43 & age_pat<=53 //Born between 1970-1980
replace cohort2 = 4 if age_pat>53 & age_pat<=63 //Born between 1960-1970
replace cohort2 = 5 if age_pat>63 				//Born before 1960
ereplace city_cohort2=group(citycode_pat cohort2)

preserve 
drop if age_pat<15 | educ2_avg<2

*Panel A
capture est drop *

*Column 1
eststo: qui reghdfe user_num_pct_nw1 educ2_avg $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)
sum user_num_pct_nw1 if e(sample)

*Column 2
eststo: ivreghdfe user_num_pct_nw1 (educ2_avg=csl_affected) $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first
sum user_num_pct_nw1 if e(sample)

*Column 3
eststo: qui reghdfe hhi educ2_avg $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)
sum hhi if e(sample)

*Column 4
eststo: ivreghdfe hhi (educ2_avg=csl_affected) $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first
sum hhi if e(sample)

*Column 5
eststo: qui reghdfe entropy educ2_avg $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)
sum entropy if e(sample)

*Column 6
eststo: ivreghdfe entropy (educ2_avg=csl_affected) $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first
sum entropy if e(sample)

esttab, ///
keep(educ2_avg) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))

esttab using "Tables/Tabel4_PanelA.tex", replace ///
keep(educ2_avg) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))
est drop *

*Panel B
capture est drop *

*Column 1
eststo: qui reghdfe log_don_amt_nw educ2_avg $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)
sum log_don_amt_nw if e(sample)

*Column 2
eststo: qui reghdfe log_don_amt_nw educ2_avg user_num_pct_nw1 $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)

*Column 3
eststo: qui reghdfe log_don_amt_nw educ2_avg hhi $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)

*Column 4
eststo: qui reghdfe log_don_amt_nw educ2_avg entropy $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)

*Column 5
eststo: qui reghdfe log_don_amt_nw educ2_avg user_num_total_hundred $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)

*Column 6
eststo: qui reghdfe log_don_amt_nw educ2_avg share_hy_total_hundred $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)

*Column 7
eststo: qui reghdfe log_don_amt_nw educ2_avg share_pyq_total_hundred $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)

*Column 8
eststo: qui reghdfe log_don_amt_nw educ2_avg user_num_total_hundred $shares $controls_iv, absorb(citycode_pat cohort2) cluster(city_cohort2)

esttab, ///
keep(educ2_avg $measurements user_num_total_hundred $shares) ///
order(educ2_avg $measurements user_num_total_hundred $shares) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))

esttab using "Tables/Tabel4_PanelB.tex", replace ///
keep(educ2_avg $measurements user_num_total_hundred $shares) ///
order(educ2_avg $measurements user_num_total_hundred $shares) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))
est drop *


*Panel C
capture est drop *

*Column 1
eststo: ivreghdfe log_don_amt_nw (educ2_avg=csl_affected) $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first
sum log_don_amt_nw if e(sample)

*Column 2
eststo: ivreghdfe log_don_amt_nw (educ2_avg=csl_affected) user_num_pct_nw1 $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first

*Column 3
eststo: ivreghdfe log_don_amt_nw (educ2_avg=csl_affected) hhi $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first

*Column 4
eststo: ivreghdfe log_don_amt_nw (educ2_avg=csl_affected) entropy $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first

*Column 5
eststo: ivreghdfe log_don_amt_nw (educ2_avg=csl_affected) user_num_total_hundred $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first

*Column 6
eststo: ivreghdfe log_don_amt_nw (educ2_avg=csl_affected) share_hy_total_hundred $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first

*Column 7
eststo: ivreghdfe log_don_amt_nw (educ2_avg=csl_affected) share_pyq_total_hundred $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first

*Column 8
eststo: ivreghdfe log_don_amt_nw (educ2_avg=csl_affected) user_num_total_hundred $shares $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first

esttab, ///
keep(educ2_avg $measurements user_num_total_hundred $shares) ///
order(educ2_avg $measurements user_num_total_hundred $shares) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N, fmt(%15.0fc))

esttab using "Tables/Tabel4_PanelC.tex", replace ///
keep(educ2_avg $measurements user_num_total_hundred $shares) ///
order(educ2_avg $measurements user_num_total_hundred $shares) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N, fmt(%15.0fc))
est drop *

restore

preserve 
drop if age_pat<15 | educ2_avg<2
*Figure 6: Correlations between schooling years and medical crowdfunding performance
binscatter log_don_amt_nw educ2_avg,						///
absorb(citycode_pat) 										///
xtitle("Schooling years", size(5))							///
ytitle("Log donation amount", size(5)) 						///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
saving("Figures/Figure6_1",replace)
graph export "Figures/Figure6_1.png", replace

binscatter log_don_amt_nw educ2_avg,						///
control(user_num_pct_nw1)									///
absorb(citycode_pat) 										///
xtitle("Schooling years", size(5))							///
ytitle("Log donation amount", size(5)) 						///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
saving("Figures/Figure6_2",replace)
graph export "Figures/Figure6_2.png", replace

binscatter log_don_amt_nw educ2_avg,						///
control(hhi)												///
absorb(citycode_pat) 										///
xtitle("Schooling years", size(5))							///
ytitle("Log donation amount", size(5)) 						///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
saving("Figures/Figure6_3",replace)
graph export "Figures/Figure6_3.png", replace

binscatter log_don_amt_nw educ2_avg,						///
control(entropy)											///
absorb(citycode_pat) 										///
xtitle("Schooling years", size(5))							///
ytitle("Log donation amount", size(5)) 						///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
saving("Figures/Figure6_4",replace)
graph export "Figures/Figure6_4.png", replace


*Figure 7: Correlations between schooling years and measurements of sharing network structure
binscatter user_num_pct_nw1 educ2_avg,						///
absorb(citycode_pat) 										///
xtitle("Schooling years", size(5))							///
ytitle("Proportion of views from depth 1", size(5)) 		///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
saving("Figures/FigureA3_1",replace)
graph export "Figures/FigureA3_1.png", replace

binscatter hhi educ2_avg,									///
absorb(citycode_pat) 										///
xtitle("Schooling years", size(5))							///
ytitle("HHI", size(5)) 										///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
saving("Figures/FigureA3_2",replace)
graph export "Figures/FigureA3_2.png", replace

binscatter entropy educ2_avg,								///
absorb(citycode_pat) 										///
xtitle("Schooling years", size(5))							///
ytitle("Entropy", size(5)) 									///
xlabel(,nogrid labsize(5))									///
ylabel(,labsize(5))											///
saving("Figures/FigureA3_3",replace)
graph export "Figures/FigureA3_3.png", replace

restore

/*
*Alternative specification
preserve
drop if age_pat<15

*Panel A
capture est drop *

*Column 1
eststo: qui reghdfe user_num_pct_nw1 educ2_avg $controls, absorb(citycode_pat) cluster(citycode_pat)
sum user_num_pct_nw1 if e(sample)

*Column 2
eststo: ivreghdfe user_num_pct_nw1 (educ2_avg=csl_affected) $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first
sum user_num_pct_nw1 if e(sample)

*Column 3
eststo: qui reghdfe hhi educ2_avg $controls, absorb(citycode_pat) cluster(citycode_pat)
sum hhi if e(sample)

*Column 4
eststo: ivreghdfe hhi (educ2_avg=csl_affected) $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first
sum hhi if e(sample)

*Column 5
eststo: qui reghdfe entropy educ2_avg $controls, absorb(citycode_pat) cluster(citycode_pat)
sum entropy if e(sample)

*Column 6
eststo: ivreghdfe entropy (educ2_avg=csl_affected) $controls_iv, absorb(citycode_pat cohort) cluster(city_cohort) first
sum entropy if e(sample)

esttab, ///
keep(educ2_avg) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))

*Panel B
capture est drop *

*Column 1
eststo: qui reghdfe log_don_amt_nw educ2_avg $controls, absorb(citycode_pat) cluster(citycode_pat)
sum log_don_amt_nw if e(sample)

*Column 2
eststo: qui reghdfe log_don_amt_nw educ2_avg user_num_pct_nw1 $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 3
eststo: qui reghdfe log_don_amt_nw educ2_avg hhi $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 4
eststo: qui reghdfe log_don_amt_nw educ2_avg entropy $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 5
eststo: qui reghdfe log_don_amt_nw educ2_avg user_num_total_hundred $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 6
eststo: qui reghdfe log_don_amt_nw educ2_avg share_hy_total_hundred $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 7
eststo: qui reghdfe log_don_amt_nw educ2_avg share_pyq_total_hundred $controls, absorb(citycode_pat) cluster(citycode_pat)

*Column 8
eststo: qui reghdfe log_don_amt_nw educ2_avg user_num_total_hundred $shares $controls, absorb(citycode_pat) cluster(citycode_pat)

esttab, ///
keep(educ2_avg $measurements user_num_total_hundred $shares) ///
order(educ2_avg $measurements user_num_total_hundred $shares) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) stats(N r2, fmt(%15.0fc %9.3fc))
*/