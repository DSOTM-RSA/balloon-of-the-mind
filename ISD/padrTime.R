library(padr)
library(dplyr)
coffee %>% thicken(interval = "hour")


coffee_day <- coffee %>% 
  thicken(interval = "day") %>% 
  group_by(time_stamp_day) %>% 
  summarise(total = mean(amount))
coffee_day

coffee_full <- coffee_day %>% pad
coffee_full


library(ggplot2)
coffee_full %>% fill_by_value(total) %>% 
  ggplot(aes(time_stamp_day, total)) + geom_line()
