

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

stepper <- function(nsteps=25,pool=1000,dups=0.25,splits=0.5){
  
  sams <- c(seq(1,pool,1),c(sample(seq(1,pool,1),dups*pool),
                            seq((pool+dups*pool),2*pool,1)))
  
  # prepare
  transactions <- matrix(ncol=2,nrow=nsteps)
  
  for (i in seq_len(nsteps)){
    
    sams <- shares(sams,sp=splits)
    res<-as.numeric(length(unique(sams))/length(sams))
    trn <-res
    transactions[i,2]<-trn
    transactions[i]<-floor(0.2*length(sams))

  }
  
  return(transactions)
  
}


tr<-stepper()

# replicate runs
reps <- 250
walks<-replicate(reps,stepper())

# generate a mean "walk"
avgOutcomes <-rowMeans(walks,dims=2,na.rm = TRUE)

plot(avgOutcomes[,2],type="l",
     main="Average Trajectory for Removing Duplicates",
     ylab="Fraction of Unique Items",
     xlab="Steps (n)")
