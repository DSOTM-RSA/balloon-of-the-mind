# stepper Sequence function
stepFunction <- function(x,df) {
  
  date <-format(Sys.time(), "%b-%d-%Y") 
  
  remDr$navigate("http://www.google.com") # is this still needed?
  print(remDr$getCurrentUrl())
  
  remDr$navigate("http://rna.tbi.univie.ac.at/cgi-bin/RNAWebSuite/RNAfold.cgi")
  
  webElem <- remDr$findElement(using = 'id', value = "SCREEN") #pre 
  
  # send chr data to form
  webElem$sendKeysToElement(list(as.character(df[(x[]),1]),key = "return")) #(index[]), 1st column of df
  webElem$sendKeysToElement(list(as.character(df[(x[]),2]))) # (index[]), 2nd column of df
  
  # send click to submitElement
  webElemSubmit <- remDr$findElement('xpath', "//input[@class = 'proceed']") # pre
  webElemSubmit$clickElement()
  
  Sys.sleep(20) # wait for computation to finish
  
  # succesful transfer to results
  print(remDr$getCurrentUrl())
  
  # neater download implementation
  downLink <- remDr$getCurrentUrl() %>% as.character() %>% 
    read_html() %>% html_nodes("a") %>% html_attr("href") %>% 
    .[8] %>% as.character()
  
  print(downLink)
  
  subs<-df[(x[]),1] %>% substring(.,2)
  
  print(subs)
  
  #download.file(downLink,destfile = paste0(date,"secSeq",df[(x[]),1],".txt")) using df directly
  
  download.file(downLink,destfile = paste0(date,"_",subs,".txt"))
  
}