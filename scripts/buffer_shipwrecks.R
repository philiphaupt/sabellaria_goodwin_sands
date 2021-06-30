# buffer dangerous wrecks by 500 m 

goodwin_shipwrecks_wgs84_sf <- sf::st_intersection(shipwrecks_with_add_dat_sf, goodwin_wgs84_sf)
dangerous_wrecks_utm31 <- goodwin_shipwrecks_wgs84_sf %>% 
  filter(DEPTH < 20 | DESCRIPTION == "Dangerous wreck" | is.na(DEPTH)) %>% 
  st_transform(32631)


buffered_wrecks <- st_buffer(dangerous_wrecks_utm31, 500) %>% st_union()

ggplot(data = goodwin_shipwrecks_wgs84_sf)+
  geom_sf(aes(col = DEPTH))+
  geom_sf(data = buffered_wrecks, col = "red", alpha = 0.6)

