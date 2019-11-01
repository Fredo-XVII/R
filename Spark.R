# Session info
sessionInfo()
sparkR.uiWebUrl()
sparkR.conf()

# from RPubs : https://rpubs.com/wendyu/sparkr

# Download and Installation
# Spark can be downloaded directly from the link: http://spark.apache.org/downloads.html

# After downloading, save the zipped file to a directory of choice, and then unzip the file. 
# We can then set up Spark in R environment.

# Set system environmental variables to run Spark (either in windows, or R):
  ## SPARK_HOME:
  Sys.setenv(SPARK_HOME = "C:\\Apps\\Apache\\spark-2.0.0\\")

  ## SPARKR_DRIVER_R: R_HOME from sys.getenv

  ## JAVA_HOME:

  ## WINUTILS_HOME:

# Set library path and load SparkR library
.libPaths(c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib"), .libPaths()))
library(SparkR)


# This script for running Spark code from the R Console, or Rstudio
Sys.getenv() # ensure the environmental variables are set as stated above

library(SparkR, lib.loc = c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib")))

# note: did not run Start up file to get this to work...start_up changes the Java directory, don't forget!!!!
# Java: make sure that you set the Java directory with JRE - is working, currently version Java8 is working.
sparkR.session(enableHiveSupport = FALSE ,
               master = "local[*]", 
               sparkHome = Sys.getenv("SPARK_HOME") , # this was the missing link!!
               sparkConfig = list(spark.driver.memory = "2g", 
                                  spark.sql.warehouse.dir="C:\\Apps\\winutils\\winutils-master\\hadoop-2.7.1") # winutils path directory

               sparkConfig = list(spark.driver.memory = "5g", spark.executor.memory = "25g" ,
                                  spark.driver.cores = "250", spark.rpc.message.maxSize="1024")
              )

df <- as.DataFrame(faithful)
str(df)
colnames(df)
histogram(df$waiting)

createOrReplaceTempView(df, "df")

waiting_70 <- sql("select * from df where waiting > 70")
str(waiting_70)
collect(waiting_70)

collect(summary(df))

corr(df, "waiting", "eruptions")

model <- spark.glm(df, eruptions ~ waiting)
summary(model)

# temp file code for downloading csv
temp_csv <- tempfile(fileext = ".csv")

***
***

# OTHER PACKAGES THAT ACCESS SPARK

# Initiate H20:
# https://github.com/h2oai/sparkling-water/tree/master/examples#step-by-step-through-weather-data-example

library(h2o)

# After starting H2O, you can use the Web UI at http://localhost:54321
h2o.init()
# or
h2o.shutdown()
h2o.init(nthreads = 4) # for 4 cores

# Pointing to a docker instance
dockerH2O <- h2o.init(ip = "192.168.59.103", port = 54321)

library(sparklyr)
my_context <- spark_connect(master = "spark://172.31.1.184:7077", spark_home = "/home/ubuntu/spark-2.0.0", version="2.0.0")
spark_disconnect(my_context)

***
***

# NOTES:
  ## COMMAND LINE: Launching java with spark-submit command C:\Apps\Apache\spark-2.0.0\/bin/spark-submit2.cmd   --driver-memory "2g" sparkr-shell C:\Users\z001c9v\AppData\Local\Temp\RtmpkTkRE7\backend_port3140155f461a 

