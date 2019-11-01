### FUTURE IDEAS
  # GRAB THE PACKAGE NAMES DIRECTLY FROM THE R VERSION LIB FOR CURRENT TO CREATE CSV.  THE IDEA IS THAT YOU COULD THEN RUN
  # THE WHOLE PROCESS FROM THE NEW VERSION OF R, WITHOUT HAVING TO GO BACK AND FORTH BETWEEN R VERSION.
  # BASICALLY WOULD ELIMINATE STEP#2.
  # Code: library("reshape", lib.loc="C:/Apps/R/R-3.2.2/library")
  # Resource on how to control library location:
    https://www.stat.osu.edu/computer-support/mathstatistics-packages/installing-r-libraries-locally-your-home-directory

### FROM THE NEW VERSION OF R:

# choose.dir() - provides the proper path format for your system.
OLD_R_VERSION <- "R-3.3.1"

filepath <- sprintf('C:\\Apps\\R\\%s\\library',OLD_R_VERSION) 
  
old_pkg_list <- list.files(filepath)

cur_pkg_list <- as.data.frame(installed.packages(lib.loc = .libPaths()),stringsAsFactors = FALSE )$Package

add_list <- !(old_pkg_list %in% cur_pkg_list)

install.packages(old_pkg_list[add_list])

-----

### Old version of package transfer

## saving to 
## File locations
file_cur <- 'C:\\Users\\z001c9v\\Documents\\R\\Package_list_current.csv'
file_list <- 'C:\\Users\\z001c9v\\Documents\\R\\Package_list.csv'

## Get the full details of the current packages
pckgs_current <- installed.packages()
pckgs_ds <- as.data.frame(pckgs_current)


write.csv(pckgs_ds, file = file_cur , row.names = FALSE)

### STEP #1:
## Get the list of packages from current R version
pckgs <- installed.packages()
num_rows <- nrow(as.data.frame(pckgs))
pckgs_list <- pckgs[1:num_rows] # save to .Rdata when closing
#pckgs_list <- pckgs[1:num_rows,1] # need to specify first column of the packages

# Write to Disk to import into the new R version
write.csv(pckgs_list, file = file_list , row.names = FALSE)

### STEP #2:
## GUI - Select new R version, then shutdown RStudio

### STEP #3:
## Install packages into new version of R. Change to new R verions in Tools->Options before running this code
print("Installing required packages from Internet")

## Load current packages to R
pckgs_list <- read.csv(file_list)

## Example of format: list.of.packages <- c("plyr", "reshape2","readxl","data.table" , "utils")
list.of.packages <- pckgs_list
list.of.packages <- pckgs_list[[1]] # need to grab the first of the list created, don't know why this is the case.
new.packages <- list.of.packages[!(pckgs_list %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages) 

### STEP #4: IF NECESSARY
## Installed packages using git
#1 Teradata - using install gui works best if code below doesn't run
install.packages("C:/Apps/R/teradataR-master/build/teradataR_1.1.0.tar.gz", repos = NULL, type = "source")
# 2 more packages needed to install from git
# 3 

### STEP #5:
## Package check to ensure that there is at least the same number as before
pckgs_new <- installed.packages()
num_rows_new <- nrow(as.data.frame(pckgs))
isTRUE((num_rows_new >= num_rows))

----- 

### Cool code involving installing packages

#### The following two commands remove any previously installed H2O packages for R.
if ("package:h2o" %in% search()) { detach("package:h2o", unload=TRUE) }
if ("h2o" %in% rownames(installed.packages())) { remove.packages("h2o") }

#### Next, we download packages that H2O depends on.
pkgs <- c("methods","statmod","stats","graphics","RCurl","jsonlite","tools","utils")
for (pkg in pkgs) {
    if (! (pkg %in% rownames(installed.packages()))) { install.packages(pkg) }
}

#### Now we download, install, and initialize the H2O package for R.
install.packages("h2o", type = "source", repos = "http://h2o-release.s3.amazonaws.com/h2o/rel-weierstrass/2/R")
install.packages(c("sparklyr","rsparkling"))

#### Test the install of sparklyr
library(sparklyr)
library(tidyverse)
options(rsparkling.sparklingwater.version = "2.2.0")
library(rsparkling)

sc <- spark_connect(master = "yarn-client", 
                    version="2.2", 
                    config = list("spark.dynamicAllocation.enabled" = "false",
                                 "spark.speculation" = "false"), 
                    spark_home = Sys.getenv("SPARK_HOME"))

test_df <- tbl(sc, 'prd_sed_fnd.cal_date')
str(test_df)

-----

#### Github

pack <- installed.packages()


library(devtools)
install_github("amplab-extras/SparkR-pkg", subdir="pkg")


