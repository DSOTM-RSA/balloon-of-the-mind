# Clifford Attractors
# inspiration :: 
# using base R for computation (no Rccp)


library(ggplot2)
library(dplyr)
library(scales)
library(svglite)


# load libraries for colour plotting

#library(viridis)
#library(MASS)
#library(fields)


# set global paramaters
xs=runif(1000000) # trace poiints (~4Mb for 5x10^5)
gens=seq(1:200) # number of images to generate

# main loop
for (j in 1:length(gens)){

# model parameters (~ 4:1 generation ratio!)
a = runif(1,min=1,max=2)*-1
b = runif(1,min=1,max=2)*-1
c = runif(1,min=1,max=2)*-1
d = runif(1,min=1,max=2)*-1

# make holder vectors
res1 <- numeric(length(xs)+1)
res2 <- numeric(length(xs)+1)

# clifford attractors for X=0, Y=0
res1[1] <- sin(a)-c*cos(a)
res2[1] <- sin(b)-d*cos(b)

# sequential trajectories derived from previous values
for (i in seq_along(xs)) {
  res1[i+1] <- sin(a*res2[i])+c*cos(a*res1[i])
  res2[i+1] <- sin(b*res1[i])+d*cos(b*res2[i])
}


# code for colour plotting and density estimates
# convert to a DF
# DF <- as.data.frame(cbind(res1,res2))

# calculate 2d density over a grid
# dens <- kde2d(res1,res2,n = 100)

# create a new data frame from 2d density grid
# gr <- data.frame(with(dens, expand.grid(x,y)), as.vector(dens$z))
# names(gr) <- c("xgr", "ygr", "zgr")

# fit a model
#mod <- loess(zgr~xgr*ygr, data=gr)

# apply the model to the original data to estimate density at that point
# DF$pointdensLoess <- predict(mod, newdata=data.frame(xgr=res1, ygr=res2))

# or use fields for billinear or bicubic interpoaltion
# DF$pointdensBL <- fields::interp.surface(dens, DF)

# basic discrete colors
# map_colors<-colorRampPalette(viridis(32,option = "inferno"))
# DF$colA <- map_colors(32)[as.numeric(cut(DF$pointdensLoess,breaks = 24))]
# DF$colB <- map_colors(32)[as.numeric(cut(DF$pointdensBL,breaks = 24))]


# generate labels for output
lab <- paste0(sample(letters,5),collapse="")


# plotting
png(paste0("imgs/",lab,".png"),units="px", width=2000, height=2000,res=300)
plot(res1,res2,type="p",pch=16,asp=1,
     cex=0.01,col=alpha("black",0.02),xlim=c(-3,3),
     ylim=c(-3,3),axes=FALSE,xlab="",ylab="")
dev.off()

}

j=1
