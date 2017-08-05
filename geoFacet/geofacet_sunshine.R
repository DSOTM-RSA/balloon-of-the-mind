######################################################################################

# playing with weather data and visualisation
# Dan Gray, github.com/DSOTM-RSA

######################################################################################

library(tidyverse)
library(geofacet)
library(viridis)
library(extrafont)


where<-getwd()	# get home-dir

# load data: available ftp://ftp-cdc.dwd.de/pub/CDC/regional_averages_DE/annual/sunshine_duration/
data <- read_delim("regional_averages_sd_year.txt",
                  ";", escape_double = FALSE, trim_ws = TRUE,skip = 1)

sun <- data %>% select(-Jahr_1,-Deutschland,-X20,-`Brandenburg/Berlin`,
                       -Niedersachsen,-`Thueringen/Sachsen-Anhalt`) %>% 
  gather(.,key="state",value="amount",-Jahr) %>% 
  mutate(state=factor(state,levels=unique(state)))

# calculate variability
group_stats <- sun %>% group_by(state) %>% 
  summarise(Range = (max(amount)-min(amount))/max(amount)*100)

  
# build a grid   
mygrid <- data.frame(
  code=c("1","2","3","4","5","6","7","8","9","10","11","12","13"),
 name = c("Mecklenburg-Vorpommern", "Schleswig-Holstein", 
          "Brandenburg", "Sachsen-Anhalt", "Niedersachsen/Hamburg/Bremen", 
          "Nordrhein-Westfalen", "Sachsen", "Hessen", 
          "Thueringen", "Rheinland-Pfalz", "Baden-Wuerttemberg", "Bayern", "Saarland"),
  row = c(2, 2, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 6),
  col = c(5, 3, 5, 4, 3, 2, 5, 3, 4, 2, 3, 4, 1),
  stringsAsFactors = FALSE)

geofacet::grid_preview(mygrid)

# create facet plot based on user-generated grid
ggplot(sun,aes(Jahr,amount)) + geom_line(color="black") + 
  geom_smooth(size=0.75,color="steelblue") +
  facet_geo(~state,grid=mygrid) +
  scale_fill_viridis(discrete=T)+ 
  labs(title = "Historical Trends in Sunshine across German States (*some missing)",
       subtitle = "Data: Der Deutsche Wetter Dienst: Climate Data Center (CDC)",
       caption = "github.com/DSOTM-RSA",
       x = "Year",
       y = "Total Sunshine (hours)") +
  theme_bw(base_family = "Ubuntu Condensed", base_size = 11) + 
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
panel.background = element_blank(), axis.line = element_line(colour = "black"),
strip.text.x = element_text(size = 8)) 

ggsave(file=paste0(where,"/figs/geofacet_sunshineTrends.pdf"),  width=8.3, height=5.8)
embed_fonts(file=paste0(where,"/figs/geofacet_sunshineTrends.pdf"))

