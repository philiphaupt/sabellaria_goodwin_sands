# reclassify the number of categories of probailities
library(ecbtools)

#-----------

# Convert sabellaria raster to stack raster to allow extracting kmeans
sab_stack <- raster::stack(sab_mod_goodwin)
# reclassify the probability maop into cateogries based on values - can use proximity to influence
set.seed(123)
kmeans_sab <- raster.kmeans(x = sab_stack, k = n_prob_categories, iter.max = 100, nstart = 10, geo = T, geo.weight = 0.2)

# test plot
plot(kmeans_sab, 
     col = topo.colors(n_prob_categories), 
     main = paste0(n_prob_categories, " probability categories, high and low") 
     )

