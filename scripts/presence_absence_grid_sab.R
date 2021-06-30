# Make presence absence raster from sampling grid

# 1. Take an existing raster of the area you are interested in mask.raster and set the background cells to zero (absences).
# 
# 2. rasterize the presence points for your species species.data and set those cells to one (presences).
# 
# 3. Label the new raster by your species names raster.label and save it as a new raster.


presence.absence.raster <- function (mask.raster,species.data,raster.label="") {
  require(raster)
  
  # set the background cells in the raster to 0
  mask.raster[!is.na(mask.raster)] <- 0
  
  #set the cells that contain points to 1
  speciesRaster <- rasterize(species.data,mask.raster,field=1)
  speciesRaster <- merge(speciesRaster,mask.raster)
  
  #label the raster
  names(speciesRaster) <- raster.label
  return(speciesRaster)
}



# create presence absence raster for foxes
pa.raster <- presence.absence.raster(mask.raster=myRaster, species.data=fox.data, raster.label=species)
plot(pa.raster, main=names(pa.raster))