# Granger Causality Test
# Metrics: CAF Pulls vs Sales

# Granger Causality Steps: ----
# Step #1: Regress Current Y on all Y terms and other variables, if any, but 'do not' include the lagged X variables in this regression. 
  # This is the restricted regression. From this regression obtain the restricted residual sum of squares, RSS(r).

# Step #2: Now run the regression including the lagged X terms. This is the Unrestricted regression. 
  # From this regression obtain the unrestricted regresion sum of squares, RSS(ur).

# Step #3: The Null Hypothesis is Ho: Sum[a(i)] = 0, that is, the lagged X terms do not belong in the regression.

# Step #4: To test this Hypothesis, we apply the F test, namely, F = (RSS(r) - RSS(ur)/m) / ( RSS(ur)/(n-k)) ,
  # which follows the F distribution with m and (n-k) df. m is equal to the number of lagged X terms and k is the number of parameters
  # estimated in the unrestricted model.

# Step #5: If the computed F value exceeds the critical F value at the chosen level of significance, we reject the Null Hypothesis, in 
  # which case the lagged X terms belong in the regression.  This is another way of saying X causes Y.

# Notes: Both X and Y must be Stationary.  

# CODE: -----
# Prep and libaries
source('~/R/R_startup.R')
library(xts)
library(tseries)
library(TSA)
library(lmtest)
library(GGally)

# Monthly Data
STR_SALES_MO <- STR_SALES %>% 
                mutate(ACCT_YR_MO_I = as.yearmon(ACCT_WK_END_D)) %>%
                select(-ACCT_WK_END_D, -ACCT_WK_I, -TREND, -TREND2, -PRYR_AD_WK_END_D, -PRYR_AD_WK_I, -PRYR_AD_YR_I) %>%
                group_by(ACCT_YR_MO_I, ACCT_YR_I , ACCT_MO_I , ACCT_QTR_I, POST_PER) %>%
                summarize_all(sum) %>%
                select(ACCT_YR_MO_I, ACCT_YR_I , ACCT_MO_I , ACCT_QTR_I, POST_PER, SLS_A, SLS_Q, PRYR_SLS_A, PRYR_SLS_Q)

                STR_SALES_MO$TREND <- seq(1,length(STR_SALES_MO$ACCT_YR_MO_I), by = 1)
                STR_SALES_MO$TREND2 <- STR_SALES_MO$TREND^2
                STR_SALES_MO$DIFLAG52_SLS_A <- log(STR_SALES_MO$SLS_A) - log(STR_SALES_MO$PRYR_SLS_A)
                
MANU_CAFPULLS_MO <- M_Pulls %>%
                    mutate(ACCT_YR_MO_I = as.yearmon(ACCT_WK_END_D)) %>%
                    select(-ACCT_WK_END_D, -ACCT_WK_I, -TREND, -TREND2, -PRYR_AD_WK_END_D, -PRYR_AD_WK_I, -PRYR_AD_YR_I) %>%
                    group_by(ACCT_YR_MO_I, ACCT_YR_I , ACCT_MO_I , ACCT_MO_I , ACCT_QTR_I, POST_PER) %>%
                    summarize_all(sum) %>%
                    select(ACCT_YR_MO_I, ACCT_YR_I , ACCT_MO_I , ACCT_QTR_I, POST_PER, MAN_PULLS_S, MANU_CAF_TRIPS_S, 
                           MANU_CAF_TRIPS_S, MANU_CAF_EACHES_S, TOT_PULLS, TOT_EACHES, PRYR_MANU_CAF_TRIPS_S, PRYR_MANU_CAF_EACHES_S)
                    
                    MANU_CAFPULLS_MO$TREND <- seq(1,length(MANU_CAFPULLS_MO$ACCT_YR_MO_I), by = 1)
                    MANU_CAFPULLS_MO$TREND2 <- MANU_CAFPULLS_MO$TREND^2
                    MANU_CAFPULLS_MO$difflag52_man_caf_pulls <- log(MANU_CAFPULLS_MO$MANU_CAF_TRIPS_S) - log(MANU_CAFPULLS_MO$PRYR_MANU_CAF_TRIPS_S)

## Variables:
## Dependent: Y
X <- diff(log(STR_SALES_MO$SLS_A), lag = 1)
Y <- diff(log(MANU_CAFPULLS_MO$MANU_CAF_TRIPS_S), lag = 1)
## if series is already differenced and logged
X <- STR_SALES_MO$DIFLAG52_SLS
Y <- MANU_CAFPULLS_MO$difflag52_man_caf_pulls

# Step #1:
plot(STR_SALES_MO$ACCT_YR_MO_I[-1:-12],Y,type="l",col="red")
  lines(STR_SALES_MO$ACCT_YR_MO_I[-1:-12],X,col="green")
  
pairs(~ Y + lag.xts(Y, k=12) + lag.xts(Y, k=1) + lag.xts(Y, k=2) + lag.xts(Y, k=3) + lag.xts(Y, k = 4) + lag.xts(Y, k=5) + lag.xts(Y, k=6)  )

# Restricted Model
lm_r <- lm(Y ~ lag.xts(Y, k = 1) + lag.xts(Y, k=2) + lag.xts(Y, k=3) + lag.xts(Y, k = 4) + lag.xts(Y, k=5) + lag.xts(Y, k=6) )
lm_r <- lm(Y ~ lag.xts(Y, k = 1) + lag.xts(Y, k=12) )
summary(lm_r)
acf(residuals(lm_r))
pacf(residuals(lm_r))
RSS_r <- sum(residuals(lm_r)^2)
m <- 2 #6 # number of lags in the model

# UN - Restricted Model
lm_ur <- lm(Y ~ lag.xts(Y, k = 1) + lag.xts(Y, k=2) + lag.xts(Y, k=3) + lag.xts(Y, k = 4) + #lag.xts(Y, k=5) + lag.xts(Y, k=6) +
                lag.xts(X, k = 1) + lag.xts(X, k=2) + lag.xts(X, k=3) + lag.xts(X, k = 4) #+ lag.xts(X, k=5) + lag.xts(X, k=6)
            
            )
#lm_ur <- lm(Y ~ lag.xts(Y, k = 1) + lag.xts(Y, k=12) + X + lag.xts(X, k = 1) + lag.xts(X, k=12) )
summary(lm_ur)
acf(residuals(lm_ur))
pacf(residuals(lm_ur))
RSS_ur <- sum(residuals(lm_ur)^2)
n_k <- lm_ur$df.residual # (n Obs in model) - lm_ur$df.residual # number of lags in the model

# Step # 4: Calculate the F statistic
F <- ((RSS_r - RSS_ur) / m ) / (RSS_ur/n_k)
F # 1.159745
m
n_k

### MONTHLY DATA 
## DIFFERENCED LAG = 1
# Result: X = CAF PULLS Causes Y = Sales
# The critical value at 5% level of significance is 3.87; the test statistic is 1.16.  The results show that we cannot reject the Null 
# Hypothesis that X does not Cause Y.

# Result: X = Sales Cause Y = CAF PULLS
# The critical value at 5% level of significance is 3.87; the test statistic is 0.003321667.  The results show that we cannot reject the Null 
# Hypothesis that X does not Cause Y.

## DIFFERENCED LAG = 12
# Result: X = CAF PULLS Causes Y = Sales
# The critical value at 5% level of significance is 3.87; the test statistic is 1.16.  The results show that we cannot reject the Null 
# Hypothesis that X does not Cause Y.

# Result: X = Sales Cause Y = CAF PULLS
# The critical value at 5% level of significance is 3.87; the test statistic is 0.003321667.  The results show that we cannot reject the Null 
# Hypothesis that X does not Cause Y.



# WEEKLY DATA


## Variables:
## Dependent: Y
Y <- diff(log(STR_SALES$SLS_A), lag = 52)
X <- diff(log(M_Pulls$MANU_CAF_TRIPS_S), lag = 52)
## if series is already differenced and logged 
Y <- STR_SALES$DIFLAG52_SLS_A[!is.na(STR_SALES$DIFLAG52_SLS_A)]
X <- M_Pulls$difflag52_man_caf_pulls[!is.na(M_Pulls$difflag52_man_caf_pulls)]
# Removing the outliers impacting significance
## if series is already differenced and logged 
Y <- STR_SALES$DIFLAG52_SLS_A[!is.na(STR_SALES$DIFLAG52_SLS_A) & !STR_SALES$ACCT_WK_END_D == as.Date('2016-11-26') & !STR_SALES$ACCT_WK_END_D == as.Date('2016-12-24')]
X <- M_Pulls$difflag52_man_caf_pulls[!is.na(M_Pulls$difflag52_man_caf_pulls) & !STR_SALES$ACCT_WK_END_D == as.Date('2016-11-26') & !STR_SALES$ACCT_WK_END_D == as.Date('2016-12-24')]


# Step #1
par(mfrow= c(1,1))
plot(STR_SALES$ACCT_WK_END_D[-1:-52],Y,type="l",col="red", ylim = c(-0.50,1.50)) # ACCT_WK_END_D[-1:-52]
lines(STR_SALES$ACCT_WK_END_D[-1:-52],X,col="green")
abline(v = as.Date('2016-09-03'))
abline(h = 0.0)

  ## Univariate
pairs(~ Y + lag.xts(Y, k=12) + lag.xts(Y, k=1) + lag.xts(Y, k=2) + lag.xts(Y, k=3) + lag.xts(Y, k = 4) + lag.xts(Y, k=5) + lag.xts(Y, k=6)
      , lower.panel=panel.smooth, col = STR_SALES$POST_PER[-1:-52])
pairs(~ Y + lag.xts(Y, k=7) + lag.xts(Y, k=8) + lag.xts(Y, k=9) + lag.xts(Y, k=10) + lag.xts(Y, k = 11) + lag.xts(Y, k=12) + lag.xts(Y, k=13)  
      , lower.panel=panel.smooth, col = STR_SALES$POST_PER[-1:-52])
  ## Multivariate
pairs(~ Y + lag.xts(X, k=12) + lag.xts(X, k=1) + lag.xts(X, k=2) + lag.xts(X, k=3) + lag.xts(X, k = 4) + lag.xts(X, k=5) + lag.xts(X, k=6) 
      , lower.panel=panel.smooth, col = STR_SALES$POST_PER[-1:-52])
pairs(~ Y + lag.xts(X, k=7) + lag.xts(X, k=8) + lag.xts(X, k=9) + lag.xts(X, k=10) + lag.xts(X, k = 11) + lag.xts(X, k=12) + lag.xts(X, k=13)
      , lower.panel=panel.smooth, col = STR_SALES$POST_PER[-1:-52])


# Restricted Model
lm_r <- lm(Y ~ lag.xts(Y, k = 1) + lag.xts(Y, k=2) + lag.xts(Y, k=3) + lag.xts(Y, k = 4) + lag.xts(Y, k=5) + lag.xts(Y, k=6) # + lag.xts(Y, k=52)  # +
             #if_else(STR_SALES$ACCT_WK_I == 43,1,0)[-1] + if_else(STR_SALES$ACCT_WK_I == 44, 1, 0 )[-1] + if_else(STR_SALES$ACCT_WK_I == 48, 1, 0 )[-1]
           #- 1
)
#lm_r <- lm(Y ~ lag.xts(Y, k = 1) + lag.xts(Y, k=12) )
summary(lm_r)
dwtest(lm_r)
BIC(lm_r)
hist(residuals(lm_r))
acf(residuals(lm_r), lag.max = 52)
pacf(residuals(lm_r), lag.max = 52)
adf.test(residuals(lm_r))
RSS_r <- sum(residuals(lm_r)^2)
RSS_r

# UN - Restricted Model
lm_ur <- lm(Y ~ lag.xts(X, k = 1) + lag.xts(X, k=2) + lag.xts(X, k=3) + lag.xts(X, k = 4) + lag.xts(X, k=5) + lag.xts(X, k=6) + # +  lag.xts(X, k=52)
              lag.xts(Y, k = 1) + lag.xts(Y, k=2) + lag.xts(Y, k=3) + lag.xts(Y, k = 4) + lag.xts(Y, k=5) + lag.xts(Y, k=6) #  lag.xts(Y, k=52) +
            #if_else(STR_SALES$ACCT_WK_I == 43,1,0)[-1] + if_else(STR_SALES$ACCT_WK_I == 44, 1, 0 )[-1] + if_else(STR_SALES$ACCT_WK_I == 48, 1, 0 )[-1] +
            #- 1
)
#lm_ur <- lm(Y ~ lag.xts(Y, k = 1) + lag.xts(Y, k=12) + X + lag.xts(X, k = 1) + lag.xts(X, k=12) )
summary(lm_ur)
dwtest(lm_ur)
BIC(lm_ur)
hist(residuals(lm_ur))
acf(residuals(lm_ur), lag.max = 52)
pacf(residuals(lm_ur), lag.max = 52)
adf.test(residuals(lm_ur))
RSS_ur <- sum(residuals(lm_ur)^2)
RSS_ur
m <- 6 # number of lags in the model
n_k <- length(Y) - lm_ur$rank # (n Obs in model) - lm_ur$df.residual # number of lags in the model
n_k

# Step # 4: Calculate the F statistic
F <- ((RSS_r - RSS_ur) / m ) / (RSS_ur/n_k)
F # 1.59126
m
n_k
waldtest(lm_r, lm_ur)
anova(lm_r,lm_ur)
## DIFFERENCED LAG = 52
# Result: X = CAF MAN PULLS Causes Y = SALES of the differenced 52 week series.
# The critical value at 5% level of significance is 2.25, with 6 and 54 degrees of freedom; the test statistic is 2.546352.  
# The results show that we reject the Null Hypothesis that X does not Cause Y, in favor of the alternative hypothesis that 
# X (ie. MAN CAF PULLS ) does cause Y (SALES).  

### NOTE: That the thanksgiving outlier is probably driving the significant results at lags 4 and 5: 2016-11-26 , 2016-12-24
### Once I removed the 2 holiday peaks the significance goes away for the lags 4 and 5.  In other words, 2 data points/weeks were such large outliers
### that they were creating significance in the 4 and 5 lag where there was none.

# Result: X = CAF MAN PULLS Causes Y = SALES of the differenced 52 week series.
# The critical value at 5% level of significance is 2.25, with 6 and 54 degrees of freedom; the test statistic is 0.7011363.  
# The results show that we cannot reject the Null Hypothesis that X does not Cause Y, in favor of the alternative hypothesis that 
# X (ie. MAN CAF PULLS ) does cause Y (SALES).

# Result: X = SALES Causes Y = CAF MAN PULLS of the differenced 52 week series.
# The critical value at 5% level of significance is 2.25, with 6 and 54 degrees of freedom; the test statistic is 0.2708048.  
# The results show that we cannot reject the Null Hypothesis that X does not Cause Y, in favor of the alternative hypothesis that 
# X (ie. SALES ) does cause Y ( MAN CAF PULLS ).

# Iterpreting Coeficients
pairs(Y ~ X + lag.xts(X, k=4) + lag.xts(X, k = 5) , col = STR_SALES$ACCT_YR_I[-1:-52])
cor.test(Y, lag.xts(X, k=5))
plot(Y,lag.xts(X, k=5))
abline(lm(Y~lag.xts(X, k=5)))
lm_y_x <- lm(Y ~ STR_SALES$TREND[-1:-52] + X + lag.xts(X, k = 1) + lag.xts(X, k=2) + lag.xts(X, k=3) + lag.xts(X, k = 4) + lag.xts(X, k=5) + lag.xts(X, k=6) )
lm_y_x <- lm(Y ~ lag.xts(Y) + lag.xts(X, k=4) + lag.xts(X, k = 5) - 1  )
summary(lm_y_x)
sd(Y)
lm_y_x$coefficients[[2]] # instantaneous rate of growth
exp(lm_y_x$coefficients[[2]])
( exp(lm_y_x$coefficients[[2]]) - 1 ) * 100 # compound rate of growth in Percents
