
qui reghdfe log_aisd score, ///
			absorb(rating) ///
			vce(cluster $mainclustervar)
est store model1
qui reghdfe log_aisd score $loanfeatures $borrowerchars, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model2
qui reghdfe log_aisu score, ///
			absorb(rating) ///
			vce(cluster $mainclustervar)
est store model3			
qui reghdfe log_aisu score $loanfeatures $borrowerchars, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model4
qui reghdfe log_spread score, ///
			absorb(rating) ///
			vce(cluster $mainclustervar)
est store model5
qui reghdfe log_spread score $loanfeatures $borrowerchars, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model6

cd $output
estfe . model*, labels($mainfelabels)
return list
esttab model* using tab_reg_fees_score_A.tex, ///
	          indicate("Loan Features = $loanfeatures" ///
			  "Borrower Characteristics = $borrowerchars" ///
			  `r(indicate_fe)') ///
			  mgroups("Log($\text{AISD}$)" ///
					  "Log($\text{AISU}$)" ///
					  "Log($\text{Spread}$)", ///
					  pattern(1 0 1 0 1 0) ///
			  prefix(\multicolumn{@span}{c}{) suffix(}) ///
			  span erepeat(\cmidrule(lr){@span})) ///
			  varlabels(, elist(score \midrule)) ///
			  $tableoptions
			  
est clear

********************************************************************************

qui reghdfe log_upfront_fee score, ///
			absorb(rating) ///
			vce(cluster $mainclustervar)
est store model1
qui reghdfe log_upfront_fee score $loanfeatures $borrowerchars, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model2	
qui reghdfe log_commitment_fee score, ///
			absorb(rating) ///
			vce(cluster $mainclustervar)
est store model3
qui reghdfe log_commitment_fee score $loanfeatures $borrowerchars, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model4
qui reghdfe log_facility_fee score, ///
			absorb(rating) ///
			vce(cluster $mainclustervar)
est store model5
qui reghdfe log_facility_fee score $loanfeatures $borrowerchars, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model6

cd $output
estfe . model*, labels($mainfelabels)
return list
esttab model* using tab_reg_fees_score_B.tex, ///
	          indicate("Loan Features = $loanfeatures" ///
			  "Borrower Characteristics = $borrowerchars" ///
			  `r(indicate_fe)') ///
			  mgroups("Log($\text{Upfront Fee}$)" ///
					  "Log($\text{Commitment Fee}$)" ///
					  "Log($\text{Facility Fee}$)", ///
					  pattern(1 0 1 0 1 0) ///
			  prefix(\multicolumn{@span}{c}{) suffix(}) ///
			  span erepeat(\cmidrule(lr){@span})) ///
			  varlabels(, elist(score \midrule)) ///
			  $tableoptions
			  
est clear
