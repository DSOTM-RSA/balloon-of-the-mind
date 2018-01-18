files <- list.files() 
dataTmp=lapply(files, read.table, header=FALSE, sep=",")

for (i in 1:length(dataTmp)){
  dataTmp[[i]]<-cbind(dataTmp[[i]],files[i])
  dataTmp[[i]]<-cbind(dataTmp[[i]],runif(1,1,2))
  }
dataBound <- do.call("rbind", dataTmp) 
colnames(dataBound)[c(1,2)]<-c("structures", "date")


data_wide <- spread(dataBound,structures,date)
