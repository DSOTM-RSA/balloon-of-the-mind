

# compute function
# splits duplicates into 2 piles
shares <- function(x,sp){
    
  fracA<-length(x)*sp
  fracB <-length(x)-fracA
  
  sideA <- sample(x,fracA,replace=TRUE)
  sideB <- sample(x,fracB,replace=TRUE)
  
  leftB<-sideB[-which(sideB %in% sideA)]
  
  leftAB <- c(sideA,leftB)
  
}


# stepper function
# passes all parameters
# holds loop function
# writes diagnostics

stepper <- function(nsteps=25,pool=52,dups=0.10,splits=0.75){
  
  sams <- c(seq(1,pool,1),c(sample(seq(1,pool,1),dups*pool),
                            seq((pool+dups*pool),2*pool,1)))
  
  # prepare
  transactions <- matrix(ncol=2,nrow=nsteps)
  
  for (i in seq_len(nsteps)){
    
    sams <- shares(sams,sp=splits)
    res<-as.numeric(length(unique(sams))/length(sams))
    trn <-res
    transactions[i,2]<-trn
    #transactions[i]<-floor(dups*length(sams))
    transactions[i]<-i # update :: keep track of step in loop, used for plotting

  }
  
  return(transactions)
  
}


tr<-stepper()

# replicate runs
reps <- 100

# returns an array
walks<-replicate(reps,stepper())

# with replicate returning a matrix
opt.two<-do.call( rbind, replicate(reps, stepper(), simplify=FALSE ) )

# with lapply
opt.three<-do.call(rbind, lapply(1:reps, function(i) stepper()))

# generate a mean "walk"
avgOutcomes <-rowMeans(walks,dims=2,na.rm = TRUE)

plot(avgOutcomes[,2],type="l",
     main="Average Trajectory for Removing Duplicates",
     ylab="Fraction of Unique Items",
     xlab="Steps (n)")

# option four :: convert to dataframe from array without plyr
opt.four <- as.data.frame.table(walks)

library(tidyr)
df1 <- spread(data = opt.four, key = Var2, value = Freq) 

#%>% 
  setNames(c("Obs Step","Run","Cards","Proportion"))
head(df1)
library(ggplot2)

ggplot(aes(A,B),data=df1) + 
  geom_line(aes(group=Var3),alpha=0.025) + geom_smooth()
