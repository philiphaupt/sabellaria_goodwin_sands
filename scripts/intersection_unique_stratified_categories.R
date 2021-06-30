# Intersection between layers to create unique sampling categories for stratified sampling design

# Move this to new script
## intersect new polygons
stratified_map_1 <- sf::st_intersection(bathy_sf, prob_sf) %>% mutate(stratification_1 = paste0(depth_category, "_", prob_category))
stratified_map_2 <- st_difference(stratified_map_1, buffered_wrecks)
#plot(stratified_map_1["stratification_1"])
# ggplot2::ggplot(stratified_map_1)+
#   geom_sf(aes(fill = stratification_1))+
#   geom_sf(data = sab_weighted_buffer, (aes(fill = taxonname)))

# stratification_2 (habitat)
stratified_map_3 <- sf::st_intersection(hab,stratified_map_2)
stratified_map_3 <- stratified_map_3 %>% 
  mutate(stratification_3 = paste0(hab_type, "_", stratification_1))



# TEST PLOT
ggplot(data = stratified_map_3 )+
   geom_sf(aes(fill =stratification_3))



