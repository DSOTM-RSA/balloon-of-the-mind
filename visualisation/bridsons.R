
# 07
holder_x<-numeric()
holder_y<-numeric()

# 00
x <- runif(1,0,2)
y <- runif(1,0,2)

# 08
holder_x <- x
holder_y <- y

# 01
rmin <- 2
rmax <- 2^2

# 02
inner <- (x-rmin)^2+(y-rmin)^2
outer <- (x-rmax)^2+(y-rmax)^2

# 03
library(plotrix)
plot(x,y,xlim=c(-10,10),ylim=c(-10,10))
draw.circle(x,y,rmin)
draw.circle(x,y,rmax)

# 09
#len <- 1:length(holder_x)
#sam_act <- sample(s,1)

# 04
x_sam <- x + runif(1,2,4)
y_sam <- x + runif(1,2,4)

# 10
#x_sam <- holder_x[sam_act] + runif(1,2,4)
#y_sam <- holder_y[sam_act] + runif(1,2,4)

# 05
points(x_sam,y_sam,pch=21,bg="red")

# 06
abs(x - x_sam) > rmin
abs(y - y_sam) > rmin

# abs(holder_x - x_sam) > rmin
# abs(holder_y - y_sam) > rmin

# 08
holder_x <- c(holder_x,x_sam)
holder_y <- c(holder_y,y_sam)



