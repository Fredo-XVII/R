#setup
z.id <- "xxxxx" # readline("input z-ID:")#pop up in console
start.date <- "2016-10-05"
end.date <- "2016-10-06"
store.list <- 3117 # co_loc_i

# sales floor volatile table pull 
cn <- odbcConnect("xxxxx", z.id, .rs.askForPassword("input password:"))
file <- read_file(paste0("C:/Users/", z.id, "/Documents/GitHub/Operational-Clock/Op Clock - SQL/prod/filename.sql"))
file <- gsub("[start_date]", start.date, file, fixed=TRUE)
file <- gsub("[end_date]", end.date, file, fixed=TRUE)
file <- gsub("[store_inputs]", store.list, file, fixed=TRUE)
# write_file(file, "filename.sql")
# test <- sqlQuery(cn, "select * from file ;")
