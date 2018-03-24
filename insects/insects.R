
library(tidyverse)
source("ROAM.r")

s005 <- read_csv("~/Downloads/journal.pone.0185809.s005.csv")
s004 <- read_csv("~/Downloads/journal.pone.0185809.s004.csv")

captures <- s004 %>% mutate(expPeriod = to.daynr-from.daynr,
                            avgAcc=(biomass/expPeriod))

locales <- captures %>% 
  group_by(location.type)

# distribution plot  
ggplot(locales, aes(avgAcc, ..count.. , colour=factor(year), fill=factor(year))) +
  geom_density(position="fill",alpha=0.45,adjust=1) +
  xlab("Average Biomass Accumulation (g/D)") +
  ylab("Density (Proportion of Occurences)") +
  theme_plain(base_size = 9)

ggsave(filename = "density-accumulation.png",width=8,height=5)
  
# traditional plot
ggplot(captures,aes(mean.daynr,avgAcc,color=year,size=expPeriod)) + 
  geom_point() + 
  scale_size_area(max_size = 8,breaks=c(5,15,30,45)) +
  scale_color_gradient(low="blue",high="red") +
  xlab("Day of Year") +
  ylab("Average Biomass Accumulation (g/D)") +
  labs(title="Decline in flying insect biomass at 69 Stations in Germany over the period 1989-2016",
       size="Trap Exposure Time") +
  guides(color=guide_colourbar(title="Year")) +
  coord_trans(y="log") + 
  scale_y_continuous(expand = c(0,0.5),breaks=c(0.5,5,20)) +
  scale_x_continuous(expand=c(0.1,0.1),breaks=c(90,150,210,270,330)) +
  theme_plain(base_size = 9) 

ggsave(filename = "temporal-accumulation.png",width=8,height=5)

# all stations
plot_list <- c("SLL1","LIN1","PLI1","NIE1","BLK1","LIE1")

s005_small <- s005 %>% filter(plot %in% plot_list)

s005_small <- s005_small %>% 
  mutate(site = factor(plot, levels = plot_list,ordered=TRUE))

# Preferred approach for day-to-day work
plots_site_year <- s005_small %>%
  group_by(site) %>%
  nest() %>%
  mutate(plot = map2(data, site, ~ggplot(data = .x,aes(x=daynr,y=temperature,color=factor(year)))  +
                       geom_point() +
                       geom_smooth() + 
                       #facet_wrap(~year) +
                       ggtitle(.y) +
                       ylab("T") +
                       xlab("Day of Year")))

print(plots_site_year)

map2(paste0(plots_site_year$site, ".png"), plots_site_year$plot, ggsave)
