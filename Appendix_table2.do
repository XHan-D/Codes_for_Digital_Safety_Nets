/*
********************************************************************************
** This dofile is the code for Appendix table 2 in "Digital Safety Nets: How Social Networks Shape Online Medical Crowdfunding Performance".
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** last update: 2025-7-29
** Created date: 2024-12-6
** Data used: 1. sample_total.dta
********************************************************************************
*/

use "Workdata/sample_total.dta", clear
capture est drop *

*Appendix Table2 Robustness Check
*Panel A
foreach measure in $measurements{
	eststo: qui reg log_user_num_nw `measure', cluster(citycode_pat)
	qui sum log_user_num_nw if e(sample)
	qui estadd scalar mean=r(mean)
	
	eststo: qui reghdfe log_user_num_nw `measure' $controls, absorb(citycode_pat) cluster(citycode_pat)
	qui sum log_user_num_nw if e(sample)
	qui estadd scalar mean=r(mean)
}

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelA.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))


*Panel B
capture est drop *

foreach measure in $measurements{
	eststo: qui reg complete_pct `measure', cluster(citycode_pat)
	qui sum complete_pct if e(sample)
	qui estadd scalar mean=r(mean)
	
	eststo: qui reghdfe complete_pct `measure' $controls, absorb(citycode_pat) cluster(citycode_pat)
	qui sum complete_pct if e(sample)
	qui estadd scalar mean=r(mean)
}

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelB.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))


*Panel C
capture est drop *

foreach measure of varlist don_amt_pct_nw1 hhi_don entropy_don{
	eststo: qui reg log_don_amt_nw `measure', cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
	
	eststo: qui reghdfe log_don_amt_nw `measure' $controls, absorb(citycode_pat) cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
}

esttab, ///
keep(don_amt_pct_nw1 hhi_don entropy_don) ///
order(don_amt_pct_nw1 hhi_don entropy_don) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelC.tex", replace ///
keep(don_amt_pct_nw1 hhi_don entropy_don) ///
order(don_amt_pct_nw1 hhi_don entropy_don) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))


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
foreach measure in $measurements{
	eststo: qui reg log_don_amt_nw `measure', cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
	
	eststo: qui reghdfe log_don_amt_nw `measure' $controls, absorb(citycode_pat) cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
}

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelD.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))
restore


*Panel E
capture est drop *

foreach nv of varlist user_num_pct_nw1 hhi entropy{
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
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
	
	eststo: qui reghdfe log_don_amt_nw `nv' $controls, absorb(citycode_pat) cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
	
	restore
}

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelE.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))


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
foreach measure in $measurements{
	eststo: qui reg log_don_amt_nw `measure', cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
	
	eststo: qui reghdfe log_don_amt_nw `measure' $controls, absorb(citycode_pat) cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
}

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelF.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))


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
foreach measure in $measurements{
	eststo: qui reg log_don_amt_nw `measure', cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
	
	eststo: qui reghdfe log_don_amt_nw `measure' $controls, absorb(citycode_pat) cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
}

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelG.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))


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
foreach measure in $measurements{
	eststo: qui reg log_don_amt_nw `measure', cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
	
	eststo: qui reghdfe log_don_amt_nw `measure' $controls, absorb(citycode_pat) cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
}

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelH.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))


*Panel I
preserve
drop if is_commercial_insurance==1

foreach var of varlist $controls citycode_pat{
	drop if `var'>=.
}
bys citycode_pat: drop if _N==1
sort case_id

capture est drop *
foreach measure in $measurements{
	eststo: qui reg log_don_amt_nw `measure', cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
	
	eststo: qui reghdfe log_don_amt_nw `measure' $controls, absorb(citycode_pat) cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
}

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelI.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))


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
foreach measure in $measurements{
	eststo: qui reg log_don_amt_nw `measure', cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
	
	eststo: qui reghdfe log_don_amt_nw `measure' $controls, absorb(citycode_pat) cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
}

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelJ.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))


*Panel K
capture est drop *
foreach measure in $measurements{
	eststo: qui reg log_don_amt_nw `measure' if user_num_pct_nw1<100, cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
	
	eststo: qui reghdfe log_don_amt_nw `measure' $controls if user_num_pct_nw1<100, absorb(citycode_pat) cluster(citycode_pat)
	qui sum log_don_amt_nw if e(sample)
	qui estadd scalar mean=r(mean)
}

esttab, ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))

esttab using "Tables/TabelA2_PanelK.tex", replace ///
keep($measurements) ///
order($measurements) ///
b(%9.3fc) se(%9.3fc) star(* 0.10 ** 0.05 *** 0.01) ///
stats(mean N r2, fmt(%9.3fc %15.0fc %9.3fc))
