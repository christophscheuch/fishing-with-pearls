
source("code/prestige_tools.R")

################################################################################
# read data ---------------------------------------------------------------
compm.adsprate <- read_csv("raw/compm_adsprate.csv", 
                           col_types = cols(.default = "c"))

ratings.all <- compm.adsprate %>%
  select(gvkey, datadate, splticrm) %>%
  mutate(datadate = ymd(datadate),
         year = year(datadate),
         month = month(datadate),
         splticrm_no = if_else(splticrm == "AAA", 1, as.numeric(NA)),
         splticrm_no = if_else(splticrm == "AA+", 2, splticrm_no),
         splticrm_no = if_else(splticrm == "AA", 3, splticrm_no),
         splticrm_no = if_else(splticrm == "AA-", 4, splticrm_no),
         splticrm_no = if_else(splticrm == "A+", 5, splticrm_no),
         splticrm_no = if_else(splticrm == "A", 6, splticrm_no),
         splticrm_no = if_else(splticrm == "A-", 7, splticrm_no),
         splticrm_no = if_else(splticrm == "BBB+", 8, splticrm_no),
         splticrm_no = if_else(splticrm == "BBB", 9, splticrm_no),
         splticrm_no = if_else(splticrm == "BBB-", 10, splticrm_no),
         splticrm_no = if_else(splticrm == "BB+", 11, splticrm_no),
         splticrm_no = if_else(splticrm == "BB", 12, splticrm_no),
         splticrm_no = if_else(splticrm == "BB-", 13, splticrm_no),
         splticrm_no = if_else(splticrm == "B+", 14, splticrm_no),
         splticrm_no = if_else(splticrm == "B", 15, splticrm_no),
         splticrm_no = if_else(splticrm == "B-", 16, splticrm_no),
         splticrm_no = if_else(splticrm == "CCC+", 17, splticrm_no),
         splticrm_no = if_else(splticrm == "CCC", 18, splticrm_no),
         splticrm_no = if_else(splticrm == "CCC-", 19, splticrm_no),
         splticrm_no = if_else(splticrm == "CC", 20, splticrm_no),
         splticrm_no = if_else(splticrm == "C", 21, splticrm_no),
         splticrm_no = if_else(splticrm == "D", 22, splticrm_no),
         splticrm_no = if_else(splticrm == "SD", 22, splticrm_no))

################################################################################
# keep only firms from the dealscan sample --------------------------------
load("clean/dealscan.RData")

dealscan.firms <- dealscan %>% 
  distinct(bgvkey) %>% 
  filter(!is.na(bgvkey))

ratings.dealscan <- ratings.all %>%
  rename(bgvkey = gvkey) %>%
  inner_join(dealscan.firms, by = c("bgvkey")) %>%
  group_by(bgvkey) %>%
  arrange(year, month) %>%
  mutate(monthgap = month - lag(month)) %>%
  ungroup() %>%
  mutate(splticrm_l1 = if_else(monthgap == 1 | monthgap == -11,
                             lag(splticrm), as.character(NA)),
         splticrm_l1 = if_else(splticrm == "",
                             as.character(NA), splticrm),
         splticrm_l1_no = as.numeric(as.factor(splticrm_l1)),
         splticrm_l1_no_new = as.factor(ifelse(is.na(splticrm_l1_no),
                                             25, splticrm_l1_no))) %>%
  select(bgvkey, splticrm_l1, splticrm_l1_no_new,
         rating_n = splticrm_no, rating_date = datadate, year, month)

# rating at issuance
ratings.issuance <- dealscan %>%
  filter(!is.na(bgvkey)) %>%
  distinct(bgvkey, facilitystartdate) %>%
  mutate(year = year(facilitystartdate), month = month(facilitystartdate)) %>%
  left_join(ratings.dealscan, by = c("bgvkey", "year", "month")) %>%
  select(bgvkey, facilitystartdate, rating_issuance = rating_n,
         splticrm_l1, splticrm_l1_no_new)

# rating at maturity
ratings.maturity <- dealscan %>%
  filter(!is.na(bgvkey)) %>%
  distinct(bgvkey, facilityenddate) %>%
  mutate(year = year(facilityenddate), month = month(facilityenddate)) %>%
  left_join(ratings.dealscan, by = c("bgvkey", "year", "month")) %>%
  select(bgvkey, facilityenddate, rating_maturity = rating_n)

# average rating over maturity
dealscan.dates <- dealscan %>%
  distinct(bgvkey, facilitystartdate, facilityenddate) %>%
  filter(!is.na(bgvkey)) %>%
  mutate(year_start = year(facilitystartdate),
         month_start = month(facilitystartdate),
         year_end = year(facilityenddate),
         month_end = month(facilityenddate)) %>%
  inner_join(ratings.dealscan %>% distinct(bgvkey), by = "bgvkey")

ratings.average <- list()
for (j in 1:nrow(dealscan.dates)) {
  tmp <- ratings.dealscan %>%
    filter(bgvkey == dealscan.dates$bgvkey[j] &
             rating_date >= dealscan.dates$facilitystartdate[j] &
             rating_date <= dealscan.dates$facilityenddate[j]) %>%
    group_by(bgvkey) %>%
    summarize(rating_n_avg = mean(rating_n)) %>%
    mutate(facilitystartdate = dealscan.dates$facilitystartdate[j],
           facilityenddate = dealscan.dates$facilityenddate[j])
  ratings.average[[j]] <- tmp
  svMisc::progress(j, nrow(dealscan.dates))
  rm(tmp)
}
ratings.average <- bind_rows(ratings.average)

################################################################################
# save rating samples -----------------------------------------------------

save(ratings.issuance, ratings.maturity, ratings.average, 
     file = "clean/dealscan_borrower_ratings.RData")
=======
################################################################################
# extract loan level borrower credit ratings for dealscan sample
# christoph scheuch, october 2017
################################################################################

source("code/prestige_tools.R")

################################################################################
# read data ---------------------------------------------------------------
compm.adsprate <- read_csv("raw/compm_adsprate.csv", 
                           col_types = cols(.default = "c"))

ratings.all <- compm.adsprate %>%
  select(gvkey, datadate, splticrm) %>%
  mutate(datadate = ymd(datadate),
         year = year(datadate),
         month = month(datadate),
         splticrm_no = if_else(splticrm == "AAA", 1, as.numeric(NA)),
         splticrm_no = if_else(splticrm == "AA+", 2, splticrm_no),
         splticrm_no = if_else(splticrm == "AA", 3, splticrm_no),
         splticrm_no = if_else(splticrm == "AA-", 4, splticrm_no),
         splticrm_no = if_else(splticrm == "A+", 5, splticrm_no),
         splticrm_no = if_else(splticrm == "A", 6, splticrm_no),
         splticrm_no = if_else(splticrm == "A-", 7, splticrm_no),
         splticrm_no = if_else(splticrm == "BBB+", 8, splticrm_no),
         splticrm_no = if_else(splticrm == "BBB", 9, splticrm_no),
         splticrm_no = if_else(splticrm == "BBB-", 10, splticrm_no),
         splticrm_no = if_else(splticrm == "BB+", 11, splticrm_no),
         splticrm_no = if_else(splticrm == "BB", 12, splticrm_no),
         splticrm_no = if_else(splticrm == "BB-", 13, splticrm_no),
         splticrm_no = if_else(splticrm == "B+", 14, splticrm_no),
         splticrm_no = if_else(splticrm == "B", 15, splticrm_no),
         splticrm_no = if_else(splticrm == "B-", 16, splticrm_no),
         splticrm_no = if_else(splticrm == "CCC+", 17, splticrm_no),
         splticrm_no = if_else(splticrm == "CCC", 18, splticrm_no),
         splticrm_no = if_else(splticrm == "CCC-", 19, splticrm_no),
         splticrm_no = if_else(splticrm == "CC", 20, splticrm_no),
         splticrm_no = if_else(splticrm == "C", 21, splticrm_no),
         splticrm_no = if_else(splticrm == "D", 22, splticrm_no),
         splticrm_no = if_else(splticrm == "SD", 22, splticrm_no))

################################################################################
# keep only firms from the dealscan sample --------------------------------
load("clean/dealscan.RData")

dealscan.firms <- dealscan %>% 
  distinct(bgvkey) %>% 
  filter(!is.na(bgvkey))

ratings.dealscan <- ratings.all %>%
  rename(bgvkey = gvkey) %>%
  inner_join(dealscan.firms, by = c("bgvkey")) %>%
  group_by(bgvkey) %>%
  arrange(year, month) %>%
  mutate(monthgap = month - lag(month)) %>%
  ungroup() %>%
  mutate(splticrm_l1 = if_else(monthgap == 1 | monthgap == -11,
                             lag(splticrm), as.character(NA)),
         splticrm_l1 = if_else(splticrm == "",
                             as.character(NA), splticrm),
         splticrm_l1_no = as.numeric(as.factor(splticrm_l1)),
         splticrm_l1_no_new = as.factor(ifelse(is.na(splticrm_l1_no),
                                             25, splticrm_l1_no))) %>%
  select(bgvkey, splticrm_l1, splticrm_l1_no_new,
         rating_n = splticrm_no, rating_date = datadate, year, month)

# rating at issuance
ratings.issuance <- dealscan %>%
  filter(!is.na(bgvkey)) %>%
  distinct(bgvkey, facilitystartdate) %>%
  mutate(year = year(facilitystartdate), month = month(facilitystartdate)) %>%
  left_join(ratings.dealscan, by = c("bgvkey", "year", "month")) %>%
  select(bgvkey, facilitystartdate, rating_issuance = rating_n,
         splticrm_l1, splticrm_l1_no_new)

# rating at maturity
ratings.maturity <- dealscan %>%
  filter(!is.na(bgvkey)) %>%
  distinct(bgvkey, facilityenddate) %>%
  mutate(year = year(facilityenddate), month = month(facilityenddate)) %>%
  left_join(ratings.dealscan, by = c("bgvkey", "year", "month")) %>%
  select(bgvkey, facilityenddate, rating_maturity = rating_n)

# average rating over maturity
dealscan.dates <- dealscan %>%
  distinct(bgvkey, facilitystartdate, facilityenddate) %>%
  filter(!is.na(bgvkey)) %>%
  mutate(year_start = year(facilitystartdate),
         month_start = month(facilitystartdate),
         year_end = year(facilityenddate),
         month_end = month(facilityenddate)) %>%
  inner_join(ratings.dealscan %>% distinct(bgvkey), by = "bgvkey")

ratings.average <- list()
for (j in 1:nrow(dealscan.dates)) {
  tmp <- ratings.dealscan %>%
    filter(bgvkey == dealscan.dates$bgvkey[j] &
             rating_date >= dealscan.dates$facilitystartdate[j] &
             rating_date <= dealscan.dates$facilityenddate[j]) %>%
    group_by(bgvkey) %>%
    summarize(rating_n_avg = mean(rating_n)) %>%
    mutate(facilitystartdate = dealscan.dates$facilitystartdate[j],
           facilityenddate = dealscan.dates$facilityenddate[j])
  ratings.average[[j]] <- tmp
  svMisc::progress(j, nrow(dealscan.dates))
  rm(tmp)
}
ratings.average <- bind_rows(ratings.average)

################################################################################
# save rating samples -----------------------------------------------------
save(ratings.issuance, ratings.maturity, ratings.average, 
     file = "clean/dealscan_borrower_ratings.RData")
