# Create  a sampling grid
library(raster)
library(ecbtools)
#library(genrandompnts)

# # user variables
# n_grps <- 6 # number of grous/categories taht you want to reclasify the raster/probability surface as.
# samples_per_category <- 5
# side_scan_area_size <- 1001
# min_dist <- 3000 # nb! readme: minimum distance between centres of sampled areas# nb - this can be undermined if the above is too large. Also can cause problems if not a round number, suggest multiples of 1000!
# ts_length <- 1000 # e.g. 1000 is a 1 km transect length
# ts_repl_dist_apart <- 450 # if the swath is about 400m, then you want to make sure that there is at least 801m between them!
# 


sab_mod_goodwin # get raster details

#----------------
# reclassify the probaility surface
# Convert points to sp (assumes that the sf object is called example_points)
# sab_sp <- as(sab, "Spatial")

# # Generate empty raster layer and rasterize points
# sab_pt_raster <- raster(crs = sab_mod_goodwin, vals = 0, resolution = c(300, 299), ext = extent(c(393571.5, 411271.5, 5665794, 5689714))) %>%
#   rasterize(sab)




#-------------
#------Method 2: make grid, then select random subset, avoids overlap
# create a regular grid with a minimum distance of 1000 m between points
s2 <- st_as_sf(sf::st_make_grid(x = kmeans_sab, cellsize = min_dist, what = "centers"))

# assign raster value - i.e. category//grp
s2$category = raster::extract(kmeans_sab, s2)

# filter results dropping no data values (outsiude of goodwin sands and then resample x number oper category)
s2_filtered <- s2 %>% filter(!is.na(category)) %>% # remove areas outisde or based on na data values
  group_by(category) %>% # group accoring to category
  slice_sample(n = samples_per_category) # keep five per group


s2f_polys <- s2_filtered %>% st_buffer(side_scan_area_size, endCapStyle = "SQUARE")
plot(kmeans_sab, col = terrain.colors(n_grps))
plot(s2f_polys, add = TRUE, alpha = 0.5)
#-----------------
# step2  create line transects
# 2.1 create regular grid points inside sample polygons, the convert them into lines
ts_pts_start_end <- st_make_grid(s2f_polys, cellsize = c(ts_length, ts_repl_dist_apart), what = "centers") %>% #makes regular points at spef=cified distnaces 
  st_intersection(s2f_polys) # # keep ony points in polys
#plot(ts_pts_start_end)#test -works

# convert points to lines
l <- split(as.data.frame(st_coordinates(ts_pts_start_end)), rep(seq(length(ts_pts_start_end)/2), each = 2))
lp <- raster::spLines(lapply(l, as.matrix))
ts_lines <- st_as_sf(lp)


# test plot
plot(kmeans_sab, col = terrain.colors(n_grps))
plot(s2f_polys, add = TRUE, alpha = 0.5)
plot(ts_lines, add = TRUE)
plot(ts_pts_start_end, add = TRUE)

#-------------
#-----------method 1: for randomly stratified - problem that you can have overlapping points - see method 2

#--------------------
# sampling grid
# check outpus - we do not really want overllapping squares - so rerun a few times until none are overallaping and save the seed value - so taht you can reproduce your restul exactly.
#x <- .Random.seed
#result <- <your code goes here>
#attr(s, "seed") <- x
set.seed(123)

# Randomly sample within each class (do not sample in NA)
s <- sampleStratified(kmeans_sab, size=25, na.rm=TRUE)


# Convert cell number to XY coords
xy <- xyFromCell(kmeans_sab,s) 

# extract values at points
v <- raster::extract(kmeans_sab, xy)

# Plot data
plot(kmeans_sab, col = topo.colors(n_grps))
points(xy)

st_crs(sab_model_utm31) # get crs info, and apply below
# convert xy to sf object
sampling_points_utm31 <- st_as_sf(as.data.frame(xy), coords = c("x", "y"), crs = 32631, agr = "constant")
sampling_points_utm31 <- cbind(sampling_points_utm31, v) # associate cluster values to points

#define larger sampling areas from points by applying 1 km buffer
sampling_areas_utm31 <- st_buffer(sampling_points_utm31, dist = side_scan_area_size, endCapStyle = "SQUARE")

#drop some areas, especially no data ones
filtered_sampling_areas_utm31 <- sampling_areas_utm31 %>% 
  filter(!is.na(v)) %>% # remove areas outisde or based on na data values
  # sf::st_intersection() %>% # identify intersections/overlap
  #filter(n.overlaps < 2) %>% # remove polys that overlap
  group_by(v) %>% # group accoring to category
  slice_sample(n = samples_per_category) # retain only X number of polys from each cateory



plot(kmeans_sab, col = terrain.colors(n_grps))
plot(filtered_sampling_areas_utm31, add = TRUE, alpha = 0.5)

sf::st_write(filtered_sampling_areas_utm31, "sabellaria_sampling.gpkg", layer = "side_scan_areas")
#-------------

# check outputs ggplot
# raster to ggplot data first = 
gplot_data <- function(x, maxpixels = 50000)  {
  x <- raster::sampleRegular(x, maxpixels, asRaster = TRUE)
  coords <- raster::xyFromCell(x, seq_len(raster::ncell(x)))
  ## Extract values
  dat <- utils::stack(as.data.frame(raster::getValues(x))) 
  names(dat) <- c('value', 'variable')
  
  dat <- dplyr::as_tibble(data.frame(coords, dat))
  
  if (!is.null(levels(x))) {
    dat <- dplyr::left_join(dat, levels(x)[[1]], 
                            by = c("value" = "ID"))
  }
  dat
}
gplot_kmeans_sab <- gplot_data(kmeans_sab)

ggplot()+
  geom_tile(data = gplot_kmeans_sab, 
            aes(x = x, y = y)) +
  geom_sf(data = filtered_sampling_areas_utm31, aes(col = as.factor(v)) )

    # scale_fill_gradient("Distance",
    #                     low = 'yellow', high = 'blue',
    #                     na.value = NA)


# Then you can reset the PRNG as follows; result2 should be the same as result.
# .Random.seed <- attr(s, "seed")
  