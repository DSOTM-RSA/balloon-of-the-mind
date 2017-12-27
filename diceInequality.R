library(tidyverse)

# Kinetic Energy Model

# define parameters
players <- 100
interactions<-10000

rank_01 <- players/100
rank_50 <- players - (players/2)+1

# build intial game
dat <- matrix(c(1:players,rep(1000,players),rep(0,players)),nrow=players)


# create simulation function
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


stepper <- function(nsteps,parts,game) {
  
  #filler <- matrix(ncol=nsteps,nrow=parts)
  #filler[,] <-rep(0,parts)

  for (i in seq_len(nsteps))
    
    game <-energies(game)

  # extract transaction and counter
  trn <-game[,2] 
  cnt <-game[,3] 
  
  sorts <- game[order(game[,2],decreasing=TRUE),]
  values <- sorts[,2]

  #plot(game[,2],type="l")
  #trn
  #filler[,]<-cnt
  #filler
  values
}


a<-stepper(1000,100,dat)

a

walks<-replicate(200,stepper(100,100,dat))

matplot(t(walks),type="l", xlab="Replicates")



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




# plot WIP
outcomes_ranked <-dat[order(dat[,2],decreasing=TRUE),]

rank_01 <- players/100
rank_99 <- players - (players/100)+1

trajs_01 <- outcomes_ranked[1:rank_01,1]
trajs_99 <- outcomes_ranked[rank_99:players,1]


paths_01 <- energies_transactions[trajs_01,]
paths_99 <- energies_transactions[trajs_99,]


# plot the data
par(mfrow=c(1,1))

matplot(t(paths_01),type="l",lty = 1,lwd=0.5,
        ylim=c(0,outcomes_ranked[1,2]+1000),
        ylab="Amount",xlab="Iterations")

matplot(t(paths_99),type="l",lty = 1,lwd=0.5,
        ylim=c(0,outcomes_ranked[1,2]+1000),
        ylab="Amount",xlab="Iterations")



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

