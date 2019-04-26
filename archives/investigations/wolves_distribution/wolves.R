library(readr)
library(tidyverse)
library(deldir)

# load ROAM functions
setwd("~/Documents/GitArchive/porkBelly/")
source("ROAM.r")


# read data
setwd("~/Documents/GitArchive/porkBelly/experiments/wolves/")
wolf_data <- read_delim("wolf_data_2014.tsv",
                        "\t", escape_double = FALSE, trim_ws = TRUE)


# complete the data by filling missing "data-slots"
complete.ts <-wolf_data %>% 
  complete(Jahr=full_seq(Jahr,1),nesting(Bundesland,Territorium),
           fill=list(Status="np",Repro=0,Welpen=0))


# create annotations
labs_status <-data.frame(Status=c("e","p","r","np"),
                         Name=c("Single","Pair","Pack","Not Present"),
                         stringsAsFactors = FALSE)


# find unique locations with newborns
locations <- complete.ts %>% 
  group_by(Territorium) %>% 
  summarise(welpen_sum = sum(Welpen)) %>%
  arrange(desc(Territorium)) %>% filter(.,welpen_sum>0)


# quick plot
locations %>% 
  ggplot(.,aes(fct_reorder(Territorium,welpen_sum,.desc = TRUE),welpen_sum)) +
                                         geom_col() + 
  theme_plain(base_size = 9) + scale_x_discrete(labels= abbreviate) +
  xlab("Territory") + ylab("Total Newborns (n)")


# load coordinates
coords_wolves <- read_delim("coords_wolves_2014.tsv","\t", 
                            escape_double = FALSE, trim_ws = TRUE)
# and join
locations_mapped <-left_join(locations,coords_wolves)


# mapping of locales :: projected map version (base)
library(mapproj)

# compute projection 
locations_projected <- mapproject(locations_mapped$Lon,
                                  locations_mapped$Lat, "mollweide")
# build plot
par(mar=c(0,0,0,0))
plot(locations_projected, asp=1, type="n", xlab="", ylab="",bty="n")
points(locations_projected, pch=20, cex=log(locations_mapped$welpen_sum), col="black")

# compute vorroni tesselation
vtess <- deldir(locations_projected$x, locations_projected$y)
plot(vtess, wlines="tess", wpoints="none", number=FALSE, add=TRUE, lty=1)


# mapping of locales :: ggplot version

# compute voronoi tesselation
voronoi_gg <- deldir(locations_mapped$Lon,locations_mapped$Lat)

# build plot
ggplot(data=locations_mapped,aes(Lon,Lat)) +
  geom_segment(aes(x=x1,y=y1,xend=x2,yend=y2),
               size=0.5,color="grey",data=voronoi_gg$dirsgs) + 
  stat_density_2d(aes(fill = ..level.., alpha = ..level..),bins=25, 
                  geom = "polygon",, color = NA) +
  scale_fill_gradient2("Density", low = "white", mid = "yellow", high = "red",midpoint = 0.25) +
  scale_alpha(range = c(0, 0.3), guide = FALSE) +
  geom_point(size=log(locations_mapped$welpen_sum)) +
  xlab("Longitude (E)") + ylab("Latitude (N)") + 
  labs(title="Distribution of Wolf Prospensity in Eastern Germany",
       subtitle="With Voronoi Tesselations Marking Locales (AZ Equal Area Projection)") +  
  theme_plain(base_size = 9) + 
  coord_map("azequalarea",orientation = c(51,13,5))

ggsave("voronoi_wolves-density.png",width=10,height=6)


# compute some basic stats
stats <- complete.ts %>% 
  group_by(Jahr,Bundesland,Status) %>% 
  summarise(n=n()) %>% filter(Status != "np") %>% 
  left_join(labs_status)

# plot :: ts of groups over time per region
ggplot(stats,aes(Jahr,n)) + geom_point() + 
  geom_smooth(method="lm",se=FALSE) +
  facet_grid(Bundesland ~ Name) +
  theme_plain(base_size = 9) +
  xlab("Year") + ylab("Count") +
  scale_y_continuous(expand=c(0.1,0.1),
                     breaks=c(0,2,4,6)) +
  scale_x_continuous(expand=c(0.1,0.1),
                     breaks=c(2000,2003,2006,2009,2012))

ggsave("ts_wolves-groups.png",width=10,height=6)

library(raster)
wc <- getData('worldclim', res=5,var="tmin")
plot(wc)

bfc <- extract(wc, coords_wolves[,2:3])
head(bfc)

e <- extent(SpatialPoints(coords_wolves[, 2:3]))

# 5000 random samples (excluding NA cells) from extent e
set.seed(0)
bg <- sampleRandom(wc, 5000, ext=e)
dim(bg)
## [1] 5000   19
head(bg)

d <- rbind(cbind(pa=1, bfc), cbind(pa=0, bg))
d <- data.frame(d)
dim(d)


library(rpart)
cart <- rpart(pa~., data=d)
printcp(cart)
plotcp(cart)

#

plot(cart, uniform=TRUE, main="Regression Tree")
text(cart, cex=.8)