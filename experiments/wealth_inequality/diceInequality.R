library(tidyverse)

# Kinetic Energy Model

# create energy-simulation function
energies <- function(x){
  
  Wpos <- sample(x[,1],1)
  Lpos <- sample(x[,1],1)
  
  transfer <- runif(n = 1,min=0,max=mean(x[,2]))
  
  if (x[Lpos,2] > transfer) {
    
    x[Wpos,2] <- x[Wpos,2]+transfer
    x[Lpos,2] <- x[Lpos,2]-transfer
    
    x[Wpos,3] <- x[Wpos,3]+1
    x[Lpos,3] <- x[Lpos,3]+1

  } else {
    
    x[Wpos,2] <-x[Wpos,2]
    x[Lpos,2] <-x[Lpos,2]
    
    x[Wpos,3] <- x[Wpos,3]+1
    x[Lpos,3] <- x[Lpos,3]+1
    
  }
  
  vals <- x[,1:3]

}

# create stepper function
stepper <- function(nsteps=10000,agents=200,rate=0.1,wF=0.025) {
  
  # build intial game
  dat <- matrix(c(1:agents,rep(100,agents),
                  rep(0,agents)),nrow=agents)
  
  # define redistribution rates/intervals
  rDis <- round(nsteps*rate,-1)
  
  # setup for NULL taxation
  if (rDis==0){
    
    rInt <-seq(1,nsteps,nsteps)
    wF <- 0
    
  } else {
    
    rInt <- seq(rDis,nsteps,rDis)
    
  }
  

  # define ranking system
  rank_01 <- agents/100
  rank_50 <- agents - (agents/2)+1
  
  # prepare logbook of transactions
  transactions <- matrix(ncol=nsteps,nrow=agents)
  
  # prepare diagnostics 
  diagnostics <- matrix(ncol=4,nrow=nsteps)
  
  for (i in seq_len(nsteps)){
    
    if (i %in% rInt) {
      
      dat <- energies(dat)
      
      # Redistribution  Scheme
      totTaxes <-sum(dat[,2]*wF)
      indSplits <- totTaxes/agents
      print(paste0(totTaxes,": All"))
      print(paste0(indSplits,": Split"))
      dat[,2] <- dat[,2]+indSplits
      
    
      # extract transaction and counter
      trn <-dat[,2] 
      cnt <-dat[,3] 
      
      # sorting of results for diagnostics
      sorts <- dat[order(dat[,2],decreasing=TRUE),]
      
      pos01_unit <- sorts[1,1]
      
      pos01_val <- sorts[1,2]
      pos50_val <-sum(sorts[rank_50:agents,2])
      
      diagnostics[i,1] <-pos01_unit
      diagnostics[i,2] <-pos01_val
      diagnostics[i,3] <-pos50_val
      diagnostics[i,4] <-round((pos01_val/pos50_val)*100,1)
      
      
      # pass per-round balances to logbook
      transactions[,i]<-trn
      
    } else {
    
      # pass function results back to DF
      dat <-energies(dat)
      
      # extract transaction and counter
      trn <-dat[,2] 
      cnt <-dat[,3] 
      
      # sorting of results for diagnostics
      sorts <- dat[order(dat[,2],decreasing=TRUE),]
      
      pos01_unit <- sorts[1,1]
      
      pos01_val <- sorts[1,2]
      pos50_val <-sum(sorts[rank_50:agents,2])
      
      diagnostics[i,1] <-pos01_unit
      diagnostics[i,2] <-pos01_val
      diagnostics[i,3] <-pos50_val
      diagnostics[i,4] <-round((pos01_val/pos50_val)*100,1)
      
      
      # pass per-round balances to logbook
      transactions[,i]<-trn
      
    }
    
    
  }
  
  # return data
  # completeRecord <-rbind(transactions,t(diagnostics))
  # return(completeRecord)
  
  # case for overall wealth-split trajectories
  return(diagnostics)
  
}

# SIMPLE DIAGNOSTIC CASE :: SINGLE RUN
# save to object
output<-stepper(rate = 0,wF = 0.1)
plot(output[,4],type="l")


# PRODUCTION CASE :: CARRY OUT MANY EXPERIMENTS
# repeating N times (100 is ~30mB)

reps <- 100
walks<-replicate(reps,stepper())

# get "average outcome"
avgOutcomes <-rowMeans(walks,dims=2)
plot(avgOutcomes[,4],type="l",
     main="Total Wealth of Top 1% Total versus the Bottom 50%",
     ylab="Wealth Disparity (%)",
     xlab="Interactions (n)")


# RINSE REPEAT FORMUALTION :: COMPARE SEVERAL CASES
par(mfrow=c(1,1))
replicate(reps,stepper2(nsteps = 4000,agents = 100)) %>% 
  rowMeans(.,dims=2) %>% .[,4] %>% plot(type="l")
replicate(reps,stepper2(nsteps = 4000,agents = 200)) %>% 
  rowMeans(.,dims=2) %>% .[,4] %>% lines(type="l",col="green")
replicate(reps,stepper2(nsteps = 4000,agents = 400)) %>% 
  rowMeans(.,dims=2) %>% .[,4] %>% lines(type="l",col="blue")



# get "average outcome"
avgOutcomes <-rowMeans(walks2,dims=2)
plot(avgOutcomes[,4],type="l")

# extract index and avgs into long vector for CI plot
a<-rep(1:interactions,reps)
b<-c(walks[,,])
join<-as.data.frame(cbind(a,b))

ggplot(aes(a,b),data=join) + geom_smooth()


# No 2 Return All Data
# save to object
output<-stepper(,,dat)

# two different plots
matplot(t(output[1:players,]),type="l")
plot(output[players+4,],type="l")

# and plotting
matplot(t(walks[1:10,,2]),type="l", xlab="Game Length")
plot(walks[players+4,,2],type="l", 
     xlab="Game Length", ylab = "Top 1% to Bottom 50% Ratio")


single_Energy<-energies(dat)

# create log for long-simulation run
energies_transactions <- matrix(ncol=interactions,nrow=players)
energies_ranks <- matrix(ncol=interactions,nrow=players)

# diagnostics
energies_splits <- matrix(ncol=4,nrow=interactions)
  
  # iterate through  main loop
  i=1
  for (i in i:ncol(energies_transactions)) {
    
    results<-energies(dat) # get matrix of results
    
    # extract transaction and counter
    trn <-results[,2] 
    cnt <-results[,3] 
    
    #cnt<-energies(dat[,2])
    #energies_transactions[,i] <-res
    
    # pass balances to log
    energies_transactions[,i] <-trn 
    
    # pass balances to balance sheet
    #dat[,2]<-energies_transactions[,i]  
    dat[,2]<-trn
    dat[,3]<-cnt 
    
    #
    
    sorts <- results[order(results[,2],decreasing=TRUE),]
    energies_ranks[,i] <-sorts[,1]
    
    pos01_unit <- sorts[1,1]
    pos01_val <- sorts[1,2]
    
    pos50_val <-sum(sorts[rank_50:players,2])
    
    energies_splits[i,1] <-pos01_unit
    energies_splits[i,2] <-pos01_val
    energies_splits[i,3] <-pos50_val
    energies_splits[i,4] <-round((pos01_val/pos50_val)*100,1)
    
    
    
  } 
  
                      

 

# calculating length of streaks
energies_splits_df <- as.data.frame(energies_splits)

# demo of functions for finding mean "rank-size change"
energies_splits_df %>% group_by(V2,V1) %>% group_size() %>% 
  cumsum() %>% .[2:length(.)]

# pass above as vector of indices to compute over
which(energies_ranks[,9]==energies_splits[10,1])

# gives "turnover rate" as a function of interactions 
energies_splits_df %>% group_by(V2,V1) %>% group_size()%>% 
  median()/players


# main plot
plot(energies_splits[,4],type="l")

##############################################


  # define parameters
  players <- 10
  interactions<-250
  
  # make intial distribution
  dat <- matrix(rep(interactions,players),nrow = players)
  
  # assign dice "multipliers" 
  dice <-c(-0.8,-0.4,-0.2,0.2,0.4,0.8)
  
  # define game function
  diceGame <- function(x) {
    
    beg <- sum(x) # total in beginning
    int <- x*(1+sample(dice,players,replace = TRUE)) # draw outcomes
    newTot <- sum(int) # sum of new balance
    
    fac <- (newTot-beg)/newTot # calculate factor
    duty <- int-(fac*int) # apply to keep total wealth constant
  
    return(duty) # return new distribution to players
  }
  
  # create holder of results
  holder <- matrix(ncol=interactions,nrow=players)
  
  # iterate through main loop
  i=1
  for (i in i:ncol(holder)) {
    
    results<-apply(dat, MARGIN = 2,FUN = diceGame) # iterate draws down columns
    
    holder[,i] <-results # pass results to holder
    
    dat<-results # reassign latest outcome to balance sheet
    
}

  
matplot(t(holder),type = "l",
        main="Inequality Arising from Pure Chance (Dice Analogy)",
        xlab = "Interactions (n)",
        ylab="Wealth",lty = 1,lwd = 0.5)

# single run
oneTime<-apply(dat,MARGIN = 2,FUN = diceGame)

