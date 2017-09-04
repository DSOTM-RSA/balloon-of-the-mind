
library(tidyverse) # loading the tidyverse


raw.data <- read_delim("statTabsAgg.tsv","\t", 
                       escape_double = FALSE, trim_ws = TRUE)  

raw.data$date <- as.character(raw.data$date)

dat<-raw.data %>% separate("time",c("hour","min"),sep=2) %>% 
  unite("times", hour, min, sep=":") %>% unite("time",date,times, sep = " ") 

write_csv(dat,path = "tempFile.csv")

rm(raw.data,dat)

dat.DT <- read_delim("tempFile.csv",",", 
                       escape_double = FALSE, trim_ws = TRUE) 

# identify missing values 
dat.DT$wind_speed[dat.DT$wind_speed >= 100] <- NA

# use only complete cases
dat.DT <- dat.DT %>% filter(complete.cases(.))

library(padr)

mean_speed_by_station <-dat.DT %>% thicken(interval = "day") %>% 
  mutate(stations = as.factor(usaf_station)) %>% 
  group_by(stations,time_day) %>% 
  summarise(mu_wind_speed = mean(wind_speed))


ggplot(aes(time_day,mu_wind_speed,colour=factor(stations)),
       data = mean_speed_by_station) + 
  geom_line() + facet_grid(stations~.)
       



