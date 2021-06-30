#plot 

# this isolates the transects should yu owish to use them on their own!
samplers <- (transects@samplers)
ggplot(data = samplers)+
  geom_sf()+
  geom_sf(data = boxes, col = "red", alpha = 0.5)+
  geom_sf(data = stratified_map_3, aes(fill = stratification_3), alpha = 0.5)
