#------Method 2: make grid, then select random subset, avoids overlap
# create a regular grid with a minimum distance of x m between points - specified by user that the start
s2 <- st_as_sf(sf::st_make_grid(x = kmeans_bathy, cellsize = min_area_separation, what = "centers"))

# assign raster value - i.e. category//grp
s2$category = raster::extract(kmeans_bathy, s2)

# filter results dropping no data values (outsiude of goodwin sands and then resample x number oper category)
s2_filtered <- s2 %>% filter(!is.na(category)) %>% # remove areas outisde or based on na data values
  group_by(category) %>% # group according to category
  slice_sample(n = samples_per_category) # keep five per group


s2f_polys <- s2_filtered %>% st_buffer(side_scan_area_width, endCapStyle = "SQUARE")
plot(kmeans_bathy, col = terrain.colors(n_grps))
plot(s2f_polys, add = TRUE, alpha = 0.5)


#-----------------
# step2  create line transects
# 2.1 create regular grid points inside sample polygons, the convert them into lines
ts_pts_start_end <- st_make_grid(s2f_polys, 
                                 cellsize = c(ts_length, ts_repl_dist_apart), 
                                 what = "centers") %>% #makes regular points at specified distances 
  st_intersection(s2f_polys) # # keep ony points in polys
#plot(ts_pts_start_end)#test -works

# convert points to lines
l <- split(as.data.frame(st_coordinates(ts_pts_start_end)), rep(seq(length(ts_pts_start_end)/2), each = 2))
lp <- raster::spLines(lapply(l, as.matrix))
ts_lines <- st_as_sf(lp)

# ROTATE POLYGONS 45 degrees to get them to align
source("./scripts/rotate_sampling_lines.R")


# test plot

plot(kmeans_bathy, col = terrain.colors(n_grps))
plot(s2f_polys, add = TRUE, alpha = 0.5)
plot(ts_lines, add = TRUE)
plot(ts_pts_start_end, add = TRUE)

