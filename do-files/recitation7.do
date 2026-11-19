*=============================================================================*
* Faiz Essa
* ECON UN3412: Econometrics
* Recitation 7: Regression with Panel Data (SW Empirical Exercise 10.1)
*
* Required Subdirectories in Working Directory:
*   - data/     (contains raw input data: Guns.dta)
*   - output/   (stores log file: recitation7.log)
*=============================================================================*

* 0. Environment Setup & Logging
capture log close                              // Close any open logs
clear all                                      // Clear memory
set more off                                   // Disable pause prompts during output

* Set working directory to project root (adjust path as needed)
cd "/Users/faizessa/Library/CloudStorage/Dropbox/Mac/Documents/ta/ECONUN3412"

* Start logging session
log using "output/recitation7.log", replace text

/********************************************************************************
* PROBLEM 1: SW Empirical Exercise 10.1 (Guns.dta)
********************************************************************************/
use "data/Guns.dta", clear

* Inspect dataset and declare panel structure (stateid = entity, year = time)
describe
summarize
xtset stateid year

* Generate natural logarithms of the three crime rates
generate lnvio = ln(vio)
label variable lnvio "Log of Violent Crime Rate (per 100,000)"

generate lnrob = ln(rob)
label variable lnrob "Log of Robbery Rate (per 100,000)"

generate lnmur = ln(mur)
label variable lnmur "Log of Murder Rate (per 100,000)"

* Define local macro for the control variables in regression (2)
local controls incarc_rate density avginc pop pb1064 pw1064 pm1029

/*=============================================================================
(a) Estimate:
    (1) a regression of ln(vio) against shall, and
    (2) a regression of ln(vio) against shall, incarc_rate, density, avginc,
        pop, pb1064, pw1064, and pm1029.
=============================================================================*/

* Regression (1): Pooled OLS without controls
display _newline "=== (a)(1) Pooled OLS: ln(vio) on shall ==="
regress lnvio shall, robust

* Regression (2): Pooled OLS with demographic and economic controls
display _newline "=== (a)(2) Pooled OLS: ln(vio) on shall + controls ==="
regress lnvio shall `controls', robust

/*
(i.) Interpret the coefficient on shall in regression (2). Is this estimate
large or small in a real-world sense?

Answer:
- The coefficient on `shall` in regression (2) is -0.368.
- Interpretation: Holding incarceration rate, density, average income, total
  population, and demographic shares constant, states with a shall-issue
  concealed weapons law have a violent crime rate that is approximately 36.8%
  lower (or more precisely, 100 * (exp(-0.3684) - 1) = -30.8% lower) than states
  without such a law.
- magnitude: A ~31-37% reduction in violent crime is a very large
  effect.

(ii.) Does adding the control variables in regression (2) change the estimated
effect of a shall-issue law in regression (1) as measured by statistical
significance? As measured by the real-world significance of the estimated
coefficient?

Answer:
- Statistical significance: In both regression (1) (coef = -0.443, SE = 0.048,
  t = -9.32) and regression (2) (coef = -0.368, SE = 0.035, t = -10.59), the
  coefficient on `shall` is highly statistically significant at the 1% level.
- Real-world significance: Adding controls attenuates the point estimate slightly
  from -0.443 (-44.3%) to -0.368 (-36.8%), but both estimates remain very large
  in magnitude and economically meaningful.

(iii.) Suggest a variable that varies across states but plausibly varies
little—or not at all—over time and that could cause omitted variable bias in
regression (2).

Answer:
- Examples include underlying cultural attitudes toward guns and violence,
  long-standing quality/organization of state police and judicial institutions,
  geography/urban structure, historical gang presence. These factors
  differ across states, are largely time-invariant.
*/

/*=============================================================================
(b) Do the results change when you add fixed state effects? If so, which set of
regression results is more credible, and why?
=============================================================================*/

* Regression (3): State Fixed Effects (clustered SEs at the state level)
display _newline "=== (b) State Fixed Effects: ln(vio) on shall + controls + State FE ==="
xtreg lnvio shall `controls', fe vce(cluster stateid)

* Alternative syntax with explicit state dummies and clustered SEs:
* regress lnvio shall `controls' i.stateid, vce(cluster stateid)

/*
Answer:
- Yes, the results change dramatically. The coefficient on `shall` drops from
  -0.368 (t = -10.59) to -0.046 (clustered SE = 0.042, t = -1.10, p = 0.276).
- The estimated effect is now much smaller (-4.6%) and statistically
  indistinguishable from zero at conventional significance levels.
- The state fixed effects regression is far more credible because it controls
  for all time-invariant unobserved state characteristics (cultural attitudes
  toward firearms, historical crime levels, baseline institutional quality) that
  are correlated with both violent crime and the passage of shall-issue laws.
*/

/*=============================================================================
(c) Do the results change when you add fixed time effects? If so, which set of
regression results is more credible, and why?
=============================================================================*/

* Regression (4): Two-Way Fixed Effects (State FE + Year FE, clustered SEs)
display _newline "=== (c) State & Time Fixed Effects: ln(vio) on shall + controls + State FE + Year FE ==="
xtreg lnvio shall `controls' i.year, fe vce(cluster stateid)

* Test joint significance of the time fixed effects
testparm i.year

/*
Answer:
- Adding time fixed effects reduces the magnitude
  even further, from -0.046 to -0.028 (clustered SE = 0.041, t = -0.69,
  p = 0.496), which remains statistically insignificant.
- The time fixed effects are jointly highly significant (F-test p-value < 0.001).
- The regression with both state and time fixed effects is more credible because
  national crime rates fluctuate over time at the
  same time that more states were adopting shall-issue laws.
*/

/*=============================================================================
(d) Repeat the analysis using ln(rob) and ln(mur) in place of ln(vio).
=============================================================================*/

*-----------------------------------------------------------------------------*
* Dependent Variable: ln(rob) (Log Robbery Rate)
*-----------------------------------------------------------------------------*
display _newline "=== (d) Robbery Rate: Model (1) Pooled OLS (no controls) ==="
regress lnrob shall, robust

display _newline "=== (d) Robbery Rate: Model (2) Pooled OLS (with controls) ==="
regress lnrob shall `controls', robust

display _newline "=== (d) Robbery Rate: Model (3) State Fixed Effects ==="
xtreg lnrob shall `controls', fe vce(cluster stateid)

display _newline "=== (d) Robbery Rate: Model (4) State + Year Fixed Effects ==="
xtreg lnrob shall `controls' i.year, fe vce(cluster stateid)
testparm i.year

*-----------------------------------------------------------------------------*
* Dependent Variable: ln(mur) (Log Murder Rate)
*-----------------------------------------------------------------------------*
display _newline "=== (d) Murder Rate: Model (1) Pooled OLS (no controls) ==="
regress lnmur shall, robust

display _newline "=== (d) Murder Rate: Model (2) Pooled OLS (with controls) ==="
regress lnmur shall `controls', robust

display _newline "=== (d) Murder Rate: Model (3) State Fixed Effects ==="
xtreg lnmur shall `controls', fe vce(cluster stateid)

display _newline "=== (d) Murder Rate: Model (4) State + Year Fixed Effects ==="
xtreg lnmur shall `controls' i.year, fe vce(cluster stateid)
testparm i.year

/*
Summary of (d):
- For both `ln(rob)` and `ln(mur)`, the pattern mirrors `ln(vio)`:
*/

/*=============================================================================
(e) In your view, what are the most important remaining threats to the internal
validity of this regression analysis?

Example answers:
1. Simultaneous Causality: States may pass (or
   repeal) shall-issue laws in response to recent state-specific surges or
   trends in violent crime.
2. Omitted variables that vary across time AND state: Unobserved state-level factors that change
   over time—such as state-specific policing reforms, changes in local drug
   markets, sentencing laws, or state-specific economic shocks—are not absorbed
   by state fixed effects (which only capture time-invariant state factors) or
   year fixed effects (which only capture national shocks).

(f) Based on your analysis, what conclusions would you draw about the effects
of concealed weapons laws on these crime rates?

Answer:
- The large negative relationship between shall-issue laws and violent crime
  found in simple cross-sectional / pooled OLS regressions is driven by omitted
  variable bias from unobserved time-invariant state differences.
- Once we control for state fixed effects and national time trends, there is no
  statistically significant evidence that shall-issue concealed weapons laws
  reduce violent crime, robbery, or murder rates.
=============================================================================*/

* Close log file
log close
