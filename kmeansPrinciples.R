# kmeans from first principles
# source :: http://enhancedatascience.com/2017/10/24/machine-learning-explained-kmeans/


# Goal :: split data in "k" groups represented by their means
# i.e. create k centers whihc minimize the distance between them and the points in their cluster


# Algorithmic approach

# 1. Randomly INITIALIZE the centers by selecting k-observations
# 2. While some CRITERIA (convergence) is NOT met:
#     a. ASSIGN each observation to its closest center
#     b. UPDATE each center :: the new centers are the mean of their observations
#     c. UPDATE the convergence criteria


# Build from scratch

require(MASS)
require(ggplot2)
set.seed(1234)

set1 = mvrnorm(n=150, c(-4,10), matrix(c(1.5,1,1,1.5),2))
set2 = mvrnorm(n=150, c(5,7), matrix(c(1,2,2,6),2))
set3 = mvrnorm(n=150, c(-1,1), matrix(c(4,0,0,4),2))
set4 = mvrnorm(n=150, c(10,-10), matrix(c(4,0,0,4),2))
set5 = mvrnorm(n=150, c(3,-3), matrix(c(4,0,0,4),2))

DF = data.frame(rbind(set1,set2,set3,set4,set5),
                cluster=as.factor(c(rep(1:5,each=150))))

ggplot(DF, aes(x=X1,y=X2, colour = cluster)) +
  geom_point()


# Now we build the component parts of the function
  
kmeansDer <- function(data, K=4, stop_crit=10e-5){
  
  # 1. INITIALISE clusters
  centroids=data[sample.int(nrow(data),K),]
  current_stop_crit=10000
  cluster=rep(0,nrow(data))
  converged=F
  it=1
  
  # 2. While CRITERIA is not met...
  while(current_stop_crit>=stop_crit & converged==F){
    it=it+1
    
    if (current_stop_crit<=stop_crit){
      converged=T
    }
    old_centroids=centroids
    
    # 2a. ASSIGN points to a centroid
    for (i in 1:nrow(data)){
      min_dist=10e10
      
      for (centroid in 1:nrow(centroids)){
        distance_to_centroid=sum((centroids[centroid,]-data[i,])^2)
        
        if (distance_to_centroid <= min_dist){
          cluster[i]=centroid
          min_dist=distance_to_centroid
        }
      }
    }
    
    # 2b. UPDATE each centroid (i.e. the means of their points!)
    for (i in 1:nrow(centroids)){
      centroids[i,]=apply(data[cluster==i,],2,mean)
    }
    
    # 2c. UPDATE stopping criteria
    current_stop_crit=mean((old_centroids-centroids)^2)
    return(list(data=data.frame(data,cluster),centroids=centroids))
  }
  
}  

# Run and view results
results=kmeansDer(DF[1:2],K=5)
results$centroids$cluster=1:5
results$data$isCentroid=F
results$centroids$isCentroid=T


data_plot=rbind(results$centroids,results$data)
ggplot(data_plot,aes(x=X1,y=X2,
                     color=as.factor(cluster),
                     size=isCentroid,
                     alpha=isCentroid)) + 
  geom_point()
