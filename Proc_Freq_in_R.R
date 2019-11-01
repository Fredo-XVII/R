cars <- datasets::mtcars

library(plyr)
z <- data.frame(table(cars[c('vs')]))
mutate(z, relFreq = prop.table(Freq), Cumulative_Freq = cumsum(Freq), 
       Cumulative_Relative_Freq = cumsum(relFreq))
