# CONNECTIONS JDBC
```{r}
TeradataDriver <- JDBC(
  "com.teradata.jdbc.TeraDriver",
  "C:\\Apps\\Teradata\\TeraJDBC__indep_indep.16.00.00.23\\terajdbc4.jar;C:\\Apps\\Teradata\\TeraJDBC__indep_indep.16.00.00.23\\tdgssconfig.jar",
  identifier.quote = "`"
)

jdbc_td <-
  dbConnect(
    TeradataDriver,
    "jdbc:teradata://tdproda/LOGMECH=LDAP", as.character("Z001C9V") , as.character(.rs.askForPassword("pwd:"))
  )
str(jdbc_td)
```
