*=============================================================================*
* Faiz Essa
* ECON UN3412: Econometrics
* Recitation 1: Introduction to Stata
* Companion .do file
*
* Required Subdirectories in Working Directory:
*   - output/   (stores generated logs, exported datasets, and tables)
*=============================================================================*

* 0. Environment Setup & Logging
capture log close                              // Close any lingering open logs
clear all                                      // Clear memory
set more off                                   // Disable pause prompts during output

* Set working directory to output folder (adjust path as needed)
cd "/Users/faizessa/Library/CloudStorage/Dropbox/Mac/Documents/ta/ECONUN3412/output"

* Start logging session
log using "recitation1.log", replace text

*=============================================================================*
* 1. LOADING AND SAVING DATA
*=============================================================================*

* Load built-in Stata dataset
sysuse auto, clear

* Saving to Stata format (.dta)
save "auto.dta", replace

* Loading from Stata format (.dta)
use "auto.dta", clear

* Exporting to CSV format (.csv)
export delimited using "auto.csv", replace

* Importing from CSV format (.csv)
import delimited "auto.csv", clear

* Exporting to Excel format (.xlsx)
export excel using "auto.xlsx", firstrow(variables) replace

* Importing from Excel format (.xlsx)
import excel "auto.xlsx", firstrow clear

*=============================================================================*
* 2. INSPECTING & MODIFYING DATA
*=============================================================================*

* Basic summary statistics
summarize mpg price weight

* Detailed summary statistics (percentiles, variance, skewness, kurtosis)
summarize mpg price weight, detail

* Create gallons per 100 miles (gpm)
generate gpm = (1 / mpg) * 100

* Create binary indicator for high fuel economy (mpg >= 25)
generate high_mpg = (mpg >= 25)

* Inspect newly created variables
summarize gpm high_mpg

*=============================================================================*
* 3. TWO-SIDED HYPOTHESIS TESTING: H0: mu = 20 vs H1: mu != 20
*=============================================================================*

* Method A: Manual computation using summary statistics and scalars
summarize mpg
scalar n_obs    = r(N)
scalar mean_mpg = r(mean)
scalar sd_mpg   = r(sd)
scalar se_mpg   = sd_mpg / sqrt(n_obs)
scalar t_stat   = (mean_mpg - 20) / se_mpg
scalar p_val    = 2 * (1 - normal(abs(t_stat)))
scalar ci_lower = mean_mpg - 1.960 * se_mpg
scalar ci_upper = mean_mpg + 1.960 * se_mpg

display _newline "=========================================================="
display "=== Manual Two-Sided Hypothesis Test (H0: mu = 20, alpha = 0.05) ==="
display "=========================================================="
display "Sample Mean:        " mean_mpg
display "Standard Error:     " se_mpg
display "t-Statistic:        " t_stat
display "Critical Value:     +/- 1.960"
display "p-Value:            " p_val
display "95% Conf. Interval: [" ci_lower ", " ci_upper "]"
display "==========================================================" _newline

* Method B: Automated testing using Stata's official ttest command
ttest mpg == 20

*=============================================================================*
* 4. USEFUL COMMANDS FOR FUTURE RECITATIONS (REFERENCE)
*=============================================================================*
* - Regression:            regress price mpg weight
* - Correlation:           correlate price mpg weight
* - Covariance:            correlate price mpg weight, covariance
* - Advanced Variables:    egen mean_mpg = mean(mpg), by(foreign)
* - Merging:               merge 1:1 id using "other_dataset.dta"
* - Visualization:         twoway scatter price mpg || lfit price mpg
* - In-app Help:           help <command>
*=============================================================================*

* Close log file
capture log close