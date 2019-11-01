# R Connect to Teradata

#ODBC

library(teradataR)
library(RODBC)

#JDBC

# on computer: C:\Program Files (x86)\Teradata\Client\14.10\Teradata Studio\plugins\com.teradata.datatools.terajdbc_14.10.0.201310271220
# the tdgssconfig.jar and terajdbc4.jar file location

library(RJDBC)
library(stringr)

# drv = JDBC("com.teradata.jdbc.TeraDriver","c:\\terajdbc\\terajdbc4.jar;c:\\terajdbc\\tdgssconfig.jar")
drv = JDBC("com.teradata.datatools.terajdbc_14.10.0.201310271220" , 
           "C:\Program Files (x86)\Teradata\Client\14.10\Teradata Studio\plugins\com.teradata.datatools.terajdbc_14.10.0.201310271220\terajdbc4.jar" ,
           "C:\Program Files (x86)\Teradata\Client\14.10\Teradata Studio\plugins\com.teradata.datatools.terajdbc_14.10.0.201310271220\tdgssconfig.jar"
           )

# conn = dbConnect(drv,"jdbc:teradata://system/TMODE=ANSI","user1","password1")

# dbGetQuery(conn,"select * from dbc.dbcinfo where date =? " , '2015-12-01')

################
#DB Connect
################
# .jaddClassPath("/MyPath/terajdbc4.jar")
# .jaddClassPath("/MyPath/tdgssconfig.jar")
# drv = JDBC("com.teradata.jdbc.TeraDriver","/MyPath/tdgssconfig.jar","/MyPath/terajdbc4.jar")
# conn = dbConnect(drv,"jdbc:teradata://MyServer/CHARSET=UTF8,LOG=ERROR,DBS_PORT=102
