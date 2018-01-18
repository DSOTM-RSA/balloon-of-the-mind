# Step 1: Import and Arrange with Lookup Tables ----

# loading libraries
library(lubridate) 
library(tidyverse) 
library(stringr)
library(extrafont)

source("customTheme.R")

# load saved DF of parsed data
setwd("~/Documents/dataR")
stationData_Raw <- read_delim("station_tables.tsv","\t", escape_double = FALSE, trim_ws = TRUE)  

# setting up dates
stationData_Raw$year <- str_sub(stationData_Raw$date,1,4)
stationData_Raw$month <- str_sub(stationData_Raw$date,5,6)
stationData_Raw$day <- str_sub(stationData_Raw$date,7,8)

stationData_Raw$hour <- str_sub(stationData_Raw$time,1,2)
stationData_Raw$minute <- str_sub(stationData_Raw$time,3,4)
stationData_Raw$second <- rep("00",nrow(stationData_Raw))

# construct datetime with lubridate
stationData_Raw$datetime<-ymd_hms(paste(stationData_Raw$year, 
                                 stationData_Raw$month,
                                 stationData_Raw$day, 
                                 stationData_Raw$hour, 
                                 stationData_Raw$minute, 
                                 stationData_Raw$second, sep="-"))

# selecting initial variables of interest
stationData_Trimmed <- stationData_Raw %>% select(.,usaf_station,elevation,wind_direction,
                                wind_speed,visibility_distance,datetime)


# join to station meta-data file
statscpt <- read_csv("statscpt.txt",
                     col_names = FALSE)

stationData_Joined<-dplyr::left_join(stationData_Trimmed,statscpt,
                                by=c("usaf_station"="X1"))

# choose final variables
Wind <- stationData_Joined %>% rename(location = X3,
                            lat = X4, lon = X5) %>% select(.,-X2,-X6,-X7)

# fix column types
Wind$wind_speed <-as.numeric(Wind$wind_speed)
Wind$wind_direction <-as.numeric(Wind$wind_direction)
Wind$usaf_station <-as.factor(Wind$usaf_station)

# deal with NA's
Wind$wind_direction[Wind$wind_direction == 999] <- NA
Wind$wind_speed[Wind$wind_speed >= 999] <- NA

summary(Wind)

# remove prep files
rm(stationData_Raw,stationData_Trimmed,stationData_Joined,statscpt)

# write data to file
write.table(Wind,file="Wind.tsv",sep="\t",col.names=T,row.names = FALSE)

# quick plot of data
ggplot(Wind,aes(usaf_station, wind_speed, fill=location)) +
  geom_violin(scale="width",trim=FALSE,draw_quantiles = c(0.50)) + 
  xlab("USAF Station ID") + 
  ylab("Wind Speed (km/s)") + 
  labs(title="Wind Profiles in the Cape Town Region (2000 - 2015)",
                                   subtitle="50% Quantile marked by Horizontal Lines",
       fill="Station Name") +
  theme_plain(base_size = 12)


# making wind roses
pieces <- c(0,30,60,90,120,150,180,210,240,270,300,330)
stationData_Raw$sgs <- findInterval(stationData_Raw$wind_direction,pieces)

# deal with NA's
stationData_Raw$wind_direction[stationData_Raw$wind_direction == 999] <- NA
stationData_Raw$wind_speed[stationData_Raw$wind_speed >= 999] <- NA

summary(stationData_Raw)

# make mini lookup table
lookUp.slices <- data.frame(
  sgs = 1:12, pieces = pieces)


# Step 2: Aggregation and Plotting ----

# i. overall aggregate
df.aggregates <- raw.data %>%  group_by(sgs) %>% 
  summarise(tot=n(),mean.speed=mean(wind_speed,na.rm = TRUE)) %>% 
  mutate(frac=tot/sum(tot)*100) %>% 
  mutate(we_eng = mean.speed*frac/(sum(mean.speed))) %>% 
  mutate(enr_frc = we_eng/sum(we_eng)*100) %>% left_join(.,lookUp.slices) %>% 
  mutate(pieces.max = pieces+30)

# ii. summarise by locations
df.locales <- raw.data %>%  group_by(usaf_station,sgs) %>% 
  summarise(tot=n(),mean.speed=mean(wind_speed,na.rm = TRUE)) %>% 
  mutate(frac=tot/sum(tot)*100) %>% 
  mutate(we_eng = mean.speed*frac/(sum(mean.speed))) %>% 
  mutate(enr_frc = we_eng/sum(we_eng)*100) %>% left_join(.,lookUp.slices) %>% 
  mutate(pieces.max = pieces+30)

# iii. summarise by locations and year
df.yearly <- raw.data %>% group_by(usaf_station,yrs,sgs) %>% 
  summarise(tot=n(), mean.speed=mean(wind_speed,na.rm=TRUE)) %>% 
  mutate(frac=tot/sum(tot)*100) %>% 
  mutate(we_eng = mean.speed*frac/sum(mean.speed)) %>% 
  mutate(enr_frc = we_eng/sum(we_eng)*100) %>% left_join(.,lookUp.slices) %>% 
  mutate(pieces.max = pieces+30)


# plotting and saving with ggplot2
ggplot(df.aggregates) + 
  geom_rect(aes(group=sgs,fill=mean.speed,ymax=pieces.max,ymin=pieces,xmax=enr_frc,xmin=0)) + 
  coord_polar(theta="y") +
  scale_fill_continuous(low = "blue",high = "red","MWS [m.s.-1]") + theme_bw()

ggsave(file=paste0(where,"/figs/windRose_mean.svg"))


ggplot(df.locales) + 
  geom_rect(aes(group=sgs,fill=mean.speed,ymax=pieces.max,ymin=pieces,xmax=enr_frc,xmin=0)) + 
  coord_polar(theta="y") + facet_wrap(~usaf_station,ncol = 4) +
  scale_fill_continuous(low = "blue",high = "red","MWS [m.s.-1]") + theme_bw()

ggsave(file=paste0(where,"/figs/windRose_locales.svg"))


bigPlot<-ggplot(df.yearly) + 
  geom_rect(aes(group=sgs,fill=mean.speed,ymax=pieces.max,ymin=pieces,xmax=enr_frc,xmin=0)) + 
  coord_polar(theta="y") + facet_wrap(~usaf_station+yrs,ncol = 12) +
  scale_fill_continuous(low = "blue",high = "red","MWS [m.s.-1]") + theme_bw()

ggsave(file=paste0(where,"/figs/very_large_canvas.svg"),width =40, height = 30, units ="in")


# one can see station 102340 is problematic (2010,2011,2012)

