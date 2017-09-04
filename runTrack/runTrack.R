# runTrack Updated 0.3 12.05.2016

where<-getwd()	# get home-dir

library(XML)
library(plyr)
library(tidyverse)

# Full Extraction ----

#filenames.all <-list.files(paste0(where,"/pairs-run-data/xmls"))
setwd("pairs-run-data/xmls")

filenames.all <-list.files()

beg=1
end=as.numeric(length(filenames.all))

red<-as.character(strsplit(filenames.all,".xml"))


# Main Loop

  for (i in beg:end) {
    reader<-paste0(filenames.all[i])
    writer1<-paste0("Tree",filenames.all[i])
    writer2<-paste0("Node",filenames.all[i])
    writer3<-paste0("List",i)
    
    write.final<-paste0(red[i])
    
    # parse and root
    tempTree <-xmlTreeParse(reader)
    xmlNode <- xmlRoot(tempTree)
    assign(writer1,tempTree)
    assign(writer2,xmlNode)
    
    # extract lists
    tempList<-xmlSApply(xmlNode, function(x) xmlSApply(x, xmlValue))
    assign(writer3,tempList)
    
    
    # cut awy from edges of matrix due to improper filling
    k=5
    len=length(tempList)-4
    Run=matrix(data=NA, nrow=len, ncol=k)
    
    for(j in 1:k){
      for(f in 1:len){
        Run[f,j] = tempList[2+f]$TrackPoints[1+j]
      }
    }
    
    assign(write.final,Run)
    
   Run <-matrix(as.numeric(Run),nrow=len,ncol=k)
   #Run <-matrix(Run,nrow=len,ncol=k)
   colnames(Run) <- c("Lat","Lon","Altitude","Velocity","HR") 
   # assume data is recorded correctly at each interval every 2 secs
   
   # transfrom to data.frame and convert
   Run.df<-as.data.frame(Run)
   Run.df$TimeInt <- rep(2,len) # an interval recording time of 3 second
   Run.df$timeTotal <- cumsum(Run.df$TimeInt)
   Run.df$speedMS <- round(Run.df$Velocity/(3600)*(1000),2)
   Run.df$distanceInt <- round(Run.df$speedMS*Run.df$TimeInt,2)
   Run.df$distance <-cumsum(Run.df$distanceInt)
   Run.df$date <-as.Date(red[i])
  
   Run.df$totalTime <- rep(tempList$trackmaster[[4]],len)
   Run.df$totalDistance <- rep(as.numeric(tempList$trackmaster[[5]]),len)
   Run.df$totalCalories <- rep(as.numeric(tempList$trackmaster[[6]]),len)
   
   
    assign(write.final,Run.df)
    
  }


# clean junk away
rm(list = ls(pattern=".xml*"))
rm(list = ls(pattern=".df*"))
rm(list = ls(pattern="Run"))
rm(list = ls(pattern = "^List"))
rm(list = ls(pattern = "^List"))


dfs <-Filter(function(x) is(x, "data.frame"), mget(ls()))
all.Data <- do.call(rbind,dfs)
rownames(all.Data)<-NULL

rm(list = ls(pattern = "^20"))


# dealing with pain in the arse , in the intervals when used
#all.Data[6]<-data.frame(lapply(all.Data[6], function(x) {gsub(",", ".", x)}))


# Some Nice Summary Data


all.Data$dates<-as.factor(all.Data$date)

# NOTE ALL DISTANCES DURATIONS AND PACES USE INCORRECT INTERVALS
# SOLUTION: USE GENERATED HEADER VALUES; OR LEFT-JOIN WITH .txt files

lookUp<-ddply(all.Data, .(dates),summarize,
      meanHR = round(mean(HR), 1),
      sdHR = round(sd(HR), 1),cvHR=round(sdHR/meanHR*100,1),
      meanVel = round(mean(Velocity),1),
      sdVel = round(sd(Velocity),1), cvVel = round(sdVel/meanVel*100,1),
      Distance = round(max(distance/1000),1),Duration=round(max(timeTotal/60),1),
      Pace = round(Duration/Distance,1))

all.Data$MetresRun <-cumsum(all.Data$distanceInt)


# plotting figures
ggplot(lookUp, aes(meanVel,meanHR)) + geom_point()

ggsave(file=paste0(where,"/lookUp.pdf"),width = 11.6, height=8.2)

ggplot(all.Data, aes(Velocity,HR)) + 
  geom_point(aes(size=timeTotal,colour=factor(date)),alpha=1/3) +
  scale_size_area() + xlim(0,17.5) + ylim(80,185)

ggsave(file=paste0(where,"/rawData.pdf"),width = 11.6, height=8.2)


all.Data.motion <- all.Data %>% 
  group_by(dates) %>% filter(Velocity >= 6 & HR >=125) %>% 
  mutate(n = ntile(Velocity, 50)) %>% 
  filter(!n %in% c(1, 50))
  
ggplot(all.Data.motion, aes(Velocity,HR)) + 
  geom_point(aes(size=timeTotal,colour=factor(date)),alpha=1/3) +
  scale_size_area() + xlim(0,17.5) + ylim(80,185)

ggsave(file=paste0(where,"/motionData.pdf"),width = 11.6, height=8.2)


ggplot(all.Data.motion, aes(n, Velocity)) + 
  geom_point(aes(size=timeTotal,colour=factor(date)), alpha=1/10) + 
  scale_size_area()

ggsave(file=paste0(where,"/binsVelocity.pdf"),width = 11.6, height=8.2)


all.Data.intervals <- all.Data %>% 
  group_by(dates) %>% filter(Velocity >= 6 & HR >=125 & date >= "2017-03-19") %>% 
  mutate(n = ntile(Velocity, 50)) %>% 
  filter(!n %in% c(1, 50))

ggplot(all.Data.intervals, aes(n, Velocity)) + 
  geom_point(aes(size=timeTotal,colour=factor(date)), alpha=1/10) + 
  scale_size_area()

ggsave(file=paste0(where,"/binsIntervals.pdf"),width = 11.6, height=8.2)


# save summary
write.table(lookUp,file=paste0(where,"/lookupSumamry.tsv"),
            sep="\t",col.names=NA,row.names = TRUE)  





