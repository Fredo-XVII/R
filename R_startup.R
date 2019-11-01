#set R memory
#Sys.getenv()
#Sys.setenv(R_GC_MEM_GROW = 3)
#Sys.setenv(R_MAX_MEM_SIZE = 5000)

#set Pw
.uid <- .rs.askForPassword("ZID: ")
.pwd <- .rs.askForPassword("LAN ID:")

# Set Java Home for 32bit JRE
#Sys.setenv("JAVA_HOME" = "C:\\Program Files (x86)\\Java\\jre1.8.0_101")

# Set Java HOME for 64bit JRE: JAVA - https://java.com/en/download/manual.jsp
Sys.setenv("JAVA_HOME" = "C:\\Program Files\\Java\\jre1.8.0_131")
#Sys.setenv(CLASSPATH="<path_from_above>")

# Set ODBC for 64bit Teradata Driver
Sys.setenv(DataConnectorLibPath = "C:\\Program Files\\Teradata\\Client\\16.00\\bin")
#***NOTE When setting up the 64bit TD driver, you have to select ldap as the security feature***

# This script is for sourcing common packages

# tidyverse tools
#library("plyr")
# library("dplyr") #Hadley Wickham - tidyverse
# library("tidyr") #Hadley Wickham - tidyverse
# library("readr") #Hadley Wickham - tidyverse
# library("ggplot2") #Hadley Wickham - tidyverse
# library("tibble") #Hadley Wickham - tidyverse
# library("purrr") #Hadley Wickham - tidyverse
library("lubridate") #Hadley Wickham
library("stringr") #Hadley Wickham
library("dtplyr") # combined dplyr + data.table
library("reshape") #Hadley Wickham
library("reshape2") #Hadley Wickham
library("feather") #Hadley Wickham
library("tidyverse") #Hadley Wickham

library("data.table") #deblow

# Visualization Tools
library("rbokeh") #Continuum
library("ggvis") #Hadley Wickham

#library(googleVis) # Google, create google charts
library("RColorBrewer")
library("plotly") # PLOTLY
library("colorRamps")

# Connectivity Tools
#library(teradataR)
library("RJDBC")
library("RODBC")
library("sqldf")

#cat("\014")
