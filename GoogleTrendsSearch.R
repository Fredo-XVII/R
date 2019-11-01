library('datasets')
library(gtrendsR)
usr <- "fredoXVII@gmail.com"  # alternatively store as options() or env.var
psw <- "xxxxx"        # idem
gconnect(usr, psw)       # stores handle in environment
head(countries[which(countries$code == 'US'),])
gt_trend <- gtrends(c("Target bathroom policy") , c("US-MN") )
plot(gt_trend)        # data set also included in package
plot(gt_trend, type = "geo" , which = 5 )
national_trend <- gt_trend$trend

states_abb <- cbind(state.name , state.abb)

gt_trend <- gtrends(c("Target bathroom policy") , c("US-MN") )

for (i in 1:length(state.abb)){
  sprintf('gt_trend_%s <- gtrends(c("Target bathroom policy") , c("US-state.abb[%s]") ) ' , i ) 
}

i <- 'Ak'
state_ds <- sprintf("gt_trend_%s" , i )

for (i in state.abb) { 
  if (i %in% c('AK','RI','VT')) {next}
  state <- sprintf("US-%s" , i)
  state_ds <- sprintf("gt_trend_%s" , i )
  state_ds <-  gtrends(c("Target bathroom policy") , c(state) )
  
  # addint resource : http://stackoverflow.com/questions/13940478/how-do-i-rename-a-data-frame-in-a-for-loop
  
down vote
accepted
I think you gave the answer yourself: you have to use ?assign.

Try something like that:

for (i in 1:5) {
  assign(paste0("DF", i), data.frame(A=rnorm(10), B=rnorm(10)))
}
This loops through the integers from 1 to 5 and creates five data.frames "DF1" to "DF5". For your example, you should just replace

name<-read.tucson(files[i],header=NULL)
with

assign(name, read.tucson(files[i],header=NULL))
Note, however, that name is a base function in R, so I would use another naming convention or just skip the first line:

assign(paste("t",files[i],sep=""), read.tucson(files[i],header=NULL))
I hope this is what you are looking for.
  #return(state_ds)
}       
        
for (i in seq(along = state.abb)) {
          paste0("gt_trend_", state.abb[i]) <- state.abb[i]
        }
        head(Income)
