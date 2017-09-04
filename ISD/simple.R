# Loading libraries
library(tidyverse) # loading the tidyverse
library(xts)
library(dygraphs)
library(padr)

raw <- read_delim("statTabsAgg.tsv","\t",
                  escape_double = FALSE, trim_ws = TRUE)

dat <- raw %>% thicken(interval = "month") 


coffee_day <- coffee %>% 
  thicken(interval = "day") %>% 
  group_by(time_stamp_day) %>% 
  summarise(total = mean(amount))
coffee_day

dat<-raw. %>% mutate(year=year(raw.data$date),
                         month=month(raw.data$date)) %>% 
  unite("times",date,time,sep="-")

rm(raw.data)

# make time scale for dygraphs
track<-as.POSIXct(dat$times,format="%Y-%m-%d-%H%M")