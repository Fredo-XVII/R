# Exploratory data analysis of sales

# Prep and libaries
source('~/R/R_startup.R')
options(dplyr.width = Inf)
library(xts)
library(tseries)
library(TSA)
library(lmtest)

# IMPORT FISCAL DATA DATA FROM TERADATA
db_td <- odbcConnect("TDPRODA" , uid = .uid , pwd = .pwd)
fiscal_cal <- sqlQuery(db_td, 
                       "SELECT distinct ACCT_WK_END_D , ACCT_YR_I , ACCT_QTR_I , ACCT_MO_I , ACCT_WK_I, PRYR_AD_WK_END_D, PRYR_AD_WK_I, PRYR_AD_YR_I
                        FROM PRODRPT_V.CAL_DATE_DIM_V
                        WHERE ACCT_YR_I IN (2015, 2016, 2017)
                        ORDER BY ACCT_WK_END_D
                       ")
STR_VOL <- sqlQuery(db_td,
                    "SELECT DISTINCT CO_LOC_I , VOL_CLAS_DESC_T , VOL_CLAS_C
                     FROM PRODRPT_V.BRCK_MRTR_STR_DIM_V 
                     ORDER BY BRCK_MRTR_STR_I
                    ")
STR_VOL <- as.data.table(STR_VOL)
setkey(STR_VOL, CO_LOC_I)


# Import data from .rds file on disk
STR_SALES_METRICS <- read_rds('STR_SALES_METRICS.rds')
STR_SALES_METRICS <- as.data.table(STR_SALES_METRICS)
setkey(STR_SALES_METRICS , ACCT_WK_END_D , CO_LOC_I , MDSE_DEPT_I)
STR_SALES_METRICS[is.na(STR_SALES_METRICS)] <- 0
STR_SALES_METRICS$POST_PER <- if_else(STR_SALES_METRICS$ACCT_WK_END_D >= as.Date('2016-08-31') , 1 , 0 )
STR_SALES_METRICS <- merge(STR_SALES_METRICS,STR_VOL, by = 'CO_LOC_I' , all.x = TRUE ) # left join in data.table package
STR_SALES_METRICS <- STR_SALES_METRICS[!CO_LOC_I %in% c(-1,1120,865,2814,1162,2440,3093),] # 865 -> 1899 , 2814 -> 2769 # Remove Target RX/Virtual
STR_SALES_METRICS <- STR_SALES_METRICS[!VOL_CLAS_C %in% c('?'),] # Removing stores with missing Volumes

# Descriptive Statistics
summary(STR_SALES_METRICS)

# Aggregate sales by week BY VOL, removes department and stores
STR_SALES <- STR_SALES_METRICS %>%
  filter( !MDSE_DEPT_I %in% c(292, 214)) %>% # remove pharmacy/rx , pharmacy/otc
  select(-MDSE_DEPT_I,-CO_LOC_I, -VOL_CLAS_DESC_T) %>%
  group_by(ACCT_WK_END_D, POST_PER, VOL_CLAS_C) %>% 
  summarize_all(sum) %>%
  arrange(ACCT_WK_END_D)

# Add fiscal dates
STR_SALES <- left_join(STR_SALES , fiscal_cal, by = c("ACCT_WK_END_D"), copy = TRUE )
STR_SALES$POST_PER <- as.factor(STR_SALES$POST_PER)
STR_SALES$ACCT_YR_I <- as.factor(STR_SALES$ACCT_YR_I)
STR_SALES$ACCT_QTR_I <- as.factor(STR_SALES$ACCT_QTR_I)
STR_SALES$ACCT_MO_I <- as.factor(STR_SALES$ACCT_MO_I)
STR_SALES$ACCT_WK_I <- as.factor(STR_SALES$ACCT_WK_I)
STR_SALES$PRYR_AD_WK_END_D <- as.Date(STR_SALES$PRYR_AD_WK_END_D)
STR_SALES$PRYR_AD_WK_I <- as.factor(STR_SALES$PRYR_AD_WK_I)
STR_SALES$PRYR_AD_YR_I <- as.factor(STR_SALES$PRYR_AD_YR_I)
STR_SALES$VOL_CLAS_C <- as.factor(STR_SALES$VOL_CLAS_C)

# Need to figure out how to do a trend for each Volume Class :
#STR_SALES$TREND <- seq(1,length(STR_SALES$ACCT_WK_END_D), by = 1)
#STR_SALES$TREND2 <- STR_SALES$TREND^2

# Add Prior Year Sales to data: 52 week lag
Prior_yr_base <- STR_SALES %>% 
  select(ACCT_WK_END_D, VOL_CLAS_C, PRYR_AD_WK_END_D, PRYR_AD_WK_I, PRYR_AD_YR_I) %>%
  mutate(JOIN_WK = PRYR_AD_WK_END_D, JOIN_CLASS = VOL_CLAS_C)
Current_yr_sales <- STR_SALES %>% 
  select(ACCT_WK_END_D, VOL_CLAS_C, SLS_A, SLS_Q ) %>%
  rename(JOIN_WK = ACCT_WK_END_D , JOIN_CLASS = VOL_CLAS_C , PRYR_SLS_A = SLS_A , PRYR_SLS_Q = SLS_Q)
Prior_yr_sls <- left_join(Prior_yr_base, Current_yr_sales, by = c('JOIN_WK','JOIN_CLASS') ) %>%
  select(ACCT_WK_END_D, VOL_CLAS_C, PRYR_AD_WK_END_D, PRYR_SLS_A, PRYR_SLS_Q)

STR_SALES <- STR_SALES %>%
  left_join(Prior_yr_sls, by = c('ACCT_WK_END_D','PRYR_AD_WK_END_D','VOL_CLAS_C'))
STR_SALES <- STR_SALES[!is.na(VOL_CLAS_C),]

# Lagged and differenced variables
STR_SALES$DIFLAG52_SLS_A <- log(STR_SALES$SLS_A) - log(STR_SALES$PRYR_SLS_A)

summary(STR_SALES$SLS_A)

# checks
sls_test <- STR_SALES %>% select( ACCT_YR_I , SLS_TOTAL_A ) %>% 
            group_by(ACCT_YR_I) %>% 
            summarise(SLS_TOTAL_A = sum(SLS_TOTAL_A))
sls_test

# Graph SALES
# Histograms SLS_TOTAL_A
qplot(x = SLS_TOTAL_A, data = STR_SALES, geom = "histogram" , bins = 100 , col = STR_SALES$ACCT_QTR_I )
qplot(x = log( SLS_TOTAL_A ), data = STR_SALES, geom = "histogram" , bins = 50 , col = STR_SALES$ACCT_QTR_I  )
qplot(x = log10( SLS_TOTAL_A ), data = STR_SALES, geom = "histogram" , bins = 50 , col = STR_SALES$ACCT_QTR_I  )
qplot(x = sqrt( SLS_TOTAL_A ), data = STR_SALES, geom = "histogram" , bins = 50 , col = STR_SALES$ACCT_QTR_I )
qplot(x = diff( log( STR_SALES$SLS_TOTAL_A ) ), geom = "histogram" , bins = 50, col = STR_SALES$ACCT_MO_I[-119]  )
qplot(x = diff( log10( STR_SALES$SLS_TOTAL_A ) ), geom = "histogram" , bins = 50, col = STR_SALES$ACCT_MO_I[-119]  )

# Histograms SLS_TOTAL_Q
qplot(x = SLS_TOTAL_Q, data = STR_SALES, geom = "histogram" , bins = 100 , col = STR_SALES$ACCT_QTR_I )
qplot(x = log( SLS_TOTAL_Q ), data = STR_SALES, geom = "histogram" , bins = 50 , col = STR_SALES$ACCT_QTR_I )
qplot(x = log10( SLS_TOTAL_Q ), data = STR_SALES, geom = "histogram" , bins = 50 , col = STR_SALES$ACCT_QTR_I )
qplot(x = sqrt( SLS_TOTAL_Q ), data = STR_SALES, geom = "histogram" , bins = 50 , col = STR_SALES$ACCT_QTR_I )
qplot(x = diff( log( STR_SALES$SLS_TOTAL_Q ) ), geom = "histogram" , bins = 50, col = STR_SALES$ACCT_MO_I[-119]  )
qplot(x = diff( log10( STR_SALES$SLS_TOTAL_Q ) ), geom = "histogram" , bins = 50, col = STR_SALES$ACCT_MO_I[-119]  )

# Histograms SLS_A
qplot(x = SLS_A, data = STR_SALES, geom = "histogram" , bins = 100 , col = STR_SALES$ACCT_QTR_I )
qplot(x = log( SLS_A ), data = STR_SALES, geom = "histogram" , bins = 50 , col = STR_SALES$ACCT_QTR_I  )
qplot(x = log10( SLS_A ), data = STR_SALES, geom = "histogram" , bins = 50 , col = STR_SALES$ACCT_QTR_I )
qplot(x = sqrt( SLS_A ), data = STR_SALES, geom = "histogram" , bins = 50 , col = STR_SALES$ACCT_QTR_I )
qplot(x = diff( log( STR_SALES$SLS_A ) ), geom = "histogram" , bins = 50, col = STR_SALES$ACCT_QTR_I[-119]  )
qplot(x = diff( log10( STR_SALES$SLS_A ) ), geom = "histogram" , bins = 50, col = STR_SALES$ACCT_QTR_I[-119]  )

# Histograms SLS_Q
qplot(x = SLS_Q, data = STR_SALES, geom = "histogram" , bins = 100 , col = STR_SALES$ACCT_QTR_I   )
qplot(x = log( SLS_Q ), data = STR_SALES, geom = "histogram" , bins = 50 , col = STR_SALES$ACCT_QTR_I )
qplot(x = log10( SLS_Q ), data = STR_SALES, geom = "histogram" , bins = 50 , col = STR_SALES$ACCT_QTR_I   )
qplot(x = sqrt( SLS_Q ), data = STR_SALES, geom = "histogram" , bins = 50 , col = STR_SALES$ACCT_QTR_I  )
qplot(x = diff( log( STR_SALES$SLS_Q ) ), geom = "histogram" , bins = 50, col = STR_SALES$ACCT_QTR_I[-119]  )
qplot(x = diff( log10( STR_SALES$SLS_Q ) ), geom = "histogram" , bins = 50, col = STR_SALES$ACCT_QTR_I[-119]  )

# Histograms SLS_RTRNS_A
qplot(x = SLS_RTRNS_A, data = STR_SALES, geom = "histogram" , bins = 100 , col = STR_SALES$ACCT_QTR_I   )
qplot(x = diff( ( STR_SALES$SLS_RTRNS_A ) ), geom = "histogram" , bins = 50, col = STR_SALES$ACCT_MO_I[-119]  )

# Histograms SLS_RTRNS_Q
qplot(x = SLS_RTRNS_Q, data = STR_SALES, geom = "histogram" , bins = 100 , col = STR_SALES$ACCT_QTR_I  )
qplot(x = diff( ( STR_SALES$SLS_RTRNS_Q ) ), geom = "histogram" , bins = 50, col = STR_SALES$ACCT_QTR_I[-119]  )

# Histograms SLS_XCHG_A
qplot(x = SLS_XCHG_A, data = STR_SALES, geom = "histogram" , bins = 100 , col = STR_SALES$ACCT_QTR_I  )
qplot(x = log( SLS_XCHG_A ), data = STR_SALES, geom = "histogram" , bins = 50 , col = STR_SALES$ACCT_QTR_I  )
qplot(x = log10( SLS_XCHG_A ), data = STR_SALES, geom = "histogram" , bins = 50 , col = STR_SALES$ACCT_QTR_I  )
qplot(x = sqrt( SLS_XCHG_A ), data = STR_SALES, geom = "histogram" , bins = 50 , col = STR_SALES$ACCT_QTR_I  )
qplot(x = diff( log( STR_SALES$SLS_XCHG_A ) ), geom = "histogram" , bins = 50, col = STR_SALES$ACCT_QTR_I[-119]  )
qplot(x = diff( log10( STR_SALES$SLS_XCHG_A ) ), geom = "histogram" , bins = 50, col = STR_SALES$ACCT_QTR_I[-119]  )

# Histograms SLS_XCHG_Q
qplot(x = SLS_XCHG_Q, data = STR_SALES, geom = "histogram" , bins = 100 , col = STR_SALES$ACCT_QTR_I  )
qplot(x = log( SLS_XCHG_Q ), data = STR_SALES, geom = "histogram" , bins = 50 , col = STR_SALES$ACCT_QTR_I  )
qplot(x = log10( SLS_XCHG_Q ), data = STR_SALES, geom = "histogram" , bins = 50 , col = STR_SALES$ACCT_QTR_I  )
qplot(x = sqrt( SLS_XCHG_Q ), data = STR_SALES, geom = "histogram" , bins = 50 , col = STR_SALES$ACCT_QTR_I  )
qplot(x = diff( log( STR_SALES$SLS_XCHG_Q ) ), geom = "histogram" , bins = 50, col = STR_SALES$ACCT_QTR_I[-119]  )
qplot(x = diff( log10( STR_SALES$SLS_XCHG_Q ) ), geom = "histogram" , bins = 50, col = STR_SALES$ACCT_QTR_I[-119]  )

# Histograms DIFLAG52_SLS_A
qplot(x = STR_SALES[!is.na(DIFLAG52_SLS_A),DIFLAG52_SLS_A] , geom = "histogram" , bins = 50, 
      col = STR_SALES[!is.na(DIFLAG52_SLS_A),ACCT_MO_I], facets = . ~ STR_SALES$VOL_CLAS_C)

# Line SLS_TOTAL_A

z <- STR_SALES$SLS_TOTAL_A
graph_4 <- function(time, z, ylabs ) {
  par(mfrow = c(4,1))
  plot(x = time , y = log( z ), ylab = sprintf('Log %s',ylabs) , type = 'line' , col = 'blue' ) #, ylim = c(19.0,20.0))
  abline(h = mean( lag.xts( log( z ) , lag = 52), na.rm = TRUE ))
  abline(v = as.Date('2016-09-03') )
  plot(x = time , y = lag.xts( log( z ) , k = 52), ylab = sprintf('LAG52 Log %s',ylabs) , type = 'c' , col = 'blue' )# , ylim = c(19.0,20.0))
  abline(h = mean( lag.xts( log( z ) , lag = 52), na.rm = TRUE )) 
  abline(v = as.Date('2016-09-03') ) 
  plot(x = time , y = diff.xts( log( z ) , lag = 52) , ylab = sprintf('YOY Log %s',ylabs)  , type = 'c' , col = 'red'  )
  abline(h = 0.0)
  abline(v = as.Date('2016-09-03') )
  plot(x = time , y = diff.xts( log( z ) ) , ylab = sprintf('Diff Log %s',ylabs) , type = 'b' , col = 'blue')
  abline(h = 0.0)
  abline(v = as.Date('2016-09-03') )
  par(mfrow = c(1,1))
}
graph_4(STR_SALES$ACCT_WK_END_D , STR_SALES$SLS_TOTAL_A , 'SLS_TOTAL_A')
graph_4(STR_SALES$ACCT_WK_END_D , STR_SALES$SLS_TOTAL_Q , 'SLS_TOTAL_Q')
graph_4(STR_SALES$ACCT_WK_END_D , STR_SALES$SLS_A , 'SLS_A')
graph_4(STR_SALES$ACCT_WK_END_D , STR_SALES$SLS_Q , 'SLS_Q')
graph_4(STR_SALES$ACCT_WK_END_D , -(STR_SALES$SLS_RTRNS_A) , 'SLS_RTRNS_A')
graph_4(STR_SALES$ACCT_WK_END_D , -(STR_SALES$SLS_RTRNS_Q) , 'SLS_RTRNS_Q')
graph_4(STR_SALES$ACCT_WK_END_D , STR_SALES$SLS_XCHG_A , 'SLS_XCHG_A')
graph_4(STR_SALES$ACCT_WK_END_D , STR_SALES$SLS_XCHG_Q , 'SLS_XCHG_Q')

# Graph the Differenced sales by Vol Class
ggplot(STR_SALES, aes(ACCT_WK_END_D, DIFLAG52_SLS_A, color = VOL_CLAS_C)) +
  geom_line() +
  facet_wrap(~ VOL_CLAS_C) +
  geom_hline(yintercept = 0.0) +
  geom_vline(xintercept = '2016-09-03' )

# Boxplots
qplot(x = as.factor(STR_SALES$ACCT_YR_I) , y = STR_SALES$DIFLAG52_SLS_A, geom = c('boxplot') ,  
      facets = . ~ STR_SALES$VOL_CLAS_C, data = STR_SALES , col = STR_SALES$POST_PER ,
      )

  
# Test for Stationarity: Unit Root Tests
# SLS_TOTAL_A
adf.test(STR_SALES$SLS_TOTAL_A, k = 1)  # RESULTS: STATIONARY
adf.test(STR_SALES$SLS_TOTAL_A, k = 13)  # RESULTS: STATIONARY
adf.test(STR_SALES$SLS_TOTAL_A, k = 26)  # RESULTS: STATIONARY
adf.test(STR_SALES$SLS_TOTAL_A, k = 52)  # RESULTS: NON-STATIONARY
adf.test(log( STR_SALES$SLS_TOTAL_A ), k = 1)  # RESULTS: STATIONARY
adf.test(log( STR_SALES$SLS_TOTAL_A ), k = 4)  # RESULTS: STATIONARY
adf.test(log( STR_SALES$SLS_TOTAL_A ), k = 6)  # RESULTS: STATIONARY
adf.test(log( STR_SALES$SLS_TOTAL_A ), k = 12)  # RESULTS: NON-STATIONARY
adf.test(diff( log( STR_SALES$SLS_TOTAL_A ) ), k = 1)  # RESULTS: STATIONARY
adf.test(diff( log( STR_SALES$SLS_TOTAL_A ) ), k = 4)  # RESULTS: STATIONARY
adf.test(diff( log( STR_SALES$SLS_TOTAL_A ) ), k = 6)  # RESULTS: STATIONARY
adf.test(diff( log( STR_SALES$SLS_TOTAL_A ) ), k = 12) # RESULTS: STATIONARY

# SLS_TOTAL_Q
adf.test(STR_SALES$SLS_TOTAL_Q, k = 1)  # RESULTS: STATIONARY
adf.test(STR_SALES$SLS_TOTAL_Q, k = 4)  # RESULTS: STATIONARY
adf.test(STR_SALES$SLS_TOTAL_Q, k = 6)  # RESULTS: STATIONARY
adf.test(STR_SALES$SLS_TOTAL_Q, k = 12)  # RESULTS: NON-STATIONARY
adf.test(log( STR_SALES$SLS_TOTAL_Q ), k = 1)  # RESULTS: STATIONARY
adf.test(log( STR_SALES$SLS_TOTAL_Q ), k = 4)  # RESULTS: STATIONARY
adf.test(log( STR_SALES$SLS_TOTAL_Q ), k = 6)  # RESULTS: STATIONARY
adf.test(log( STR_SALES$SLS_TOTAL_Q ), k = 12)  # RESULTS: NON-STATIONARY
adf.test(diff( log( STR_SALES$SLS_TOTAL_Q ) ), k = 1)  # RESULTS: STATIONARY
adf.test(diff( log( STR_SALES$SLS_TOTAL_Q ) ), k = 4)  # RESULTS: STATIONARY
adf.test(diff( log( STR_SALES$SLS_TOTAL_Q ) ), k = 6)  # RESULTS: STATIONARY
adf.test(diff( log( STR_SALES$SLS_TOTAL_Q ) ), k = 12) # RESULTS: STATIONARY

# SLS_A
adf.test(STR_SALES$SLS_A, k = 1)  # RESULTS: STATIONARY
adf.test(STR_SALES$SLS_A, k = 13)  # RESULTS: STATIONARY
adf.test(STR_SALES$SLS_A, k = 26)  # RESULTS: STATIONARY
adf.test(STR_SALES$SLS_A, k = 52)  # RESULTS: NON-STATIONARY
adf.test(log( STR_SALES$SLS_A ), k = 1)  # RESULTS: STATIONARY
adf.test(log( STR_SALES$SLS_A ), k = 4)  # RESULTS: STATIONARY
adf.test(log( STR_SALES$SLS_A ), k = 6)  # RESULTS: STATIONARY
adf.test(log( STR_SALES$SLS_A ), k = 12)  # RESULTS: NON-STATIONARY
adf.test(diff( log( STR_SALES$SLS_A ) ), k = 1)  # RESULTS: STATIONARY
adf.test(diff( log( STR_SALES$SLS_A ) ), k = 13)  # RESULTS: STATIONARY
adf.test(diff( log( STR_SALES$SLS_A ) ), k = 26)  # RESULTS: NON-STATIONARY
adf.test(diff( log( STR_SALES$SLS_A ) ), k = 52)  # RESULTS: NON-STATIONARY
adf.test(diff( diff( log( STR_SALES$SLS_A ) ) ), k = 26)  # RESULTS: NON-STATIONARY
adf.test(diff( diff( log( STR_SALES$SLS_A ) ) ), k = 52)  # RESULTS: NON-STATIONARY

# SLS_Q
adf.test(STR_SALES$SLS_Q, k = 1)  # RESULTS: STATIONARY
adf.test(STR_SALES$SLS_Q, k = 4)  # RESULTS: STATIONARY
adf.test(STR_SALES$SLS_Q, k = 6)  # RESULTS: STATIONARY
adf.test(STR_SALES$SLS_Q, k = 12)  # RESULTS: NON-STATIONARY
adf.test(log( STR_SALES$SLS_Q ), k = 1)  # RESULTS: STATIONARY
adf.test(log( STR_SALES$SLS_Q ), k = 4)  # RESULTS: STATIONARY
adf.test(log( STR_SALES$SLS_Q ), k = 6)  # RESULTS: STATIONARY
adf.test(log( STR_SALES$SLS_Q ), k = 12)  # RESULTS: NON-STATIONARY
adf.test(diff( log( STR_SALES$SLS_Q ) ), k = 1)  # RESULTS: STATIONARY
adf.test(diff( log( STR_SALES$SLS_Q ) ), k = 4)  # RESULTS: STATIONARY
adf.test(diff( log( STR_SALES$SLS_Q ) ), k = 6)  # RESULTS: STATIONARY
adf.test(diff( log( STR_SALES$SLS_Q ) ), k = 12)  # RESULTS: STATIONARY

# SLS_RTRNS_A
adf.test(STR_SALES$SLS_RTRNS_A, k = 1)  # RESULTS: STATIONARY
adf.test(STR_SALES$SLS_RTRNS_A, k = 4)  # RESULTS: STATIONARY
adf.test(STR_SALES$SLS_RTRNS_A, k = 6)  # RESULTS: STATIONARY
adf.test(STR_SALES$SLS_RTRNS_A, k = 12) # RESULTS: STATIONARY *
adf.test(log( -STR_SALES$SLS_RTRNS_A ), k = 1)  # RESULTS: STATIONARY
adf.test(log( -STR_SALES$SLS_RTRNS_A ), k = 4)  # RESULTS: STATIONARY
adf.test(log( -STR_SALES$SLS_RTRNS_A ), k = 6)  # RESULTS: STATIONARY
adf.test(log( -STR_SALES$SLS_RTRNS_A ), k = 12) # RESULTS: STATIONARY *
adf.test(diff( log( -STR_SALES$SLS_RTRNS_A ) ), k = 1)  # RESULTS: STATIONARY
adf.test(diff( log( -STR_SALES$SLS_RTRNS_A ) ), k = 4)  # RESULTS: STATIONARY
adf.test(diff( log( -STR_SALES$SLS_RTRNS_A ) ), k = 6)  # RESULTS: STATIONARY
adf.test(diff( log( -STR_SALES$SLS_RTRNS_A ) ), k = 12) # RESULTS: STATIONARY

# SLS_RTRNS_Q
adf.test(STR_SALES$SLS_RTRNS_Q, k = 1)  # RESULTS: STATIONARY
adf.test(STR_SALES$SLS_RTRNS_Q, k = 4)  # RESULTS: STATIONARY
adf.test(STR_SALES$SLS_RTRNS_Q, k = 6)  # RESULTS: NON-STATIONARY *
adf.test(STR_SALES$SLS_RTRNS_Q, k = 12) # RESULTS: NON-STATIONARY 
adf.test(log( -STR_SALES$SLS_RTRNS_Q ), k = 1)  # RESULTS: STATIONARY
adf.test(log( -STR_SALES$SLS_RTRNS_Q ), k = 4)  # RESULTS: STATIONARY
adf.test(log( -STR_SALES$SLS_RTRNS_Q ), k = 6)  # RESULTS: NON-STATIONARY *
adf.test(log( -STR_SALES$SLS_RTRNS_Q ), k = 12) # RESULTS: STATIONARY * 
adf.test(diff( log( -STR_SALES$SLS_RTRNS_Q ) ), k = 1)  # RESULTS: STATIONARY
adf.test(diff( log( -STR_SALES$SLS_RTRNS_Q ) ), k = 4)  # RESULTS: STATIONARY
adf.test(diff( log( -STR_SALES$SLS_RTRNS_Q ) ), k = 6)  # RESULTS: STATIONARY
adf.test(diff( log( -STR_SALES$SLS_RTRNS_Q ) ), k = 12) # RESULTS: STATIONARY

# SLS_XCHG_A
adf.test(STR_SALES$SLS_XCHG_A, k = 1)  # RESULTS: STATIONARY
adf.test(STR_SALES$SLS_XCHG_A, k = 4)  # RESULTS: NON-STATIONARY *
adf.test(STR_SALES$SLS_XCHG_A, k = 6)  # RESULTS: NON-STATIONARY *
adf.test(STR_SALES$SLS_XCHG_A, k = 12) # RESULTS: NON-STATIONARY *
adf.test(log( STR_SALES[which(SLS_XCHG_A>0)]$SLS_XCHG_A ), k = 1)  # RESULTS: NON-STATIONARY *
adf.test(log( STR_SALES[which(SLS_XCHG_A>0)]$SLS_XCHG_A ), k = 4)  # RESULTS: NON-STATIONARY *
adf.test(log( STR_SALES[which(SLS_XCHG_A>0)]$SLS_XCHG_A ), k = 6)  # RESULTS: NON-STATIONARY *
adf.test(log( STR_SALES[which(SLS_XCHG_A>0)]$SLS_XCHG_A ), k = 12) # RESULTS: NON-STATIONARY * 
adf.test(diff( log( STR_SALES[which(SLS_XCHG_A>0)]$SLS_XCHG_A ) ), k = 1)  # RESULTS: STATIONARY
adf.test(diff( log( STR_SALES[which(SLS_XCHG_A>0)]$SLS_XCHG_A ) ), k = 4)  # RESULTS: STATIONARY
adf.test(diff( log( STR_SALES[which(SLS_XCHG_A>0)]$SLS_XCHG_A ) ), k = 6)  # RESULTS: STATIONARY
adf.test(diff( log( STR_SALES[which(SLS_XCHG_A>0)]$SLS_XCHG_A ) ), k = 12) # RESULTS: NON-STATIONARY ***
adf.test(diff(diff( log( STR_SALES[which(SLS_XCHG_A>0)]$SLS_XCHG_A ) ), k = 12)) # RESULTS: NON-STATIONARY ***

# DIFLAG52_SLS - already logged and differenced
adf.test(STR_SALES$DIFLAG52_SLS[!is.na(STR_SALES$DIFLAG52_SLS)], k = 1)  # RESULTS: STATIONARY
adf.test(STR_SALES$DIFLAG52_SLS[!is.na(STR_SALES$DIFLAG52_SLS)], k = 4)  # RESULTS: NON-STATIONARY *
adf.test(STR_SALES$DIFLAG52_SLS[!is.na(STR_SALES$DIFLAG52_SLS)], k = 6)  # RESULTS: NON-STATIONARY *
adf.test(STR_SALES$DIFLAG52_SLS[!is.na(STR_SALES$DIFLAG52_SLS)], k = 12) # RESULTS: NON-STATIONARY *
acf(STR_SALES$DIFLAG52_SLS[!is.na(STR_SALES$DIFLAG52_SLS)], lag.max = 52, demean = F)
pacf(STR_SALES$DIFLAG52_SLS[!is.na(STR_SALES$DIFLAG52_SLS)], lag.max = 52, demean = F)


# Focus will be on Sales for the rest of the analysis: SLS_A & SLS_Q
# Autocorrelation graphs
plot(armasubsets(y=log(STR_SALES$SLS_A),nar=26,nma=26))  
acf((diff(log(STR_SALES$SLS_A))), lag.max = 52 , plot = T, demean = F)  
pacf(diff(log(STR_SALES$SLS_A)),  lag.max = 52 , plot = T , demean = F)
m1.sls_a <- arima(x = (log(STR_SALES$SLS_A)) , order = c(1,0,1) , seasonal=list(order=c(0,0,1),period=52))
m1.sls_a
tsdiag(m1.sls_a)
plot(armasubsets(y=residuals(m1.sls_a),nar=12,nma=12))
par(mfrow=c(1,1))
shapiro.test(residuals(m1.sls_a))
hist(residuals(m1.sls_a))
acf(m1.sls_a$residuals, demean = F) 
pacf(m1.sls_a$residuals, demean = F)  
BIC(m1.sls_a)
par(mfrow=c(1,1))

# Linear Trends Analysis
# Trend - results show that there is no trend, or not statistically different from zero
lm_sls_a <- lm(log(SLS_A) ~ TREND + TREND2, data = STR_SALES)
summary(lm_sls_a) 
BIC(lm_sls_a) # -32.4912
dwtest(lm_sls_a)
plot(lm_sls_a$residuals)
plot(lm_sls_a$fitted.values)
abline(a = lm_sls_a$coefficients[1], b = lm_sls_a$coefficients[2], col = 'red')

# Trend + Seasonality
lm_sls_a <- lm(log(SLS_A) ~ ACCT_MO_I, data = STR_SALES )
summary(lm_sls_a)
BIC(lm_sls_a) # -62.11357, -106.8697
dwtest(lm_sls_a)
plot(lm_sls_a$residuals)
shapiro.test(lm_sls_a$residuals)
hist(lm_sls_a$residuals)
acf(lm_sls_a$residuals, demean = F, lag.max = 36)
pacf(lm_sls_a$residuals, demean = F, lag.max = 36)
adf.test(lm_sls_a$residuals, k = 12)
McLeod.Li.test(y = lm_sls_a$residuals) # no ARCH process

lm_sls_a <- lm(log(SLS_A) ~ ACCT_WK_I, data = STR_SALES )
summary(lm_sls_a)
BIC(lm_sls_a) # -62.11357, -106.8697
dwtest(lm_sls_a)
plot(lm_sls_a$residuals)
shapiro.test(lm_sls_a$residuals)
hist(lm_sls_a$residuals)
acf(lm_sls_a$residuals, demean = F, lag.max = 36)
pacf(lm_sls_a$residuals, demean = F, lag.max = 36)
adf.test(lm_sls_a$residuals, k = 12)
McLeod.Li.test(y = lm_sls_a$residuals) # no ARCH process

# Add Differencing
lm_sls_a <- lm(diff(log(SLS_A)) ~ if_else(STR_SALES$ACCT_MO_I == 10,1,0)[-1] + if_else(STR_SALES$ACCT_MO_I == 11,1,0)[-1]
                 , data = STR_SALES )
lm_sls_a <- lm(diff(log(SLS_A)) ~ #ACCT_WK_I[-1] 
                 if_else(STR_SALES$ACCT_WK_I == 43,1,0)[-1] + if_else(STR_SALES$ACCT_WK_I == 44, 1, 0 )[-1] + if_else(STR_SALES$ACCT_WK_I == 48, 1, 0 )[-1] 
               , data = STR_SALES )
summary(lm_sls_a)
BIC(lm_sls_a) # -62.11357, -106.8697, -95.87022, -98.21396
dwtest(lm_sls_a)
plot(lm_sls_a$residuals)
shapiro.test(lm_sls_a$residuals)
hist(lm_sls_a$residuals)
acf(lm_sls_a$residuals, demean = F, lag.max = 36)
pacf(lm_sls_a$residuals, demean = F, lag.max = 36)
adf.test(lm_sls_a$residuals, k = 12)
McLeod.Li.test(y = lm_sls_a$residuals) # no ARCH process

m1.sls_seas <- arima(x = (lm_sls_a$residuals) , order = c(0,0,0)) 
m1.sls_seas
BIC(m1.sls_seas)
plot(armasubsets(y=residuals(m1.sls_seas),nar=12,nma=12))
acf(m1.sls_seas$residuals, demean = F)
pacf(m1.sls_seas$residuals, demean = F)
adf.test(m1.sls_seas$residuals)
tsdiag(m1.sls_seas)
par(mfrow=c(1,1))
