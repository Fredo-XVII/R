# Shutdown
h2o.shutdown(prompt = FALSE)

#Testing
library(h2o)

h2o.init(nthreads = -1, port = 55555)

h2o.clusterInfo()

system("ifconfig", intern=TRUE)

%config IPCompleter

# Get IP
library(devtools)
install_github("gregce/ipify")
library(ipify) # '161.225.96.152'
get_ip()

# Load data
pathToData = "hdfs://user/FREDO/econ_demo_lnd/ACS_2015_5yr_MSA_data.csv"
h2o.importFile(pathToData, destination_frame = "ACS_2015.hex")
