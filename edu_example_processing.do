/*
********************************************************************************
** This dofile is the processing code for Section VI of "Digital Safety Nets: How Social Networks Shape Online Medical Crowdfunding Performance".
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** Last update: 2025-6-21
** Create date: 2024-9-23
** Data used: 1. Workdata/sample_total.dta
			  2. census2015.dta.dta
			  3. csl_data.dta (from Table 9 in Appendix 4 of Du et al. (2021))
********************************************************************************
*/

use "Rawdata/census2015.dta",clear

**************************Processing the census data****************************
**Citycode of hukou registration
*tab M38
*assert M39=="" if M38!="2"
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

**Key variables
rename M34 gender
rename M35 birth_year
rename M51 educ

keep gender birth_year educ citycode_pat

save "Tempdata/census2015_modified.dta",replace

use "Tempdata/census2015_modified.dta", clear
gen female_pat=1 if gender=="2"
replace female_pat=0 if gender=="1"
*assert female_pat<.
drop gender
gen age_pat=2023-birth_year //The cases are all started in November, 2023.
*tab age_pat
drop birth_year
drop if age_pat>=100 //No patient in our cases is more than 100 years old.
destring educ, replace

gen primary=(educ>=2)
gen secondary=(educ>=3)
gen high=(educ>=4) //Including vocational
gen college=(educ>=7)
gen grad=(educ>=8)
recode educ (1=0)(2=6)(3=9)(4=12)(5=12)(6=15)(7=16)(8=22), gen(educ2)
//Schooling years

replace primary=. if educ==.
replace secondary=. if educ==.
replace high=. if educ==.
replace college=. if educ==.
replace grad=. if educ==.

bys citycode_pat age_pat female_pat: egen educ_avg=mean(educ)
by citycode_pat age_pat female_pat: egen educ2_avg=mean(educ2)
by citycode_pat age_pat female_pat: egen primary_avg=mean(primary)
by citycode_pat age_pat female_pat: egen secondary_avg=mean(secondary)
by citycode_pat age_pat female_pat: egen high_avg=mean(high)
by citycode_pat age_pat female_pat: egen college_avg=mean(college)
by citycode_pat age_pat female_pat: egen grad_avg=mean(grad)
label variable educ_avg "1=没上过学 2=小学 3=初中 4=普通高中 5=中职 6=大学专科 7=大学本科 8=研究生"
//Following labels in raw data.

save,replace

**Duplicating
duplicates drop citycode_pat age_pat female_pat, force
drop educ educ2 primary secondary high college grad
save "Tempdata/census2015_merge.dta", replace
clear

************************************Merging*************************************
use "Workdata/sample_total.dta", clear
merge m:1 citycode_pat age_pat female_pat using "Tempdata/census2015_merge.dta"
drop if _merge==2
drop _merge
save "Workdata/example_total.dta", replace
clear

***********************CSL Data (From Du et al. (2021))*************************
input prov_pat csl_affected_year earlier_cohort_proportion
11 1971 0.066
12 1972 0.140
13 1971 0.285
14 1971 0.254
15 1974 0.318
21 1971 0.224
22 1972 0.315
23 1971 0.278
31 1972 0.090
32 1972 0.284
33 1971 0.362
34 1973 0.477
35 1973 0.525
36 1971 0.488
37 1972 0.331
41 1972 0.304
42 1972 0.341
43 1977 0.355
44 1972 0.403
45 1977 0.389
46 1977 .
50 1971 0.412
51 1971 0.412
52 1973 0.563
53 1972 0.614
54 1979 0.905
61 1973 0.328
62 1976 0.500
63 1974 0.491
64 1971 0.412
65 1973 0.354
end

label define province_code 11 "Beijing" 12 "Tianjin" 13 "Hebei" 14 "Shanxi" ///
15 "Inner Mongolia" 21 "Liaoning" 22 "Jilin" 23 "Heilongjiang" 31 "Shanghai" ///
32 "Jiangsu" 33 "Zhejiang" 34 "Anhui" 35 "Fujian" 36 "Jiangxi" 37 "Shandong" ///
41 "Henan" 42 "Hubei" 43 "Hunan" 44 "Guangdong" 45 "Guangxi" 46 "Hainan" ///
50 "Chongqing" 51 "Sichuan" 52 "Guizhou" 53 "Yunnan" 54 "Tibet" ///
61 "Shaanxi" 62 "Gansu" 63 "Qinghai" 64 "Ningxia" 65 "Xinjiang"

label values prov_pat province_code

gen csl_affected_age=2023-csl_affected_year-1
//The campaigns are all started in November, 2023. Since CSL will affect people
//born after September in the affected year, people aged (2023-csl_affected_year)
//are likely not affected.

save "Rawdata/csl_data.dta", replace

************************************Merging*************************************

use "Tempdata/census2015_merge.dta", clear
replace age_pat=age_pat-8
rename educ2_avg educ2_avg2 
save "Tempdata/census2015_merge2.dta", replace

use "Workdata/sample_total.dta", clear
merge m:1 citycode_pat age_pat female_pat using "Tempdata/census2015_merge.dta"
drop if _merge==2
drop _merge
merge m:1 citycode_pat age_pat female_pat using "Tempdata/census2015_merge2.dta"
drop if _merge==2
drop _merge

rename educ2_avg educ2_avg1
gen educ2_avg=.
replace educ2_avg=educ2_avg1 if age_pat>30
replace educ2_avg=educ2_avg2 if age_pat<=30
save "Workdata/example_total.dta", replace
clear

use "Workdata/example_total.dta", replace

merge m:1 prov_pat using "Rawdata/csl_data.dta"
drop if _merge==2
drop _merge
gen csl_affected=1 if age_pat<=(csl_affected_age-9)
replace csl_affected=0 if age_pat>csl_affected_age
replace csl_affected=(csl_affected_age-age_pat+1)/10 ///
if age_pat>csl_affected_age-9 & age_pat<=csl_affected_age

/*
gen csl_affected=1 if age_pat<=(csl_affected_age-8)
replace csl_affected=0 if age_pat>csl_affected_age
replace csl_affected=(csl_affected_age-age_pat+1)/9 ///
if age_pat>csl_affected_age-8 & age_pat<=csl_affected_age
*/

gen csl_interaction=csl_affected*earlier_cohort_proportion

save, replace