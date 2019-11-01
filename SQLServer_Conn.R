# Connection set up for SQLServer

#devtools::install_github("rstats-db/RPostgres")
require(DBI)
require(RJDBC)
require(dplyr)

ssDriverPath = "/Users/A######/Library/SQLWorkbenchJ/sqljdbc4.jar"

#drv = JDBC("com.microsoft.sqlserver.jdbc.SQLServerDriver","c:/Users/A######/.dbeaver-drivers/drivers/mssql/sqljdbc4.jar")

ssDriver = JDBC("com.microsoft.sqlserver.jdbc.SQLServerDriver",ssDriverPath)

ssConn <- dbConnect(ssDriver, "jdbc:sqlserver://SQL####xx##:####", "SERVERNAME", "PWD")

#con <- dbConnect(drv, "jdbc:sqlserver://SQL####xx##:####", .rs.askForPassword("Enter LAN ID"), .rs.askForPassword("Enter Password"))

ss <- dbGetQuery(ssConn, sprintf("select * from SCHEMA.%s", compareTableName))
