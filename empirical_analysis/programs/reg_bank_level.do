
* loan volume
qui reghdfe logloanvolume logtop100loans_lag1, ///
					      a($bankfespec) vce(cluster $bankcluster)
est store model1
qui reghdfe logloanvolume logtop100loans_lag1 ///
						  $bankcontrols, ///
						  a($bankfespec) vce(cluster $bankcluster)
est store model2
* volume per deal
qui reghdfe logaverageloanvolume logtop100loans_lag1, ///
					   a($bankfespec) vce(cluster $bankcluster)
est store model3
qui reghdfe logaverageloanvolume logtop100loans_lag1 ///
					   $bankcontrols, /// 
					   a($bankfespec) vce(cluster $bankcluster)
est store model4
* number of loans
qui reghdfe logloannumber logtop100loans_lag1, ///
					  a($bankfespec) vce(cluster $bankcluster)
est store model5
qui reghdfe logloannumber logtop100loans_lag1 ///
					  $bankcontrols, /// 
					  a($bankfespec) vce(cluster $bankcluster)
est store model6
* number of unique borrowers
qui reghdfe loguniqueborrowers logtop100loans_lag1, ///
					   a($bankfespec) vce(cluster $bankcluster)
est store model7
qui reghdfe loguniqueborrowers logtop100loans_lag1 ///
					   $bankcontrols, /// 
					   a($bankfespec) vce(cluster $bankcluster)
est store model8

********************************************************************************

cd $output
estfe . model*, labels($bankfelabels)
return list
esttab model* using tab_reg_bank_level.tex, ///
	          indicate(`r(indicate_fe)') ///
			  mgroups("$\text{Log(Volume)}_{t}$" ///
					  "$\text{Log}\left(\frac{\text{Volume}}{\text{Loans}}\right)_{t}$" ///
					  "$\text{Log(Loans)}_{t}$" ///
					  "$\text{Log(Borrowers)}_{t}$", ///
					  pattern(1 0 1 0 1 0 1 0) ///
			  prefix(\multicolumn{@span}{c}{) suffix(}) ///
			  span erepeat(\cmidrule(lr){@span})) ///
			  varlabels(, elist(deposits \midrule)) ///
			  $tableoptions

est clear

********************************************************************************

* loan volume
qui reghdfe logloanvolume $lags, ///
					   a($bankfespec) vce(cluster $bankcluster)
est store model1
qui reghdfe logloanvolume $lags ///
					   $bankcontrols, /// 
					   a($bankfespec) vce(cluster $bankcluster)
est store model2
* volume per deal
qui reghdfe logaverageloanvolume $lags, ///
					   a($bankfespec) vce(cluster $bankcluster)
est store model3
qui reghdfe logaverageloanvolume $lags ///
					   $bankcontrols, /// 
					   a($bankfespec) vce(cluster $bankcluster)
est store model4
* number of loans
qui reghdfe logloannumber $lags, ///
					  a($bankfespec) vce(cluster $bankcluster)
est store model5
qui reghdfe logloannumber $lags ///
					  $bankcontrols, /// 
					  a($bankfespec) vce(cluster $bankcluster)
est store model6
* number of unique borrowers
qui reghdfe loguniqueborrowers $lags, ///
					   a($bankfespec) vce(cluster $bankcluster)
est store model7
qui reghdfe loguniqueborrowers $lags ///
					   $bankcontrols, /// 
					   a($bankfespec) vce(cluster $bankcluster)
est store model8

********************************************************************************

cd $output
estfe . model*, labels($bankfelabels)
return list
esttab model* using tab_reg_bank_level_lags.tex, ///
	          indicate(`r(indicate_fe)') ///
			  mgroups("$\text{Log(Volume)}_{t}$" ///
					  "$\text{Log}\left(\frac{\text{Volume}}{\text{Loans}}\right)_{t}$" ///
					  "$\text{Log(Loans)}_{t}$" ///
					  "$\text{Log(Borrowers)}_{t}$", ///
					  pattern(1 0 1 0 1 0 1 0) ///
			  prefix(\multicolumn{@span}{c}{) suffix(}) ///
			  span erepeat(\cmidrule(lr){@span})) ///
			  varlabels(, elist(deposits \midrule)) ///
			  $tableoptions

estimates clear

********************************************************************************

* loan volume
qui reghdfe logloanvolume logtop100loans_lag1, ///
					      a($bankfespec) vce(cluster $bankcluster)
est store model1
qui reghdfe logloanvolume logtop100loans_lag1 ///
						  $bankcontrols tier1, ///
						  a($bankfespec) vce(cluster $bankcluster)
est store model2
* volume per deal
qui reghdfe logaverageloanvolume logtop100loans_lag1, ///
					   a($bankfespec) vce(cluster $bankcluster)
est store model3
qui reghdfe logaverageloanvolume logtop100loans_lag1 ///
					   $bankcontrols tier1, /// 
					   a($bankfespec) vce(cluster $bankcluster)
est store model4
* number of loans
qui reghdfe logloannumber logtop100loans_lag1, ///
					  a($bankfespec) vce(cluster $bankcluster)
est store model5
qui reghdfe logloannumber logtop100loans_lag1 ///
					  $bankcontrols tier1, /// 
					  a($bankfespec) vce(cluster $bankcluster)
est store model6
* number of unique borrowers
qui reghdfe loguniqueborrowers logtop100loans_lag1, ///
					   a($bankfespec) vce(cluster $bankcluster)
est store model7
qui reghdfe loguniqueborrowers logtop100loans_lag1 ///
					   $bankcontrols tier1, /// 
					   a($bankfespec) vce(cluster $bankcluster)
est store model8

cd $output
estfe . model*, labels($bankfelabels)
return list
esttab model* using tab_reg_bank_level_appendix.tex, ///
	          indicate(`r(indicate_fe)') ///
			  mgroups("$\text{Log(Volume)}_{t}$" ///
					  "$\text{Log}\left(\frac{\text{Volume}}{\text{Loans}}\right)_{t}$" ///
					  "$\text{Log(Loans)}_{t}$" ///
					  "$\text{Log(Borrowers)}_{t}$", ///
					  pattern(1 0 1 0 1 0 1 0) ///
			  prefix(\multicolumn{@span}{c}{) suffix(}) ///
			  span erepeat(\cmidrule(lr){@span})) ///
			  varlabels(, elist(tier1 \midrule)) ///
			  $tableoptions

est clear

********************************************************************************

* loan volume
qui reghdfe logloanvolume $lags, ///
					   a($bankfespec) vce(cluster $bankcluster)
est store model1
qui reghdfe logloanvolume $lags ///
					   $bankcontrols tier1, /// 
					   a($bankfespec) vce(cluster $bankcluster)
est store model2
* volume per deal
qui reghdfe logaverageloanvolume $lags, ///
					   a($bankfespec) vce(cluster $bankcluster)
est store model3
qui reghdfe logaverageloanvolume $lags ///
					   $bankcontrols tier1, /// 
					   a($bankfespec) vce(cluster $bankcluster)
est store model4
* number of loans
qui reghdfe logloannumber $lags, ///
					  a($bankfespec) vce(cluster $bankcluster)
est store model5
qui reghdfe logloannumber $lags ///
					  $bankcontrols tier1, /// 
					  a($bankfespec) vce(cluster $bankcluster)
est store model6
* number of unique borrowers
qui reghdfe loguniqueborrowers $lags, ///
					   a($bankfespec) vce(cluster $bankcluster)
est store model7
qui reghdfe loguniqueborrowers $lags ///
					   $bankcontrols tier1, /// 
					   a($bankfespec) vce(cluster $bankcluster)
est store model8

cd $output
estfe . model*, labels($bankfelabels)
return list
esttab model* using tab_reg_bank_level_lags_appendix.tex, ///
	          indicate(`r(indicate_fe)') ///
			  mgroups("$\text{Log(Volume)}_{t}$" ///
					  "$\text{Log}\left(\frac{\text{Volume}}{\text{Loans}}\right)_{t}$" ///
					  "$\text{Log(Loans)}_{t}$" ///
					  "$\text{Log(Borrowers)}_{t}$", ///
					  pattern(1 0 1 0 1 0 1 0) ///
			  prefix(\multicolumn{@span}{c}{) suffix(}) ///
			  span erepeat(\cmidrule(lr){@span})) ///
			  varlabels(, elist(tier1 \midrule)) ///
			  $tableoptions

estimates clear
