# Get the dates for Easter Holiday from the Census Bureau

library(tidyverse)

url <- 'https://www.census.gov/srd/www/genhol/easter500.txt'

download.file(url, "easter500.txt", quiet=FALSE)

easter_500 <- readr::read_table("easter500.txt", col_names = FALSE)
names(easter_500) <- c("month","day","year")

easter_500 <- easter_500 %>% 
  dplyr::mutate(easter_d = lubridate::ymd(paste(year,month,day, sep = '-')))
