*=============================================================================*
* Faiz Essa
* ECON UN3412: Econometrics
* Recitation 6
*
* Required Subdirectories in Working Directory:
*   - data/     (contains raw input data)
*   - output/   (stores intermediate .dta files and recitation2.log)
*   - images/   (stores exported plots: preston_linear.pdf, preston_log.pdf)
*=============================================================================*

* 0. Environment Setup & Logging
capture log close                              // Close any open logs
clear all                                      // Clear memory
set more off                                   // Disable pause prompts during output

* Set working directory to project root (adjust path as needed)
cd "/Users/faizessa/Library/CloudStorage/Dropbox/Mac/Documents/ta/ECONUN3412"

* Start logging session
log using "output/recitation5.log", replace text

/********************************************************************************
* PROBLEM 1: SW Empirical Exercise 5.2 (Growth.dta)
********************************************************************************/
use "data/lead_mortality.dta", clear

/*
(a) Compute the average infant mortality rate (Inf) for cities with lead pipes
and for cities with nonlead pipes. Is there a statistically significant differ-
ence in the averages?
*/

tab lead, sum(inf)
ttest inf, by(lead)
/*
The amount of lead leached from lead pipes depends on the chemistry of
the water running through the pipes. The more acidic the water is (that
is, the lower its pH), the more lead is leached. Run a regression of Inf on
Lead, pH, and the interaction term Lead * pH.
*/

reg inf i.lead##c.ph precipitation, robust

/*
(i.) The regression includes four coefficients (the intercept and the three
coefficients multiplying the regressors). Explain what each coefficient
measures.
*/

/*
(ii.) Plot the estimated regression function relating Inf to pH for Lead= 0
and for Lead= 1. Describe the differences in the regression functions,
and relate these differences to the coefficients you discussed in (i).
*/

margins lead, at(ph=(5(0.5)9))

marginsplot, ///
    title("Estimated Regression Function: Inf vs pH by Lead") ///
    ytitle("Inf (Estimated)") ///
    xtitle("pH") ///
    legend(order(1 "Lead = 0" 2 "Lead = 1")) ///
    recast(line) ///
    noci
	
 /*
(iii.) Does Lead have a statistically significant effect on infant mortality?
Explain.
 */

test 1.lead 1.lead#c.ph

/* 
(v.) What is the average value of pH in the sample? At this pH level,
what is the estimated effect of Lead on infant mortality? What is
the standard deviation of pH? Suppose the pH level is one standard
deviation lower than the average level of pH in the sample: What is
the estimated effect of Lead on infant mortality? What if pH is one
standard deviation higher than the average value?
*/


summarize ph
local ph_mean = r(mean)
local ph_sd   = r(sd)
local ph_low  = `ph_mean' - `ph_sd'
local ph_high = `ph_mean' + `ph_sd'

* Display the calculated values for verification
display "Mean pH: " `ph_mean'
display "SD of pH: " `ph_sd'
display "Mean - 1 SD: " `ph_low'
display "Mean + 1 SD: " `ph_high'

* 3 & 4. Compute marginal effect of Lead at (Mean - 1 SD), Mean, and (Mean + 1 SD)
margins, dydx(lead) at(ph = (`ph_low' `ph_mean' `ph_high'))

* (vi.) Construct a 95% confidence interval for the effect of Lead when pH = 6.5
margins, dydx(lead) at(ph = 6.5)

log close

