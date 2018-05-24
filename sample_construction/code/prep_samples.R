source("code/prestige_tools.R")

################################################################################
# load prepared sampels ---------------------------------------------------
load("clean/dealscan.RData")
load("clean/dealscan_borrowers.RData")
load("clean/dealscan_borrowers_ratings.RData")
load("clean/dealscan_borrowers_cds.RData")
load("clean/prestige.RData")
load("clean/dealscan_banks.RData")

################################################################################
# combine clean data ------------------------------------------------------
  sample <- dealscan %>%
  mutate(year = year(facilitystartdate),
         month = month(facilitystartdate)) %>%
  left_join(dealscan.borrowers %>% 
              mutate(fyear = fyear + 1) %>%
              rename(bgvkey = gvkey,
                     year = fyear), 
            by = c("bgvkey", "year")) %>%
  left_join(prestige %>%
              rename(bgvkey = gvkey) %>%
              mutate(year = year + 1), 
            by = c("bgvkey", "year")) %>%
  mutate(rank_top_100 = if_else(is.na(rank_top_100), 
                                    as.integer(0), rank_top_100)) %>%
  left_join(ratings.issuance %>%
              rename(rating = splticrm_l1_no_new), 
            by = c("bgvkey", "facilitystartdate")) %>%
  left_join(ratings.maturity,  by = c("bgvkey", "facilityenddate")) %>%
  mutate(rating_change = rating_maturity - rating_issuance) %>%
  left_join(ratings.average, 
            by = c("bgvkey", "facilitystartdate", "facilityenddate")) %>%
  mutate(investment_grade = if_else(rating_issuance < 9, 1, 0),
         not_rated = if_else(is.na(rating_issuance), 1, 0)) %>%
  left_join(dealscan.cds, 
            by = c("bgvkey", "facilitystartdate", "facilityenddate")) %>%
  mutate(recovery_change = recovery_end - recovery_start)

sample[is.infinite(sample)] <- NA
sample[is.nan(sample)] <- NA  

################################################################################
# filter out relevant facilities ------------------------------------------
main.sample <- sample %>%
  filter(year >= 1982 & year <= 2009) %>%
  filter(!is.na(bgvkey) & 
           !is.na(total_assets) & !is.na(mtb) & !is.na(coverage) &
           !is.na(leverage) & !is.na(profitability) & !is.na(tangibility) &
           !is.na(current_ratio) & !is.na(facilityamt) & !is.na(maturity)) %>%
  filter(total_assets > 0 & facilityamt > 0 & maturity > 0)

################################################################################
# collapse facilities to deal level ---------------------------------------
main.sample.deals <- main.sample %>%
  group_by(packageid) %>%
  arrange(-facilityamt) %>%
  summarize_all(funs(first(.)))

################################################################################
# construct bank level sample ---------------------------------------------
main.sample.deals.bank <- main.sample.deals %>%
  filter(!is.na(lgvkey)) %>%
  mutate(lgvkey = as.numeric(lgvkey))

# first top 100 loan 
first.top100 <- main.sample.deals.bank %>%
  group_by(lgvkey, year) %>%
  summarize(top100loans = sum(rank_top_100 == 1)) %>%
  filter(top100loans > 0) %>%
  arrange(year) %>%
  filter(row_number() == 1) %>%
  mutate(top100_first = 1) %>%
  select(lgvkey, year, top100_first)

# construct lagged lending variables
top100loans1 <- main.sample.deals.bank %>%
  mutate(year = year + 1) %>%
  group_by(lgvkey, year) %>%
  summarize(top100loans_lag1 = sum(rank_top_100 == 1)) %>%
  mutate(logtop100loans_lag1 = log(1 + top100loans_lag1))

top100loans2 <- main.sample.deals.bank %>%
  mutate(year = year + 2) %>%
  group_by(lgvkey, year) %>%
  summarize(top100loans_lag2 = sum(rank_top_100 == 1)) %>%
  mutate(logtop100loans_lag2 = log(1 + top100loans_lag2))

top100loans3 <- main.sample.deals.bank %>%
  mutate(year = year + 3) %>%
  group_by(lgvkey, year) %>%
  summarize(top100loans_lag3 = sum(rank_top_100 == 1)) %>%
  mutate(logtop100loans_lag3 = log(1 + top100loans_lag3))

top100loans4 <- main.sample.deals.bank %>%
  mutate(year = year + 4) %>%
  group_by(lgvkey, year) %>%
  summarize(top100loans_lag4 = sum(rank_top_100 == 1)) %>%
  mutate(logtop100loans_lag4 = log(1 + top100loans_lag4))

top100loans5 <- main.sample.deals.bank %>%
  mutate(year = year + 5) %>%
  group_by(lgvkey, year) %>%
  summarize(top100loans_lag5 = sum(rank_top_100 == 1)) %>%
  mutate(logtop100loans_lag5 = log(1 + top100loans_lag5))

bank.sample <- main.sample.deals.bank %>%
  group_by(lgvkey, year) %>%
  summarize(loanvolume = sum(facilityamt),
            loannumber = n(),
            uniqueborrowers = n_distinct(borrowercompanyid),
            top100loans =  sum(rank_top_100 == 1)) %>%
  ungroup() %>%
  mutate(logloanvolume = log(loanvolume),
         averageloanvolume = loanvolume/loannumber,
         logaverageloanvolume = log(averageloanvolume),
         logloannumber = log(loannumber),
         loguniqueborrowers = log(uniqueborrowers),
         logtop100loans = log(1 + top100loans)) %>%
  full_join(top100loans1, by = c("lgvkey", "year")) %>%
  mutate(top100loans_lag1 = if_else(is.na(top100loans_lag1), as.integer(0), top100loans_lag1),
         logtop100loans_lag1 = if_else(is.na(logtop100loans_lag1), 0, logtop100loans_lag1)) %>%
  full_join(top100loans2, by = c("lgvkey", "year")) %>%
  mutate(top100loans_lag2 = if_else(is.na(top100loans_lag2), as.integer(0), top100loans_lag2),
         logtop100loans_lag2 = if_else(is.na(logtop100loans_lag2), 0, logtop100loans_lag2)) %>%
  full_join(top100loans3, by = c("lgvkey", "year")) %>%
  mutate(top100loans_lag3 = if_else(is.na(top100loans_lag3), as.integer(0), top100loans_lag3),
         logtop100loans_lag3 = if_else(is.na(logtop100loans_lag3), 0, logtop100loans_lag3)) %>%
  full_join(top100loans4, by = c("lgvkey", "year")) %>%
  mutate(top100loans_lag4 = if_else(is.na(top100loans_lag4), as.integer(0), top100loans_lag4),
         logtop100loans_lag4 = if_else(is.na(logtop100loans_lag4), 0, logtop100loans_lag4)) %>%
  full_join(top100loans5, by = c("lgvkey", "year")) %>%
  mutate(top100loans_lag5 = if_else(is.na(top100loans_lag5), as.integer(0), top100loans_lag5),
         logtop100loans_lag5 = if_else(is.na(logtop100loans_lag5), 0, logtop100loans_lag5)) %>%
  full_join(first.top100, by = c("lgvkey", "year")) %>%
  mutate(top100_first = if_else(is.na(top100_first), 0, top100_first)) %>%
  left_join(banks %>% 
              rename(lgvkey = gvkey,
                     year = fyear) %>%
              mutate(lgvkey = as.numeric(lgvkey),
                     year = year + 1), 
            by = c("lgvkey", "year")) %>%
  mutate(logtotalassets = log(total_assets),
         lgvkey = as.character(lgvkey)) %>%
  filter(!is.na(logloannumber))

bank.sample[is.infinite(bank.sample)] <- NA
bank.sample[is.nan(bank.sample)] <- NA  

################################################################################
# save to samples folder --------------------------------------------------
write_dta(main.sample, 
          "samples/prestige_main_sample.dta", version = 14)
write_dta(main.sample.deals, 
          "samples/prestige_main_sample_deals.dta", version = 14)
write_dta(bank.sample, 
          "samples/prestige_bank_sample.dta", version = 14)
