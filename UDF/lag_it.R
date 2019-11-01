# Function to build the lags for each metric
library(dplyr)
library(tidyquant)
library(timetk)

# Example: sls_a_lags <- lag_it(sales,"sls_a",12)

lag_it <- function(df,col,lags) {
  lags_num <- 1:lags
  col_names <- paste(col, "lag", lags_num, sep = "_" )
                      
  df %>% # dplyr::filter(co_loc_ref_i%in% c(3,1375)) %>%
  dplyr::select(co_loc_ref_i,acct_wk_end_d,col) %>%
  dplyr::group_by(co_loc_ref_i) %>% 
  tidyquant::tq_mutate( 
        select     = col,
        mutate_fun = lag.xts,
        k          = lags_num,
        col_rename = col_names
    )
}
