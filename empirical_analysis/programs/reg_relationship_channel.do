
* new bank relationship dummy
qui reghdfe log_tcb score new_bank_relation_alt new_relation_score ///
			$loanfeatures $borrowerchars, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model1
* old bank relationship dummy
qui reghdfe log_tcb score old_bank_relation_alt old_relation_score ///
			$loanfeatures $borrowerchars, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model2
* old bank relationship based on number of loans
qui reghdfe log_tcb score rel_number rel_number_score ///
			$loanfeatures $borrowerchars, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model3
* old bank relationship based on loan volume
qui reghdfe log_tcb score rel_amount rel_amount_score ///
			$loanfeatures $borrowerchars, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model4
* new bank relationship dummy
qui reghdfe log_upfront_fee score new_bank_relation_alt new_relation_score ///
			$loanfeatures $borrowerchars, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model5
* old bank relationship dummy
qui reghdfe log_upfront_fee score old_bank_relation_alt old_relation_score ///
			$loanfeatures $borrowerchars, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model6
* old bank relationship based on number of loans
qui reghdfe log_upfront_fee score rel_number rel_number_score ///
			$loanfeatures $borrowerchars, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model7
* old bank relationship based on loan volume
qui reghdfe log_upfront_fee score rel_amount rel_amount_score ///
			$loanfeatures $borrowerchars, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model8

cd $output
estfe . model*, labels($mainfelabels)
return list
esttab model* using tab_reg_relationship_channel.tex, ///
              indicate("Loan Features = $loanfeatures" ///
					   "Borrower Characteristics = $borrowerchars" ///
					   `r(indicate_fe)') ///
			  mgroups("Log(TCB)" ///
					  "Log(Upfront Fee)", ///
					  pattern(1 0 0 0 1 0 0 0) ///
					  prefix(\multicolumn{@span}{c}{) suffix(}) ///
					  span erepeat(\cmidrule(lr){@span})) ///
			  order(new_relation_score old_relation_score ///
					rel_number_score rel_amount_score score ///
					new_bank_relation_alt old_bank_relation_alt ///
					rel_number rel_amount) ///
			  varlabels(, elist(rel_amount \midrule)) ///
			  $tableoptions
			  
est clear
