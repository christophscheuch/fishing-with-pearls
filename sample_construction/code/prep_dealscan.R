
source("code/prestige_tools.R")

################################################################################
# read data ---------------------------------------------------------------
## raw dealscan data from WRDS
ds.facility <- read_csv("raw/dealscan_facility.csv", 
                        col_types = cols(.default = "c"))
names(ds.facility) <- tolower(names(ds.facility))
ds.package <- read_csv("raw/dealscan_package.csv", 
                       col_types = cols(.default = "c"))
names(ds.package) <- tolower(names(ds.package))
ds.currfacpricing <- read_csv("raw/dealscan_currfacpricing.csv", 
                              col_types = cols(.default = "c"))
names(ds.currfacpricing) <- tolower(names(ds.currfacpricing))
ds.lendershares <- read_csv("raw/dealscan_lendershares.csv", 
                              col_types = cols(.default = "c"))
names(ds.lendershares) <- tolower(names(ds.lendershares))
ds.financialcovenant <- read_csv("raw/dealscan_financialcovenant.csv", 
                                  col_types = cols(.default = "c"))
names(ds.financialcovenant) <- tolower(names(ds.financialcovenant))
ds.performancepricing <- read_csv("raw/dealscan_performancepricing.csv", 
                                  col_types = cols(.default = "c"))
names(ds.performancepricing) <- tolower(names(ds.performancepricing))

## dealscan-compustat linking tables
### borrower linking table of Chava and Roberts (2008)
### available on Michael Roberts' homepage 
### (http://finance.wharton.upenn.edu/~mrrobert/styled-9/styled-12/index.html)
ds.link.borrower <- read_csv("raw/dealscan_borrower_link.csv", 
                             col_types = cols(.default = "c"))
### lender linking table of Schwert (2017) 
### available on Michael Schwert's homepage 
### (https://sites.google.com/site/mwschwert/)
ds.link.lender <- read_csv("raw/dealscan_lender_link.csv", 
                           col_types = cols(.default = "c"))

## total cost of borrowing measure from Berg, Saunders & Steffen (2016)
### available on Tobias Berg's homepage 
### (http://www.tobias-berg.com/)
ds.tcb <- read_csv("raw/dealscan_tcb.csv",
                   col_types = cols(.default = "c"))
names(ds.tcb) <- tolower(names(ds.tcb))

################################################################################
# facility information ----------------------------------------------------
facility.no <- ds.facility %>%
  group_by(packageid) %>%
  summarize(facility_no = n())

facility <- ds.facility %>%
  left_join(facility.no, by = "packageid") %>%
  select(facilityid, packageid, facilitystartdate, facilityenddate,
         borrowercompanyid, facilityamt, facility_no, maturity,
         secured, loantype, loanpurpose = primarypurpose) %>%
  mutate(facilityamt    = as.numeric(facilityamt),
         maturity       = as.numeric(maturity),
         secured        = as.integer(if_else(secured == "No" | is.na(secured), 0, 1)),
         loantype_no    = as.integer(as.factor(loantype)),
         loanpurpose_no = as.integer(as.factor(loanpurpose)),
         credit_line    = as.integer(if_else(loantype %in% c("364-Day Facility" ,
                                                             "Revolver/Line < 1 Yr.",
                                                             "Revolver/Line >= 1 Yr.",
                                                             "Revolver/Term Loan"), 1, 0)),
         term_loan      = as.integer(if_else(loantype %in% c("Term Loan", "Term Loan A",
                                                             "Term Loan B", "Term Loan C",
                                                             "Term Loan D", "Term Loan E",
                                                             "Term Loan F", "Term Loan G",
                                                             "Term Loan H", "Term Loan I",
                                                             "Term Loan J", "Term Loan K",
                                                             "Delay Draw Term Loan"), 1, 0)))

################################################################################
# pricing data ------------------------------------------------------------
spreads <- ds.currfacpricing %>%
  group_by(facilityid) %>%
  summarize(aisd = maximum(as.numeric(allindrawn)),
            aisu = maximum(as.numeric(allinundrawn)))

fees.spreads <- ds.currfacpricing %>%
  filter(baserate == "LIBOR") %>%
  select(facilityid, spread = maxbps) %>%
  group_by(facilityid) %>%
  mutate(spread = maximum(as.numeric(spread))) %>%
  ungroup()

fees.facility <- ds.currfacpricing %>%
  filter(fee == "Annual Regular Fee") %>%
  select(facilityid, facility_fee = maxbps) %>%
  group_by(facilityid) %>%
  mutate(facility_fee = maximum(as.numeric(facility_fee))) %>%
  ungroup()

fees.upfront <- ds.currfacpricing %>%
  filter(fee == "Upfront Regular Fee") %>%
  select(facilityid, upfront_fee = maxbps) %>%
  group_by(facilityid) %>%
  mutate(upfront_fee = maximum(as.numeric(upfront_fee))) %>%
  ungroup()

fees.commitment <- ds.currfacpricing %>%
  filter(fee == "Commitment Regular Fee") %>%
  select(facilityid, commitment_fee = maxbps) %>%
  group_by(facilityid) %>%
  mutate(commitment_fee = maximum(as.numeric(commitment_fee))) %>%
  ungroup()

fees.utilization <- ds.currfacpricing %>%
  filter(fee == "Utilization Fee") %>%
  select(facilityid, utilization_fee = maxbps) %>%
  group_by(facilityid) %>%
  mutate(utilization_fee = maximum(as.numeric(utilization_fee))) %>%
  ungroup()

fees.cancellation <- ds.currfacpricing %>%
  filter(fee == "Cancellation Fee") %>%
  select(facilityid, cancellation_fee = maxbps) %>%
  group_by(facilityid) %>%
  mutate(cancellation_fee = maximum(as.numeric(cancellation_fee))) %>%
  ungroup()

baseprime.dum <- ds.currfacpricing %>%
  group_by(facilityid) %>%
  filter(!is.na(baserate)) %>%
  mutate(baseprime = {if(any(baserate == "Prime")) 1 else 0}) %>%
  summarize(baseprime = as.integer(mean(baseprime)))

# total cost of borrowing from Berg, Saunders & Steffen (2017)
tcb <- ds.tcb %>%
  select(facilityid, tcb) %>%
  mutate(tcb = as.numeric(tcb))

################################################################################
# performance pricing dummy -----------------------------------------------
performance.dum <- ds.performancepricing %>%
  select(facilityid) %>% 
  distinct() %>%
  mutate(performance = as.integer(1))

################################################################################
# financial covenant dummy ------------------------------------------------
covenant.dum <- ds.financialcovenant %>%
  select(packageid) %>% 
  distinct() %>%
  mutate(fincovenant = as.integer(1))

################################################################################
# define lead arrangers ---------------------------------------------------
lenders <- ds.lendershares %>%
  left_join(ds.facility %>%
              distinct(facilityid, packageid),
            by = "facilityid") %>%
  distinct(packageid, companyid, lenderrole, bankallocation) %>%
  group_by(packageid) %>%
  mutate(lenders_no = n()) %>%
  ungroup()

## define single lenders as lender
lenders.single <- lenders %>%
  filter(lenders_no == 1) %>%
  select(packageid, lenderid = companyid, 
         lenderrole, lead_share = bankallocation) %>%
  mutate(sole_lender = 1,
         leads_no = 1)

## define roles of lead banks
lenders.leads <- lenders %>%
  filter(lenders_no > 1) %>%
  filter(lenderrole %in% c("Admin agent", "Agent", "Arranger", "Lead bank")) %>%
  group_by(packageid) %>%
  mutate(sole_lender = 0,
         leads_no = n()) %>%
  ungroup()

## define single leads as lender
lenders.leads.single <- lenders.leads %>%
  filter(leads_no == 1) %>%
  select(packageid, lenderid = companyid, lenderrole, 
         lead_share = bankallocation, sole_lender, leads_no)

## collect info about multiple leads
lenders.leads.multiple <- lenders.leads %>%
  filter(leads_no > 1) %>%
  mutate(sole_lender = 0) %>%
  select(packageid, sole_lender, leads_no) %>% 
  distinct()

lenders.ids <- bind_rows(lenders.single,
                         lenders.leads.single, 
                         lenders.leads.multiple) %>%
  mutate(lead_share = if_else(as.numeric(lead_share) > 100, 
                              as.numeric(NA), as.numeric(lead_share)) / 100)

################################################################################
# competition measures ----------------------------------------------------
competition <- ds.lendershares %>% 
  distinct(facilityid, companyid, bankallocation) %>%
  group_by(facilityid) %>%
  summarize(lenders_no = n(),
            lenders_hhi = sum((as.numeric(bankallocation) / 100) ^ 2)) %>%
  mutate(lenders_hhi = if_else(lenders_hhi > 1, as.numeric(NA), lenders_hhi))

################################################################################
# combine data ------------------------------------------------------------
dealscan <- facility %>%
  mutate(facilitystartdate = ymd(facilitystartdate), 
         facilityenddate = ymd(facilityenddate)) %>%
  left_join(spreads, by = "facilityid") %>%
  left_join(fees.spreads, by = "facilityid") %>%
  left_join(fees.facility, by = "facilityid") %>%
  left_join(fees.upfront, by = "facilityid") %>%
  left_join(fees.commitment, by = "facilityid") %>%
  left_join(fees.utilization, by = "facilityid") %>%
  left_join(fees.cancellation, by = "facilityid") %>%
  left_join(baseprime.dum, by = "facilityid") %>%
  mutate(baseprime = if_else(is.na(baseprime), 
                             as.integer(0), baseprime)) %>%
  left_join(performance.dum, by = "facilityid") %>%
  mutate(performance = if_else(is.na(performance), 
                               as.integer(0), performance)) %>%
  left_join(covenant.dum, by = "packageid") %>%
  mutate(fincovenant = if_else(is.na(fincovenant), 
                               as.integer(0), fincovenant)) %>%
  left_join(tcb, by = "facilityid") %>%
  left_join(competition, by = "facilityid") %>%
  left_join(lenders.ids, by = "packageid")

################################################################################
# add links ---------------------------------------------------------------
## borrower links from Roberts (2008)
links.borrowers <- ds.link.borrower %>%
  distinct(facid, gvkey) %>%
  rename(facilityid = facid,
         bgvkey = gvkey)

dealscan <- dealscan %>%
  left_join(links.borrowers, by = "facilityid")

# lender links from Schwert (2017)
available.links <- dealscan %>%
  distinct(packageid, facilitystartdate, lenderid) %>%
  inner_join(ds.link.lender %>%
               select(lenderid = companyid) %>%
               distinct(), by = "lenderid") %>%
  na.omit()

links.lenders <- ds.link.lender %>%
  select(lenderid = companyid, lgvkey = gvkey, comp_start, comp_end) %>%
  mutate(comp_start = ymd(comp_start), comp_end = ymd(comp_end)) %>%
  distinct()

links.lenders.matched <- list()
for (j in 1:nrow(available.links)){
  tmp1 <- available.links[j, ]
  tmp2 <- links.lenders %>%
    filter(lenderid == tmp1$lenderid &
             tmp1$facilitystartdate >= comp_start &
             tmp1$facilitystartdate <= comp_end)
  tmp3 <- tmp1 %>%
    left_join(tmp2, by = "lenderid")
  links.lenders.matched[[j]] <- tmp3
  rm(tmp1, tmp2, tmp3)
  svMisc::progress(j, nrow(available.links))
}
links.lenders.matched <- bind_rows(links.lenders.matched)
save(links.lenders.matched,
     file = "Dealscan/dealscan_lender_links_matched.RData")

load("clean/dealscan_lender_links_matched.RData")

dealscan <- dealscan %>%
  left_join(links.lenders.matched %>%
              select(packageid, lgvkey),
            by = c("packageid"))

################################################################################
# add relationship lending variables --------------------------------------
## simple dummies that indicate whether relationship is new or old
## note: the level of observation is a deal (i.e. package)
relationship.dummies <- dealscan %>%
  distinct(packageid, facilitystartdate, borrowercompanyid, lenderid) %>%
  na.omit() %>%
  group_by(packageid) %>%
  arrange(facilitystartdate) %>%
  summarize(facilitystartdate = first(facilitystartdate),
            borrowercompanyid = first(borrowercompanyid),
            lenderid = first(lenderid)) %>%
  group_by(borrowercompanyid, lenderid) %>%
  arrange(facilitystartdate) %>%
  mutate(date_diff = as.numeric((facilitystartdate - 
                                   lag(facilitystartdate))) / 365.25,
         old_bank_relation = as.integer(if_else(date_diff > 5 | is.na(date_diff), 0, 1)),
         new_bank_relation = as.integer(if_else(row_number() == 1, 1, 0))) %>%
  ungroup() %>%
  select(packageid, new_bank_relation, old_bank_relation)

# identify first deal in dealscan
first.loan <- dealscan %>%
  distinct(packageid, facilitystartdate, borrowercompanyid) %>%
  na.omit() %>%
  group_by(packageid) %>%
  arrange(facilitystartdate) %>%
  summarize(facilitystartdate = first(facilitystartdate),
            borrowercompanyid = first(borrowercompanyid)) %>%
  group_by(borrowercompanyid) %>%
  arrange(facilitystartdate) %>%
  mutate(first_deal = as.integer(if_else(row_number() == 1, 1, 0))) %>%
  ungroup() %>%
  select(packageid, first_deal)

dealscan <- dealscan %>%
  left_join(relationship.dummies, by = "packageid") %>%
  left_join(first.loan, by = "packageid") %>%
  mutate(new_bank_relation_alt = if_else(first_deal == 1,
                                         as.integer(NA), new_bank_relation),
         old_bank_relation_alt = if_else(first_deal == 1,
                                         as.integer(NA), old_bank_relation))

# relationship lending variables
total.borrowing <- dealscan %>%
  distinct(borrowercompanyid, lenderid,
           packageid, facilitystartdate, facilityamt) %>%
  na.omit() %>%
  group_by(packageid) %>%
  arrange(facilitystartdate) %>%
  summarize(borrowercompanyid = first(borrowercompanyid),
            lenderid = first(lenderid),
            packagestartdate = first(facilitystartdate),
            packageamt = sum(facilityamt)) %>%
  arrange(borrowercompanyid, packagestartdate)

bcoids <- total.borrowing %>%
  distinct(borrowercompanyid)

relationships <- list()
for (i in 1:nrow(bcoids)) {

  loans <- total.borrowing %>%
    filter(borrowercompanyid == bcoids$borrowercompanyid[i])

  last.activity <- tibble()
  for (j in 1:nrow(loans)) {
    if (j == 1) {
      tmp1 <- tibble(packageid = loans$packageid[j],
                     total_number = as.numeric(NA),
                     total_volume = as.numeric(NA))
    } else {
      tmp1 <- loans %>%
        mutate(date_diff = as.numeric(loans$packagestartdate[j] -
                                        packagestartdate) / 365.25) %>%
        filter(date_diff > 0 & date_diff <= 5) %>%
        summarize(total_number = n(), total_volume = sum(packageamt)) %>%
        mutate(packageid = loans$packageid[j])
    }
    last.activity <- bind_rows(last.activity, tmp1)
  }

  pair.activity <- tibble()
  for (j in 1:nrow(loans)) {
    if (j == 1 | is.na(loans$lenderid[j])) {
      tmp2 <- tibble(packageid = loans$packageid[j],
                     bank_number = as.numeric(NA),
                     bank_volume = as.numeric(NA))
    } else {
      tmp2 <- loans %>%
        mutate(date_diff = as.numeric(loans$packagestartdate[j] -
                                        packagestartdate) / 365.25) %>%
        filter(date_diff > 0 & date_diff <= 5 &
                 lenderid == loans$lenderid[j]) %>%
        summarize(bank_number = n(), bank_volume = sum(packageamt)) %>%
        mutate(packageid = loans$packageid[j])
    }
    pair.activity <- bind_rows(pair.activity, tmp2)
  }

  rm(loans)

  tmp3 <- last.activity %>%
    left_join(pair.activity, by = "packageid") %>%
    mutate(rel_amount = bank_volume/total_volume,
           rel_number = bank_number/total_number) %>%
    select(packageid, rel_amount, rel_number)

  relationships[[i]] <- tmp3
  rm(tmp1, tmp2, tmp3)

  svMisc::progress(i, nrow(bcoids))
}
relationships <- bind_rows(relationships)
save(relationships, file = "Dealscan/dealscan_relationships_matched.RData")

load("clean/dealscan_relationships_matched.RData")

dealscan <- dealscan %>%
  left_join(relationships, by = "packageid")

################################################################################
# export data -------------------------------------------------------------

dealscan[is.nan(dealscan)] <- NA
dealscan[is.infinite(dealscan)] <- NA

save(dealscan, file = "clean/dealscan.RData")
