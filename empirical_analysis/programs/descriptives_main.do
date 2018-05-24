
cd $output
gr drop _all

gen log_tcb = log(tcb)
gen log_spread = log(spread)
gen log_upfront_fee = log(upfront_fee)

* histogram of score
qui hist score, ///
	start(1.25) kdensity bin(20) percent ///
	xlabel(0(1)10) ylabel(0(3)14.5, grid) ///
	subtitle(Distribution of Firm Prestige) ///
	xtitle("Score") ///
	$graphoptions
gr export fig_histogram_score.eps, replace

* scatter plots against score
gr twoway (scatter log_tcb score, msymbol(O) msize(vsmall)) ///
		  (lfit log_tcb score, lwidth(vthick)), ///
					  title("Total Cost of Borrowing") ///
					  ytitle("Log(TCB)") ///
					  xtitle("Score") ///
					  xlabel(0(1)10) ///
					  scale(1.4) ///
					  $graphoptions
gr export fig_scatter_tcb.eps, replace

qui gr twoway (scatter log_spread score, msymbol(O) msize(vsmall)) ///
			  (lfit log_spread score, lwidth(vthick)), ///
					  title("Loan Spread") ///
					  ytitle("Log(Spread)") ///
					  xtitle("Score") ///	
					  xlabel(0(1)10) ///
					  scale(1.4) ///
					  $graphoptions
gr export fig_scatter_spread.eps, replace

qui gr twoway (scatter log_upfront_fee score, msymbol(O) msize(vsmall)) ///
			  (lfit log_upfront_fee score, lwidth(vthick)), ///
					  title("Upfront Fee") ///
					  ytitle("Log(Upfront Fee)") ///
					  xtitle("Score") ///
					  xlabel(0(1)10) ///
					  scale(1.4) ///
					  $graphoptions
gr export fig_scatter_uff.eps, replace

* prepare variable labels for summary statistics table
** prestige variables
label var score "Score [0-10]"
label var rank_top_100 "Top 100 [0/1]"

** loan characteristics
label var tcb "Total Cost of Borrowing [bps]"
label var aisd "AISD [bps]"
label var aisu "AISU [bps]"
label var spread "Spread [bps]"
label var upfront_fee "Upfront Fee [bps]"
label var commitment_fee "Commitment Fee [bps]"
label var facility_fee "Facility Fee [bps]"
gen facilityamt_scaled = facilityamt/1000000
label var facilityamt_scaled "Amount [USD mn.]"
label var maturity "Maturity [months]"
label var facility_no "Facility Number"
label var secured "Secured [0/1]"
label var fincovenant "Financial Covenants [0/1]"
label var baseprime "Prime Base Rate [0/1]"
label var performance "Performance Pricing [0/1]"
label var credit_line "Credit Line [0/1]"
label var term_loan "Term Loan [0/1]"
label var lenders_no "Number of Lenders"
label var lead_share "Lead Share [0-1]"
label var new_bank_relation "New Relation [0/1]"
label var old_bank_relation "Old Relation (Dummy) [0/1]"
label var rel_number "Old Relation (Number) [0-1]"
label var rel_amount "Old Relation (Amount) [0-1]"

** borrower characteristics
gen total_assets_scaled = total_assets/1000
label var total_assets_scaled "Total Assets [USD bn.]"
label var coverage "Coverage [number]"
label var leverage "Leverage [number]"
label var profitability "Profitability [number]"
label var tangibility "Tangibility [number]"
label var current_ratio "Current Ratio [number]"
label var mtb "Market-to-Book [number]"
label var investment_grade "Investment Grade [0/1]"
label var not_rated "Not Rated [0/1]"
label var rating_n_avg "Average Rating [1-15]"
label var recovery_avg "Average Recovery [number]"
label var spread5y_avg "Average CDS Spread [number]"

* export summary statistics
cd $output
qui estpost summarize score rank_top_100 ///
			tcb aisd aisu spread ///
			upfront_fee commitment_fee facility_fee ///
			facilityamt_scaled maturity facility_no ///
			secured fincovenant baseprime performance ///
			credit_line term_loan ///
			lenders_no lead_share ///
			new_bank_relation old_bank_relation rel_number rel_amount ///
			total_assets_scaled coverage leverage profitability tangibility ///
			current_ratio mtb investment_grade not_rated ///
			rating_n_avg recovery_avg spread5y_avg, ///
			detail
qui esttab using tab_descstats_main.tex, ///
	replace cells("count(fmt(%9.0fc)) mean(fmt(2)) sd(fmt(2)) p10(fmt(2)) p25(fmt(2)) p50(fmt(2)) p75(fmt(2)) p90(fmt(2))") ///
	booktabs noobs label compress nomtitle nonumber b(2) ///
	collabels("\textbf{N}" "\textbf{Mean}" "\textbf{SD}" "\textbf{P10}" ///
			  "\textbf{P25}" "\textbf{P50}" "\textbf{P75}" "\textbf{P90}") ///
	refcat(score "\textbf{Prestige Variables}" ///
		tcb "\textbf{Loan Characteristics}" ///
		total_assets_scaled "\textbf{Borrower Characteristics}", nolabel) ///
	substitute(\_ _) 

drop facilityamt_scaled total_assets_scaled log_tcb log_spread log_upfront_fee
