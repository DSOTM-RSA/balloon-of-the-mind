# Advent of Code Challenge
# https://adventofcode.com/2019

setwd("C:/Users/eoedd/Desktop/locstore/projects/r/advent")

# day 1
library(purrr)
library(tidyverse)

# part 1
data_01 <- read.table("ad-01.txt", 
                    quote="\"", comment.char="") %>% as.vector()

module_fuel <- map_dbl(data_01$V1, ~ floor(.x/3)-2) %>% sum()


# part 2
func <- function(x,result=0)  {
  
  intermediate <- floor(x/3)-2
  if(intermediate > 0) {
    result <- intermediate + result
    func(intermediate,result)
  }
    else {
      return(result)
    }
}

total_fuel <- map_dbl(data_01$V1, ~ func(.x)) %>% sum()


# day 2

