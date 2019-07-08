* --------------------------------------------------------------------------------------------------
* Factset_Build: This file build the ultimate-parent aggregation data from Factset, which is
* used as input in the CMNS aggregation procedure.
* --------------------------------------------------------------------------------------------------
cap log close
log using "$logs/${whoami}_Factset_Build", replace

* Unique CUSIP9 with ISIN in CGS
use issuer_num issue_num issue_check isin currency_code using "$tempcgs/ALLMASTER_ISIN.dta", clear
gen cusip = issuer_num + issue_num + issue_check
rename currency_code iso_currency
append using "$tempcgs/incmstr.dta"
gen cusip6 = substr(cusip, 1, 6)
keep cusip cusip6 iso_currency isin
bysort isin: keep if _n == _N
bysort cusip: keep if _n == _N
save "$temp/factset/cgs_master_isin_appended", replace

* Read in Factset ultimate-parent mapping data
import excel using "$raw/factset/factset_ultimate_parents.xlsx", clear firstrow sheet("Sheet1")
rename UPCUSIPCOUNTRY UPCOUNTRY
keep CUSIP UPCUSIP UPISIN UPCOUNTRY
rename (CUSIP UPCUSIP UPISIN UPCOUNTRY) (cusip6 cusip6_bg isin_bg country_bg)
replace country_bg = "" if country_bg == "#N/A"
replace cusip6 = substr(cusip6, 1, 6)
replace cusip6_bg = substr(cusip6_bg, 1, 6)
drop if missing(cusip6_bg) & missing(isin_bg)

* Consolidate and save
duplicates drop cusip6 isin, force
duplicates drop cusip6, force
mmerge isin_bg using "$temp/factset/cgs_master_isin_appended", umatch(isin) unmatched(m)
gen cusip6_cgs = substr(cusip, 1, 6)
replace cusip6_bg = cusip6_cgs if missing(cusip6_bg)
keep cusip6 cusip6_bg country_bg
drop if missing(cusip6_bg)
rename cusip6_bg up_cusip6
rename country_bg country_fds
save "$aggregation_sources/factset_aggregation", replace

* --------------------------------------------------------------------------------------------------
* Prepare the Factset screen of Hong Kong and Luxembourg companies for aggregation
* --------------------------------------------------------------------------------------------------

* List of largest Hong Kong domiciled companies from Factset's company screen utility
import excel using "$raw/factset/HKG_Companies.xlsx", clear cellrange(A5) firstrow
drop if missing(CUSIP)
keep if EntityCountryHQ == "Hong Kong"
keep if EntityCountryRisk == "Hong Kong"
gsort - MktVal
keep if inlist(EntityCountryParentHQ, "Hong Kong", "@NA")
keep if _n <= 50
gen cusip6 = substr(CUSIP, 1, 6)
save "$aggregation_sources/factset_hkg_companies", replace

* List of largest Luxembourg domiciled companies from Factset's company screen utility
import excel using "$raw/factset/LUX_Companies.xlsx", clear cellrange(A5) firstrow
drop if missing(CUSIP)
keep if EntityCountryHQ == "Luxembourg"
keep if EntityCountryRisk == "Luxembourg"
gsort - MktVal
keep if inlist(EntityCountryParentHQ, "Luxembourg", "@NA")
keep if _n <= 50
gen cusip6 = substr(CUSIP, 1, 6)
save "$aggregation_sources/factset_lux_companies", replace

log close
