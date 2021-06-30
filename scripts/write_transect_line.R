# Write the transects and squares to geopackage for further analysis in QGIS

library(sf)

# write file
sf::st_write(boxes, "sabellaria_sampling_design.gpkg", layer = "sonar_sampling_areas", delete_layer = TRUE)
sf::st_write(samplers, "sabellaria_sampling_design.gpkg", layer = "sonar_transect_lines",delete_layer = TRUE)
sf::st_write(stratified_map_3, "sabellaria_sampling_design.gpkg",layer = "strata", delete_layer = TRUE)
