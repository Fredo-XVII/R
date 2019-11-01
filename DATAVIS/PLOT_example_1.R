# Graphs for Manual CAF Pulls impact on Sales and OOS Perc summary


# Graph 
X <- X$X_DATE
Y <- Y$VAR_Y/1000000
Y_col <- 'darkgrey'
Y_ylim <- c(0,25)
Z <- Z$VAR_Z/1000000000
Z_col <- 'red'
Z_ylim <- c(0,4)

par(mfrow = c(1,1))
plot(x = X , y = Y  , type = 'line' , col = Y_col , axes=F , ylab = '', xlab = 'Fiscal Weeks', ylim= Y_ylim , 
     yaxt='n' ,
     main = "X vs. Y"
     )
axis(side = 2, ylim= Y_ylim,  col.axis= Y_col , las=1 ) # ylim=c(0,1),  at = pretty(range(Y$VAR_Y/1000000))
#mtext("",side=2,line=2.5)
box()
# Second Plot on graph
par(new = TRUE)
plot( x = X , y = Z  , type = 'line' , col = Z_col , axes = F , xlab = '', ylab = '' ,  ylim= Z_ylim , 
      yaxt='n'
    )
axis(side = 4, ylim= Z_ylim , col.axis= Z_col ,las=1) # , at = pretty(range(Z$VAR_Z/1000000000))
abline(v = as.Date('2016-09-03'))
## Add Legend
legend("topleft",legend=c("X ( in M )","Y $ in Billions", "DATE Change: 09-03-2016"), text.width = 100, bty = "n" ,
       text.col=c(Y_col,Z_col,"black"),pch=c(16,16,16),col=c(Y_col,Z_col,"black"), cex=.75)


graph_ds.csv <- cbind.data.frame(X$X_DATE,YZ$VAR_Y, Z$VAR_Z)
names(graph_ds.csv) <- c("X","Y", "Z")
write_csv(graph_ds.csv, path = paste0(getwd(),'/graph_ds.csv'))









