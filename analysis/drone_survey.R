# functions

# calculate area-of-view of a given lens 
aov_lens <- function(sensor_size, aspect_ratio, focal_length) {
  
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


# in operation 

library(purrr)