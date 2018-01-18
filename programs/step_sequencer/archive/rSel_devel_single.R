# load libraries
require(RSelenium)
require(rvest)

# make connection
remDr <-remoteDriver(remoteServerAddr = "localhost" 
                     , port = 4445L
                     , browserName = "firefox")
# initialise
remDr$open()

# as usual
remDr$navigate("http://rna.tbi.univie.ac.at/cgi-bin/RNAWebSuite/RNAfold.cgi")
remDr$getCurrentUrl()

# get search bar
webElem <- remDr$findElement(using = 'id', value = "SCREEN")
#webElem <- remDr$findElement('xpath', "//*[(@id = 'SCREEN')]") # or

#attempts to get clear button
#clear <- remDr$findElement('xpath', "//a") # or
#clear2 <- remDr$findElement('xpath', "//input+//table//a")


# send a piece of text
webElem$sendKeysToElement(list(">test_sequence",key = "return"))
webElem$sendKeysToElement(list("GGGCUAUUAGCUCAGUUGGUUAGAGCGCACCCCUGAUAAGGGUGAGGUCGCUGAUUCGAAUUCAGCAUAGCCCA"))

# send click to submitElement
webElemSubmit <- remDr$findElement('xpath', "//input[@class = 'proceed']")
webElemSubmit$clickElement()

# downloads
downLink <- remDr$getCurrentUrl() %>% as.character() %>% 
  read_html() %>% html_nodes("a") %>% html_attr("href") %>% 
  .[8] %>% as.character()

print(downLink)

download.file(downLink,destfile = paste0(date,df[(x[]),1],".txt"))


# get sequences back
webElems <- remDr$findElements(using = 'css selector', "pre")

# unlist text within element
resHeaders <- unlist(lapply(webElems, function(x){x$getElementText()}))
results <-list()

sapply(webElems, function(x){x$getElementText()}) # also fine

# process to get just right length
sq <-strsplit(resHeaders[1],"1      ")[[1]][2]
st <-strsplit(resHeaders[3],"1      ")[[1]][2]

results<-list(sq,st)


# other functions
remDr$maxWindowSize()
remDr$screenshot(display = TRUE)
webElem$highlightElement() # highlight element






#############################
# load libraries
require(RSelenium)
require(rvest)
library(readr)

source("stepperSeq.R")

# load names and data
input_seq <- read_csv("input.seq.txt",col_names = FALSE)

# make indices
single <- seq(1:nrow(input_seq))


# make connection
remDr <-remoteDriver(remoteServerAddr = "localhost" 
                     , port = 4445L
                     , browserName = "firefox")
# initialise
remDr$open()


# download files 
multi.seq<-alply(single,1,stepFunction,df=input_seq) # returns an empty list :: OK


# stepper Sequence function
stepFunction <- function(x,df) {
  
  date <-format(Sys.time(), "%b-%d-%Y") 
  
  remDr$navigate("http://www.google.com") # is this still needed?
  print(remDr$getCurrentUrl())
        
  remDr$navigate("http://rna.tbi.univie.ac.at/cgi-bin/RNAWebSuite/RNAfold.cgi")
  
  webElem <- remDr$findElement(using = 'id', value = "SCREEN") #pre 

  # FAIL
  #webElem$sendKeysToElement(list(as.character(df[(x[1])],key = "return")))
  #webElem$sendKeysToElement(list(as.character(df[(x[2])])))
  
  # FAIL
  #webElem$sendKeysToElement(list(as.character(df[(x[1]),1]),key = "return"))
  #webElem$sendKeysToElement(list(as.character(df[(x[1]),2])))
  
  # working - send chr data to form
  webElem$sendKeysToElement(list(as.character(df[(x[]),1]),key = "return"))
  webElem$sendKeysToElement(list(as.character(df[(x[]),2])))
  
  # send click to submitElement
  webElemSubmit <- remDr$findElement('xpath', "//input[@class = 'proceed']") # pre
  webElemSubmit$clickElement()
  
  Sys.sleep(20) #wait for computation to finish
  
  # succesful trasnfer to results
  print(remDr$getCurrentUrl())

  # neater download implementation
  downLink <- remDr$getCurrentUrl() %>% as.character() %>% 
    read_html() %>% html_nodes("a") %>% html_attr("href") %>% 
    .[8] %>% as.character()
  
  print(downLink)
  
  download.file(downLink,destfile = paste0(date,"secSeq",df[(x[]),1],".txt"))
  
  
  # get sequences back return a list (unstable??)
  # webElems <- remDr$findElements(using = 'css selector', "pre") # pre
  # unlist text within element
  # resHeaders <- unlist(lapply(webElems, function(x){x$getElementText()}))


}






###############################
# test functions

selectrr1 <- function(x,df){
  
  print(df[(x[]),1])
  
}

selectrr2 <- function(x,df){
  
  print(df[(x[]),2])
  
}



single<-c(1,2,3,4,5)
out1<-alply(single,1,selectrr1,df=input_seq)
out2<-alply(single,1,selectrr2,df=input_seq)
###########################














