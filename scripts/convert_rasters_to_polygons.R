# Aim: #Create unique stratified map for informing sampling design:  assign atributes values & convert rasters to polygons & interesct resulting polygons

# Details convert raster to polygons so that we can assign cateogories in character values and intersect them with other (converted) polygons to yield a unique stratifiction map

#Bathymetry
bathy_sp <- rasterToPolygons(kmeans_bathy)
bathy_sf <- sf::st_as_sf(bathy_sp) %>% 
  group_by(layer) %>% 
  summarise() %>% 
  mutate(depth_category = ifelse(layer == 1, "shallow", "deep"))

plot(bathy_sf["depth_category"])

#Probability surface
prob_sp <- rasterToPolygons(kmeans_sab)
prob_sf <- sf::st_as_sf(prob_sp) %>% 
  group_by(layer) %>% 
  summarise() %>% 
  mutate(prob_category = ifelse(layer == 2, "low", "high"))
plot(prob_sf["prob_category"])

# 



#- could functionalise this...and create a collection of raster in a list, which is then fed through something like this....



