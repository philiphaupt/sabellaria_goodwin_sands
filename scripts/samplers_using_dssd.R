# test crtaeting a sampling design using distance based sampling package:
# this allows specfying different angles and lines, and number of lines per strata.

library("dssd")
# transect grid - rotated at desired angle
boxes <- sf::st_difference(ts_rot_proj) %>% st_cast("POLYGON")

# define parameters for making transect lines inside boxes

region <- make.region(
  region.name = "Goodwin Sands sampling area",
  #strata.name = "depth_category",
  units = "m",
  shape = boxes,
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
transects <- generate.transects(default.design)
# test plot
plot(region, transects, lwd = 1.5, col = 4)


# this isolates the transects should yu owish to use them on their own!
samplers <- (transects@samplers)
ggplot(data = samplers)+
  geom_sf()+
  geom_sf(data = boxes, col = "red", alpha = 0.1)+
  geom_sf(data = goodwin_utm31_sf, alpha = 0.1)
