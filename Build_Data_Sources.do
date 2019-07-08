* --------------------------------------------------------------------------------------------------
* Build_Data_Sources
*
* This master file runs all jobs in the build other than those that are executed in Python. This file
* is called directly by Master_Build.sh, and sets the appropriate Stata environment for the project,
* before launching the individual jobs. . Each of the steps of the build are outlined below, with short
* descriptions of their functions.
*
* Notes:
*	- Please replace the following with the appropriate variables/paths for your system:
*		<CODE_PATH>: Path to the project code on the host system
*		<DATA_PATH>: Path to the root folder containing the data
* --------------------------------------------------------------------------------------------------
clear
version 14
set more off
set excelxlsxlargefile on

* Install extra packages
cap ssc install egenmore
cap ssc install mmerge
cap ssc install jarowinkler
cap ssc install moremata
cap ssc install ftools
cap net install gtools, from(`github'/mcaceresb/stata-gtools/master/build/)

* Directory structure
global data_path "<DATA_PATH>"
global code_path "<CODE_PATH>"
global output "$data_path/output"
global aggregation_sources "$data_path/aggregation_sources"
global raw "$data_path/raw"
global temp "$data_path/temp"
global tempcgs "$temp/cgs"
global logs "$data_path/logs"
global orbis "$raw/orbi"
global orbis_ownership "$raw/orbis/ownership_data"
global sdc_bonds "$data_path/raw/SDC/bonds"
global sdc_equities "$data_path/raw/SDC/equities"
global sdc_loans "$data_path/raw/SDC/loans"
global sdc_temp "$data_path/temp/SDC"
global sdc_additional "$sdc_temp/additional"
global sdc_dta "$sdc_temp/dta"
global sdc_datasets "$sdc_temp/datasets"
global sdc_eqdta "$sdc_temp/eqdta"
global sdc_loandta "$sdc_temp/loandta"

* List of tax haven countries
global tax_haven1 	`""BRN","COK","CPV","CUW","CYM","DMA","GGY","GIB","GRD" "'
global tax_haven2 	`""HKG","IMN","JEY","KNA","LIE","MAC","MCO","MHL","MSR" "'
global tax_haven3 	`""NIU","NRU","PAN","PLW","SHN","SMR","SYC","TCA","TUV" "'
global tax_haven4 	`""VCT","VGB","VIR","VUT","WLF","WSM","FRO","FJI","GRL" "'
global tax_haven5 	`""GUM","MDV","MNE","NCL","WSM","LCA","LUX","MLT","ASC" "'
global tax_haven6 	`""CCK","DJI","FLK","PYF","GIB","GUY","KIR","CXR","NFK" "'
global tax_haven7	`""MNP","PCN","SPM","SLB","TKL","TON","BMU" "'

* List of EMU member countries
global  eu1  `""LUX","IRL","ITA","DEU","FRA","ESP","GRC","NLD","AUT" "'
global  eu2  `""BEL","FIN","PRT","CYP","EST","LAT","LTU","SVK","SVN" "'
global  eu3  `""MLT","EMU","LVA" "'

* Create necessary folders
cap mkdir $output
cap mkdir $aggregation_sources
cap mkdir $temp
cap mkdir $tempcgs
cap mkdir $logs
cap mkdir $orbis
cap mkdir $orbis_ownership
cap mkdir $sdc_temp
cap mkdir $sdc_additional
cap mkdir $sdc_dta
cap mkdir $sdc_datasets
cap mkdir $sdc_eqdta
cap mkdir $sdc_loandta

* Run CGS data import
do "$code_path/data_sources_build/cgs.do"

* Run Dealogic data import
do "$code_path/data_sources_build/dealogic.do"

* Run Factset data import
do "$code_path/data_sources_build/factset.do"

* Run SDC data import
do "$code_path/data_sources_build/sdc.do"

* Run Capital IQ data import
do "$code_path/data_sources_build/capital_iq.do"

* Run Morningstar data import
do "$code_path/data_sources_build/morningstar.do"

* Run Orbis data import
do "$code_path/data_sources_build/orbis.do"
