# Fishing with Pearls: The Value of Lending Relationships with Prestigious Companies

This repository replicates the results of [Muermann, Rauter & Scheuch (2017)](https://ssrn.com/abstract=2703343) and consists of the following two parts:

1. The sample construction implemented in R. The code cleans raw data from various sources and constructs the loan-level, deal-level and bank-level samples used in the empirical analysis. Below we provide information on the raw data used to construct the samples.
2. The empirical analysis implemented in Stata. The code reads the samples and implements all tests described in the paper. The results are exported to latex tables. Below we provide information on the modules that are necessary to 

Note that variable labels in the code might differ from the labels actually used in the paper. We refer to [Muermann, Rauter & Scheuch (2017)](https://ssrn.com/abstract=2703343) and the code for details on reasoning and implementation.

## Sample Construction

The sample construction is implemented in the open source statistical computing language [R](https://www.r-project.org/). To construct the samples used in the empirical analysis, you need the following CSV files in the `sample_construction/raw` folder.

* Dealscan
	- `dealscan_facility.csv`: facility-level information from WRDS.
	- `dealscan_package.csv`: package-level information from WRDS.
	- `dealscan_currfacpricing.csv`: current facility pricing schedule from WRDS.
	- `dealscan_lendershares.csv`: lender information from WRDS.
	- `dealscan_financialcovenant.csv`: information about financial covenants from WRDS (can only be accessed via [direct connection to the WRDS cloud](https://github.com/ckscheuch/rWRDS)).
	- `dealscan_performancepricing.csv`: performance pricing schedule from WRDS (can only be accessed via [direct connection to the WRDS cloud](https://github.com/ckscheuch/rWRDS)).
	- `dealscan_borrower_link.csv`: [Michael Robert's](http://finance.wharton.upenn.edu/~mrrobert/styled-9/styled-12/index.html) borrower linking table available on his homepage or via WRDS.
	- `dealscan_lender_link.csv`: [Michael Schwert's](https://sites.google.com/site/mwschwert/) lender linking table available on his homepage in XLSX format.
	- `dealscan_tcb.csv`: the total cost of borrowing measure developed by Tobias Berg, Anthony Saunders and Sascha Steffen. Available on [Tobias Berg's](http://www.tobias-berg.com/) homepage in DTA format.
* Compustat North America
	- `comp_firms_funda_annual.csv`: annual firm fundamentals.
	- `comp_bank_funda_annual.csv`: annual bank fundamentals.
	- `compm_adsprate.csv`: S&P ratings.
* CRSP
	- `crsp_banks.csv`: end of fiscal-year stock prices for Compustat bank fundamentals need to be retrieved from CRSP. The file `prep_compustat.R` therefore exports a list of bank CUSIPs (`bank_cusips.txt`) which can be used to extract the relevant data from WRDS because the whole CRSP data is simply too large.
* Markit
	- `cds_raw.csv`: daily CDS spreads (incl. ticker, date, 5-year spread, 10-year spread and recovery). Note that the full sample has more than 15 GB.
* Fortune's Most Admired Companies Survey
	- `prestige.csv`: manually-collected data on firm-level prestige. The data will be available online once the paper is published.

To construct the samples, first run `prep_dealscan.R`, then all other preparation files (order does not matter) and lastly `prep_samples.R`. Then transfer the output from `sample_construction/samples` to `empirical_analysis/samples`.
	
## Empirical Analysis

The empirical analysis is implemented in the statistical software [Stata](https://www.stata.com/). To replicate the results, run `_prestige_main.do` which calls all other DO-files in the appropriate order. Make sure the following modules are installed:

* [`cem`](https://gking.harvard.edu/cem): coarsened exact matching algorithm.
* [`estout`](http://repec.org/bocode/e/estout/installation.html): module to make regression tables.
* [`reghdfe`](http://scorreia.com/software/reghdfe/): module to efficiently estimate models with many levels of fixed effects.
* [`rdrobust`](https://sites.google.com/site/rdpackages/rdrobust): module for statistical inference and graphical procedures for regression discontinuity designs employing local polynomial and partitioning methods.
* [`outtable`](http://fmwww.bc.edu/RePEc/bocode/o/outtable.html): module to write matrices to LaTeX tables.
* [`winsor2`](http://www.haghish.com/statistics/stata-blog/stata-programming/download/winsor2.html): module to winsorize or trim data.
 
 All output tables are exported as TEX-files to `empirical_analysis/output`. 
