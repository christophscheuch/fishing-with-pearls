
gen loanvolume_scaled = loanvolume/1000000000
gen averageloanvolume_scaled = averageloanvolume/1000000
gen total_assets_scaled = total_assets/1000

label var loanvolume_scaled "Loan Volume [USD bn.]"
label var loannumber "Loan Number"
label var averageloanvolume_scaled "Average Loan Volume [USD mn.]"
label var uniqueborrowers "Unique Borrowers [number]"
label var top100loans "Top 100 Loans [number]"
label var total_assets_scaled "Total Assets [USD bn.]"
label var mtb "Market-to-Book [number]"
label var deposits "Deposits/Assets [number]"
label var tier1 "Tier 1 Ratio [0-100]"

* export summary statistics
cd $output
qui estpost summarize loanvolume_scaled loannumber averageloanvolume_scaled uniqueborrowers ///
					  top100loans total_assets_scaled mtb deposits tier1, detail
qui esttab using tab_descstats_bank.tex, replace cells("count(fmt(%9.0fc)) mean(fmt(2)) sd(fmt(2)) p10(fmt(2)) p25(fmt(2)) p50(fmt(2)) p75(fmt(2)) p90(fmt(2))") ///
	booktabs noobs label compress nomtitle nonumber b(2) ///
	collabels("\textbf{N}" "\textbf{Mean}" "\textbf{SD}" "\textbf{P10}" ///
			  "\textbf{P25}" "\textbf{P50}" "\textbf{P75}" "\textbf{P90}") ///
	substitute(\_ _) 
	
drop loanvolume_scaled averageloanvolume_scaled total_assets_scaled
