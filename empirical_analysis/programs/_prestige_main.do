
clear all
clear matrix
set more off
capture log close

********************************************************************************
* make sure you have the following packages installed
********************************************************************************

* cem: https://gking.harvard.edu/cem
* estout: http://repec.org/bocode/e/estout/installation.html
* reghdfe: http://scorreia.com/software/reghdfe/
* rdrobust: https://sites.google.com/site/rdpackages/rdrobust
* outtable: http://fmwww.bc.edu/RePEc/bocode/o/outtable.html
* winsor2: http://www.haghish.com/statistics/stata-blog/stata-programming/download/winsor2.html

********************************************************************************
* define folder structure & global options
********************************************************************************

global root "C:\Users\user.USER-ABHDIPU31I\Dropbox\PhD\Projects\Prestige\Empirics\Analysis"
global data "$root\data"
global output "$root\output"
global logbook "$root\log"
global programs "$root\programs"

global tableoptions "ar2 star(* 0.10 ** 0.05 *** 0.01) b(3) label compress booktabs replace mlabels(none) substitute(\_ _) sfmt(%9.0gc) interaction(" * ") nonotes scalars("clustvar Cluster Variable" "N_clust Number of Clusters")"
global graphoptions "scheme(s1mono) graphregion(color(white)) legend(off)"
					
cd $logbook
log using prestige_log.txt, replace

********************************************************************************
* facility level analysis
********************************************************************************

cd $data
use "prestige_main_sample.dta", clear

* figure 3-4: histogram of prestige & scatter plots
* table 1: descriptive statistics for main sample
cd $programs
do descriptives_main

* winsorize continuous variables
winsor2 facilityamt maturity tcb aisd aisu spread facility_fee upfront_fee ///
		commitment_fee utilization_fee cancellation_fee total_assets coverage ///
		leverage profitability tangibility ///
		current_ratio mtb, replace cuts(1 99)

* label variables & create additional variables
cd $programs
do label_main_sample

* define sets of covariates
global loanfeatures "log_facilityamt log_maturity facility_no secured fincovenant baseprime performance"
global borrowerchars "log_total_assets coverage leverage profitability tangibility current_ratio mtb"

* define main cluster / FE specifications
global mainclustervar "bgvkey"
global mainfespec "rating loanpurpose_no loantype_no industry year"
global mainfelabels "rating "Rating FE" industry "Industry FE" year "Year FE" loantype_no "Loan Type FE" loanpurpose_no "Loan Purpose FE""

* define covariates for rdd
global rddcovariates "log_facilityamt log_maturity log_total_assets leverage mtb"

* table 2: impact of borrower prestige on total cost of borrowing
cd $programs
do reg_tcb_score

* table 3: borrower prestige and components of the total cost of borrowing
cd $programs
do reg_fees_score

* table 4: borrower prestige and the pricing of credit lines & term loans
cd $programs
do reg_cltl_score

* table 5: borrower prestige and credit risk
cd $programs
do reg_credit_risk_channel

* table 6: regression discontinuity analysis
cd $programs
do reg_rdd

* table 7-9: matched sample analyses
cd $programs
do reg_matching

********************************************************************************
* deal level analysis
********************************************************************************

cd $data
use "prestige_main_sample_deals.dta", clear

* winsorize continuous variables
winsor2 facilityamt maturity tcb aisd aisu spread facility_fee upfront_fee ///
		commitment_fee utilization_fee cancellation_fee total_assets coverage ///
		leverage profitability tangibility ///
		current_ratio mtb, replace cuts(1 99)

* label variables & create additional variables
cd $programs
do label_main_sample

* table 10: borrower prestige and competition among lenders
cd $programs
do reg_competition_channel

* table 11: borrower prestige and lending relationships status
cd $programs
do reg_relationship_channel

********************************************************************************
* bank level analysis
********************************************************************************

cd $data
use "prestige_bank_sample.dta", clear

global bankcluster "lgvkey"
global bankcontrols "logtotalassets mtb deposits"
global lags "logtop100loans_lag1 logtop100loans_lag2 logtop100loans_lag3 logtop100loans_lag4 logtop100loans_lag5"
global bankfespec "lgvkey year"
global bankfelabels "lgvkey "Bank FE" year "Year FE""

* table 12: descriptive statistics for bank-level sample
cd $programs
do descriptives_bank

* label variables
cd $programs
do label_bank_sample

* table 13: bank level analysis
cd $programs
do reg_bank_level
