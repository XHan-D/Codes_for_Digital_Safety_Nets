/*
********************************************************************************
** This dofile is the main code for "Digital Safety Nets: How Social Networks Shape Online Medical Crowdfunding Performance".
** Author: Xu Han, Yiqing Xing, Junjian Yi, Haochen Zhang
** Code author: Xu Han
** Last update: 2025-9-22
** Create date: 2024-12-6
** Data used: 1. data_20231120_1124.dta
              2. citycode_pat.dta
			  3. census2015.dta
			  4. citycode_user.dta
			  5. citycode_econ.dta
** Dofiles used: 1. processing.do
			     2. measurements.do
				 3. edu_example_processing.do
				 4-10. Figure1-2, 4-8.do
				 11-13. Table1,2,4.do
				 14-15. Appendix_table1,2.do
				 16. suggestive_evidence.do (Appendix_figure1-3)
				 17. robustness.do (Appendix table 3-5)
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

do "Codes/processing.do"

*===============================================================================
*				  Measurements of Sharing Network Structure
*===============================================================================

do "Codes/measurements.do"

*===============================================================================
*				            Section III Data
*===============================================================================

do "Codes/Table1.do"
do "Codes/Figure1.do"
do "Codes/Figure2.do"
do "Codes/Figure4.do"
do "Codes/Appendix_table1.do"

*===============================================================================
*			Section IV Network structure and crowdfunding outcomes
*===============================================================================

do "Codes/Figure5.do"
do "Codes/Table2.do"
do "Codes/Appendix_table2.do"
do "Codes/robustness.do" //Appendix table 3-5

*===============================================================================
*			                 Section V Mechanism
*===============================================================================

do "Codes/suggestive_evidence.do" //Appendix figure 1-3

*===============================================================================
*			               Section VI An Application
*===============================================================================

do "Codes/edu_example_processing.do"
do "Codes/Figure8.do"
do "Codes/Table4.do"
do "Codes/Figure6.do"
do "Codes/Figure7.do"
