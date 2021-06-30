library(raster)
# prepare Goodwin Sands MCZ Sabellaria frmo JNCC mode output
library(tidyverse)
library(sf)
library(stars)
# library(drop_units)
library(ecbtools)
# library(genrandompnts)


# Read in bathymetry
bathy <- raster::raster("C:/Users/Phillip Haupt/Documents/GIS/Goodwin Sands/GEBCO_2020_24_Mar_2021_38a6a862c831/goodwin_bathy_gebco.tif")
image(bathy)

# diagnostic test to see what the projection and resolution of the data is:
st_crs(goodwin_utm31_sf) # read in via mainscript
res(bathy)
st_crs(bathy)
crs_raw_bathy <- proj4string(bathy)
crs_goodwin_utm31 <- proj4string(as_Spatial(goodwin_utm31_sf))#needs to be fcalled
# reproject to allow crop
bathy_utm31 <- projectRaster(bathy, crs = "+proj=utm +zone=31 +datum=WGS84 +units=m +no_defs")
#crop to goodwin
# first to bounding box
bathy_crop <- crop(bathy_utm31, goodwin_utm31_sf)

plot(bathy_crop)

# then to goodwin sands permineter
bathy_goodwin <- mask(bathy_crop, goodwin_utm31_sf)
plot(bathy_goodwin)

# filter out values that are too shallow
bathy_goodwin[bathy_goodwin[] > depth_limits_min ] = NA # check the use of braces to acces values of the raster
plot(bathy_goodwin, 
     #zlim = c(-10,-60), 
     main = paste0("Bathymetry of Goodwin Sands MCZ from -10 to ",round(min((values(bathy_goodwin)), na.rm = TRUE),2))
     )



# Convert sabellaria raster to stack raster to allow extracting kmeans
bathy_stack <- raster::stack(bathy_goodwin)
# reclassify the probability maop into cateogries based on values - can use proximity to influence
set.seed(123)
kmeans_bathy <- raster.kmeans(x = bathy_stack, k = n_depth_grps, iter.max = 100, nstart = 10, geo = T, geo.weight = 0.1)
# plot to see what reclassified result looks like:
plot(kmeans_bathy, main = paste0("Reclassified into ", n_depth_grps, " categories"))

#------------------------------
# If required to be sf object - not required at the momement
# convert raster to sf:


# tifpath <- ("C:/Users/Phillip Haupt/Documents/GIS/Goodwin Sands/GEBCO_2020_24_Mar_2021_38a6a862c831/goodwin_bathy_gebco.tif")
# tif <- read_stars(tifpath)
# bathy_goodwin_sf <- st_as_sf(tif)
# bathy_raw_sf <-bathy_goodwin_sf %>% 
#   rename(depth = goodwin_bathy_gebco.tif)
# 
# bathy_utm_sf <- sf::st_transform(bathy_raw_sf, 32631)
# 
# bathy_goodwin_sf <- st_intersection(bathy_utm_sf, goodwin_utm31_sf)
# 
# my_breaks = c(0,1,2,3,4,5,7,10,15, 20, 30, 40, 50)
# clean_units <- function(x){
#   attr(x,"units") <- NULL
#   class(x) <- setdiff(class(x),"units")
#   x
# }
# 
# bathy_goodwin_sf$depth_m <- clean_units(bathy_goodwin_sf$depth)
# 
# 
# ggplot(bathy_goodwin_sf)+
#   geom_sf(aes(fill = depth_m),lwd = 0)




