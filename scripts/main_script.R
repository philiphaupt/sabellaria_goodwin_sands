# Main script
# Date: 25/06/2012
# Philip Haupt

# Aim: Perpare a sampling grid for Sabellaria surveys
# Details readme:



# User input variables: User To Specify sampling grid design


# Map stratification
n_depth_grps <- 2 # number of groups/categories that you want to reclasify the raster/probability surface as.
n_prob_categories <- 2 # number of probaility categories

# Bathymetry: filter image with depth: surveys below this depth dangerous at Goodwin Sands
depth_limits_min <- -7


# Replication in stratification/ number of survey boxes in each group:
samples_per_category <- 3 # number of areas that will be surveyed per n_grps

# Replication within each area
# Survey box parameters
side_scan_area_length <- 500 # length of survey box
side_scan_area_width <- 450 # width of the area surveyed
min_area_separation <- 3000 # nb! readme: minimum distance between centres of sampled areas # nb - this can be undermined if the above is too large. Also can cause problems if not a round number, suggest multiples of 1000!

# Survey line parameters wihtin boxes
ts_length <- 1000 # e.g. 1000 is a 1 km transect length
# NOT USED - this is included in dssd calculations
#ts_repl_dist_apart <- 400 #if the swath is about 400m, then you want to make sure that there is at least 801m between them!


# end of user input

# Prepare maps

# 1. prepare Goodwin Sands MCZ
source("C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/spatial_optimisation/goodwin_sands_evidence/scripts/map_utelities_prep_goodwin_mcz.R", echo=T) # MCZ

# 2. Shipwrecks  - buffered and excluded from design
borrowed_scripts_dir <- "C:/Users/Phillip Haupt/Documents/MPA/MCZs/GoodwinSands/spatial_planning/spatial_optimisation/goodwin_sands_evidence/"
source(paste0(borrowed_scripts_dir,"./scripts/feature_prep_shipwrecks.R"), echo=T) # not included
source(paste0(borrowed_scripts_dir,"./scripts/feature_prep_shipwrecks_add_GSCT_additional_data.R"), echo=T) # not included
source("./scripts/buffer_shipwrecks.R", echo = TRUE)

# 3. Prepare Sabellaria model
source("./scripts/prepare_sabellaria_sdm_goodwin.R", echo = T)
source("./scripts/kmeans_n_grps_sab_sdm.R", echo = T)

# 4. Prepare Bathymetry model
source('~/SABELLARIA/sabellaria_goodwin_sands/scripts/goodwin_bathy.R')
#raster::writeRaster(sab_mod_goodwin, file = "sabellaria_utm31.tif")

# 5. run buffer sabellaria presence points
source('~/SABELLARIA/sabellaria_goodwin_sands/scripts/create_buffered_areas_around_sabellaria_presence.R')

# 6. Habitat map
source("./scripts/read_goodwin_habitat.R", echo = TRUE)

# 7. convert rasters to polygons
source("./scripts/convert_rasters_to_polygons.R")

# 8. Intersection of unique habitats with deep and shallow areas and probabiility distribution
source("./scripts/intersection_unique_stratified_categories.R", echo = TRUE)

# 9. Create sampling grid
source("./scripts/stratified_sampling_grid.R")

# 10. ROTATE POLYGONS 45 degrees to get them to align
source("./scripts/rotate_sampling_lines.R")

# 10. Create transect lines
source("./scripts/samplers_using_dssd.R")

# 11. Plot outcome
source("./scripts/plot_outcome.R", echo = TRUE)

# 12. write to file
source("./scripts/write_transect_line.R", echo = TRUE)

# 13. after some manual movements of boxes - read boxes [manual] in, and recreate sampling lines wihtin.
# 14. and redraw transect lines - probably easiest to manually move them - but you can run below then R will draw them inside th shifted boxes: Note that runnign the latter will overwrite files with the smae name!
#NOT RUN file.edit("./scripts/create_sonar_transect_lines_inside_manual_boxes.R", echo = TRUE)
# I added the habitat infom the the adjusted transect lines in QGIS using Join attributes by location function.
# via a join with the tblEUNIS codes in the project.

# 15. Read in the file and extract the vertices for start and end points


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



###------------
# Calculating GLCM Texture 
source("./scripts/analysis_glcm.R")
