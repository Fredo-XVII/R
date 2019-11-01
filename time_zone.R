# From lutz (aka - lookup time zone): from lat longs
co_loc_tz <- co_loc_dta %>%
  mutate(co_loc_tz = tz_lookup_coords(lat,long, method = "accurate"))

-----

# From Wikipedia: scrape website
library(rvest)

url_tz_gmt <- "https://en.wikipedia.org/wiki/List_of_tz_database_time_zones"

tz_gmt_dta <- url_tz_gmt %>% 
  read_html() %>% 
  html_nodes(xpath = '//*[@id="mw-content-text"]/div/table[1]') %>% 
  html_table() %>% 
  as.data.frame() %>% select(-notes.) %>% 
  filter(`CC.` == 'US')

tz_gmt_cols <- c("CC", "COORDINATES","TZ","COMMENTS","FORMAT","UTC_OFFSET","UTC_DST_OFFSET","NOTES")
names(tz_gmt_dta) <- tz_gmt_cols

tz_gmt_dta <- tz_gmt_dta %>% 
  mutate(lat)

tz_gmt_dta %>% head()

-----

# From IP2locationdata: provides GMT offset
library(IP2locationdata)
ip_zip_dta <- ip2locationData::ip2location.lite.db11 %>% 
  as.data.frame() %>% filter(Country == "United States" & Region != "-") %>% 
  arrange(Region, City, Lat, Long) %>% 
  select(Country, Region, City, Zip, GMT) %>% 
  distinct()

