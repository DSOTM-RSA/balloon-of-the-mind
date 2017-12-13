

  
  # define parameters
  players <- 50
  interactions<-100
  
  # make intial distribution
  x <- matrix(rep(interactions,players),nrow = players)
  
  # assign dice "multipliers" 
  dice <-c(-0.8,-0.4,-0.2,0.2,0.4,0.8)
  
  # define game function
  times <- function(x) {
    
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
    
    res<-apply(x, MARGIN = 2,FUN = times)
    
    holder[,i] <-res
    
    x<-res # reassign x to latest outcome
    
  }  

  
matplot(t(holder),type = "l",
        main="Inequality Arising from Pure Chance (Dice Analogy)",
        xlab = "Interactions (n)",
        ylab="Wealth",lty = 1,lwd = 0.5)

# single run
oneTime<-apply(x,MARGIN = 2,FUN = times)

