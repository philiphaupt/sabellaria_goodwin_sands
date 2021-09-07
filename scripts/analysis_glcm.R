# https://riptutorial.com/r/example/12880/calculating-glcm-texture

# After processing, we can analyse texture like this.

library(glcm)
library(raster)
library(Rcpp)

# Gray Level Co-Occurrence Matrix (Haralick et al. 1973) texture is a powerful image feature for image analysis. The glcm package provides a easy-to-use function to calculate such texutral features for RasterLayer objects in R.

r <- raster("C:/Program Files/R/R-4.0.2/doc/html/logo.jpg")
#r <- raster("C:/Users/Phillip Haupt/Documents/SABELLARIA/side-scan/data/2021_07_20/2021_07_20_N27_53to54_LF_0.tif")
plot(r)

rglcm <- glcm(r, 
              window = c(9,9), 
              shift = c(1,1), 
              statistics = c("mean",
                             # "variance", 
                             # "homogeneity", 
                             # "contrast", 
                             # "dissimilarity", 
                             # "entropy", 
                             # "second_moment"
                             )
)

plot(rglcm)

# Calculation rotation-invariant texture features
# 
# The textural features can also be calculated in all 4 directions (0°, 45°, 90° and 135°) and then combined to one rotation-invariant texture. The key for this is the shift parameter:
#   
rglcm1 <- glcm(r, 
               window = c(9,9), 
               shift=list(c(0,1), c(1,1), c(1,0), c(1,-1)), 
               statistics = c("mean", "variance", "homogeneity", "contrast", 
                              "dissimilarity", "entropy", "second_moment")
)

plot(rglcm1)