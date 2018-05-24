
source("code/prestige_tools.R")

################################################################################
# read raw data -----------------------------------------------------------
cds.raw <- data.table::fread("raw/cds_raw.csv")

cds.raw.sub <- cds.raw %>%
  select(ticker, date, spread5y, spread10y, recovery) %>%
  mutate(date = dmy(date)) %>%
  filter(ticker != "" & !is.na(ticker) & date <= "2009-12-31") %>%
  group_by(ticker, date) %>%
  summarize_all(funs(mean(., na.rm = TRUE))) %>%
  ungroup()

cds.dates <- cds.raw.sub %>% 
  distinct(date)

cds.ticker <- cds.raw.sub %>% 
  distinct(ticker) %>%
  filter(ticker != "")

################################################################################
# load clean data ---------------------------------------------------------
load("clean/dealscan.RData")
load("clean/dealscan_borrowers.RData")

dealscan.dates <- dealscan %>%
  distinct(bgvkey, facilitystartdate, facilityenddate) %>%
  filter(facilitystartdate >= min(cds.dates$date)) %>%
  na.omit()

borrower.tickers <- dealscan.borrowers %>%
  distinct(gvkey, ticker) %>% 
  na.omit()

dealscan.dates.cds <- dealscan.dates %>% 
  left_join(borrower.tickers %>%
              rename(bgvkey = gvkey), by = "bgvkey") %>%
  na.omit() %>%
  inner_join(cds.ticker, by = "ticker") %>%
  distinct()

cds.dealscan <- cds.raw.sub %>%
  inner_join(borrower.tickers %>% distinct(ticker), by = "ticker")

################################################################################
# compute cds data at different dates -------------------------------------
# cds spread at issuance
dealscan.cds.issuance <- dealscan.dates.cds %>%
  distinct(ticker, facilitystartdate) %>%
  left_join(cds.dealscan %>% 
              rename(facilitystartdate = date), 
            by = c("ticker", "facilitystartdate")) %>%
  group_by(ticker, facilitystartdate) %>%
  summarize_all(funs(mean(as.numeric(.), na.rm = T))) %>%
  rename_(.dots = setNames(names(.), paste0(names(.), "_start"))) %>%
  rename(ticker = ticker_start, facilitystartdate = facilitystartdate_start)

# cds spread at maturity
dealscan.cds.maturity <- dealscan.dates.cds %>%
  distinct(ticker, facilityenddate) %>%
  left_join(cds.dealscan %>% 
              rename(facilityenddate = date), 
            by = c("ticker", "facilityenddate")) %>%
  group_by(ticker, facilityenddate) %>%
  summarize_all(funs(mean(as.numeric(.), na.rm = T))) %>%
  rename_(.dots = setNames(names(.), paste0(names(.), "_end"))) %>%
  rename(ticker = ticker_end, facilityenddate = facilityenddate_end)

# average over maturity
dealscan.cds.average <- list()
for (j in 1:nrow(dealscan.dates.cds)) {
  tmp <- cds.dealscan %>% 
    filter(ticker == dealscan.dates.cds$ticker[j] &
             date >= dealscan.dates.cds$facilitystartdate[j] & 
             date >= dealscan.dates.cds$facilityenddate[j]) %>%
    select(-date) %>%
    group_by(ticker) %>%
    summarize_all(funs(mean(as.numeric(.), na.rm = T))) %>%
    rename_(.dots = setNames(names(.), paste0(names(.), "_avg"))) %>%
    rename(ticker = ticker_avg) %>%
    mutate(facilitystartdate = dealscan.dates.cds$facilitystartdate[j],
           facilityenddate = dealscan.dates.cds$facilityenddate[j])
  dealscan.cds.average[[j]] <- tmp
  rm(tmp)
  svMisc::progress(j, nrow(dealscan.dates.cds))
}
dealscan.cds.average <- data.table::rbindlist(dealscan.cds.average)

################################################################################
# combine individual cds samples ------------------------------------------
dealscan.cds <- dealscan.dates.cds %>%
  left_join(dealscan.cds.issuance, by = c("ticker", "facilitystartdate")) %>%
  left_join(dealscan.cds.maturity, by = c("ticker", "facilityenddate")) %>%
  left_join(dealscan.cds.average, by = c("ticker", "facilitystartdate", "facilityenddate")) %>%
  mutate(cds_change5y = spread5y_end - spread5y_start,
         cds_change10y = spread10y_end - spread10y_start) %>%
  select(bgvkey, facilitystartdate, facilityenddate, 
         spread5y_end, spread10y_end, 
         spread5y_avg, spread10y_avg,
         cds_change5y, cds_change10y,
         recovery_start, recovery_end, recovery_avg)

dealscan.cds[is.nan(dealscan.cds)] <- NA
dealscan.cds[is.infinite(dealscan.cds)] <- NA

################################################################################
# save cds data -----------------------------------------------------------
save(dealscan.cds, file = "clean/dealscan_borrowers_cds.RData")
