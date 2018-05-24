
* create logged variables
foreach var in facilityamt maturity tcb aisd aisu spread facility_fee upfront_fee commitment_fee utilization_fee cancellation_fee total_assets {
	gen log_`var' = log(`var')
}

replace lead_share = lead_share*100

* prepare variable labels for regression table latex output
label var score "$\text{Score}_{t-1}$"
label var rank_top_100 "$\text{Top 100}_{t-1}$"
label var log_facilityamt "$\text{Log(Amount)}_{t}$"
label var facility_no "$\text{Facility Number}_{t}$"
label var log_maturity "$\text{Log(Maturity)}_{t}$"
label var secured "$\text{Secured}_{t}$"
label var fincovenant "$\text{Financial Covenants}_{t}$"
label var baseprime "$\text{Prime Base Rate}_{t}$"
label var performance "$\text{Performance Pricing}_{t}$"
label var new_bank_relation_alt "New Relationship"
label var old_bank_relation_alt "Relationship Dummy"
label var rel_number "Relationship Number"
label var rel_amount "Relationship Amount"

label var log_total_assets "$\text{Log(Total Assets)}_{t-1}$"
label var coverage "$\text{Coverage}_{t-1}$"
label var leverage "$\text{Leverage}_{t-1}$"
label var profitability "$\text{Profitability}_{t-1}$"
label var tangibility "$\text{Tangibility}_{t-1}$"
label var current_ratio "$\text{Current Ratio}_{t-1}$"
label var mtb "$\text{Market-to-Book}_{t-1}$"

label var lenders_no "Lenders Number"
label var lead_share "Lead Share"
label var log_tcb "Log(TCB)"
label var log_spread "Log(Spread)"
label var lgvkey "Firm"
label var state "State"
label var industry "Industry"
label var lenderid "Bank"
label var credit_line "Credit Line"
label var term_loan "Term Loan"

* create interaction terms
gen score_cl = score*credit_line
lab var score_cl "Score * Credit Line"

gen new_relation_score = new_bank_relation_alt*score
label var new_relation_score "Score * New Relationship"
gen old_relation_score = old_bank_relation_alt*score
label var old_relation_score "Score * Relationship Dummy"
gen rel_number_score = rel_number*score
label var rel_number_score "Score * Relationship Number"
gen rel_amount_score = rel_amount*score
label var rel_amount_score "Score * Relationship Amount"

gen new_relation_top100 = new_bank_relation_alt*rank_top_100
label var new_relation_top100 "Top 100 * New Relationship"
gen old_relation_top100 = old_bank_relation_alt*rank_top_100
label var old_relation_top100 "Top 100 * Relationship Dummy"
gen rel_number_top100 = rel_number*rank_top_100
label var rel_number_top100 "Top 100 * Relationship Number"
gen rel_amount_top100 = rel_amount*rank_top_100
label var rel_amount_top100 "Top 100 * Relationship Amount"

gen lenders_no_score = lenders_no * score
label var lenders_no_score "Score * Lenders Number"
gen lead_share_score = lead_share * score
label var lead_share_score "Score * Lead Share"

* generate additional FE groups
egen industry_year = group(industry year)
egen bank_year = group(lenderid year)
egen type_year = group(loantype_no year)
egen purpose_year = group(loanpurpose_no year)
