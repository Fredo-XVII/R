
library("RJDBC")
drv <- JDBC("com.sap.db.jdbc.Driver", "C:/Users/xxxx/Desktop/HANA JDBC Drivers", "'")
conn <- dbConnect( drv,"jdbc:sap://<host>:<port>/?currentschema=<your HANA Schema>", "HANA User ID", "HANA Password")
res <- dbGetQuery(conn, "select * from Schema.Table")
