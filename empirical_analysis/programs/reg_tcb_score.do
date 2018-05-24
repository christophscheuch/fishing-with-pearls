
* loan type, loan purpose, industry, year, rating, bank FE
qui reghdfe log_tcb score $loanfeatures $borrowerchars, ///
				  absorb(rating industry year loantype_no loanpurpose_no) ///
				  vce(cluster bgvkey)
est store model1
* loan type, loan purpose, year, bank, firm FE
qui reghdfe log_tcb score $loanfeatures $borrowerchars, ///
				  absorb(rating industry_year loantype_no loanpurpose_no) ///
				  vce(cluster bgvkey)
est store model2
* loan type, loan purpose, industry*year, bank, firm FE
qui reghdfe log_tcb score $loanfeatures $borrowerchars, ///
				  absorb(rating industry_year type_year purpose_year) ///
				  vce(cluster bgvkey)
est store model3
* loan type, loan purpose, industry*year, bank*year, firm FE
qui reghdfe log_tcb score $loanfeatures $borrowerchars, ///
				  absorb(bgvkey industry_year loantype_no loanpurpose_no) ///
				  vce(cluster bgvkey)
est store model4
* loan type*year, loan purpose*year, industry*year, bank*year, firm FE
qui reghdfe log_tcb score $loanfeatures $borrowerchars, ///
				  absorb(bgvkey type_year purpose_year industry_year) ///
				  vce(cluster bgvkey)
est store model5
* loan type, loan purpose, industry, year, rating, bank FE
qui reghdfe log_tcb score $loanfeatures $borrowerchars, ///
				  absorb(rating industry year loantype_no loanpurpose_no) ///
				  vce(cluster state)
est store model6
* loan type, loan purpose, industry*year, bank, firm FE
qui reghdfe log_tcb score $loanfeatures $borrowerchars, ///
				  absorb(rating industry_year loantype_no loanpurpose_no) ///
				  vce(cluster state)
est store model7
* loan type*year, loan purpose*year, industry*year, firm FE
qui reghdfe log_tcb score $loanfeatures $borrowerchars, ///
				  absorb(bgvkey type_year purpose_year industry_year) ///
				  vce(cluster state)
est store model8

cd $output
estfe . model*, labels(rating "Rating FE" industry "Industry FE" year "Year FE" ///
					   loantype_no "Loan Type FE" loanpurpose_no "Loan Purpose FE" ///
					   industry_year "Industry x Year FE" ///
					   type_year "Loan Type x Year FE" purpose_year "Loan Purpose x Year FE" ///
					   bgvkey "Firm FE")
return list
esttab model* using tab_reg_tcb_score.tex, ///
	          indicate(`r(indicate_fe)') ///
			  mgroups("Log(TCB)", pattern(1 0 0 0 0 0 0 0) ///
			  prefix(\multicolumn{@span}{c}{) suffix(}) ///
			  span erepeat(\cmidrule(lr){@span})) ///
			  varlabels(, elist(mtb \midrule)) ///
			  $tableoptions

est clear

********************************************************************************

* loan type, loan purpose, industry, year, rating, bank FE
qui reghdfe log_aisd score $loanfeatures $borrowerchars, ///
				  absorb(rating industry year loantype_no loanpurpose_no) ///
				  vce(cluster bgvkey)
est store model1
* loan type, loan purpose, year, bank, firm FE
qui reghdfe log_aisd score $loanfeatures $borrowerchars, ///
				  absorb(rating industry_year loantype_no loanpurpose_no) ///
				  vce(cluster bgvkey)
est store model2
* loan type, loan purpose, industry*year, bank, firm FE
qui reghdfe log_aisd score $loanfeatures $borrowerchars, ///
				  absorb(rating industry_year type_year purpose_year) ///
				  vce(cluster bgvkey)
est store model3
* loan type, loan purpose, industry*year, bank*year, firm FE
qui reghdfe log_aisd score $loanfeatures $borrowerchars, ///
				  absorb(bgvkey industry_year loantype_no loanpurpose_no) ///
				  vce(cluster bgvkey)
est store model4
* loan type*year, loan purpose*year, industry*year, bank*year, firm FE
qui reghdfe log_aisd score $loanfeatures $borrowerchars, ///
				  absorb(bgvkey type_year purpose_year industry_year) ///
				  vce(cluster bgvkey)
est store model5
* loan type, loan purpose, industry, year, rating, bank FE
qui reghdfe log_aisd score $loanfeatures $borrowerchars, ///
				  absorb(rating industry year loantype_no loanpurpose_no) ///
				  vce(cluster state)
est store model6
* loan type, loan purpose, industry*year, bank, firm FE
qui reghdfe log_aisd score $loanfeatures $borrowerchars, ///
				  absorb(rating industry_year loantype_no loanpurpose_no) ///
				  vce(cluster state)
est store model7
* loan type*year, loan purpose*year, industry*year, firm FE
qui reghdfe log_aisd score $loanfeatures $borrowerchars, ///
				  absorb(bgvkey type_year purpose_year industry_year) ///
				  vce(cluster state)
est store model8

cd $output
estfe . model*, labels(rating "Rating FE" ///  
					   industry "Industry FE" year "Year FE" ///
					   loantype_no "Loan Type FE" loanpurpose_no "Loan Purpose FE" ///
					   industry_year "Industry x Year FE" ///
					   type_year "Loan Type x Year FE" purpose_year "Loan Purpose x Year FE" ///
					   bgvkey "Firm FE")
return list
esttab model* using tab_reg_aisd_score.tex, ///
	          indicate(`r(indicate_fe)') ///
			  mgroups("Log(AISD)", pattern(1 0 0 0 0 0 0 0) ///
			  prefix(\multicolumn{@span}{c}{) suffix(}) ///
			  span erepeat(\cmidrule(lr){@span})) ///
			  varlabels(, elist(mtb \midrule)) ///
			  $tableoptions

est clear
