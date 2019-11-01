# Connect to PostgreSQL
library(RPostgreSQL)

con <-dbConnect(RPostgreSQL :: PostgreSQL(), 
                dbname = 'dbname',
                host = "host",
                port = port,
                user = "user",
                password = "password")
dbGetQuery(con, "select * from schema.table")


library(RPostgres)

con <- dbConnect(
    RPostgres::Postgres(),
    dbname = 'database_name',
    host = 'host_address',
    port = 5432,
    # or any other port specified by your DBA
    user = 'username',
    password = 'get_yr_own_pw'
)

# Push df to schema other than public (default)
RPostgres::dbWriteTable(con, name = DBI::Id(schema = "landing", table = "iris"), value = iris, overwrite = TRUE)
