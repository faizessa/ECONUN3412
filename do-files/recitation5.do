*=============================================================================*
* Faiz Essa
* ECON UN3412: Econometrics
* Recitation 5
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
use "data/growth.dta", clear

drop if country_name == "Malta"

regress growth tradeshare, robust
/********************************************************************************
* PROBLEM 2: SW Empirical Exercise 4.1 (birthweight_smoking.dta) 
********************************************************************************/
use "data/birthweight_smoking.dta", clear

regress birthweight smoker, robust

regress birthweight smoker alcohol nprevist, robust
margins, atmeans

regress birthweight alcohol nprevist, robust
predict bw_res, r

regress smoker alcohol nprevist, robust
predict smoker_res, r

regress bw_res smoker_res, robust

regress birthweight alcohol tripre0 tripre2 tripre3

/********************************************************************************
* PROBLEM 3: SW Empirical Exercise 4.2 (Growth.dta) 
********************************************************************************/

use "data/growth.dta", clear

drop if country_name == "Malta"

summarize growth tradeshare yearsschool oil rev_coups assasinations rgdp60 // if country_name != "Malta"

regress growth tradeshare yearsschool rev_coups assasinations rgdp60
margins, atmeans

* 2. Create the target value variable (Mean + 1 SD)

regress growth tradeshare oil yearsschool rev_coups assasinations rgdp60
summarize tradeshare
margins, at(tradeshare = `=r(mean) + r(sd)') atmeans 

log close 
