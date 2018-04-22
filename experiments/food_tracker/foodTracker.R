library(readr)
library(padr)
library(tidyverse)
library(knitr)
library(kableExtra)

setwd("~/Documents/GitArchive/notebook")
source("data/ROAM.r")

setwd("~/Documents/GitArchive/porkBelly/experiments/food_tracker")

basics <- read_delim("basics.tsv", "\t",
                     escape_double = FALSE, 
                     col_types = cols(Date = col_date(format = "%d/%m/%Y")), 
                     trim_ws = TRUE)


# overview of data 
kable(head(basics),"html") %>% kable_styling(font_size=12)

# weekly quantities
weekly_summary <-basics %>% 
  thicken(interval = 'week') %>% 
  group_by(Date_week) %>% 
  summarise(items_tot=n(),costs_tot=sum(Price)) %>% 
  arrange(desc(Date_week))

# plot :: weekly costs TS
weekly_summary %>% 
  ggplot(., aes(Date_week,costs_tot)) + 
  geom_point() + geom_smooth(method = "lm") +
  theme_plain(base_size = 11) +
  xlab("Date") +
  ylab("Weekly Expenditure (Estimated)")

# plot: items vs total cost
weekly_summary %>% 
  ggplot(., aes(items_tot,costs_tot)) + 
  geom_point() + geom_smooth(method = "lm") +
  theme_plain(base_size = 11) +
  xlab("Items Purchased (per Week)") +
  ylab("Total Cost (€)")

# aggregate split per category
aggregate_costs<-basics %>% thicken(interval = 'week') %>% 
  mutate(Category=factor(Category)) %>% 
  group_by(Category) %>% 
  summarise(cost_total=sum(Price)) %>% 
  mutate(cost_total_prop=round(cost_total/sum(cost_total)*100,0)) %>% 
  arrange(desc(cost_total_prop))

# plot :: aggregate proportional costs per category
aggregate_costs %>% ggplot(., aes(cost_total_prop,
                      fct_reorder(Category,cost_total_prop))) +
  geom_point(size=4,shape=3) + 
  coord_flip() + 
  theme_plain(base_size = 11) +
  xlab("Proportional Spend") +
  ylab("Food Category")
  
# building model
model_data<-basics %>% thicken(interval = 'week') %>% 
  mutate(Category=factor(Category)) %>% 
  group_by(Date_week,Category) %>% 
  mutate(un = n()) %>% 
  summarise(cost_category=sum(Price),no_items=n()) %>% 
  mutate(cost_prop=round(cost_category/sum(cost_category)*100,0),
         no_items_prop=round(no_items/sum(no_items)*100,0))

# plot :: cost vs yield by category
model_data %>% 
  ggplot(., aes(cost_prop,no_items_prop,colour=Category, size=no_items)) + 
  geom_point() + 
  theme_plain(base_size = 11) + 
  coord_trans(y="log",x="log") +
  scale_y_continuous(expand=c(0.1,0.1),
                     breaks=c(5,10,20,45)) +
  scale_x_continuous(expand=c(0.1,0.1),
                     breaks=c(5,10,20,45)) +
  xlab("Proportional Cost") +
  ylab("Proportional Amount") +
  labs(title="Relationship between Relative Spend and Yield over 7 Weeks (N = 52)",
       size="Items (n)") + 
  guides(color=guide_legend(title="Food Category")) 
  

#%>% 
  left_join(weekly) %>% 
  ungroup() %>% 
  mutate(Date_week=factor(Date_week))

str(model_data








  