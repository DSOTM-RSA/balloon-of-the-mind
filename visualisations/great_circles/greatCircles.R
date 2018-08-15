
great_Circle_Traces <- function(lat1,lon1,lat2,lon2,f=seq(0.01,0.99,0.01)) {
  
  # convert positions from lat/lon to radians
  lat1 <- lat1*(pi/180)
  lon1 <- lon1*(pi/180)
  
  lat2 <- lat2*(pi/180)
  lon2 <- lon2*(pi/180)
  
  
  # compute individual terms
  termOne <- sin(lat1)*sin(lat2)
  termTwo <- cos(lat1)*cos(lat2)*cos(abs(lon1-lon2))
  
  # this gives the central angle between the points ("distance in radians")
  centralAngle <- acos(termOne + termTwo)
  
  # compute distance in km 
  curve <- 6371*centralAngle
  

  # calculating intermediate points
  A <- sin((1-f)*centralAngle)/sin(centralAngle)
  B <- sin(f*centralAngle)/sin(centralAngle)
  x = A*cos(lat1)*cos(lon1) + B*cos(lat2)*cos(lon2)
  y = A*cos(lat1)*sin(lon1) + B*cos(lat2)*sin(lon2)
  z = A*sin(lat1) + B*sin(lat2)
  lat = atan2(z,sqrt(x^2+y^2)) 
  lon = atan2(y,x)
  
  # convert positions from radians to km
  lat = lat*(180/pi)
  lon = lon*(180/pi)
  
  
  # return results
  return(as.data.frame(cbind(curve,lat,lon)))
}

Bremen_Vienna<-great_Circle_Traces(58,8,54,36)
