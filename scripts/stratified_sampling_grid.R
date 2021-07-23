# Sampling grid based on stratification

#Start here: respificy the grid sahpe etc.

#------Method 2: make grid, then select random subset, avoids overlap
# create a regular grid with a minimum distance of x m between points - specified by user that the start
sample_grid_pts_raw <- st_as_sf(sf::st_make_grid(x = stratified_map_3, cellsize = min_area_separation, what = "centers"))
#test plot
ggplot(data = sample_grid_pts_raw)+
  geom_sf()+
  geom_sf(data = stratified_map_3, alpha = 0.7)

# assign raster value - i.e. category//grp
sample_grid_pts_strat_info <- sf::st_intersection(stratified_map_3,sample_grid_pts_raw) %>% 
  rename(category = stratification_3)
# filter results dropping no data values (outsiude of goodwin sands and then resample x number oper category)
sample_grid_pts_strat_info_filtered <- sample_grid_pts_strat_info %>% # remove areas outisde or based on na data values
  group_by(category) %>% # group according to category
  slice_sample(n = samples_per_category) # keep five per group

#test plot
ggplot(data = sample_grid_pts_strat_info_filtered)+
  geom_sf(col = "red")+
  geom_sf(data = stratified_map_3, alpha = 0.7)



s3f_polys <- sample_grid_pts_strat_info_filtered %>% 
  st_buffer(side_scan_area_length, endCapStyle = "SQUARE")

ggplot(data = stratified_map_3)+
  geom_sf(col = "grey33")+
  geom_sf(data = s3f_polys, col = "red", alpha = 0.3)+
  geom_sf(data = sample_grid_pts_strat_info_filtered, col = "black")
  


#-----------------NOT USED
# step2  create line transects
# 2.1 create regular grid points inside sample polygons, the convert them into lines
# ts_pts_start_end <- st_make_grid(s3f_polys, 
#                                  cellsize = c(ts_length, ts_repl_dist_apart), 
#                                  what = "centers") %>% #makes regular points at specified distances 
#   st_intersection(s3f_polys) # # keep ony points in polys
# #plot(ts_pts_start_end)#test -works
# 
# # convert points to lines
# l <- split(as.data.frame(st_coordinates(ts_pts_start_end)), rep(seq(length(ts_pts_start_end)/2), each = 2))
# lp <- raster::spLines(lapply(l, as.matrix))
# ts_lines <- st_as_sf(lp)
# ts_lines <- st_set_crs(ts_lines, 32631)
# 
# ts_lines <- ts_lines %>% 
#   slice_sample(n = samples_per_category)
  






