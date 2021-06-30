# read habitat (utm 31)

#sf::st_layers("C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/original_data/goodwin_habitat_utm31n.gpkg")

hab <- sf::st_read("C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/original_data/goodwin_habitat_utm31n.gpkg", layer = "goodwin_habitat_no_topo_error_utm31")

print("Habitat object is: hab.")

ggplot(data = hab)+
  geom_sf(aes(fill = hab_type))

