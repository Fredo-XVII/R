# THIS IS CODE RELATED TO LEVELS

# SET WEEK DAY LEVELS IN ORDER
DATA$Day_of_Week <- factor(DATA$Day_of_Week, levels = c("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"))

# USING DATA FROM CALENDAR TABLE
## Use mo_i to order the months corretly for the levels.
month_lvls <- cal_date %>% select(mo_i, mo_abbr_n) %>% distinct() %>% arrange(mo_i)
month_lvls$mo_abbr_n <- factor(month_lvls$mo_abbr_n, levels = month_lvls$mo_abbr_n)
DATA2$mo_abbr_n <- factor(DATA2$mo_abbr_n, levels = month_lvls$mo_abbr_n)
