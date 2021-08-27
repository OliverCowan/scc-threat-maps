library(tidyverse)
library(readxl)
library(sf)
library(fasterize)
library(raster)
library(rgdal)
# import EST shapefile
# select relevant columns 
# filter to only include only reptiles, amphibians and mammals [NB: can add birds to this but makes data unwieldy]
# rename columns
#replace sensitive species codes with species names [NB: I have removed renaming SS2 but if you add birds, remove teh '#' @line23]
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

# run python analysis #NOTWORKING!!!!!!!!!!!
system('"C:/Program Files/ArcGIS/Pro/bin/Python/envs/arcgispro-py3/python 
       SRC/EST_Threats.py',
       intern = TRUE)


HighSens <- st_read("Input/EST_High_No_Birds_Threat_Data.shp")
r <- raster("Input/Slope_Degrees_30s.tif")
High_Sens_Threats <- fasterize(HighSens, r, fun = "count", background = 0, by = "Level_One_")
writeRaster(High_Sens_Threats, "Output/High_Sens_Threats", format = "GTiff")

MedSens <- st_read("Input/EST_Medium_No_Birds_Threat_Data.shp")
Med_Sens_Threats <- fasterize(MedSens, r, fun = "count", background = 0, by = "Level_One_")
writeRaster(Med_Sens_Threats, "Output/Med_Sens_Threats", format = "GTiff")


High_Sens_Threats_L2 <- fasterize(HighSens, r, fun = "count", background = 0, by = "Level_Two_")
writeRaster(High_Sens_Threats_L2, "Output/High_Sens_Threats_L2", format = "GTiff")


Med_Sens_Threats_L2 <- fasterize(MedSens, r, fun = "count", background = 0, by = "Level_Two_")
writeRaster(Med_Sens_Threats_L2, "Output/Med_Sens_Threats_L2", format = "GTiff")

