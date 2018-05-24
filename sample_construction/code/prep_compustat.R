
source("code/prestige_tools.R")

################################################################################
# read data ---------------------------------------------------------------
comp.firms <- data.table::fread("raw/comp_firms_funda_annual.csv", 
                    colClasses = list(character = 1: 981))

dealscan.firms <- read_csv("raw/dealscan_borrower_link.csv") %>%
  as_tibble() %>%
  distinct(gvkey)

comp.firms <- comp.firms %>% 
  inner_join(dealscan.firms, by = "gvkey")

################################################################################
# extract borrower characteristics ----------------------------------------
## keep only relevant items
comp.firms.sub <- comp.firms %>%
  as_tibble() %>%
  mutate(aco = as.numeric(aco),       # current assets
         at = as.numeric(at),         # total assets
         ceq = as.numeric(ceq),       # common equity total
         csho = as.numeric(csho),     # common shares outstanding
         datadate = ymd(datadate),    # date when information was released
         dlc = as.numeric(dlc),       # debt in current liabilities
         dltt = as.numeric(dltt),     # long-term debt total
         ebitda = as.numeric(ebitda), # earnings before interest
         fyear = as.integer(fyear),   # fiscal year
         fyr = as.integer(fyr),       # fiscal year-end
         lco = as.numeric(lco),       # current liabilities
         ppent = as.numeric(ppent),   # property, plant equipment total
         prcc_f = as.numeric(prcc_f), # closing price annual fiscal
         sale = as.numeric(sale),     # sales/turnover
         xint = as.numeric(xint)) %>% # interest and related expense total
  select(gvkey, ticker = tic, cusip, datadate, fyear, fyr, tic, sic, state, 
         aco, at, ceq, csho, dlc, dltt, ebitda, lco, ppent, prcc_f, sale, xint) %>%
  distinct() 

## construct borrower characteristics
dealscan.borrowers <- comp.firms.sub %>%
  mutate(total_assets = at,
         coverage = ebitda / xint,
         leverage = (dltt + dlc) / at,
         profitability = ebitda / sale,
         tangibility = ppent / at,
         current_ratio =  aco / lco,
         mtb = (at + csho * prcc_f - ceq) / at,
         industry = as.integer(substr(sic, 1, 1)),
         state = if_else(state == "", as.character(NA), state)) %>%
  select(gvkey, ticker, cusip, fyear, fyr, industry, state,
         total_assets, coverage, leverage, profitability, tangibility, 
         current_ratio, mtb) %>%
  filter(!is.na(gvkey) & !is.na(fyear) & !is.na(fyr))

## fix issue with multiple rows per date
dealscan.borrowers <- dealscan.borrowers %>%
  group_by(gvkey, fyear, fyr) %>%
  summarize(ticker = first(ticker),
            cusip = first(cusip),
            industry = first(industry),
            state = first(state),
            total_assets = mean(total_assets, na.rm = T),
            coverage = mean(coverage, na.rm = T),
            leverage = mean(leverage, na.rm = T),
            profitability = mean(profitability, na.rm = T),
            tangibility = mean(tangibility, na.rm = T),
            current_ratio = mean(current_ratio, na.rm = T),
            mtb = mean(mtb, na.rm = T)) %>%
  ungroup()

## adjust for fiscal year-end conventions
dealscan.borrowers <- dealscan.borrowers %>%
  mutate(fyear = if_else(fyr < 6, as.integer(fyear - 1), fyear)) %>%
  group_by(gvkey, fyear) %>%
  arrange(fyr) %>%
  summarize_all(funs(first(.))) %>%
  ungroup()

## replace all nans & infinites with NA
dealscan.borrowers[is.nan(dealscan.borrowers)] <- NA
dealscan.borrowers[is.infinite(dealscan.borrowers)] <- NA

## save data
save(dealscan.borrowers, file = "clean/dealscan_borrowers.RData")

################################################################################
# bank data ---------------------------------------------------------------
comp.banks <- read_csv("raw/comp_bank_funda_annual.csv",
                       col_types = cols(.default = "c"))
names(comp.banks) <- tolower(names(comp.banks))

comp.banks.sub <- comp.banks %>%
  mutate(at = as.numeric(at),       # total assets
         ceq = as.numeric(ceq),     # common equity
         csho = as.numeric(csho),   # shares outstanding
         capr1 = as.numeric(capr1), # risk-adjusted capital ratio - tier1
         dptc = as.numeric(dptc),   # total deposits
         lt = as.numeric(lt),       # total liabilities
         cusip = substr(cusip, 1, 8),
         fyear = as.integer(fyear),
         fyr = as.integer(fyr)) %>%
  select(gvkey, cusip, fyear, fyr, 
         at, ceq, csho, capr1, dptc, lt)

# now go to WRDS and get share prices from CRSP 
cusips <- comp.banks %>% distinct(cusip)
write.table(cusips, file = "raw/bank_cusips.txt", row.names = FALSE,
            quote = FALSE, col.names = FALSE)

# get share prices at fiscal year ends
crsp.banks <- read_csv("raw/crsp_banks.csv")
names(crsp.banks) <- tolower(names(crsp.banks))

prices <- crsp.banks %>%
  select(cusip, date, price = altprc) %>%
  mutate(date = ymd(date),
         price = abs(price),
         fyear = as.integer(year(date)), 
         fyr = month(date)) %>%
  select(-date) %>% 
  distinct()

banks <- comp.banks.sub %>%
  left_join(prices, by = c("cusip", "fyear", "fyr")) %>%
  mutate(total_assets = at,
         market_cap = csho * price,
         book_equity = ceq / at,
         market_equity = market_cap / (at - book_equity + market_cap),
         mtb = market_equity / book_equity,
         deposits = dptc / at,
         tier1 = capr1)  %>%
  select(gvkey, fyear, fyr, 
         total_assets, book_equity, market_equity,
         mtb, deposits, tier1)

## adjust for fiscal year-end conventions
banks <- banks %>%
  mutate(fyear = if_else(fyr < 6, as.integer(fyear - 1), fyear)) %>%
  group_by(gvkey, fyear) %>%
  arrange(fyr) %>%
  summarize_all(funs(first(.))) %>%
  ungroup()

## replace all nans & infinites with NA
banks[is.nan(banks)] <- NA
banks[is.infinite(banks)] <- NA

## save data
save(banks, file = "clean/dealscan_banks.RData")
