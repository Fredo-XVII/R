# Function to build the lags for each metric
library(dplyr)
library(tidyquant)
library(timetk)

# Example:
# # First Difference 
#sls_a_diff_lags <- diff_it(sales,"sls_a",1,1)
# 52nd Difference
#sls_a_diff_lags52 <- diff_it(sales,"sls_a",1,52)


diff_it <- function(df,col,diff,lags) {
  lags_num <- 1:lags
  col_names <- paste(col, "diff", diff, "lag", lags, sep = "_" )
                      
  df %>% #dplyr::filter(co_loc_ref_i%in% c(3,1375)) %>%
  dplyr::select(co_loc_ref_i,acct_wk_end_d,col) %>%
  dplyr::group_by(co_loc_ref_i) %>% 
  tidyquant::tq_mutate( 
        select     = col,
        mutate_fun = diff.xts,
        lag        = lags,
        differences = diff,
        col_rename = col_names
    )
}
