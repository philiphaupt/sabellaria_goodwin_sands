# side scan sonar times needed
library(tidyverse)
library(units)
# Stephen Thomson Eastern IFCA, Sep 2016		
# Philip Haupt Kent and Essex IFCA, Jun 2021
# 
# Notes
# 
# NB These calculations DO NOT include steaming to / from the survey area, nor steaming between survey areas (if applicable)


# Assumptions to act as basis for calculation -		Changing these assumptions will change the outcome	
# Sonar line spacing, m	150
line_spacing <- 150 # Our standard is 150 m. - gives 133% coverage at 100 m. range
# Sonar surveys Speed over Ground,
speed_kts <- 6  # knots	6		Six knots gives optimum resolution / coverage
# Time for each turn, 
turn_time <- 5 #minutes	5		Five minutes is a reasonable start on which to base calculations

# Givens - infomration about your sampling areas, transect lengths, etc.
# Area ID, e.g. AAAAA	BBBBB	CCCCC
area_id <- unique(samplers$strata)
# Area Name, e.g. Area 1	Area 2	Area 2
area_name <- paste0("area_", area_id)
# Area, Ha # e.g. 500	1875	3750
area_ha <- st_area(boxes)/10000 %>% set_units("ha")
  

# L, km, e.g. 5	12.5	15 # (lentgth in km)
transect_length <-  side_scan_area_length
# W, km (width in kilometers), e.g. 1	1.5	2.5
transect_width <- side_scan_area_width


# you may want the above infomarion to be generated from your sampling design
# so I will add ascript to generate the Gives table from the design, and earleir scripts.

# Calculations -
# No. sonar lines
no_sonar_lines <- round(((transect_width*1000)/line_spacing)+1,0)
# Total length sonar lines to run for each area, km
total_length_lines_km <- no_sonar_lines*transect_length
# Total length sonar lines to run for each area, n.m.
total_length_lines_nm <- total_length_lines_km*0.54
# Total time to run sonar lines for each area, hrs (inc turns)
total_survey_time_needed <- (total_length_lines_nm/speed_kts)+((no_sonar_lines+1)*(turn_time/60))

print(cbind(no_sonar_lines, total_length_lines_km, total_length_lines_nm, total_survey_time_needed))

# Overall total time needed to complete teh survey
sum(total_survey_time_needed)


