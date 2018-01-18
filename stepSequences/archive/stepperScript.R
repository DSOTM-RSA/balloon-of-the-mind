# load libraries
require(RSelenium)
require(rvest)
library(tidyverse)

# load function
source("stepperSeq.R") 

# load names and data
input_seq <- read_csv("input.seq.txt",col_names = FALSE)

# make indices
single <- seq(1:nrow(input_seq)) # using indices instead of direct ref to df

# start Selenium via terminal before this step
# docker run -d -p 4445:4444 selenium/standalone-firefox:3.0.1

# make connection
remDr <-remoteDriver(remoteServerAddr = "localhost" 
                     , port = 4445L
                     , browserName = "firefox")
# initialise
remDr$open()

# download files 
multi.seq <-plyr::alply(single,1,stepFunction,df=input_seq) # returns an empty list :: OK


# further text processing

# add filenames to each line
#for f in *.txt
#do
#sed -i -e '1,$s/$/'"\,$f"'/' $f
#done

# join files together
#cat *.txt > filenames-appended.txt

# merge every 2 lines --> more appropriate wide format
#awk '{ ORS = (NR%2 ? "," : RS) } 1' filenames-appended.txt > secStructures.txt



