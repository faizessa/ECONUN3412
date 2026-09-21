*=============================================================================*
* Faiz Essa
* ECON UN3412: Econometrics
* Recitation 2: OLS in Stata (The Preston Curve)
* Companion .do file
*
* Required Subdirectories in Working Directory:
*   - data/     (contains raw input data: wdi_gdp.csv, wdi_life_expectancy.csv)
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
log using "output/recitation2.log", replace text

*=============================================================================*
* 1. IMPORTING AND PREPARING THE DATASETS
*=============================================================================*

* Import GDP per capita CSV and save as Stata .dta
import delimited "data/wdi_gdp.csv", clear
describe
save "output/wdi_gdp.dta", replace

* Import Life Expectancy CSV and save as Stata .dta
import delimited "data/wdi_life_expectancy.csv", clear
describe
save "output/wdi_life_expectancy.dta", replace

*=============================================================================*
* 2. MERGING THE TWO DATASETS
*=============================================================================*

* Load the master dataset (GDP per capita)
use "output/wdi_gdp.dta", clear

* Perform a 1:1 merge using the 3-letter ISO country code
merge 1:1 country_code using "output/wdi_life_expectancy.dta"

* Inspect the merge diagnostic table
tabulate _merge

* Keep only matched observations across both files
keep if _merge == 3

* Drop the system-generated merge indicator
drop _merge

* Save the consolidated cross-country dataset
save "output/wdi_preston_merged.dta", replace

*=============================================================================*
* 3. EXPLORATORY ANALYSIS & THE LINEARITY ASSUMPTION
*=============================================================================*

* Rescale GDP per capita into thousands of USD for interpretable coefficients
generate gdppc_k = gdppc / 1000
label variable gdppc_k "GDP per capita (thousands of USD)"
label variable life_exp "Life expectancy at birth (years)"

* Summary statistics
summarize life_exp gdppc gdppc_k

* Plot 1: Testing the Linearity Assumption (Scatterplot + Linear OLS fit)
twoway (scatter life_exp gdppc_k, mcolor(navy%70) msize(small)) ///
       (lfit life_exp gdppc_k, lcolor(cranberry) lwidth(medium)), ///
       title("Preston Curve: Testing the Linearity Assumption", size(medium)) ///
       subtitle("Life Expectancy vs. GDP per Capita (2019)", size(small)) ///
       xtitle("GDP per Capita (Thousands of Current USD)") ///
       ytitle("Life Expectancy at Birth (Years)") ///
       legend(order(1 "Countries" 2 "Linear OLS Fit")) ///
       scheme(s2color) graphregion(color(white))

graph export "images/preston_linear.pdf", replace

*=============================================================================*
* 4. AN ALTERNATIVE MODEL: LOG-LINEAR SPECIFICATION
*=============================================================================*

* Create natural logarithm of GDP per capita
generate log_gdppc = log(gdppc)
label variable log_gdppc "Log GDP per capita"

* Plot 2: Scatterplot + Log-Linear OLS fit
twoway (scatter life_exp log_gdppc, mcolor(navy%70) msize(small)) ///
       (lfit life_exp log_gdppc, lcolor(cranberry) lwidth(medium)), ///
       title("Preston Curve: Log-Linear Specification", size(medium)) ///
       subtitle("Life Expectancy vs. Log GDP per Capita (2019)", size(small)) ///
       xtitle("Natural Log of GDP per Capita, ln(GDP)") ///
       ytitle("Life Expectancy at Birth (Years)") ///
       legend(order(1 "Countries" 2 "Log-Linear OLS Fit")) ///
       scheme(s2color) graphregion(color(white))

graph export "images/preston_log.pdf", replace

*=============================================================================*
* 5. ESTIMATING AND INTERPRETING OLS REGRESSIONS
*=============================================================================*

* Model 1: Baseline Linear Model
display _newline "=== Model 1: Linear Specification ==="
regress life_exp gdppc_k

* Hypothesis Test on Slope: H0: beta_1 = 0.5 vs H1: beta_1 != 0.5
test gdppc_k = 0.5

* Model 2: Semi-Elasticity (Log-Linear) Model
display _newline "=== Model 2: Log-Linear Specification ==="
regress life_exp log_gdppc

* Hypothesis Test on Slope: H0: alpha_1 = 5 vs H1: alpha_1 != 5
test log_gdppc = 5

* Close log file
log close
