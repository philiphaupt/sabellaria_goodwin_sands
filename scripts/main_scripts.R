#main scipts

#1. prepare Goodwin Sands MCZ
source("C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/spatial_optimisation/goodwin_sands_evidence/scripts/map_utelities_prep_goodwin_mcz.R", echo=T) # MCZ

#2. prepare Sabellaria sample points from survey data
source("C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/spatial_optimisation/goodwin_sands_evidence/scripts/feature_prep_sabellaria_and_mussels.R", echo = F)

#3. Prepare Sabellaria model
source("./scripts/prepare_sabellaria_sdm_goodwin.R", echo = T)

raster::writeRaster(sab_mod_goodwin, file = "sabellaria_utm31.tif")

getwd()
# next survey design
# sample points areas with 
# 1) high probability and previous records, 
# 2) high probability and NO previous records, 
# 3) low- medium probability and previous records, 
# 4) low-medium probability and NO previous records, 


# 5) Decide on cut-off for high prob//low-medium, and recalls raster, then surface of presence absence and ADD to raster surface to create four classes

# 6) Overlay randomly sampling points stratified  among four categories.

# 7) How does depth interact with feasibility of differnt survey types?
# What are the different survey types?
# Video
# Side-scan sonar
# multibeam sonar
# Acoustic image (ARIS 1800 Explorer) currently with Ron Jessop - can we borrow it?