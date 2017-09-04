# Step 1: Import and Arrange with Lookup Tables ----

# loading libraries
library(lubridate) # simple conversion of dates
library(tidyverse) # loading the tidyverse


raw.data <- read_delim("statTabsAgg.tsv","\t", escape_double = FALSE, trim_ws = TRUE)  
raw.data$yrs <-year(raw.data$date) 

# making wind roses
pieces <- c(0,30,60,90,120,150,180,210,240,270,300,330)
raw.data$sgs <- findInterval(raw.data$wind_direction,pieces)

# deal with NA's
raw.data$wind_direction[raw.data$wind_direction == 999] <- NA
raw.data$wind_speed[raw.data$wind_speed >= 999] <- NA

summary(raw.data)

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
ggsave("windRose_mean.svg")


ggplot(df.locales) + 
  geom_rect(aes(group=sgs,fill=mean.speed,ymax=pieces.max,ymin=pieces,xmax=enr_frc,xmin=0)) + 
  coord_polar(theta="y") + facet_wrap(~usaf_station,ncol = 4) +
  scale_fill_continuous(low = "blue",high = "red","MWS [m.s.-1]") + theme_bw()
ggsave("windRose_locales.svg")


bigPlot<-ggplot(df.yearly) + 
  geom_rect(aes(group=sgs,fill=mean.speed,ymax=pieces.max,ymin=pieces,xmax=enr_frc,xmin=0)) + 
  coord_polar(theta="y") + facet_wrap(~usaf_station+yrs,ncol = 12) +
  scale_fill_continuous(low = "blue",high = "red","MWS [m.s.-1]") + theme_bw()
ggsave("very-large-canvas.svg",width = 40, height = 30, units = "in" )

# one can see station 102340 is problematic (2010,2011,2012)

