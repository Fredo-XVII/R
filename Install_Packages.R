# Works with Security on Machine
install.packages('sparklyr', repos='http://cran.us.r-project.org')

# Loop over package list
liblist <- c("spdep","rgeos","rgdal","sp")
lapply(liblist, require, character.only=T)

# Get IP
library(devtools)
install_github("gregce/ipify")
library(ipify) # 
get_ip()
