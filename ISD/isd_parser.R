# Step 1: Create Sets of Data to Download ----

library(magrittr)
library(stringr)

# # read in selected station IDS
sts.raw <- read.csv("statsde.txt",header = FALSE) 
sts <- as.vector(sts.raw$V1) %>% as.character() # extract station IDS

yrs<-rep(2006:2015,each=length(sts)) # make a rep vector of dates
suf <- ".gz" # make suffix

tmp<-str_c(sts,yrs,sep = "-99999-")
sts.folder <- str_c(tmp,suf) 

# create url for wget
base.url <- "ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-lite/" # make strings for ftp address
base.url<-"ftp://ftp.ncdc.noaa.gov/pub/data/noaa/" # full data
tail.url <- rep(2006:2015,each=length(sts)) 
lead.address<-str_c(base.url,tail.url,sep = "") #  join leading ftp address

full_srch<-str_c(lead.address,sts.folder,sep = "/") # join full string

full_srch_Tab<-as.data.frame(full_srch) # as data.frame for easy export
write.table(full_srch_Tab,"list-de.txt",row.names = FALSE,col.names = FALSE,quote=FALSE) # export table



# Step 2: Parse in Data-Files (very Slow!) - Export for Later Use ----

library(isdparser)
library(dplyr)

# set directory of data files
filenames <- list.files()
ptm <- proc.time() # how long does it take?

  ldf <- lapply(filenames[1:100],isd_parse,parallel=TRUE) %>% 
    lapply(.,"[",c(2,4:5,7:8,10,13:14,15,16:17,22,26)) %>% dplyr::bind_rows(.)
  
  proc.time() - ptm
  
  #   user  system elapsed 
  #  4.497   0.332 104.193 
  
  # user   system  elapsed 
  # 54.156    4.153 1500.672   
  
  # write data to convenient file for later quick import
  write.table(ldf,file="statTabsAgg.tsv",sep="\t",col.names=T,row.names = FALSE)
  
  rm(ldf)  
  
  
  
  ################
  # OR
  

  library(rbenchmark)
  library(plyr)
  library(isdparser)
  
  require(doMC)
  registerDoMC(3) # 3 processors
  
  filenames <- list.files()
  single <- seq(1:length(filenames)) # using indices instead of direct ref to df


  sRead <- function() {
    
    rD <- alply(single,1, function(x,df) isd_parse(df[x]) ,df=filenames,.parallel = FALSE)
  }
  
  pRead <- function() {
    
    rD <- alply(single,1, function(x,df) isd_parse(df[x]) ,df=filenames,.parallel = TRUE)
  }
  
  benchmark(sRead(), pRead(), replications = 2, order = "elapsed")
  
library(microbenchmark)
  mbm = microbenchmark(
    base = sRead(),
    parr = pRead(),times = 1
  )
  
  # based on 3 processors
  # test replications elapsed relative user.self sys.self user.child sys.child
  # 2 pRead()            2 239.936    1.000     1.021    0.326    410.902     7.907
  # 1 sRead()            2 440.188    1.835   399.801    5.868      0.000     0.000
  
  #Unit: seconds
  #expr      min       lq     mean   median       uq      max neval
  #base 220.4953 220.4953 220.4953 220.4953 220.4953 220.4953     1
  #parr 113.2417 113.2417 113.2417 113.2417 113.2417 113.2417     1
  
  
  
  
  
  ###
  df <- data.frame(group = as.factor(sample(1:1e4, 1e6, replace = T)), 
                   val = sample(1:10, 1e6, replace = T))
  
  require(plyr)
  require(doMC)
  registerDoMC(2) # 20 processors
  
  # parallelisation using doMC + plyr 
  P.PLYR <- function() {
    o1 <- ddply(df, .(group), function(x) sum(x$val), .parallel = TRUE)
  }
  
  # no parallelisation
  PLYR <- function() {
    o2 <- ddply(df, .(group), function(x) sum(x$val), .parallel = FALSE)
  }
  
  require(rbenchmark)
  benchmark(P.PLYR(), PLYR(), replications = 2, order = "elapsed")
  
  
  # parallelisation using doMC + plyr 
  P.PLYR <- function() {
    o1 <- ddply(df, .(group), function(x) 
      median(x$val) * median(rnorm(1e4)), .parallel = TRUE)
  }
  
  # no parallelisation
  PLYR <- function() {
    o2 <- ddply(df, .(group), function(x) 
      median(x$val) * median(rnorm(1e4)), .parallel = FALSE)
  }
  
# Appendix ----

# wget -m -i test

# ftp of aggregated daily ISD data for 9000 stations
ftp://ftp.ncdc.noaa.gov/pub/data/gsod/2016/ 
# ftp of lite version of entire ISD dataset..
ftp://ftp.ncdc.noaa.gov/pub/data/noaa/isd-lite 
# full version of  ISD data
ftp://ftp.ncdc.noaa.gov/pub/data/noaa 
