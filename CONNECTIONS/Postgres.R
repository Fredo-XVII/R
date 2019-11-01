# Testing Connection

library(RPostgres)
# Postgres Connection
con <- RPostgres::dbConnect(
  RPostgres::Postgres(),
  dbname = 'dbname',
  host = 'server.hq.co.com',
  port = 5432,
  user = 'user',
  password = 'password'
)

DBI::dbWriteTable(con, name = "prod.iris", value = iris, row.names = FALSE, overwrite = TRUE)
RPostgres::dbDisconnect(con)

RPostgres::dbWriteTable(conn = con, 
                        row.names = FALSE,
                        prefix = "landing",
                         name = "iris",
                         value = iris,
                         overwrite = TRUE)

RPostgres::dbWriteTable(con, name = DBI::Id(schema = "landing", table = "iris"), value = iris, overwrite = TRUE)

RToolShed::to_postgres(iris,con,"iris","prod")

RPostgres::dbGetRowCount(RPostgres::dbGetQuery(con, "select * from prod.iris"))
RPostgres::dbGetQuery(con, "select * from prod.iris")
RPostgres::dbDisconnect(con)


