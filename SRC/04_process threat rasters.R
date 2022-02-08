# Libraries ---------------------------------------------------------------
library(fasterize)
library(raster)
library(tidyverse)
library(readxl)
library(sf)
library(rasterVis)
library(RColorBrewer)

# Load data ---------------------------------------------------------------
load("C:/Users/DominicH/Desktop/scc-threat-maps/AllSens.RData")

## Raster template
r <- raster("Input/Slope_Degrees_30s.tif")

## RSA border for clipping/masking
outline <- st_read("Input/RSA_Outline.shp")

## Threat codes for easy layer referencing
codes_lev1 <- read_csv("Input/Threat_Codes_L1.csv")
codes_lev2 <- read_csv("Input/Threat_Codes_L2.csv")

## Priority areas
prior_areas <- st_read("Input/EWT_PrioritySites_2019_proj.shp") %>%
  st_transform(crs = latlongCRS) %>%
  filter(Selected == 1)

# Checks ------------------------------------------------------------------
temp <- AllSens %>%
  st_drop_geometry()

names(temp)

# Total number of species
temp %>%
  group_by(Scntf_N) %>%
  tally()

# Species per class
temp %>%
  distinct(Scntf_N, .keep_all = TRUE) %>%
  group_by(Class) %>%
  tally()

# Species list
unique(temp$Scntf_N)

# Add code to threat features ---------------------------------------------
AllSens <- AllSens %>%
  left_join(codes_lev1, by = c("Level_One_" = "level1_name")) %>%
  left_join(codes_lev2, by = c("Level_Two_" = "level2_name")) %>%
  mutate(level2_code = ifelse(is.na(level2_code), "NA", level2_code))

AllSens_Threats_L1 <- fasterize(AllSens, r, fun = "count", background = 0, by = "level1_code")
AllSens_Threats_L2 <- fasterize(AllSens, r, fun = "count", background = 0, by = "level2_code")

plot(AllSens_Threats_L2)

mask_clip_rsa <- function(x){

  ## Mask and clip to RSA shapefile
  Masked_AllSens_Threats <- mask(x, outline)
  Clipped_AllSens_Threats <- crop(Masked_AllSens_Threats, outline)

  ## Convert to raster stack
  Clipped_AllSens_Threats <- stack(Clipped_AllSens_Threats)

  return(Clipped_AllSens_Threats)


}

AllSens_Threats_L1 <- mask_clip_rsa(AllSens_Threats_L1)
AllSens_Threats_L2 <- mask_clip_rsa(AllSens_Threats_L2)

## Write rasters to TIFF files
output_raster <- function(x,y,num){
  writeRaster(y[[x]], glue::glue("Output/SA_rasters/L{num}_{x}"), format = "GTiff", overwrite = TRUE)
}

pwalk(.l = list(as.list(names(AllSens_Threats_L1)),list(AllSens_Threats_L1),list(1)),
      .f = output_raster)

pwalk(.l = list(as.list(names(AllSens_Threats_L2)),list(AllSens_Threats_L2),list(2)),
      .f = output_raster)

# Intersect with EWT priority areas ---------------------------------------

mask_clip_ewt <- function(x){

  ## Mask and clip to RSA shapefile
  Masked_AllSens_Threats <- mask(x, prior_areas)
  Clipped_AllSens_Threats <- crop(Masked_AllSens_Threats, prior_areas)

  ## Convert to raster stack
  Clipped_AllSens_Threats <- stack(Clipped_AllSens_Threats)

  return(Clipped_AllSens_Threats)


}

AllSens_Threats_L1_PA <- mask_clip_ewt(AllSens_Threats_L1)
AllSens_Threats_L2_PA <- mask_clip_ewt(AllSens_Threats_L2)

## Write rasters to TIFF files
output_raster <- function(x,y,num){
  writeRaster(y[[x]], glue::glue("Output/EWT_PA_rasters/PA_L{num}_{x}"), format = "GTiff", overwrite = TRUE)
}

pwalk(.l = list(as.list(names(AllSens_Threats_L1_PA)),list(AllSens_Threats_L1_PA),list(1)),
      .f = output_raster)

pwalk(.l = list(as.list(names(AllSens_Threats_L2_PA)),list(AllSens_Threats_L2_PA),list(2)),
      .f = output_raster)

