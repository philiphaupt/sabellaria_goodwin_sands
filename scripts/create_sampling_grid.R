# Create  a sampling grid
library(raster)
library(ecbtools)

n_grps <- 2

sab_mod_goodwin # get raster details

# convert points to grid
# Convert points to sp (assumes that the sf object is called example_points)
sab_sp <- as(sab, "Spatial")

# # Generate empty raster layer and rasterize points
# sab_pt_raster <- raster(crs = sab_mod_goodwin, vals = 0, resolution = c(300, 299), ext = extent(c(393571.5, 411271.5, 5665794, 5689714))) %>%
#   rasterize(sab)

# Convert sabellaria raster to stack raster to allow extracting kmeans
sab_stack <- raster::stack(sab_mod_goodwin)
# reclassify the probability maop into cateogries based on values - can use proximity to influence
kmeans_sab <- raster.kmeans(x = sab_stack, k = n_grps, iter.max = 100, nstart = 10, geo = T, geo.weight = 0.2)

# test plot
plot(kmeans_sab, col = topo.colors(n_grps))

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
sampling_areas_utm31 <- st_buffer(sampling_points_utm31, dist = 1000, endCapStyle = "SQUARE")

#drop some areas, especially no data ones
filtered_sampling_areas_utm31 <- sampling_areas_utm31 %>% 
  filter(!is.na(v)) %>% 
  group_by(v) %>% # drops na data areas
  slice_sample(n = 10)

plot(kmeans_sab, col = terrain.colors(n_grps))
plot(filtered_sampling_areas_utm31, add = TRUE, alpha = 0.5)

sf::st_write(filtered_sampling_areas_utm31, "sabellaria_sampling.gpkg", layer = "side_scan_areas")

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
  