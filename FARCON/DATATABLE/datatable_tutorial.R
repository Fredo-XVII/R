# 

setwd('C:\\Users\\z001c9v\\Documents\\GitHub\\R\\FARCON\\DATATABLE\\')

library(data.table)
library(curl)
library(RCurl)

flights <- fread("http://raw.githubusercontent.com/wiki/arunsrinivasan/flights/NYCflights14/flights14.csv")

str(flights)

head(flights)

lax_list <- flights[dest == "LAX", carrier]
lax_dt <- flights[dest == "LAX", list(carrier)]
lax_carrier_dep_dt <- flights[dest == "LAX", list(carrier, dep_delay)]

# Group by aggregation
lax_carrier_counts <- flights[dest == "LAX", .N, by = carrier]
head(lax_carrier_counts)
lax_carrier_counts <- flights[dest == "LAX", list(count = .N), by = carrier]
lax_carrier_counts_avg <- flights[dest == "LAX", list(count = .N, avg_dep_delay = mean(dep_delay)), by = carrier]

# 2 column group by
orig_dest_counts <- flights[, list(count = .N, avg_dep_delay = mean(dep_delay)), by = c("origin","dest")]
orig_dest_counts[order(count)] # desc
orig_dest_counts[order(-count)] # asc

# Practice Questions:
# 1.  
jfk_lax <- flights[origin == "JFK" & dest == "LAX"]
# 2.
jfk_lax_summary <- jfk_lax[, list( num_flights = .N, 
                num_carriers = length(unique(c(carrier))),
                avg_dep_delay = mean(dep_delay),
                sd_dep_delay = sd(dep_delay)
                ), 
                by = c("origin")]

flights_origin_summary <- flights[, list( num_flights = .N, 
                                   num_carriers = length(unique(c(carrier))),
                                   avg_dep_delay = mean(dep_delay),
                                   sd_dep_delay = sd(dep_delay)
                                   ), 
                                  by = c("origin")]

#3. Conditional processing from the "by" statement
dep_delay_0 <- flights[, list(count = .N), by = .(dep_delay > 0)]

#4.


####

#Create new columns with :=
 
flights[,distance_per_air_time := distance / air_time]

# .SD notations -  need both .SD and .SDcols
agg_dep_arr <- flights[,
                       lapply(.SD, mean),
                       by = origin,
                       .SDcols = c("dep_delay","arr_delay")
                       ]

# Ttest
agg_lm <- flights[, 
                  list(test = t.test(dep_delay)$statistic, .N), 
                  by = origin
                  ]

### Now on to keys and joins

setkey(flights, origin)
jfk <- flights[.(("JFK"))] # . = list
unique(jfk$dest)

setkey(flights, origin, dest)
jfk <- flights[.(c("JFK","LAX"))]
unique(jfk$dest)

# Practic exercises
# Create the emp_shoes data.table
emp_shoes <- data.table(
  emp_id = sample(1:100000) ,
  shoe_size = as.numeric(sample(5:12, 100000, replace = TRUE))
)
#
emp_brands <- data.table(
  emp_id = sample(1:100000, size = 50000, replace = F) ,
  shoe_brand = sample(c("A","B","C","D","E")) ,
  emp_age = as.numeric(sample(25:50, size = 50000, replace = T)) 
)
# Join
setkey(emp_shoes, emp_id)
setkey(emp_brands, emp_id)
# Perform the join
emp_data <- emp_shoes[emp_brands]













