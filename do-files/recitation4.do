*=============================================================================*
* Faiz Essa
* ECON UN3412: Econometrics
* Recitation 4
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
log using "output/recitation2.log", replace text

/********************************************************************************
* PROBLEM 7: SW Empirical Exercise 4.1 (Growth.dta)
********************************************************************************/
use "data/growth.dta", clear

graph twoway (scatter growth tradeshare)
capture graph export "images/ps2_growth.png" 

list country_name growth tradeshare if tradeshare > 1.5

regress growth tradeshare, robust 

regress growth tradeshare if country_name != "Malta", robust

// plotting regression functions
graph twoway (scatter growth tradeshare) ///
	(lfit growth tradeshare) ///
	(lfit growth tradeshare if country_name != "Malta")
capture graph export "images/ps2_growth_2.png" 

	
/********************************************************************************
* PROBLEM 8: SW Empirical Exercise 4.2 (Earnings_and_Height.dta) 
********************************************************************************/
use "data/Earnings_and_Height.dta", clear

summarize earnings if height <= 67
summarize earnings if height > 67

gen tall = (height > 67)
ttest earnings, by(tall) unequal

graph twoway (scatter earnings height)
capture graph export "images/ps2_earnings.png" 

regress earnings height, robust

gen height_cm = height/0.394
regress earning height_cm

regress earnings height if sex == 0, robust

/********************************************************************************
* PROBLEM 9: SW Empirical Exercise 5.3 (birthweight_smoking.dta)
********************************************************************************/

* Close log file
log close
