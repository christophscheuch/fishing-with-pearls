
source("code/prestige_tools.R")

################################################################################
# read data ---------------------------------------------------------------
prestige.raw <- read_csv("raw/prestige.csv", col_types = cols(.default = "c"))

prestige <- prestige.raw %>%
  mutate(publication_date = ymd(paste(publication, substring(issue_date, 3))),
         year = as.numeric(year), 
         score = as.numeric(score),
         rank_score = as.numeric(rank_score),
         rank_top_100 = as.integer(rank_top_100)) %>%
  select(gvkey, year, score, rank_score, rank_top_100)

################################################################################
# export data -------------------------------------------------------------
save(prestige, file = "clean/prestige.RData")
