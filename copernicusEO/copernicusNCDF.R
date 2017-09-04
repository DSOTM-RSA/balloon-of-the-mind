library(RNetCDF)
setwd("~/Downloads")
nc <- open.nc("MetO.nc")
print.nc(nc)
nc_data <- read.nc(nc)
ndims <- file.inq.nc(nc)$ndims
dimnames <- character(ndims)
for(i in seq_len(ndims)) {
dimnames[i] <- dim.inq.nc(nc, i-1)$name
}


dat <- nc_data$vomecrty[,,1,1]
dim(dat)
nc_lat<-nc_data$lat
nc_lon<-nc_data$lon
dim(nc_lat)
dim(nc_lon)
dat[1:100,200:250]
dat[1:10,200:210]
dimnames(dat)<-list(lon=nc_lon,lat=nc_lat)
dat[1:10,200:210]
dat_t<-t(dat)
dat_t[1:10,200:210]
View(dat_t)
image(dat_t)
image(dat)

dat_levs <- nc_data$vomecrty[,,,1]


library(OceanView)
x<-as.double(rownames(dat))
y<-as.double(colnames(dat))

image2D(z=dat,x=x,y=y) # default for grid values
image2D(z=dat,x=x,y=y,NAcol = "black",resfac = 2) # interpolate
image2D(z=dat,x=x,y=y,NAcol = "black",rasterImage = TRUE) # use raster, smooths by defualt
image2D(z=dat,x=x,y=y,NAcol = "black",rasterImage = TRUE,contour=TRUE) # with contours
