# time needed calclated using my methods

#

# number of transect lines
no_sonar_lines <- nrow(samplers)/2
# Total length sonar lines to run for each area, km
total_length_lines_km <- (ts_length/1000)*(no_sonar_lines)
# Total length sonar lines to run for each area, n.m.
total_length_lines_nm <- total_length_lines_km*0.54
# Total time to run sonar lines for each area, hrs (inc turns)
total_survey_time_needed <- (total_length_lines_nm/speed_kts)+((no_sonar_lines+1)*(turn_time/60))

print(cbind(no_sonar_lines, total_length_lines_km, total_length_lines_nm, total_survey_time_needed))

# Overall total time needed to complete the survey
sum(total_survey_time_needed)

# survey days 5 - 6 hrs working time
sum(total_survey_time_needed)/5
