library(readr)
library(padr)
library(tidyverse)
library(knitr)
library(kableExtra)

setwd("~/Documents/GitArchive/notebook")
source("data/ROAM.r")
 
foodTracker_Winter_18 <- read_delim("foodTracker - Winter_18.tsv", "\t", 
                                     escape_double = FALSE, 
                                     col_types = cols(Date = col_date(format = "%d/%m/%Y")), 
                                     trim_ws = TRUE)

basics <- read_delim("basics.tsv", "\t",
                     escape_double = FALSE, 
                     col_types = cols(Date = col_date(format = "%d/%m/%Y")), 
                     trim_ws = TRUE)

str(foodTracker_Winter_18)

# overview of data 
kable(head(basics),"html") %>% kable_styling(font_size=12)

# weekly quantities
basics %>% 
  thicken(interval = 'week') %>% 
  group_by(Date_week) %>% 
  summarise(items_tot=n(),costs_tot=sum(Price)) %>% 
  arrange(desc(Date_week)) %>% 
  ggplot(., aes(Date_week,costs_tot)) + 
  geom_point() + geom_smooth(method = "lm") +
  theme_plain(base_size = 9)

# weekly visits
basics %>% 
  thicken(interval = 'week') %>% 
  group_by(Date_week) %>% 
  summarise(items_tot=n(),costs_tot=sum(Price)) %>% 
  arrange(desc(Date_week)) %>% 
  ggplot(., aes(items_tot,costs_tot)) + 
  geom_point() + geom_smooth(method = "lm") +
  theme_plain(base_size = 9)

# split per category
basics %>% 
  thicken(interval = 'week') %>% group_by(Category) %>% 
  summarise(Cost = sum(Price)) %>% 
  arrange(desc(Cost)) %>% 
  ggplot(., aes(Category,Cost)) + geom_col() +
  theme_plain(base_size = 9)

# smoothed distribution of costs
basics %>% 
  ggplot(.,aes(Price, ..count.. , 
               colour=Category, fill = Category)) + 
  geom_density(position="fill",alpha=0.75,adjust=4) +
  theme_plain(base_size = 9) + ylab("Proportion of Occurences")



# idea: proportions of product per week (TS)

# building model
model_data<-basics %>% thicken(interval = 'week') %>% 
  mutate(Category=factor(Category)) %>% 
  group_by(Date_week,Category) %>% 
  mutate(un = n()) %>% 
  summarise(cost_Cat=sum(Price),no=n()) %>% 
  mutate(cost_p=round(cost_Cat/sum(cost_Cat)*100,0)) %>% 
  select(-cost_Cat) %>% 
  left_join(weekly) %>% 
  ungroup() %>% 
  mutate(Date_week=factor(Date_week))

str(model_data)

# inital 
products_summary <-foodTracker_Winter_18 %>% 
  thicken(interval = 'week') %>% group_by(Category) %>% 
  filter(Category=="OG") %>% group_by(Item) %>% 
  mutate(PpK=(Price/Weight)) %>% 
  summarise(Quantity_kg=sum(Weight),
            PV_per_kg = mean(PpK,na.rm=TRUE),
            Price_Volatility = sd(PpK,na.rm=TRUE)) %>% 
  arrange(desc(Quantity_kg))


# payoff expensive products (or volatile) medium amounts ??
ggplot(products_summary,aes(PV_per_kg,Quantity_kg)) + 
  geom_point(aes(colour=factor(Item))) 








  