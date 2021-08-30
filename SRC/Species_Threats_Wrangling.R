# Load required packages
library(tidyverse)
library(readxl)
library(sf)
library(fasterize)
library(raster)

# import EST shapefile
# select relevant columns 
# filter to only include only reptiles, amphibians and mammals [NB: can add birds 
# to this but makes data unwieldy]
# rename columns
# replace sensitive species codes with species names [NB: I have removed renaming
# Sensitive Species 2 but if you add birds, remove the '#' @line28]
# separate tmp3 column at the '-', only keep the scientific name; rename column

screening_tool_no_birds <- read_sf("Input/animal_combined_sensitivity.shp") %>% #name shows that this code filters out birds, change if necessary
  select(OBJECTID:tmp3,geometry) %>% 
  filter(str_detect(OBJECTID, 'REPT|AMPH|MAMM')) %>% #add 'BIRD' if so desired but be warned the medium sensitivity layer will throw up an error when converted to shapefile
  rename(Sensitivity = tmp1,
         Layer = tmp2) %>% 
  mutate_at("tmp3", str_replace, 'Sensitive species 12', 'Reptilia-Kinixys lobatsiana') %>%
  mutate_at("tmp3", str_replace, 'Sensitive species 13','Reptilia-Chersobius signatus') %>%
  mutate_at("tmp3", str_replace, 'Sensitive species 15', 'Reptilia-Bitis armata') %>%
  mutate_at("tmp3", str_replace, 'Sensitive species 16', 'Reptilia-Psammobates geometricus') %>%
  mutate_at("tmp3", str_replace, 'Sensitive species 18', 'Reptilia-Bitis albanica') %>% 
  mutate_at("tmp3", str_replace, 'Sensitive species 1', 'Reptilia-Crocodylus niloticus') %>%
  #mutate_at("tmp3", str_replace, 'Sensitive species 2', 'Aves-Balearica regulorum') %> 
  mutate_at("tmp3", str_replace, 'Sensitive species 3', 'Aves-Poicephalus robustus') %>%
  mutate_at("tmp3", str_replace, 'Sensitive species 7', 'Mammalia-Philantomba monticola') %>%
  separate(tmp3, c(NA, "Scientific_Name"), sep = "-")

# write and export for further analyses in Python
st_write(screening_tool_no_birds, "Output/Species_AllSens_Clean_No_Birds.shp")

# can insert code here to run python script from R. I tried but it didn't work!!!!

# import the  output shapefile with attached threats as created with python code
# import raster with correct cell size-I'm using Slope_Degrees-30S.tf
# Import RSA outline shapefile for clipping/masking
AllSens <- st_read("Input/Species_All_Clean_No_Birds_Threat_Data.shp")
r <- raster("Input/Slope_Degrees_30s.tif")
outline <- st_read("Input/RSA_Outline.shp")

# create multiband raster with each band counting the frequency of level one threats with fasterize
AllSens_Threats <- fasterize(AllSens, r, fun = "count", background = 0, by = "Level_One_")

# mask and clip to RSA shapefile
Masked_AllSens_Threats <- mask(AllSens_Threats, outline) 
Clipped_AllSens_Threats <- crop(Masked_AllSens_Threats, outline)

#create unique rasters from each band, rename as Level One threat category and export as tiff
Band1 <- Clipped_AllSens_Threats[[1]]
writeRaster(Band1, "Output/All_Agriculture_&_aquaculture", format = "GTiff", overwrite = T)

Band2 <- Clipped_AllSens_Threats[[2]]
writeRaster(Band2, "Output/All_Invasive_&_other_problematic_species_genes_&_diseases", format = "GTiff", overwrite = T)

Band3 <- Clipped_AllSens_Threats[[3]]
writeRaster(Band3, "Output/All_Natural_system_modifications", format = "GTiff", overwrite = T)

Band4 <- Clipped_AllSens_Threats[[4]]
writeRaster(Band4, "Output/All_Residential_&_commercial_development", format = "GTiff", overwrite = T)

Band5 <- Clipped_AllSens_Threats[[5]]
writeRaster(Band5, "Output/All_Energy_production_&_mining", format = "GTiff", overwrite = T)

# Band6 excluded as it is NA and is from only one species (Pelusios castanoides)

Band7 <- Clipped_AllSens_Threats[[7]]
writeRaster(Band7, "Output/All_Pollution", format = "GTiff", overwrite = T)

Band8 <- Clipped_AllSens_Threats[[8]]
writeRaster(Band8, "Output/All_Biological_resource_use", format = "GTiff", overwrite = T)

Band9 <- Clipped_AllSens_Threats[[9]]
writeRaster(Band9, "Output/All_Transportation_&_service_corridors", format = "GTiff", overwrite = T)

Band10 <- Clipped_AllSens_Threats[[10]]
writeRaster(Band10, "Output/All_Climate_change_&_severe_weather", format = "GTiff", overwrite = T)

Band11 <- Clipped_AllSens_Threats[[11]]
writeRaster(Band11, "Output/All_Human_intrusions_&_disturbance", format = "GTiff", overwrite = T)

# Band12 is "other options" and is only applicable to a single species (Acinonyx jubatus)
Band12 <- Clipped_AllSens_Threats[[12]]
writeRaster(Band12, "Output/All_Other_options", format = "GTiff", overwrite = T)

---------------------------------------------------------------------------------------
# For now ignore this, it can be fleshed out if we want to repeat the above but for each sensitivity layer
#Filter for Medium Sensitivity
Species_Medium_No_Birds <- screening_tool_no_birds %>%
  filter(str_detect(Sensitivity, 'Medium'))
  
#Filter for High Sensitivity
Species_High_No_birds <- screening_tool_no_birds %>%
  filter(str_detect(Sensitivity, 'High'))

#Filter for Very High Sensitivity
Species_Very_High_No_birds <- screening_tool_no_birds %>%
  filter(str_detect(Sensitivity, 'Very high'))
  
#export for further analyses with python
st_write(Species_Medium_No_Birds, "Output/Species_Medium_Clean_No_Birds.shp")
st_write(Species_High_No_birds, "Output/Species_High_Clean_No_Birds.shp")
st_write(Species_Very_High_No_birds, "Output/Species_VeryHigh_Clean_No_Birds.shp")

HighSens <- st_read("Input/EST_High_No_Birds_Threat_Data.shp")
r <- raster("Input/Slope_Degrees_30s.tif")
High_Sens_Threats <- fasterize(HighSens, r, fun = "count", background = 0, by = "Level_One_")

MedSens <- st_read("Input/EST_Medium_No_Birds_Threat_Data.shp")
Med_Sens_Threats <- fasterize(MedSens, r, fun = "count", background = 0, by = "Level_One_")

High_Sens_Threats_L2 <- fasterize(HighSens, r, fun = "count", background = 0, by = "Level_Two_")
writeRaster(High_Sens_Threats_L2, "Output/High_Sens_Threats_L2", format = "GTiff")


Med_Sens_Threats_L2 <- fasterize(MedSens, r, fun = "count", background = 0, by = "Level_Two_")
writeRaster(Med_Sens_Threats_L2, "Output/Med_Sens_Threats_L2", format = "GTiff")

