
* number of lenders
qui reghdfe lenders_no score lead_share, ///
			absorb(rating) ///
			vce(cluster $mainclustervar)
est store model1
qui reghdfe lenders_no score lead_share ///
			$loanfeatures $borrowerchars, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model2
* lead share
qui reghdfe lead_share score lenders_no, ///
			absorb(rating) ///
			vce(cluster $mainclustervar)
est store model3
qui reghdfe lead_share score lenders_no ///
			$loanfeatures $borrowerchars, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model4
* total cost of borrowing
qui reghdfe log_tcb score lenders_no lenders_no_score, ///
			absorb(rating) ///
			vce(cluster $mainclustervar)
est store model5
qui reghdfe log_tcb score lenders_no lenders_no_score ///
			$loanfeatures $borrowerchars, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model6
qui reghdfe log_tcb score lead_share lead_share_score, ///
			absorb(rating) ///
			vce(cluster $mainclustervar)
est store model7
qui reghdfe log_tcb score lead_share lead_share_score ///
			$loanfeatures $borrowerchars, ///
			absorb($mainfespec) ///
			vce(cluster $mainclustervar)
est store model8

cd $output
estfe . model*, labels($mainfelabels)
return list
esttab model* using tab_reg_competition_channel.tex, ///
              indicate("Loan Features = $loanfeatures" ///
			  "Borrower Characteristics = $borrowerchars" ///
			  `r(indicate_fe)') ///
			  mgroups("Number of Lenders" ///
					  "Lead Share" ///
					  "Log(TCB)", ///
					  pattern(1 0 1 0 1 0 0 0) ///
			  prefix(\multicolumn{@span}{c}{) suffix(}) ///
			  span erepeat(\cmidrule(lr){@span})) ///
			  order(score lenders_no_score lenders_no) ///
			  varlabels(, elist(lead_share_score \midrule)) ///
			  $tableoptions
			  
est clear
