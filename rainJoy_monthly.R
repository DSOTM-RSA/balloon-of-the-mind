######################################################################################

# playing with rainfall data and visualisation
# Dan Gray, github.com/DSOTM-RSA

# source inspiration for chart type: github.com/ikashnitsky
# https://gist.github.com/ikashnitsky/2f6e29acbb9cbeb1694630c5932b8ad5

######################################################################################

# load libraries
library(tidyverse)
library(forcats)
library(ggjoy)
library(viridis)
library(extrafont)

# load monthly data: downlaod from ftp://ftp-cdc.dwd.de/pub/CDC/
monthly <- read_delim("~/Desktop/monthly/produkt_nieder_monat_18900101_20161231_00691.txt",
                      ";", escape_double = FALSE, trim_ws = TRUE)

# extract individual months and years
dateStr <- as.character(monthly$MESS_DATUM_BEGINN)
dateNum <- substr(dateStr, 1, 6) %>% as.double()
dateMonth <-substr(dateNum, 5, 6) %>% as.double()
dateYear <- substr(dateNum, 1, 4) %>% as.double()

# temporary data.frame for modifications
frame <- mutate(monthly, frameID = dateNum-dateNum[1],
                month = dateMonth, year = dateYear)

# convert factors to numeric and fix NaN
frame$STATIONS_ID <-as.factor(frame$STATIONS_ID)
frame$monthFct <-as.factor(frame$month)
frame$MO_RR[frame$MO_RR==-999] <-NA

# select, mutate, and plot in one go
frame %>% select (MO_RR,monthFct,year) %>% 
  mutate(labels=fct_recode(monthFct,"Januar" = "1", "Februar" = "2", "März" = "3", "April" = "4",
         "Mai"= "5", "Juni" = "6", "Juli" = "7", "August" = "8",
         "September" = "9", "Oktober" = "10", "November" = "11", "Dezember" = "12")) %>% 
  ggplot(aes(x=MO_RR,y=labels %>% fct_rev())) + 
  geom_joy(aes(fill=labels)) + 
  scale_fill_viridis(discrete=T,option="D", direction=-1,begin=.1,end=.9) + 
  labs(x = "Precipitation (mm)", y = "Month of Year",
       title = "Distribution of Historical Monthly Rainfall in Bremen (1890-2016)",
       subtitle = "Data: Der Deutsche Wetter Dienst: Climate Data Center (CDC)",
       caption = "github.com/DSOTM-RSA") +
  theme_minimal(base_family = "Ubuntu Condensed", base_size = 15) +
  theme(legend.position = "none")

ggsave("rainJoy_monthly.pdf",  width=8.3, height=5.8)
embed_fonts("rainJoy_monthly.pdf")


# historical total yearly
frame %>% filter(year<=2015 & year>=1891) %>% 
  mutate(grp = cut(year, breaks = c(1890,1915,1940,1965,1990,2015),
                    labels=c("1891-1915","1916-1940","1941-1965","1966-1990","1991-2015"))) %>% 
  select(MO_RR,monthFct,year,grp) %>% 
  group_by(year,grp) %>% 
  summarise(Total=sum(MO_RR)) %>% ungroup() %>% 
  ggplot(aes(x=Total,y=grp %>% fct_rev())) +
  geom_joy(aes(fill=grp),rel_min_height=0.01) + 
  scale_fill_viridis(discrete=T,option="D", direction=-1,begin=.1,end=.9) + 
  labs(x = "Total Yearly Precipitation (mm)", y = "Inteval",
       title = "Distribution of Historical Total Yearly Rainfall in Bremen (1891-2015)",
       subtitle = "Data: Der Deutsche Wetter Dienst: Climate Data Center (CDC)",
       caption = "github.com/DSOTM-RSA") +
  theme_minimal(base_family = "Ubuntu Condensed", base_size = 15) +
  theme(legend.position = "none")

ggsave("rainJoy_decadal_yearlyTotal.png", width=8.3, height=5.8)

ggsave("rainJoy_decadal_yearlyTotal.pdf", width=8.3, height=5.8)
embed_fonts("rainJoy_decadal_yearlyTotal.pdf")


# historical maximum monthly  
frame %>% filter(year<=2015 & year>=1891) %>% 
  mutate(grp = cut(year, breaks = c(1890,1915,1940,1965,1990,2015),
                   labels=c("1891-1915","1916-1940","1941-1965","1966-1990","1991-2015"))) %>% 
  select(MO_RR,monthFct,year,grp) %>% 
  group_by(year,grp) %>% 
  summarise(maxMonthly=max(MO_RR)) %>% ungroup() %>% 
  ggplot(aes(x=maxMonthly,y=grp %>% fct_rev()))+
  geom_joy(aes(fill=grp),rel_min_height=0.01) + 
  scale_fill_viridis(discrete=T,option="D", direction=-1,begin=.1,end=.9) + 
  labs(x = "Maximum Monthly Precipitation (mm)", y = "Inteval",
       title = "Distribution of Historical Maximum Monthly Rainfall in Bremen (1891-2015)",
       subtitle = "Data: Der Deutsche Wetter Dienst: Climate Data Center (CDC)",
       caption = "github.com/DSOTM-RSA") +
  theme_minimal(base_family = "Ubuntu Condensed", base_size = 15) +
  theme(legend.position = "none")  

ggsave("rainJoy_decadal_monthlyMaximum.pdf",  width=8.3, height=5.8)
embed_fonts("rainJoy_decadal_monthlyMaximum.pdf")


# historical maximum peak rainfall month
frame %>% filter(year<=2015 & year>=1891) %>% 
  mutate(grp = cut(year, breaks = c(1890,1915,1940,1965,1990,2015),
                   labels=c("1891-1915","1916-1940","1941-1965","1966-1990","1991-2015"))) %>% 
  select(MO_RR,month,year,grp) %>% 
  group_by(year,grp) %>% filter(MO_RR==max(MO_RR)) %>% 
  ungroup() %>% 
  ggplot(aes(x=month,y=grp %>% fct_rev()))+
  geom_joy(aes(fill=grp),rel_min_height=0.01) + 
  scale_fill_viridis(discrete=T,option="D", direction=-1,begin=.1,end=.9) + 
  labs(x = "Month of Year Where Maximum Monthly Rainfall Occurs", y = "Inteval",
       title = "Distribution of Historical Peak Monthly Rainfall in Bremen (1891-2015)",
       subtitle = "Data: Der Deutsche Wetter Dienst: Climate Data Center (CDC)",
       caption = "github.com/DSOTM-RSA") +
  theme_minimal(base_family = "Ubuntu Condensed", base_size = 15) +
  theme(legend.position = "none")    

ggsave("rainJoy_decadal_monthlyPosition.png", width=8.3, height=5.8)

ggsave("rainJoy_decadal_monthlyPosition.pdf", width=8.3, height=5.8)
embed_fonts("rainJoy_decadal_monthlyPosition.pdf")


# load daily data: downlaod from ftp://ftp-cdc.dwd.de/pub/CDC/
daily <- read_delim("~/Desktop/daily/produkt_nieder_tag_18900101_20161231_00691.txt",
                      ";", escape_double = FALSE, trim_ws = TRUE)

# extract individual months and years
dateStr <- as.character(daily$MESS_DATUM)
dateNum <- substr(dateStr, 1, 6) %>% as.double()
dateMonth <-substr(dateNum, 5, 6) %>% as.double()
dateYear <- substr(dateNum, 1, 4) %>% as.double()

# temporary data.frame for modifications
frame <- mutate(daily, frameID = dateNum-dateNum[1],
                month = dateMonth, year = dateYear)

# convert factors to numeric and fix NaN
frame$STATIONS_ID <-as.factor(frame$STATIONS_ID)
frame$yearFct <-as.factor(frame$year)
frame$monthFct <-as.factor(frame$month)
frame$RS[frame$RS==-999] <-NA



# historical maximum monthly  
frame_01 <-frame %>% filter(year<=2015 & year>=1891) %>% 
  mutate(grp = cut(year, breaks = c(1890,1915,1940,1965,1990,2015),
                   labels=c("1891-1915","1916-1940","1941-1965","1966-1990","1991-2015"))) %>% 
  select(RS,monthFct,yearFct,grp) %>% 
  group_by(monthFct,yearFct,grp) %>% 
  summarise(maxDay_Month=max(RS)) %>% ungroup() 


frame_02 <- frame %>% filter(year<=2015 & year>=1891) %>% 
  mutate(grp = cut(year, breaks = c(1890,1915,1940,1965,1990,2015),
                   labels=c("1891-1915","1916-1940","1941-1965","1966-1990","1991-2015"))) %>% 
  select(RS,monthFct,yearFct,grp) %>% 
  group_by(monthFct,yearFct,grp) %>% 
  summarise(tot_Month=sum(RS)) %>% ungroup() 

frame_tmp<-frame_01 %>% 
  mutate(dayContMonth = (maxDay_Month/frame_02$tot_Month)*100) %>% 
  filter(dayContMonth>=50) %>% add_count(dayContMonth) %>% 
  group_by(grp) %>% 
  summarise(tots=sum(n)) %>% 
  ggplot()+ geom_col(aes(x=grp,y=tots,fill=grp)) + 
  scale_fill_viridis(discrete = T) + 
  labs(x = "Inteval", y ="Number of Events (n)",
  title = "Historical Single Day Extreme Rainfall Events (>50% Monthly Total) in Bremen (1891-2015)",
  subtitle = "Data: Der Deutsche Wetter Dienst: Climate Data Center (CDC)",
  caption = "github.com/DSOTM-RSA") +
  theme_minimal(base_family = "Ubuntu Condensed", base_size = 13) +
  theme(legend.position = "none")  


frame_tmp

ggsave("rainJoy_daily_Extreme.png", width=8.3, height=5.8)

ggsave("rainJoy_daily_Extreme.pdf", width=8.3, height=5.8)
embed_fonts("rainJoy_daily_Extreme.pdf")
