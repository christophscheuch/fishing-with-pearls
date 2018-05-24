
preserve
drop if rank_score < 80
drop if rank_score > 120
gen rank_relative = (rank_score - 100)
drop if month < 4

********************************************************************************
* make rdd plots
********************************************************************************

cd $output
global rddgraphoptions "ci(90) nbins(10) kernel(triangular)"
graph drop _all
qui rdplot log_tcb rank_relative, $rddgraphoptions ///
		graph_options(title("Log(TCB)") ///
					  ytitle("Log(TCB)") ///
					  xtitle("Rank relative to 100") ///
					  $graphoptions name(logtcb))
gr export fig_rdd_tcb.eps, replace
qui rdplot rating_n_avg rank_relative, $rddgraphoptions ///
		graph_options(title("Average Rating") ///
					  ytitle("Average Rating") ///
					  xtitle("Rank relative to 100") ///
					  $graphoptions name(ratingavg))
gr export fig_rdd_rating.eps, replace
gr combine logtcb ratingavg, ///
		cols(1) graphregion(color(white)) scheme(s1mono)
gr export fig_rdd.eps, replace

eststo: regress log_tcb $rddcovariates
predict log_tcb_residual, residual
eststo: regress rating_n_avg $rddcovariates
predict rating_n_avg_residual, residual

graph drop _all
qui rdplot log_tcb_residual rank_relative, $rddgraphoptions ///
		graph_options(title("Log(TCB) - Residual") ///
					  ytitle("Log(TCB)") ///
					  xtitle("Rank relative to 100") ///
					  $graphoptions name(logtcb))
gr export fig_rdd_tcb_residual.eps, replace
qui rdplot rating_n_avg_residual rank_relative, $rddgraphoptions ///
		graph_options(title("Average Rating - Residual") ///
					  ytitle("Average Rating") ///
					  xtitle("Rank relative to 100") ///
					  $graphoptions name(ratingavg))						  
gr export fig_rdd_rating_residual.eps, replace
gr combine logtcb ratingavg, ///
		cols(1) graphregion(color(white)) scheme(s1mono)
gr export fig_rdd_residual.eps, replace

********************************************************************************
* run rdd regressions
********************************************************************************

replace rank_relative = -rank_relative
encode bgvkey, generate(bgvkey_enc)

qui rdrobust log_tcb rank_relative, p(1) kernel(triangular) all
est store model1
qui rdrobust log_tcb rank_relative, p(1) kernel(triangular) all ///
			 covs($rddcovariates)
est store model2
qui rdrobust rating_n_avg rank_relative, p(1) kernel(triangular) all
est store model3
qui rdrobust rating_n_avg rank_relative, p(1) kernel(triangular) all ///
		     covs($rddcovariates)
est store model4

cd $output
esttab model* using tab_reg_rdd_A.tex, ///
					star(* 0.10 ** 0.05 *** 0.01) ///
					mgroups("Log(TCB)" "$\overline{\text{Rating}}$", ///
					pattern(1 0 1 0) ///
					prefix(\multicolumn{@span}{c}{) suffix(}) ///
					span erepeat(\cmidrule(lr){@span})) ///
					label compress booktabs replace nonotes mlabels(none)
est clear
restore

********************************************************************************
* placebo rdd
********************************************************************************

preserve
drop if rank_score < 130
drop if rank_score > 170
drop if month < 4
gen rank_relative = (rank_score - 150) / 150

replace rank_relative = -rank_relative

qui rdrobust log_tcb rank_relative, p(1) kernel(triangular) all
est store model1
qui rdrobust log_tcb rank_relative, p(1) kernel(triangular) all ///
			 covs($rddcovariates)
est store model2
qui rdrobust rating_n_avg rank_relative, p(1) kernel(triangular) all
est store model3
qui rdrobust rating_n_avg rank_relative, p(1) kernel(triangular) all ///
		     covs($rddcovariates)
est store model4

cd $output
esttab model* using tab_reg_rdd_B.tex, ///
					star(* 0.10 ** 0.05 *** 0.01) ///
					mgroups("Log(TCB)" "$\overline{\text{Rating}}$", ///
					pattern(1 0 1 0) ///
					prefix(\multicolumn{@span}{c}{) suffix(}) ///
					span erepeat(\cmidrule(lr){@span})) ///
					label compress booktabs replace nonotes mlabels(none)
est clear
restore
