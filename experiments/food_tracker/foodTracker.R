library(readr)
 foodTracker_Winter_18 <- read_delim("foodTracker - Winter_18.tsv", "\t", 
                                     escape_double = FALSE, 
                                     col_types = cols(Date = col_date(format = "%d/%m/%Y")), 
                                     trim_ws = TRUE)


str(foodTracker_Winter_18)
library(padr)
library(tidyverse)

foodTracker_Winter_18 %>% 
  thicken(interval = 'week') %>% group_by(Category) %>% 
  summarise(Cost = sum(Price)) %>% 
  arrange(desc(Cost)) 

# read in data
data_Food <- read_delim("foodTracker - Winter_18_2.tsv", "\t", 
                                    escape_double = FALSE, 
                                    col_types = cols(Date = col_date(format = "%d/%m/%Y")), 
                                    trim_ws = TRUE)

# weekly quants
week_tot <- data_Food %>% thicken(interval = 'week') %>% 
  group_by(Date_week) %>% summarise(items_tot=n(),costs_tot=sum(Price))

# building model
model_data<-data_Food %>% thicken(interval = 'week') %>% 
  mutate(Category=factor(Category)) %>% 
  group_by(Date_week,Category) %>% 
  mutate(un = n()) %>% 
  summarise(cost_Cat=sum(Price),no=n()) %>% 
  mutate(cost_p=round(cost_Cat/sum(cost_Cat)*100,0)) %>% 
  select(-cost_Cat) %>% 
  left_join(week_tot) %>% 
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








  