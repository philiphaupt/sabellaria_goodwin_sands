# AIM: ROTATE SAMPLING LINES: In order to rotate the sampling lines to better align with tbathymetry of Godowin Sands MCZ:
library(sf)
library(tidyverse)
library(PAR)

# 1. Determine the angle of rotation required via angle: determined from the longest sides of the Goodwin Sands MCZ boundaries
# 2. Calculate the angle in radians, and 
# 3. apply to boxes and lines.

#---------------
# 1. Calc angle

# 1.1 prepare Goodwin Sands MCZ
source("C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/spatial_optimisation/goodwin_sands_evidence/scripts/map_utelities_prep_goodwin_mcz.R", echo=T) # MCZ

# 1.2. isolate nodes from polygon (vertices)
goodwin_pts <- sf::st_cast(goodwin_utm31_sf, "POINT")

# 1.3  find the furthest north and futest south points (latitude/y)
# 1.3.1 split x and y into matrix
goodwin_pts_matrix <- st_coordinates(goodwin_pts)

# 1.3.2 determine min and max Y
pos_max <- as.vector(which.max(goodwin_pts_matrix[,2]))# MAX, i.e. furthest north
pos_min <- as.vector(which.min(goodwin_pts_matrix[,2])) # Min i.e. furthest south

# 1.3.3. keep only coordinates from Goodwdin which match the above
goodwin_pts_n_s_extremes <- goodwin_pts_matrix[c(pos_max, pos_min),]

# 1.4. Calculate the angle between two points
# get angle in radians or degrees
angle <- do.call(atan2, rev(as.list(st_point(goodwin_pts_n_s_extremes[1,])- st_point(goodwin_pts_n_s_extremes[2,])))) #enable this for degrees: * 180/pi # 1Deg × π/180 = 0.01745Rad


# 1.5  rotate [transect] lines/boxes etc.
# Rotate object function
# function to rotate sf objects, expects radians = which is pi/x, where 2 = 90 degrees
rot = function(a) matrix(c(cos(a), sin(a), -sin(a), cos(a)), 2, 2)  

# transform projection to WWGS84
#sampling_polys <- st_transform(s2f_polys, 4326)
sampling_polys <- st_transform(s3f_polys, 32631)
# ts_lines_proj <- ts_lines %>% sf::st_set_crs(st_crs(goodwin_pts))
#keep only geometry
ts_geom <- st_cast(st_geometry(sampling_polys), "MULTIPOLYGON")
# ts_line_geom <- st_cast(st_geometry(ts_lines), "MULTILINESTRING")

# obtain centroid to rotate around
ts_centroids <- st_centroid(ts_geom)
# ts_line_cnrtds <- st_centroid(ts_line_geom)
# apply rotation
ts_rot <- (ts_geom - ts_centroids) * 1/rot(angle) + ts_centroids
ts_rot_proj <- ts_rot %>% sf::st_set_crs(st_crs(ts_geom))
# ts_line_rot <- (ts_line_geom - ts_line_cnrtds) * (pi-rot(angle)) + ts_line_cnrtds
# ts_line_rot_proj <- ts_line_rot %>% sf::st_set_crs(st_crs(goodwin_pts))
#test plot
# plot(sampling_polys, border = 'grey')
# plot(ts_rot_proj, add = TRUE, border = 'black')
# plot(ts_centroids, add = TRUE, cex = .5, col = "red")
# plot(ts_line_rot_proj, add = TRUE, border = 'black')
# 

# test plot
# ggplot(data = ts_rot_proj)+
#   geom_sf(col = "red")+
#   geom_sf(data = ts_line_rot_proj)+
#   geom_sf(data = stratified_map_2, alpha = 0.7)
# 

# also avaialble in the PAR package:
# remotes::install_github('RodrigoAgronomia/PAR')


# from https://github.com/r-spatial/sf/issues/696
# rot = function(a) matrix(c(cos(a), sin(a), -sin(a), cos(a)), 2, 2)   
# nc = st_read(system.file("shape/nc.shp", package="sf"), quiet = TRUE)
# ncg = st_geometry(nc)                                                
# plot(ncg, border = 'grey')                                           
# cntrd = st_centroid(ncg)                                             
# #> Warning in st_centroid.sfc(ncg): st_centroid does not give correct
# #> centroids for longitude/latitude data
# ncg2 = (ncg - cntrd) * 1/rot(angle)  + cntrd                       
# plot(ncg2, add = TRUE)                                               
# plot(cntrd, col = 'red', add = TRUE, cex = .5)  
