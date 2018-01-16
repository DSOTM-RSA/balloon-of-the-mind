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


foodTracker_Winter_18 %>% 
  thicken(interval = 'week') %>% group_by(Category) %>% 
  summarise(Cost = sum(Price)) %>% 
  mutate(Prop_Spend=Cost/sum(Cost)*100)%>%
  ggplot(.,aes(Category,Prop_Spend)) + geom_bar(stat="identity") 


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








  