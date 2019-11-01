# for creating dummies of the first and last row in a group by using Data Tables
DT <- cbind(DT, first=0L, last=0L)
DT[DT[unique(DT),,mult="first", which=TRUE], first:=1L]
DT[DT[unique(DT),,mult="last", which=TRUE], last:=1L]
DT[unique(DT),,mult="first", which=TRUE]


# Graphing Code Snippet 
  #googlevis
goog_vis_dt <- prod_fx_YrMth %>%
                mutate( YrMth_i = as.Date.yearmon(YrMth)) %>%
                select( YrMth_i , PROD_CATEG , Prod_spend.Cumsum.log , Cum_chg_r_geo.cum)
motion_gr <- gvisMotionChart(goog_vis_dt, idvar = "PROD_CATEG" , timevar = "YrMth_i")
plot(motion_gr)

  #rbokeh
figure() %>%
        ly_multi_line(data=prod_fx_YrMth, x= Prod_spend.Cumsum.log , lgroup = PROD_CATEG )
        
# Clustering 
  # Kmeans - cluster selection
  mydata <- d
wss <- (nrow(mydata)-1)*sum(apply(mydata,2,var))
  for (i in 2:15) wss[i] <- sum(kmeans(mydata,
                                       centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")
     #http://stackoverflow.com/questions/15376075/cluster-analysis-in-r-determine-the-optimal-number-of-clusters
       
# Searching for partial table name in a database using dplyr and sqlQuery/RODBC  
sqlTables(db_td_DLPL,schema = "DLFIN_PLDEPT") %>%
  filter(grepl('POG', TABLE_NAME))
    
sqlColumns(db_td_DLPL,schema = "DLFIN_PLDEPT" , sqtable = "POG_Totals")
  
  


