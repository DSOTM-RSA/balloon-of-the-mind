library(tidyverse)

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


# IMPLEMENTATION
# build paramters grid :: expand.grid() --> cross all combinations of sensor vs rest
# call fucntions sequentially

l <- c(17.3,3.2) # lens
z <- c(12,17,24,35,100) # zooms
h <- c(15,35,50,100,250) # heigths
s <- c(2.5,4,7.5) # speeds
t <- c(5,12,20) # times


# prepare grid
values_df <-expand.grid(l,z,h,s,t) %>% 
  set_names(.,c("lens","zoom","height","speed","time")) %>% 
  mutate(asp=case_when(lens == 17.3 ~ 0.75, TRUE ~ as.numeric(0.66)))


aovs<-aov_lens(values_df$lens,values_df$asp,values_df$zoom)  

segment_widths <- segment_size(values_df$height,aovs[[1]])

segment_lengths <- segment_size(values_df$height,aovs[[2]])

blocks <- block_size(segment_widths,segment_lengths)

surveys <- survey_extent(values_df$speed,
                         values_df$time,
                         segment_lengths,
                         blocks) 

# build reference df for planning 
surveys_df <- cbind(values_df,
                   segment_widths,
                   segment_lengths,
                   blocks,
                   surveys)



