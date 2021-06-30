# Aim: create sampling points layer 


# read in sabellaria
library(sf)
library(tidyverse)

# SPECIES - only designated species were used
# read in spatial point data for sabellaria and mussels
sab_and_mussels <- sf::st_read("C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/original_data/sab_and_mussels_mcz_features_utm31n.gpkg")
sab_and_mussels <- sab_and_mussels %>% mutate(name = tolower(str_sub(sab_and_mussels$taxonname,1,3))) # add simplified species name


# ASSIGN FEATURE IDs: Species
sab_and_mussels$fid <- sab_and_mussels$id # rename column "id" to "fid",becuase column name "ID" is reserved for problem setting in PriotizeR.
sab_and_mussels$id[sab_and_mussels$name == "sab"] <- 1 # assign id numbers based on species names that match the SPEC file
sab_and_mussels$id[sab_and_mussels$name == "myt"] <- 2 # assign id numbers based on species names that match the SPEC file



# overlay sabellaria points
sab <- sab_and_mussels %>% filter(name == "sab")
st_coordinates(sab)
points(st_coordinates(sab), cex = 0.5 * log(as.numeric(sab$count)))
summary(as.numeric(sab$count))
median(as.numeric(sab$count))
  # ggplot(data = sab, aes(x = as.numeric(count), col = "red"))+
  #   geom_density()

# Buffer the points using abudnance weighting
sab_weighted_buffer <- sf::st_buffer(sab, 
                                     endCapStyle = "ROUND",
                                     dist = 30*log(as.numeric(sab$count))
)
#test plot
plot(sab_weighted_buffer["taxonname"])
  
# reproject to utm
sab_weighted_buffer_utm31 <- sab_weighted_buffer %>% st_transform(32631)
