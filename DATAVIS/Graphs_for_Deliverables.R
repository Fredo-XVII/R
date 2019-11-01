# Graphs for Manual CAF Pulls impact on Sales and OOS Perc summary


# Graph Total Pulls vs. Sales Ad-Ad 2015 - 2017wk15
X <- STR_SALES$ACCT_WK_END_D
Y <- M_Pulls$TOT_PULLS/1000000
Y_col <- 'darkgrey'
Y_ylim <- c(0,25)
Z <- STR_SALES$SLS_A/1000000000
Z_col <- 'red'
Z_ylim <- c(0,4)

par(mfrow = c(1,1))
plot(x = X , y = Y  , type = 'line' , col = Y_col , axes=F , ylab = '', xlab = 'Fiscal Weeks', ylim= Y_ylim , 
     yaxt='n' ,
     main = "Total Pull Trips vs. Sales"
     )
axis(side = 2, ylim= Y_ylim,  col.axis= Y_col , las=1 ) # ylim=c(0,1),  at = pretty(range(M_Pulls$TOT_PULLS/1000000))
#mtext("",side=2,line=2.5)
box()
# Second Plot on graph
par(new = TRUE)
plot( x = X , y = Z  , type = 'line' , col = Z_col , axes = F , xlab = '', ylab = '' ,  ylim= Z_ylim , 
      yaxt='n'
    )
axis(side = 4, ylim= Z_ylim , col.axis= Z_col ,las=1) # , at = pretty(range(STR_SALES$SLS_A/1000000000))
abline(v = as.Date('2016-09-03'))
## Add Legend
legend("topleft",legend=c("Total Pulls Trips ( in M )","Sales $ in Billions", "ILR Change: 09-03-2016"), text.width = 100, bty = "n" ,
       text.col=c(Y_col,Z_col,"black"),pch=c(16,16,16),col=c(Y_col,Z_col,"black"), cex=.75)


# Graph Manual CAF Pulls vs. Sales 2015 - 2017wk15
X <- STR_SALES$ACCT_WK_END_D
Y <- M_Pulls$MANU_CAF_TRIPS_S/1000
Y_col <- 'darkgrey'
Y_ylim <- c(0,1500)
Z <- STR_SALES$SLS_A/1000000000
Z_col <- 'red'
Z_ylim <- c(0,4)

par(mfrow = c(1,1))
plot(x = X , y = Y  , type = 'line' , col = Y_col , axes=F , ylab = '', xlab = 'Fiscal Weeks', ylim= Y_ylim , 
     yaxt='n' ,
     main = "Manual CAF Pull Trips vs. Sales"
)
axis(side = 2, ylim= Y_ylim,  col.axis= Y_col , las=1 ) # ylim=c(0,1),  at = pretty(range(M_Pulls$TOT_PULLS/1000000))
#mtext("",side=2,line=2.5)
box()
# Second Plot on graph
par(new = TRUE)
plot( x = X , y = Z  , type = 'line' , col = Z_col , axes = F , xlab = '', ylab = '' ,  ylim= Z_ylim , 
      yaxt='n'
)
axis(side = 4, ylim= Z_ylim , col.axis= Z_col ,las=1) # , at = pretty(range(STR_SALES$SLS_A/1000000000))
abline(v = as.Date('2016-09-03'))
## Add Legend
legend("topleft",legend=c("Manual CAF Pull Trips ( in '000s )","Sales $ in Billions ", "ILR Change: 09-03-2016"), text.width = 100, bty = "n" ,
       text.col=c(Y_col,Z_col,"black"),pch=c(16,16,16),col=c(Y_col,Z_col,"black"), cex=.75)


# Graph Total Pull Trips vs. OOS % 2015 - 2017wk15
X <- STR_SALES$ACCT_WK_END_D
Y <- M_Pulls$TOT_PULLS/1000000 
Y_col <- 'darkgrey'
Y_ylim <- c(0,25)
Z <- OOS_WK$OOS_PERC*100 # STR_SALES$SLS_A/1000000000
Z_col <- 'red'
Z_ylim <- c(0,15) # c(0,4)

par(mfrow = c(1,1))
plot(x = X , y = Y  , type = 'line' , col = Y_col , axes=F , ylab = '', xlab = 'Fiscal Weeks', ylim= Y_ylim , 
     yaxt='n' ,
     main = "Total Pulls Trips vs. OOS %"
)
axis(side = 2, ylim= Y_ylim,  col.axis= Y_col , las=1 ) # ylim=c(0,1),  at = pretty(range(M_Pulls$TOT_PULLS/1000000))
#mtext("",side=2,line=2.5)
box()
# Second Plot on graph
par(new = TRUE)
plot( x = X , y = Z  , type = 'line' , col = Z_col , axes = F , xlab = '', ylab = '' ,  ylim= Z_ylim , 
      yaxt='n'
)
axis(side = 4, ylim= Z_ylim , col.axis= Z_col ,las=1) # , at = pretty(range(STR_SALES$SLS_A/1000000000))
abline(v = as.Date('2016-09-03'))
## Add Legend
legend("topleft",legend=c("Total Pulls Trips ( in M )","OOS % ( in Percents ) ", "ILR Change: 09-03-2016"), text.width = 100, bty = "n" ,
       text.col=c(Y_col,Z_col,"black"),pch=c(16,16,16),col=c(Y_col,Z_col,"black"), cex=.75)


# Graph Manual CAF Pulls vs. OOS % 2015 - 2017wk15
X <- STR_SALES$ACCT_WK_END_D
Y <- M_Pulls$MANU_CAF_TRIPS_S/1000
Y_col <- 'darkgrey'
Y_ylim <- c(0,1500)
Z <- OOS_WK$OOS_PERC*100 # STR_SALES$SLS_A/1000000000
Z_col <- 'red'
Z_ylim <- c(0,15) # c(0,4)

par(mfrow = c(1,1))
plot(x = X , y = Y  , type = 'line' , col = Y_col , axes=F , ylab = '', xlab = 'Fiscal Weeks', ylim= Y_ylim , 
     yaxt='n' ,
     main = "Manual CAF Pull Trips vs. OOS %"
)
axis(side = 2, ylim= Y_ylim,  col.axis= Y_col , las=1 ) # ylim=c(0,1),  at = pretty(range(M_Pulls$TOT_PULLS/1000000))
#mtext("",side=2,line=2.5)
box()
# Second Plot on graph
par(new = TRUE)
plot( x = X , y = Z  , type = 'line' , col = Z_col , axes = F , xlab = '', ylab = '' ,  ylim= Z_ylim , 
      yaxt='n'
)
axis(side = 4, ylim= Z_ylim , col.axis= Z_col ,las=1) # , at = pretty(range(STR_SALES$SLS_A/1000000000))
abline(v = as.Date('2016-09-03'))
## Add Legend
legend("topleft",legend=c("Manual CAF Pull Trips ( in '000s )","OOS % ( in Percents ) ", "ILR Change: 09-03-2016"), text.width = 100, bty = "n" ,
       text.col=c(Y_col,Z_col,"black"),pch=c(16,16,16),col=c(Y_col,Z_col,"black"), cex=.75)


graph_Pulls_Sales_OOS_ds.csv <- cbind.data.frame(STR_SALES$ACCT_WK_END_D, M_Pulls$TOT_PULLS, M_Pulls$MANU_CAF_TRIPS_S, STR_SALES$SLS_A, OOS_WK$OOS_PERC)
names(graph_Pulls_Sales_OOS_ds.csv) <- c("Week_End_Date","TOT_PULLS", "Manual_CAF_Pulls", "Sales", "OOS_PERC")
write_csv(graph_Pulls_Sales_OOS_ds.csv, path = paste0(getwd(),'/graph_Pulls_Sales_OOS_ds.csv'))

