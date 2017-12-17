

# Kinetic Energy Model

# define parameters
players <- 10
interactions<-1000

dat <- matrix(c(1:players,rep(1000,players)),nrow=players)

# create simulation function
energies <- function(x){
  
  Wpos <- sample(x[,1],1)
  Lpos <- sample(x[,1],1)
  
  transfer <- runif(n = 1,min=0,max=mean(x[,2]))
  
  if (x[Lpos,2] > transfer) {
    
    x[Wpos,2] <- x[Wpos,2]+transfer
    x[Lpos,2] <- x[Lpos,2]-transfer
    
    #vals <- x[,2]

  } else {
    
    x[Wpos,2] <-x[Wpos,2]
    x[Lpos,2] <-x[Lpos,2]
    
  }
  
  vals <- x[,2]

}


single_Energy<-energies(dat)

# make holder for long-simulation run
energies_outcomes <- matrix(ncol=interactions,nrow=players)

# iterate through main loop
i=1
for (i in i:ncol(energies_outcomes)) {
  
  res<-energies(dat)
  
  energies_outcomes[,i] <-res
  
  dat[,2]<-energies_outcomes[,i] # reassign outcome to initial
  
}  



sorted <-energies_outcomes[order(rowMeans(energies_outcomes), 
                                 decreasing = T),]

val_top1 <- sort(energies_outcomes[,max(interactions)],
                 decreasing=T)[1]

val_bot50 <- sum(sort(energies_outcomes[,max(interactions)],
                      decreasing=F)[1:5])

top1 <- round((val_top1/val_bot50)*100,1)


# plot the data
matplot(t(energies_outcomes),type="l",lty = 1,lwd=0.5,
        main=paste0(
          "Upper 1% have ",top1,
          "% of the Total Wealth of the Bottom 50%"))




  # define parameters
  players <- 50
  interactions<-100
  
  # make intial distribution
  x <- matrix(rep(interactions,players),nrow = players)
  
  # assign dice "multipliers" 
  dice <-c(-0.8,-0.4,-0.2,0.2,0.4,0.8)
  
  # define game function
  diceGame <- function(x) {
    
    beg <- sum(x) # total in beginning
    int <- x*(1+sample(dice,players,replace = TRUE)) # draw outcomes
    newTot <- sum(int) # sum of new balance
    
    fac <- (newTot-beg)/newTot # calculate factor
    duty <- int-(fac*int) # apply to keep total amount constant
    
    #assign("x",duty)
    
    #return(c(int,beg,sum(int),fac,duty,sum(duty)))
    
    return(duty) # return new distribution to players
  }
  
  # create holder of results
  holder <- matrix(ncol=interactions,nrow=players)
  
  # iterate through main loop
  
  i=1
  for (i in i:ncol(holder)) {
    
    res<-apply(x, MARGIN = 2,FUN = diceGame)
    
    holder[,i] <-res
    
    x<-res # reassign x to latest outcome
    
  }  

  
matplot(t(holder),type = "l",
        main="Inequality Arising from Pure Chance (Dice Analogy)",
        xlab = "Interactions (n)",
        ylab="Wealth",lty = 1,lwd = 0.5)

# single run
oneTime<-apply(x,MARGIN = 2,FUN = times)

