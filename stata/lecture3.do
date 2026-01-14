clear all
cap log close
log using lecture3.log, replace

* Data
do load_data
include settings.do

* Joint inference
postfile f h ir se using lp, replace
forvalues h=0/`maxhorz' {
	qui reg F`h'.`outcome' `impulse' `controls', robust
	post f (`h') (_b["`impulse'"]) (_se["`impulse'"]) // Store horizon, coefficient, and SE
	qui reg F`h'.`outcome' `impulse' `controls'
	estimates store lp`h' // Store regression results for later joint inference
}
postclose f

suest lp*, vce(robust) // Stack regression results

local teststr ""
forvalues h=0/`maxhorz' { // Build string of LP coefficients to be tested
	local teststr "`teststr' [lp`h'_mean]`impulse'"
}
test `teststr', matvlc(vcov_matrix) // Test null of no effect at any horizon
mat list vcov_matrix // Display var-cov matrix of LP estimates

estimate_supt_critical_value, vcov_matrix(vcov_matrix) conf_level(0.68) // To install this function: net install estimate_supt_critical_value, from("https://raw.githubusercontent.com/ryanedmundkessler/simultaneous_confidence_bands/master/ado/")
local supt_cv = r(critical_value) // Critical value for simultaneous confidence band

preserve

use lp, clear
gen lower_pw = ir-se
gen upper_pw = ir+se
gen lower_si = ir-`supt_cv'*se
gen upper_si = ir+`supt_cv'*se
twoway connected ir lower_pw upper_pw lower_si upper_si h, lpattern(solid solid solid dash ..) lwidth(thick thin ..) lcolor(black maroon ..) msymbol(circle none ..) msize(large ..) mcolor(black ..) xtitle("horizon (years)") xlabels(0(1)10) graphregion(color(white)) legend(order(1 "estimates" 2 "68% pointwise band" 4 "68% simultaneous band"))
graph export irf_joint.pdf, replace

* Polynomial fit
gen h2 = h^2
local fit_reg h h2 // Covariates in parametric fit
reg ir `fit_reg'
predict ir_fit // Best-fitting polynomial
local sum_sq_res = e(rss) // Sum of squared residuals, for later

twoway connected ir ir_fit lower_pw upper_pw h, lpattern(solid dash solid ..) lwidth(thick thick thin ..) lcolor(black blue maroon ..) msymbol(circle none ..) msize(large ..) mcolor(black ..) xtitle("horizon (years)") xlabels(0(1)10) graphregion(color(white)) legend(order(1 "estimates" 2 "polynomial fit" 3 "68% pointwise band") rows(1))
graph export irf_fit.pdf, replace

* Shrinkage estimation
svmat vcov_matrix, names(mat) // Make columns of var-cov matrix into data variables
local trace = 0
forvalues h=0/`maxhorz' { // Compute trace of var-cov matrix of residuals
	local i = `h'+1
	qui reg mat`i' `fit_reg'
	predict mat`i'_res, resid
	local trace = `trace' + mat`i'_res[`i']
}
local shrink = min(`trace'/`sum_sq_res', 1) // Shrinkage factor
gen ir_shrink = (1-`shrink')*ir + `shrink'*ir_fit // Shrinkage estimator
disp as text "Shrinkage factor = " as result `shrink'
list h ir ir_fit ir_shrink

twoway connected ir ir_fit ir_shrink lower_pw upper_pw h, lpattern(solid dash dash_dot solid ..) lwidth(thick thick thick thin ..) lcolor(black blue green maroon ..) msymbol(circle none ..) msize(large ..) mcolor(black ..) xtitle("horizon (years)") xlabels(0(1)10) graphregion(color(white)) legend(order(1 "estimates" 2 "polynomial fit" 3 "shrinkage estimator" 4 "68% pointwise band"))
graph export irf_shrink.pdf, replace

restore

log close