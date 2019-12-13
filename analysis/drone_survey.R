# functions

# calculate area-of-view of a given lens 
aov_lens <- function(sensor_size, focal_length) {
  
  # set appropriate aspect ratio
  if (sensor_size == 17.3) {
    aspect_ratio = 0.75 
  } else (aspect_ratio = 0.66)
  
  aov_width <- (180*sensor_size)/(pi*focal_length)
  aov_length <- aov_width*aspect_ratio

  return(list(aov_width, aov_length))
}


# calculate segment size on ground at a given flight height [sideways and forward looking]
segment_size <- function(drone_height, aov) {
  
  segment_tmp <- (tan(0.5*aov*pi/180)*drone_height)
  return(segment_tmp)

}


# calculate block size imaged on ground
block_size <- function (half_width, half_length){
  
  block_tmp <-(2*half_width)*(2*half_length)/10000 # hectares
  return(block_tmp)
  
}


# calculate survey extent given flight parameters and observation window derived from lens
survey_extent <- function(speed, flight_time, half_length, area_block){
  
  distance_covered <- speed * flight_time
  blocks_covered <- 1 + (distance_covered/(half_length*2))
  coverage_tmp <- blocks_covered * area_block
  return(coverage_tmp)
  
}



# TESTING 
library(purrr)

# define some parameters
lens <- 13.2 # full frame, m4/3, 1# etc.
zooms <- c(12,17,24,35,50,100,150) # wide-angle, mid, zoom

aov <-aov_lens(13.2,zooms)

segment <-map2(100,aov,segment_size)

block <-map2(segment[1],segment[2],block_size)

survey <-pmap(list(10,20,segment[2],block),survey_extent)


plot(zooms,unlist(survey),type = "b",xlab = "",ylab = "")


# IMPLEMENTATION
# purrr: cross() or expand.grid() --> cross all combinations of sensor vs rest

l <- c(17.31,3.2)
z <- c(12,17,24,35,100)
h <- c(15,35,50,100,250)
s <- c(2.5,4,7.5)
t <- c(5,12,20)

cross_df <-expand.grid(l,z,h,s,t) %>% 
  set_names(.,c("lens","zoom","height","speed","time"))
            
            

