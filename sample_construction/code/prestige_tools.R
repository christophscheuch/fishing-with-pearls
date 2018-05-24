# load packages
library(tidyverse) #for data manipulation
library(lubridate) #for parsing dates
library(svMisc) #for progress bar in loops
library(haven) #for saving in dta format

# these functions have no method for data frames in base R
is.infinite.data.frame <- function(x) do.call(cbind, lapply(x, is.infinite))
is.nan.data.frame <- function(x) do.call(cbind, lapply(x, is.nan))

# maximum function that replaces NAs with NA instead of -Inf
maximum <- function(x) if_else(!all(is.na(x)), max(x, na.rm = T), as.numeric(NA))

# load packages
library(tidyverse) #for data manipulation
library(lubridate) #for parsing dates
library(svMisc) #for progress bar in loops
library(haven) #for saving in dta format

# these functions have no method for data frames in base R
is.infinite.data.frame <- function(x) do.call(cbind, lapply(x, is.infinite))
is.nan.data.frame <- function(x) do.call(cbind, lapply(x, is.nan))

# maximum function that replaces NAs with NA instead of -Inf
maximum <- function(x) if_else(!all(is.na(x)), max(x, na.rm = T), as.numeric(NA))

# set date format to english - important for parsing dates
Sys.setlocale("LC_TIME", "English") 
