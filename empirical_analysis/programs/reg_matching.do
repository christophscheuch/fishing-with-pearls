********************************************************************************
* coarsened exact matching
********************************************************************************

preserve
keep if log_tcb != .

cd $output
imb $borrowerchars, tr(rank_top_100)
matrix define a = r(imbal)
outtable using "tab_imb_before", mat(a) replace label format(%9.3f) nobox
qui reghdfe log_tcb rank_top_100 $borrowerchars $loanfeatures, ///
		absorb($mainfespec) ///
		vce(cluster $mainclustervar)
est store model1
qui reghdfe rating_n_avg rank_top_100 $borrowerchars $loanfeatures, ///
		absorb($mainfespec) ///
		vce(cluster $mainclustervar)
est store model4

qui cem log_total_assets leverage, treatment(rank_top_100)
imb $borrowerchars if cem_matched == 1, tr(rank_top_100)
matrix define b = r(imbal)
outtable using "tab_imb_after_A", mat(b) replace label format(%9.3f) nobox

qui reghdfe log_tcb rank_top_100 $borrowerchars $loanfeatures [aweight = cem_weights], ///
		absorb($mainfespec) ///
		vce(cluster $mainclustervar)
est store model2
qui reghdfe rating_n_avg rank_top_100 $borrowerchars $loanfeatures [aweight = cem_weights], ///
		absorb($mainfespec) ///
		vce(cluster $mainclustervar)
est store model5

qui cem log_total_assets leverage mtb coverage, treatment(rank_top_100)
imb $borrowerchars if cem_matched == 1, tr(rank_top_100)
matrix define c = r(imbal)
outtable using "tab_imb_after_B", mat(c) replace label format(%9.3f) nobox

qui reghdfe log_tcb rank_top_100 $borrowerchars $loanfeatures [aweight = cem_weights], ///
		absorb($mainfespec) ///
		vce(cluster $mainclustervar)
est store model3
qui reghdfe rating_n_avg rank_top_100 $borrowerchars $loanfeatures [aweight = cem_weights], ///
		absorb($mainfespec) ///
		vce(cluster $mainclustervar)
est store model6

cd $output
estfe . model*, labels($mainfelabels)
return list
esttab model1 model2 model3 model4 model5 model6 using tab_reg_matching_cem.tex, ///
	          indicate("Borrower Characteristics = $borrowerchars" ///
					   "Loan Features = $loanfeatures" ///
					   `r(indicate_fe)') ///
			  mgroups("Log($\text{TCB}$)" ///
					  "$\overline{\text{Rating}}$", ///
					  pattern(1 0 0 1 0 0) ///
			  prefix(\multicolumn{@span}{c}{) suffix(}) ///
			  span erepeat(\cmidrule(lr){@span})) ///
			  varlabels(, elist(rank_top_100 \midrule)) ///
			  $tableoptions
est clear
restore

********************************************************************************
* nearest neighbor & propensity score matching
********************************************************************************

preserve
keep if log_tcb != .

* nearest neighbor matching  
** note: includes bias-adjustment for all continuous variables
qui teffects nnmatch (log_tcb $borrowerchars) (rank_top_100), ///
			 nneighbor(1) atet biasadj($borrowerchars)
est store model1
cap teffects nnmatch (log_tcb $loanfeatures $borrowerchars) (rank_top_100), ///
			 nneighbor(1) atet biasadj($borrowerchars log_facilityamt log_maturity) ///
			 ematch(secured fincovenant baseprime performance) osample(nn_1_violation)
qui teffects nnmatch (log_tcb $loanfeatures $borrowerchars) (rank_top_100) if nn_1_violation == 0, ///
			 nneighbor(1) atet biasadj($borrowerchars log_facilityamt log_maturity) ///
			 ematch(secured fincovenant baseprime performance) 
est store model2
qui teffects nnmatch (log_tcb $borrowerchars) (rank_top_100), ///
			 nneighbor(10) atet biasadj($borrowerchars)
est store model3
cap teffects nnmatch (log_tcb $loanfeatures $borrowerchars) (rank_top_100), ///
			 nneighbor(10) atet biasadj($borrowerchars log_facilityamt log_maturity) ///
			 ematch(secured fincovenant baseprime performance) osample(nn_10_violation)
cap teffects nnmatch (log_tcb $loanfeatures $borrowerchars) (rank_top_100) if nn_10_violation == 0, ///
			 nneighbor(10) atet biasadj($borrowerchars log_facilityamt log_maturity) ///
			 ematch(secured fincovenant baseprime performance) osample(nn_10_violation2)
qui teffects nnmatch (log_tcb $loanfeatures $borrowerchars) (rank_top_100) if nn_10_violation == 0 & nn_10_violation2 == 0, ///
			 nneighbor(10) atet biasadj($borrowerchars log_facilityamt log_maturity) ///
			 ematch(secured fincovenant baseprime performance)
est store model4

cd $output
esttab model* using tab_reg_matching_A.tex, ///
					star(* 0.10 ** 0.05 *** 0.01) ///
					mgroups("Log(TCB)", ///
					pattern(1 0 0 0) ///
					prefix(\multicolumn{@span}{c}{) suffix(}) ///
					span erepeat(\cmidrule(lr){@span})) ///
					label compress booktabs replace nonotes mlabels(none)
est clear

* propensity score matching
qui teffects psmatch (log_tcb) (rank_top_100 $borrowerchars, probit), ///
			 nneighbor(1) atet vce(iid)
est store model1
qui teffects psmatch (log_tcb) (rank_top_100 $loanfeatures $borrowerchars, probit), ///
			 nneighbor(1) atet vce(iid)
est store model2
qui teffects psmatch (log_tcb) (rank_top_100 $borrowerchars, probit), ///
			 nneighbor(10) atet vce(iid)
est store model3
qui teffects psmatch (log_tcb) (rank_top_100 $loanfeatures $borrowerchars, probit), ///
			 nneighbor(10) atet vce(iid)
est store model4

cd $output
esttab model* using tab_reg_matching_B.tex, ///
					star(* 0.10 ** 0.05 *** 0.01) ///
					mgroups("Log(TCB)", ///
					pattern(1 0 0 0) ///
					prefix(\multicolumn{@span}{c}{) suffix(}) ///
					span erepeat(\cmidrule(lr){@span})) ///
					label compress booktabs replace nonotes mlabels(none)
est clear
restore
