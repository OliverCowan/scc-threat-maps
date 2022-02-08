# Load required packages
library(tidyverse)
library(sf)

est <- st_read("Output/est_filtered_all.shp")
head(est)
unique(est$Scntf_N)
nrow(est)

# RUN 1 -------------------------------------------------------------------

## Create a subset of data and run python code
est %>%
  filter(row_number() %in% 1:200000) %>%
  st_write("Output/est_all_01.shp")

## Parameter changes for python file
arcpy.MakeFeatureLayer_management("Output/est_all_01.shp", "EST_Species_Layer")
outFeatureClass = os.path.join("Output", "est_threats_01")

## Run
system('"C:/Program Files/ArcGIS/Pro/bin/Python/envs/arcgispro-py3/python" EST_Threats.py',
       intern = TRUE)

# RUN 2 -------------------------------------------------------------------

## Create a subset of data and run python code
est %>%
  filter(row_number() %in% 200001:400000) %>%
  st_write("Output/est_all_02.shp")

## Parameter changes for python file
arcpy.MakeFeatureLayer_management("Output/est_all_02.shp", "EST_Species_Layer")
outFeatureClass = os.path.join("Output", "est_threats_02")

## Run
system('"C:/Program Files/ArcGIS/Pro/bin/Python/envs/arcgispro-py3/python" EST_Threats.py',
       intern = TRUE)

# RUN 3 -------------------------------------------------------------------

## Create a subset of data and run python code
est %>%
  filter(row_number() %in% 400001:600000) %>%
  st_write("Output/est_all_03.shp")

## Parameter changes for python file
arcpy.MakeFeatureLayer_management("Output/est_all_03.shp", "EST_Species_Layer")
outFeatureClass = os.path.join("Output", "est_threats_03")

## Run
system('"C:/Program Files/ArcGIS/Pro/bin/Python/envs/arcgispro-py3/python" EST_Threats.py',
       intern = TRUE)

# RUN 4 -------------------------------------------------------------------

## Create a subset of data and run python code
est %>%
  filter(row_number() %in% 600001:nrow(est)) %>%
  st_write("Output/est_all_04.shp")

## Parameter changes for python file
arcpy.MakeFeatureLayer_management("Output/est_all_04.shp", "EST_Species_Layer")
outFeatureClass = os.path.join("Output", "est_threats_04")

## Run
system('"C:/Program Files/ArcGIS/Pro/bin/Python/envs/arcgispro-py3/python" EST_Threats.py',
       intern = TRUE)


# COMBINE OUTPUTS ---------------------------------------------------------

## Clear workspace and restart first

sens1 <- st_read("Output/est_threats_01.shp")
sens2 <- st_read("Output/est_threats_02.shp")
sens3 <- st_read("Output/est_threats_03.shp")
sens4 <- st_read("Output/est_threats_04.shp")

AllSens <- bind_rows(sens1, sens2, sens3, sens4)

save.image("AllSens.RData")


