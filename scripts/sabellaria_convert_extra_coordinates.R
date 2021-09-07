#Aim of script: read GPS coordinates in DDM format data from excel file and convert to DD and save new outputs (points and lines) to GPX and GPKG.
# The main requirements is that the input data is Excel and coordinates are in DDM format (WGS 84 unprojected geographic coordinates) and must have column names that start with labelled lat and lon/g.
# The input format needs to be entered in a way that can easily be separated: I suggest using d to denote degress, and a point to separate decimal minutes from the minutes, like this
# e.g. 001d.14.345


# Load libraries (you may need to install these if you do not have them)
library(tidyverse)
library(readxl)
library(sf)
# load my converter function
source("C:/Users/Phillip Haupt/Documents/GIS/COORDINATE_CONVERTER/coordinate_converter/scripts/ddm_to_dd_converter.R")

# Inputs
# 1) read in the data - if the file is not found it will open a broweser for you to select the file.
data_in <- try(readxl::read_xlsx("C:/Users/Phillip Haupt/Documents/SABELLARIA/sabellaria_goodwin_sands/extra_coordinates_added_to_Sabellaria_survey.xlsx"),
    file.choose(), silent = FALSE)

# 2) Data prep: Prepare data for converion
# 2.1) create a copy that we can modify (we do this becuase we want to join the attributes from the original data back at then, but not try to take them through all the processing along the way.)
dat_for_conversion <- data_in
# 2.2) convert names to lower caps (so that it matches what the function is expecting! (in case you used upper caps))
names(dat_for_conversion) <- tolower(names(dat_for_conversion))
# 2.3) Reduce the dimensions of the data selecting only excatly what is needed.
dat_for_conversion <- dat_for_conversion %>% select(lat = starts_with("lat"), long = starts_with("lon"))



# Outputs
# 3.1) Convert the coordinates from ddm to dd (This calls teh function loaded at the start and it is automatically run for the columns named lat and lon/g)
conversion_fn_output <- apply( dat_for_conversion[,grep("lat", colnames(dat_for_conversion))| grep("long", colnames(dat_for_conversion))] , 2 , conversion_fn )
# the output is a nested list of coordinates - which is not handy so below,

# 3.2) Change the object to a tibble (not nested list), so that we can use it easier.
output_data <- tibble(x = unlist(conversion_fn_output[grep("lon", names(conversion_fn_output))]),
                      y = unlist(conversion_fn_output[grep("lat", names(conversion_fn_output))]))

# 4) Convert the data in to a recognised spatial format (this will allow changing points to lines, plotting and saving to GIS formats.
output_pts_sf <- st_as_sf(output_data, coords = c("x", "y"), crs = 4326) # Creates r spatial object (sf). Note, can change crs to 32631 to get utm31 output

# Group points to the same transect - this will use two consecutive points entered the same grp number. This grp number wil in turn be used to make a distinct line for each group (grp).
output_pts_sf$grp <- rep(1:(nrow(output_data)/2), each=2) # this could easiy be changed to be based on something else, like the orignal data line numbers if needed.

# 5.1) Join the original attributes back to the converted data.
output_pts_sf <- cbind(output_pts_sf, data_in)

# 5.1) change line name to factor (for plotting)
output_pts_sf <- output_pts_sf %>% 
        mutate(line_name = as.factor(line_name))

# 6) Make tansect lines from points: cast points to lines
new_transect_lines_sf <- output_pts_sf %>%
    filter(survey_block %in% "D") %>% 
        group_by(line_name) %>% # you can change teh grp number to the somethign like line_name from the attribute table to group the points by.
        summarise() %>%
        st_cast(to = "LINESTRING",
                ids = "line_name",
                do_split = TRUE) 
# Ignore the warning (repeated) message - it is just specifying the assumptions made when processing - for each group of points.

# 7) reproject lines for consistency to UTM31
new_transect_lines_sf_utm <- st_transform(new_transect_lines_sf, 32631)

# 8) Visual test of outputs
# Plot output to see if it looks correct
ggplot() +
        geom_sf_text(data = output_pts_sf,
                     aes(label = point_ids),
        )+
        geom_sf(data = new_transect_lines_sf, #using WGS one here, but we will write the projected version.
                aes(col = line_name)) +
        geom_sf(data = output_pts_sf,
                aes(col = line_name)) +
        labs(col = "Transect /n line /n numbers") +
        theme_bw() +
        scale_color_discrete() 

# Get column names from original files - and add to new transects and points
# original_points <- st_read(dsn = "C:/Users/Phillip Haupt/Documents/SABELLARIA/sabellaria_goodwin_sands/sabellaria_sampling_design.gpkg",
#                            layer="sonar_transects_start_end_pts_for_upload_WGS84")
# column_names_points <- names(original_points)
# 
# original_transects <- st_read(dsn = "C:/Users/Phillip Haupt/Documents/SABELLARIA/sabellaria_goodwin_sands/sabellaria_sampling_design.gpkg",
#                               layer="sonar_transects_adj_strata_info")
# column_names_ts_lines <- names(original_transects)




# 9) Save to GIS and GPS formats (only once you are happy with output)
# 9.1) save new POINTS to existing file by appending the points from output_pts_sf to the GPKG.
st_write(
        output_pts_sf,
        dsn = "C:/Users/Phillip Haupt/Documents/SABELLARIA/sabellaria_goodwin_sands/sabellaria_sampling_design.gpkg",
        layer = "sonar_transects_start_end_pts_for_upload_WGS84_ADD",
        delete_layer = TRUE
        )


# 9.2) save new LINES to existing file by appending the lines to the GPKG.
st_write(
        new_transect_lines_sf_utm,
        dsn = "C:/Users/Phillip Haupt/Documents/SABELLARIA/sabellaria_goodwin_sands/sabellaria_sampling_design.gpkg",
        layer = "sonar_transects_adj_strata_info_ADD",
        delete_layer = TRUE
)

# 9.3) save to new GPX file for Ben to upload to Boat's GPS. - might be best to save this from QGIS once happy - commented off.
# writeOGR(new_transect_lines_sf, 
#          dsn="C:/Users/Phillip Haupt/Documents/SABELLARIA/sabellaria_goodwin_sands/sabellaria_sampling_design_test.gpx",
#          dataset_options="GPX_USE_EXTENSIONS=yes",layer="routes",driver="GPX", overwrite_layer = T)

