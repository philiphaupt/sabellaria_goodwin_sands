# create sampling lines inside manual boxes

library(sf)
library(dssd)

boxes_manual <- st_read("C:/Users/Phillip Haupt/Documents/SABELLARIA/sabellaria_goodwin_sands/sabellaria_sampling_design.gpkg", layer = "sonar_transect_areas_manual_adj")


region <- make.region(
  region.name = "Goodwin Sands manual sampling area",
  #strata.name = "depth_category",
  units = "m",
  shape = boxes_manual,
)

cover <- make.coverage(region,
                       n.grid.points = 300)
plot(region, cover)


default.design <- make.design(region = region,
                              transect.type = "line",
                              design = "systematic",
                              samplers = 38,
                              #spacing = 100,
                              design.angle = c(angle*(90/pi)),
                              edge.protocol = "minus",
                              truncation = 2000, 
                              coverage.grid = cover)
transects_manual <- generate.transects(default.design)
# test plot
plot(region, transects_manual, lwd = 1.5, col = 4)


# this isolates the transects should yu owish to use them on their own!
samplers_manual <- (transects_manual@samplers)
ggplot(data = samplers)+
  geom_sf()+
  geom_sf(data = boxes, col = "red", alpha = 0.1)+
  geom_sf(data = goodwin_utm31_sf, alpha = 0.1)


#sf::st_write(samplers_manual, "sabellaria_sampling_design.gpkg", layer = "sonar_transect_lines_manual",delete_layer = TRUE)
