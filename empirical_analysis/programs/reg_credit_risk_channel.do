
* average rating over loan maturity
qui reghdfe rating_n_avg score $loanfeatures $borrowerchars, ///
						a($mainfespec) vce(cluster $mainclustervar)
est store model1
qui reghdfe rating_n_avg score log_spread $loanfeatures $borrowerchars, ///
						a($mainfespec) vce(cluster $mainclustervar)
est store model2
* average recovery over loan maturity
qui reghdfe recovery_avg score $loanfeatures $borrowerchars, ///
						a($mainfespec) vce(cluster $mainclustervar)
est store model3
qui reghdfe recovery_avg score log_spread $loanfeatures $borrowerchars, ///
						a($mainfespec) vce(cluster $mainclustervar)
est store model4
* average cds spread over loan maturity
qui reghdfe spread5y_avg score $loanfeatures $borrowerchars, ///
						a($mainfespec) vce(cluster $mainclustervar)
est store model5
qui reghdfe spread5y_avg score log_spread $loanfeatures $borrowerchars, ///
						a($mainfespec) vce(cluster $mainclustervar)
est store model6

cd $output
estfe . model*, labels($mainfelabels)
return list
esttab model* using tab_reg_default_risk_channel.tex, ///
              indicate("Loan Features = $loanfeatures" ///
			  "Borrower Characteristics = $borrowerchars" ///
			  `r(indicate_fe)') ///
			  mgroups("$\overline{\text{Rating}}$" ///
					  "$\overline{\text{Recovery}}$" ///
					  "$\overline{\text{CDS Spread}}$", ///
					  pattern(1 0 1 0 1 0) ///
			  prefix(\multicolumn{@span}{c}{) suffix(}) ///
			  span erepeat(\cmidrule(lr){@span})) ///
			  varlabels(, elist(log_spread \midrule)) ///
			  $tableoptions
			  
est clear

********************************************************************************

* rating at maturity
qui reghdfe rating_maturity score $loanfeatures $borrowerchars, ///
						a($mainfespec) vce(cluster $mainclustervar)
est store model1
qui reghdfe rating_maturity score log_spread $loanfeatures $borrowerchars, ///
						a($mainfespec) vce(cluster $mainclustervar)
est store model2
* average recovery at maturity
qui reghdfe recovery_end score $loanfeatures $borrowerchars, ///
						a($mainfespec) vce(cluster $mainclustervar)
est store model3
qui reghdfe recovery_end score log_spread $loanfeatures $borrowerchars, ///
						a($mainfespec) vce(cluster $mainclustervar)
est store model4
* average cds spread at maturity
qui reghdfe spread5y_end score $loanfeatures $borrowerchars, ///
						a($mainfespec) vce(cluster $mainclustervar)
est store model5
qui reghdfe spread5y_end score log_spread $loanfeatures $borrowerchars, ///
						a($mainfespec) vce(cluster $mainclustervar)
est store model6

cd $output
estfe . model*, labels($mainfelabels)
return list
esttab model* using tab_reg_default_risk_channel_maturity.tex, ///
              indicate("Loan Features = $loanfeatures" ///
			  "Borrower Characteristics = $borrowerchars" ///
			  `r(indicate_fe)') ///
			  mgroups("$\text{Rating}_m$" ///
					  "$\text{Recovery}_m$" ///
					  "$\text{CDS Spread}_m$", ///
					  pattern(1 0 1 0 1 0) ///
			  prefix(\multicolumn{@span}{c}{) suffix(}) ///
			  span erepeat(\cmidrule(lr){@span})) ///
			  varlabels(, elist(log_spread \midrule)) ///
			  $tableoptions
			  
est clear

********************************************************************************

* rating change
qui reghdfe rating_change score $loanfeatures $borrowerchars, ///
						a($mainfespec) vce(cluster $mainclustervar)
est store model1
qui reghdfe rating_change score log_spread $loanfeatures $borrowerchars, ///
						a($mainfespec) vce(cluster $mainclustervar)
est store model2
* change in recovery
qui reghdfe recovery_change score $loanfeatures $borrowerchars, ///
						a($mainfespec) vce(cluster $mainclustervar)
est store model3
qui reghdfe recovery_change score log_spread $loanfeatures $borrowerchars, ///
						a($mainfespec) vce(cluster $mainclustervar)
est store model4
* change in cds spread
qui reghdfe cds_change5y score $loanfeatures $borrowerchars, ///
						a($mainfespec) vce(cluster $mainclustervar)
est store model5
qui reghdfe cds_change5y score log_spread $loanfeatures $borrowerchars, ///
						a($mainfespec) vce(cluster $mainclustervar)
est store model6

cd $output
estfe . model*, labels($mainfelabels)
return list
esttab model* using tab_reg_default_risk_channel_change.tex, ///
              indicate("Loan Features = $loanfeatures" ///
			  "Borrower Characteristics = $borrowerchars" ///
			  `r(indicate_fe)') ///
			  mgroups("$\Delta\text{Rating}$" ///
					  "$\Delta\text{Recovery}$" ///
					  "$\Delta\text{CDS Spread}$", ///
					  pattern(1 0 1 0 1 0) ///
			  prefix(\multicolumn{@span}{c}{) suffix(}) ///
			  span erepeat(\cmidrule(lr){@span})) ///
			  varlabels(, elist(log_spread \midrule)) ///
			  $tableoptions
			  
est clear
