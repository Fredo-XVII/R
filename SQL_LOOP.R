# VERSION #1
# DATA loop to build data in Teradata

# Prep code # Read in query and prepare data frames
source('~/R/R_startup.R')

db_td <- odbcConnect('TDPRODA' , uid = uid , pwd = pwd)

SQL_FILE <- 'METRICS_DIFF_Q' # THE FILE SHOULD HAVE THE SAME NAME AS THE TABLE
SCHEMA <- 'SCHEMA_TD'  # THE SCHEMA OF THE TABLE IN TERADATA
pulls_query <- read_file(sprintf(paste0(SQL_FILE,'%s'), '.SQL'))

## Grab table schema from Teradata: ## Need to create example table in Teradata in order to grab columns.

### FIRST CREATE THE TABLE METADATA
drop_meta_query <- sprintf("DROP TABLE %s" , paste0(SCHEMA,'.',SQL_FILE) ) 
drop_meta <- sqlQuery(db_td , drop_meta_query)
build_meta0 <- gsub('ORDER','--ORDER', pulls_query, fixed = TRUE)
build_meta1 <- gsub('<"PERIOD_END"/>','2017-05-13', build_meta0, fixed = TRUE)
build_meta_query <- sprintf(
  "CREATE TABLE %s AS 
  (%s
  ) WITH NO DATA"
  , paste0(SCHEMA,'.',SQL_FILE) , build_meta1
)

build_meta_query1 <- sqlQuery(db_td , build_meta_query)

### 2ND - GRAB THE METADATA
table_meta <- sqlColumns(db_td, paste0(SCHEMA,'.',SQL_FILE) )
BASE_DATA <- data.frame(matrix(ncol = nrow(table_meta['COLUMN_NAME']), nrow = 0))
table_cols <- as.vector(table_meta$COLUMN_NAME)
colnames(BASE_DATA) <- table_cols

# Grab dates data for loops

cal_date <- sqlQuery(db_td, 
                     "
                     SELECT DISTINCT ACCT_WK_END_D
                     FROM SCHEMA.DATE_V
                     WHERE YEAR IN (2015, 2016, 2017)
                     AND GREG_D <= DATE '2017-05-13' -- CURRENT_DATE
                     ORDER BY WEEK_END_DATE
                     "
)

# Prep for loop

# Create loop - length(cal_date)

for(i in 1:nrow(cal_date) ) {
  print(cal_date[i,1])
  pulls_loop <- gsub('<"PERIOD_END"/>',cal_date[i,1], pulls_query, fixed = TRUE)
  loop_data <- sqlQuery(db_td, pulls_loop) 
  loop_data$ORG <- as.factor(loop_data$ORG) # not in other loops to address data quality issues in data lab.
  BASE_DATA <- bind_rows(BASE_DATA,loop_data)
}


write_rds(BASE_DATA,sprintf(paste0(SQL_FILE,'%s'), '.rds'))

# Close Connection
odbcClose(db_td)
rm(list= ls())
gc()

-----

# VERSION #2 

# Build Metrics by subbing in constraints.

# Run these scripts before this script for data build.
# 1. ES_upload_to_R.R
# 2. ITEMS_EDS_UPLOAD_TO_TD_VOL.R
# 3. THIS FILE!

#----Prep----
source('~/R/R_startup.R')
library(dbplyr)
db_td <- odbcConnect('PROD', uid = .uid, pwd = .pwd)

#----Import ElasticSearch data from Python Script run, in CSV format.----

#ES_EDS  <- fread(file = "DATA5.csv") # EDS_PULL_2017-11-05 - Copy.csv" , "EDS_PULL_2017-11-05.csv"

#----First grab parameters----

## Dates
MIN_D <- min(unique(ES_EDS_BASE$GREG_D))
MAX_D <- max(unique(ES_EDS_BASE$GREG_D))



#----Build Query Function for Metrics----

TD_QUERY <- function(QUERY) {
  # Parameters
  # QUERY <-  'BASE_DATA_FOR_METRICS' #'STR_SALES_METRICS' # 'BASE_DATA_FOR_METRICS'
  #MIN_D <- '2017-11-01'
  #MAX_D <- '2017-11-01'
  # Gsub
  load_query <- read_file(sprintf(paste0(QUERY,'%s'), '.SQL'))
  build_query1 <- gsub("SCHEMA", td_schema, load_query)
  build_query2 <- gsub('<MIN_DATE>', MIN_D, build_query1)
  build_query3 <- gsub('<MAX_DATE>', MAX_D, build_query2)
  build_query4 <- gsub('STORE_TABLE', STORES_TBL_NAME, build_query3)
  build_query5 <- gsub('ITEM_TABLE', ITEMS_TBL_NAME, build_query4)
  pull_data <- sqlQuery(db_td, build_query5)
  pull_data <- as.data.table(pull_data)
  setkey(pull_data, CO_LOC_I, MDSE_ITEM_I, GREG_D)
  assign(paste0(QUERY,'_BASE'), pull_data, envir = .GlobalEnv)
  rm(pull_data)
  sprintf("Completed Query %s.SQL",QUERY)
}


TD_QUERY_ATTR <- function(QUERY) {
  # Parameters
  # QUERY <-  'BASE_DATA_FOR_METRICS' #'STR_SALES_METRICS' # 'BASE_DATA_FOR_METRICS'
  load_query <- read_file(sprintf(paste0(QUERY,'%s'), '.SQL'))
  build_query11 <- gsub("SCHEMA", td_schema, load_query)
  build_query12<- gsub('STORE_TABLE', STORES_TBL_NAME, build_query11)
  build_query13 <- gsub('ITEM_TABLE', ITEMS_TBL_NAME, build_query12)
  pull_data <- sqlQuery(db_td, build_query13)
  pull_data <- as.data.table(pull_data)
  assign(paste0(QUERY,'_BASE'), pull_data, envir = .GlobalEnv)
  rm(pull_data)
  sprintf("Completed Query %s.SQL",QUERY)
}

#----Build Data----

# Build Base Data
TD_QUERY(QUERY = 'BASE_DATA_FOR_METRICS')

# Build Sales Data
TD_QUERY(QUERY = 'STR_SALES_METRICS')

# Build Item Attribute Data
TD_QUERY_ATTR(QUERY = 'ITEM_ATTR')


# Build Store Attribute Data
TD_QUERY_ATTR(QUERY = 'STORE_ATTR')
STORE_ATTR_BASE$MTHS_OPEN <- interval(STORE_ATTR_BASE$CO_LOC_OPEN_D, today()) %/% months(1) #TODAY = '2017-11-29'

