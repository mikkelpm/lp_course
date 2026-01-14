clear all
cap log close
log using lecture1.log, replace

* Data
do load_data
describe
summarize
include settings.do

twoway (tsline `outcome', yaxis(1) lwidth(thick)) (tsline `impulse', yaxis(2) lwidth(thin)), tlabel(#8) ytitle("", axis(1)) ytitle("", axis(2)) legend(order(1 "log global GDP (left axis)" 2 "global temperature anomaly ({c 176}C, right axis)") rows(2)) graphregion(color(white))
graph export data.pdf, replace

* Implicit temperature shock
local sample "1962,2015"
reg F4.`outcome' `impulse' `controls' if tin(`sample')
reg `impulse' `controls' if tin(`sample')
predict impulse_resid if tin(`sample'), resid
reg F4.`outcome' impulse_resid if tin(`sample')
su impulse_resid, detail
tsline impulse_resid, graphregion(color(white)) ytitle("temperature shock") tlabel(#8)
graph export shock.pdf, replace

* Lag length selection
varsoc `outcome' `impulse' recessiondates lnpoil_wti treasury1y, maxlag(4)

* Run LP and compute SE in two ways
postfile f h ir se se_nw using lp, replace
forvalues h=0/`maxhorz' {
	qui ivreg2 F`h'.`outcome' `impulse' `controls', robust kernel(bartlett) bw(auto) // Newey-West SE
	local nw_se = _se["`impulse'"]
	qui reg F`h'.`outcome' `impulse' `controls', robust // Heteroskedasticity-robust SE
	post f (`h') (_b["`impulse'"]) (_se["`impulse'"]) (`nw_se') // Store horizon, coefficient, and SE
}
postclose f

* Report IRF and SE
preserve
use lp, clear
list h ir se se_nw

gen lower = ir-se
gen upper = ir+se
gen lower_nw = ir-se_nw
gen upper_nw = ir+se_nw
twoway connected ir lower upper lower_nw upper_nw h, lpattern(solid solid solid dash ..) lwidth(thick thin ..) lcolor(black maroon ..) msymbol(circle none ..) msize(large ..) mcolor(black ..) xtitle("horizon (years)") xlabels(0(1)10) graphregion(color(white)) legend(order(1 "estimates" 2 "68% CI" 4 "68% CI, Newey-West") rows(1))
graph export irf.pdf, replace
restore

* Variance decomposition
reg `impulse' `controls'
predict impulse_resid_full, resid // Estimate shock on full available sample
postfile f h r2 using fevd, replace
forvalues h=0/`maxhorz' {
	qui reg F`h'.`outcome' `controls' // Regression w/o shock
	qui predict res, resid // Residual
	qui reg res F(0/`h').impulse_resid_full // Regress residual on current+future shocks
	post f (`h') (e(r2)) // Store horizon and R^2
	drop res
}
postclose f

preserve
use fevd, clear
list h r2
restore

* LP-IV
local norm gtmp_bkly_aw
reg `norm' `impulse' `controls', robust

postfile f h ir se using lp_iv, replace
forvalues h=0/`maxhorz' {
	qui ivreg2 F`h'.`outcome' `controls' (`norm' = `impulse'), robust
	post f (`h') (_b["`norm'"]) (_se["`norm'"]) // Store horizon, coefficient, and SE
}
postclose f

preserve
use lp_iv, clear
gen lower = ir-se
gen upper = ir+se
twoway connected ir lower upper h, lpattern(solid ..) lwidth(thick thin ..) lcolor(black maroon ..) msymbol(circle none ..) msize(large ..) mcolor(black ..) xtitle("horizon (years)") xlabels(0(1)10) graphregion(color(white)) legend(order(1 "estimates" 2 "68% CI") rows(1))
graph export irf_iv.pdf, replace
restore

log close