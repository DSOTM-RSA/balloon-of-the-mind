library(readr)
library(tidyverse)

# load ROAM functions
source("ROAM.r")

# read data
wolf_data <- read_delim("wolf_data.tsv",
                        "\t", escape_double = FALSE, trim_ws = TRUE)


# complete the data by filling missing "data-slots"
complete.ts <-wolf_data %>% 
  complete(Jahr=full_seq(Jahr,1),nesting(Bundesland,Territorium),
           fill=list(Status="np",Repro=0,Welpen=0))


# create annotations
labs_status <-data.frame(Status=c("e","p","r","np"),
                         Name=c("Single","Pair","Pack","Not Present"),
                         stringsAsFactors = FALSE)

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
