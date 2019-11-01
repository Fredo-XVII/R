# Connection string for hadoop using RODBC

```{r setup, include=FALSE}
library(odbc)
db_br2 = dbConnect(odbc::odbc(),
               'hadoop',
               uid = .uid,
               pwd = .pwd)

knitr::opts_chunk$set(echo = TRUE)
knitr::opts_chunk$set(connection = "db_br2")
```

```{sql, output.var = "df1"}
select * from schema.table
```
