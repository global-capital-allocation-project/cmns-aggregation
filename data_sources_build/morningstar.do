* --------------------------------------------------------------------------------------------------
* Morningstar_Country: This job constructs the modal country code assigned to each CUSIP in the 
* Morningstar holdings data, which is used in the CMNS aggregation procedure.
* --------------------------------------------------------------------------------------------------
cap log close
log using "$logs/${whoami}_Morningstar_Country_Build", replace
set seed 1

* Minimum number of reporting funds for us to include CUSIP/country combination in the output: regular
* threshold and special threshold applied for issuers resident in tax havens (according to CGS)
local min_reporting_funds_for_mode = 5
local min_reporting_funds_for_mode_th = 1

* If there are no non-TH codes within the mode, we consider codes reported by at least a certain fraction
* of the funds that report the modal code; we refer to this as submode tolerance. There are two thresholds:
* a regular threshold and special threshold applied for issuers resident in tax havens (according to CGS)
local submode_tolerance = 0.7
local submode_tolerance_th = 0.1

* We discard observations with more than a certain number of country codes in the mode or submode, since
* in these cases there is considerable disagreement among funds. There are two thresholds: a regular threshold 
* and special threshold applied for issuers resident in tax havens (according to CGS)
local max_countries_in_mode_or_sub = 3
local max_countries_in_mode_or_sub_th = 10

* Append monthly Morningstar holdings files and keep only relevant variables.
* See Maggiori, Neiman, and Schreger (JPE 2019) for details on construction of the
* Morningstar holdings sample. The raw files that are necessary for this job are
* referred to as "step3" files in the build code of MNS.
foreach holdingname in "NonUS" "US" { 
	forvalues x=$firstyear/$lastyear {
		display "$raw/morningstar_holdings/`holdingname'_`x'_m_step3.dta"
		append using "$raw/morningstar_holdings/`holdingname'_`x'_m_step3.dta", keep(cusip6 iso_co MasterPo)
	} 
}
save "$temp/morningstar_holdings_appended.dta", replace

* Perform the country assignments
use "$temp/morningstar_holdings_appended.dta", clear
drop if cusip6=="" | iso_co==""
replace iso_co="ANT" if iso_co=="AN"
replace iso_co="SRB" if iso_co=="CS"
replace iso_co="FXX" if iso_co=="FX"
replace iso_co="XSN" if iso_co=="S2"
replace iso_co="XSN" if iso_co=="XS"
replace iso_co="YUG" if iso_co=="YU"
replace iso_co="ZAR" if iso_co=="ZR"

* Collapse to fund-country-CUSIP level
gen counter = 1 if !missing(iso_country_code)
bysort cusip6 iso_co MasterPort: egen country_fund_count = sum(counter)
drop counter
gcollapse (firstnm) country_fund_count, by(cusip6 iso_country_code MasterPortfolioId)
save "$temp/morningstar_holdings_collapsed", replace

* --------------------------------------------------------------------------------------------------
* Within-fund country assignments
* --------------------------------------------------------------------------------------------------

* Link to CGS domicile: TH vs. non-TH
use "$temp/morningstar_holdings_collapsed", clear
drop if cusip == "#N/A N"
mmerge cusip using $temp/cgs/cgs_compact_complete.dta, umatch(issuer_number) ukeep(domicile) unmatched(m) uname(cgs_)
gen th_residency = 0
forvalues j=1(1)10 {
		cap replace th_residency = 1 if (inlist(cgs_domicile,${tax_haven`j'}))
}
cap drop _merge

* For each fund, keep only the modal country assignment for each CUSIP, if this is unique
bysort cusip6 MasterPortfolioId: egen country_fund_count_max = max(country_fund_count)
drop if country_fund_count < `submode_tolerance' * country_fund_count_max & th_residency == 0
drop if country_fund_count < `submode_tolerance_th' * country_fund_count_max & th_residency == 1
by cusip6 MasterPortfolioId: egen n_countries_in_mode_or_submode = nvals(iso_country_code)

* Find out how many countries are in the submode and mode, within each fund
gen in_mode = 0
replace in_mode = 1 if country_fund_count == country_fund_count_max
bysort cusip6 in_mode MasterPortfolioId: egen countries_in_mode = nvals(iso_country_code)
replace countries_in_mode = . if in_mode == 0
bysort cusip6 MasterPortfolioId: egen _countries_in_mode = max(countries_in_mode)
replace countries_in_mode = _countries_in_mode
drop _countries_in_mode
gen countries_in_submode = n_countries_in_mode_or_submode - countries_in_mode

* Generate tax haven indicators
gen country_fund_nth = 1
forvalues j=1(1)10 {
		cap replace country_fund_nth=0 if (inlist(iso_country_code,${tax_haven`j'}))
}

* If there are non-TH countries in the mode, drop all the TH countries
bysort cusip6 in_mode MasterPortfolioId: egen max_nth_in_modal_category = max(country_fund_nth)
bysort cusip6 MasterPortfolioId: egen max_nth = max(country_fund_nth)
gen max_nth_in_mode = max_nth_in_modal_category if in_mode == 1
by cusip6 MasterPortfolioId: egen _max_nth_in_mode = max(max_nth_in_mode)
replace max_nth_in_mode = _max_nth_in_mode
drop _max_nth_in_mode
gen max_nth_in_submode = max_nth_in_modal_category if in_mode == 0
by cusip6 MasterPortfolioId: egen _max_nth_in_submode = max(max_nth_in_submode)
replace max_nth_in_submode = _max_nth_in_submode
replace max_nth_in_submode = 0 if missing(max_nth_in_submode)
drop _max_nth_in_submode
drop if in_mode == 1 & max_nth_in_mode == 1 & country_fund_nth == 0
drop if in_mode == 0 & max_nth_in_mode == 1

* If there are two or more non-TH countries in the mode, pick one at random
bysort cusip6 in_mode MasterPortfolioId: gen _rand = runiform()
by cusip6 in_mode MasterPortfolioId: egen max_rand = max(_rand)  
drop if in_mode == 1 & countries_in_mode > 1 & _rand < max_rand & max_nth_in_modal_category == 1

* There are no non-TH countries in the mode, but there is one non-TH country in the submode
* There are no non-TH countries in the mode, but there are >1 non-TH countries in the submode; 
* pick via count order and then at random
drop if in_mode == 1 & max_nth_in_mode == 0 & max_nth_in_submode == 1 
drop if in_mode == 0 & country_fund_nth == 0 & max_nth_in_submode == 1
by cusip6 in_mode MasterPortfolioId: egen max_count_in_modal_category = max(country_fund_count)
drop if in_mode == 0 & country_fund_nth == 1 & max_nth_in_submode == 1 & country_fund_count < max_count_in_modal_category
cap drop max_rand
by cusip6 in_mode MasterPortfolioId: egen max_rand = max(_rand)
drop if in_mode == 0 & country_fund_nth == 1 & max_nth_in_submode == 1 & _rand < max_rand

* There is only one TH country in the mode and there are only TH countries in the submode
* There are >1 TH countries in the mode and there are only TH countries in the submode
drop if in_mode == 0 & max_nth_in_submode == 0 & max_nth_in_mode == 0
drop if in_mode == 1 & max_nth_in_submode == 0 & max_nth_in_mode == 0 & _rand < max_rand

* Sanity check the procedure
bysort MasterPortfolioId cusip6: egen n_countries_left = nvals(iso_country_code)
assert n_countries_left == 1
by MasterPortfolioId cusip6: gen n_vals = _N
assert n_vals == 1

* Collapse the data to CUSIP-country level
cap drop country_fund_count
gen country_fund_count = 1
gcollapse (sum) country_fund_count, by(cusip6 iso_country_code th_residency)
save "$temp/morningstar_holdings_cusip_country", replace

* --------------------------------------------------------------------------------------------------
* Across-funds country assignments
* --------------------------------------------------------------------------------------------------

* Find modal and submodal country assigned to each cusip
use "$temp/morningstar_holdings_cusip_country", clear
bysort cusip6: egen country_fund_count_max = max(country_fund_count)
drop if country_fund_count < `submode_tolerance' * country_fund_count_max & th_residency == 0
drop if country_fund_count < `submode_tolerance_th' * country_fund_count_max & th_residency == 1
drop if country_fund_count_max < `min_reporting_funds_for_mode' & th_residency == 0
drop if country_fund_count_max < `min_reporting_funds_for_mode_th' & th_residency == 1
by cusip6: egen n_countries_in_mode_or_submode = nvals(iso_country_code)
drop if n_countries_in_mode_or_submode > `max_countries_in_mode_or_sub' & th_residency == 0
drop if n_countries_in_mode_or_submode > `max_countries_in_mode_or_sub_th' & th_residency == 1

* Use FIGI data to check which issuers are governments (sovereign or local); for these
* we do not accept anything in the submode
mmerge cusip6 using $mns_data/figi/figi_cusip6_sectype, unmatched(m)
drop if country_fund_count != country_fund_count_max & inlist(consolidated_sector, "Govt", "Muni")
drop _merge

* Find modal country assigned to each cusip
gen in_mode = 0
replace in_mode = 1 if country_fund_count == country_fund_count_max
bysort cusip6 in_mode: egen countries_in_mode = nvals(iso_country_code)
replace countries_in_mode = . if in_mode == 0
bysort cusip6: egen _countries_in_mode = max(countries_in_mode)
replace countries_in_mode = _countries_in_mode
drop _countries_in_mode
gen countries_in_submode = n_countries_in_mode_or_submode - countries_in_mode

* Generate tax haven indicators
gen country_fund_nth = 1
forvalues j=1(1)10 {
		cap replace country_fund_nth=0 if (inlist(iso_country_code,${tax_haven`j'}))
}

* If there are non-TH countries in the mode, drop all the TH countries
by cusip6 in_mode: egen max_nth_in_modal_category = max(country_fund_nth)
by cusip6: egen max_nth = max(country_fund_nth)
gen max_nth_in_mode = max_nth_in_modal_category if in_mode == 1
by cusip6: egen _max_nth_in_mode = max(max_nth_in_mode)
replace max_nth_in_mode = _max_nth_in_mode
drop _max_nth_in_mode
gen max_nth_in_submode = max_nth_in_modal_category if in_mode == 0
by cusip6: egen _max_nth_in_submode = max(max_nth_in_submode)
replace max_nth_in_submode = _max_nth_in_submode
replace max_nth_in_submode = 0 if missing(max_nth_in_submode)
drop _max_nth_in_submode
drop if in_mode == 1 & max_nth_in_mode == 1 & country_fund_nth == 0
drop if in_mode == 0 & max_nth_in_mode == 1

* If there are two or more non-TH countries in the mode, pick one at random
by cusip6 in_mode: gen _rand = runiform()
by cusip6 in_mode: egen max_rand = max(_rand)  
drop if in_mode == 1 & countries_in_mode > 1 & _rand < max_rand & max_nth_in_modal_category == 1

* There are no non-TH countries in the mode, but there is one non-TH country in the submode
* There are no non-TH countries in the mode, but there are >1 non-TH countries in the submode; 
* pick via count order and then at random
drop if in_mode == 1 & max_nth_in_mode == 0 & max_nth_in_submode == 1 
drop if in_mode == 0 & country_fund_nth == 0 & max_nth_in_submode == 1
by cusip6 in_mode: egen max_count_in_modal_category = max(country_fund_count)
drop if in_mode == 0 & country_fund_nth == 1 & max_nth_in_submode == 1 & country_fund_count < max_count_in_modal_category
cap drop max_rand
by cusip6 in_mode: egen max_rand = max(_rand)  
drop if in_mode == 0 & country_fund_nth == 1 & max_nth_in_submode == 1 & _rand < max_rand

* There is only one TH country in the mode and there are only TH countries in the submode
* There are >1 TH countries in the mode and there are only TH countries in the submode
drop if in_mode == 0 & max_nth_in_submode == 0 & max_nth_in_mode == 0
drop if in_mode == 1 & max_nth_in_submode == 0 & max_nth_in_mode == 0 & _rand < max_rand

* Sanity check the procedure
by cusip6: egen n_countries_left = nvals(iso_country_code)
assert n_countries_left == 1
by cusip6: gen n_vals = _N
assert n_vals == 1

* Output dataset
keep cusip6 iso_country_code
rename iso_country_code country_ms
save "$aggregation_sources/morningstar_country.dta", replace

log close
