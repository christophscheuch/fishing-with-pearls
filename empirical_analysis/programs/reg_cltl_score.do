
* total cost of borrowing
qui reghdfe log_tcb score score_cl credit_line ///
			if term_loan == 1 | credit_line == 1, ///
			absorb(rating) ///
			vce(cluster $mainclustervar)
est store model1
test score + score_cl = 0
qui reghdfe log_tcb score score_cl credit_line $loanfeatures $borrowerchars ///
			if term_loan == 1 | credit_line == 1, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model2
test score + score_cl = 0
qui reghdfe log_spread score score_cl credit_line ///
			if term_loan == 1 | credit_line == 1, ///
			absorb(rating) ///
			vce(cluster $mainclustervar)
est store model3
test score + score_cl = 0
qui reghdfe log_spread score score_cl credit_line $loanfeatures $borrowerchars ///
			if term_loan == 1 | credit_line == 1, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model4
test score + score_cl = 0
qui reghdfe log_facility_fee score score_cl credit_line ///
			if term_loan == 1 | credit_line == 1, ///
			absorb(rating) ///
			vce(cluster $mainclustervar)
est store model5
test score + score_cl = 0
qui reghdfe log_facility_fee score score_cl credit_line $loanfeatures $borrowerchars ///
			if term_loan == 1 | credit_line == 1, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model6
test score + score_cl = 0
qui reghdfe log_upfront_fee score score_cl credit_line ///
			if term_loan == 1 | credit_line == 1, ///
			absorb(rating) ///
			vce(cluster $mainclustervar)
est store model7
test score + score_cl = 0
qui reghdfe log_upfront_fee score score_cl credit_line $loanfeatures $borrowerchars ///
			if term_loan == 1 | credit_line == 1, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model8
test score + score_cl = 0

*****************************************************************************

cd $output
estfe . model*, labels($mainfelabels)

return list
esttab model* using tab_reg_cltl_score.tex, ///
	          indicate("Loan Features = $loanfeatures" ///
			  "Borrower Characteristics = $borrowerchars" ///
			  `r(indicate_fe)')  ///
			  mgroups("Log($\text{TCB}$)" ///
					  "Log($\text{Loan Spread}$)" ///
					  "Log(Facility Fee)" ///
					  "Log(Upfront Fee)", ///
					  pattern(1 0 1 0 1 0 1 0) ///
			  prefix(\multicolumn{@span}{c}{) suffix(}) ///
			  span erepeat(\cmidrule(lr){@span})) ///
			  varlabels(, elist(credit_line \midrule)) ///
			  $tableoptions

est clear
