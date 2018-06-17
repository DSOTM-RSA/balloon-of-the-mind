library(readr)
library(padr)
library(tidyverse)
library(knitr)
library(kableExtra)

setwd("~/Documents/GitArchive/notebook")
source("data/ROAM.r")

setwd("~/Documents/GitArchive/porkBelly/experiments/food_tracker")

basics <- read_delim("foodTracker2018.tsv", "\t",
                     escape_double = FALSE, 
                     col_types = cols(Date = col_date(format = "%d/%m/%Y")), 
                     trim_ws = TRUE)


# overview of data 
kable(head(basics),"html") %>% kable_styling(font_size=10)


# weekly quantities
weekly_summary <-basics %>% 
  thicken(interval = 'week') %>% 
  group_by(Date_week) %>% 
  summarise(items_tot=n(),costs_tot=sum(Price)) %>% 
  arrange(desc(Date_week))

# plot: items vs total cost
weekly_summary %>% 
  ggplot(., aes(items_tot,costs_tot)) + 
  geom_point() + geom_smooth(method = "lm") +
  theme_plain(base_size = 11) +
  xlab("Items Purchased (per Week)") +
  ylab("Total Cost (€)")

# plot :: weekly costs TS
weekly_summary %>% 
  ggplot(., aes(Date_week,costs_tot)) + 
  geom_point() + geom_smooth(method = "lm") +
  theme_plain(base_size = 11) +
  xlab("Date") +
  ylab("Weekly Expenditure (Estimated)")


# aggregate split per category
aggregate_costs <-basics %>% thicken(interval = 'week') %>% 
  mutate(Category=factor(Category)) %>% 
  group_by(Category) %>% 
  summarise(cost_total=sum(Price)) %>% 
  mutate(cost_total_prop=round(cost_total/sum(cost_total)*100,0)) %>% 
  arrange(desc(cost_total_prop))


  
# building model
model_data<-basics %>% thicken(interval = 'week') %>% 
  mutate(Category=factor(Category)) %>% 
  group_by(Date_week,Category) %>% 
  mutate(un = n()) %>% 
  summarise(cost_category=sum(Price),no_items=n()) %>% 
  mutate(cost_prop=round(cost_category/sum(cost_category)*100,0),
         no_items_prop=round(no_items/sum(no_items)*100,0))

# per item for OG
model_items <- basics %>% 
  mutate(Category=factor(Category),Item = factor(Item)) %>% 
  group_by(Category,Item) %>% 
  mutate(un = n()) %>% summarise(total_uses=n()) %>% 
  arrange(desc(total_uses)) %>% 
  filter(Category == "OG")

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
  labs(title="Relationship between Relative Spend and Yield over 9 Weeks (N = 52)",
       size="Items (n)") + 
  guides(color=guide_legend(title="Food Category")) 


# range of items per week
ggplot(model_data, aes(x=fct_reorder(Category,no_items_prop, fun = median, .desc=TRUE), y = no_items_prop)) +
  geom_boxplot(outlier.colour = "red",outlier.alpha = 0.75) +
  xlab("Category") + ylab("Quantity (%)") +
  theme_plain(base_size = 11) 


# exploring missing data
library(visdat)
library(naniar)
library(simputation)

vis_dat(basics)
vis_miss(basics)

miss_case_table(basics)

aq_shadow <- bind_shadow(basics)

ggplot(aq_shadow,
       aes(x = Price,
           colour = Weight_NA)) + 
  geom_density()


# proper imputation
str(basics)

basics_fct <- basics %>% mutate(Item_fct = as.factor(Item),
                                Category_fct = as.factor(Category)) %>% 
  select(-Item,-Category)

da1 <- impute_lm(basics_fct, Weight ~ Price | Item_fct)
head(da1,3)

da2 <- impute_median(basics_fct, Weight ~ Item_fct)
head(da2,3)

da8 <- impute_lm(basics_fct, Weight ~ Price | Item_fct)

da9 <- impute_lm(basics_fct, Weight ~ Price + Item_fct)

out <-basics_fct %>% impute_cart(Weight ~ Item_fct)


basics %>%
  impute_lm(Weight ~ Price ) %>%
  ggplot(aes(x = Price,
             y = Weight)) + 
  geom_point()




aq_shadow %>%
  impute_lm(Weight ~ Price) %>%
  ggplot(aes(x = Price,
             y = Weight,
             colour = Weight_NA)) + 
  geom_point()
  