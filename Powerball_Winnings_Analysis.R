library(RCurl)
library(XML)
library(histogram)
pb_winnings_url <- "http://www.powerball.com/powerball/winnums-text.txt"

## emailed file to myself from website
outfile_txt <- "C:\\Users\\Z001C9V\\Documents\\Data\\PwBll_winnings.txt" # fixed missing values in Excel
outfile_csv <- "C:\\Users\\Z001C9V\\Documents\\Data\\PB Winnings.csv"

powball <- read.csv(outfile_csv, header = TRUE)
str(powball)
powball$date <- as.Date(powball$Draw_Date, format = "%m/%d/%Y")
powball$date
powball$wkdays <- weekdays(powball$date)
diff(powball$date)

## Histogram
draws <- stack(powball[,2:5])#,powball[,3],powball[,4],powball[,5])
hist(draws$values,plot = TRUE)
hist_pb <- histogram(powball$PB,type = "regular" , breaks = 36,control = list(between=FALSE,maxbin = 138))#,plot = TRUE)
str(hist_pb)
head(hist_pb)

freqs <- data.frame()
for (i in 1:69){
       freqs[i] <- 0 
}

for (i in 1:length(draws)) {
        
        if (draws$values[i] = i) {
                freqs$[i] <- freqs[i] + 1
        }       
}
