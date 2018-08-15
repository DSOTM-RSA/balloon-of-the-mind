
layers <- ogrListLayers("180BE09E07F6A590F372A711AEC701D6.gpx")
geo.sP <-readOGR("180BE09E07F6A590F372A711AEC701D6.gpx",layer=layers[5])
geo.sL <-readOGR("180BE09E07F6A590F372A711AEC701D6.gpx",layer=layers[5])

plot(geo.sP)
plot(geo.sL)


locs.gb.coords <- as.data.frame(coordinates(geo.sL))


map <- openmap(as.numeric(c(max(locs.gb.coords$coords.x2), min(locs.gb.coords$coords.x1))),
               as.numeric(c(min(locs.gb.coords$coords.x2), max(locs.gb.coords$coords.x1))), 
               type = "mapbox")


plot(map)
lines(locs.gb.coords$coords.x1,locs.gb.coords$coords.x2,col="black")
