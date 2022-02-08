# Load required packages
library(tidyverse)
library(sf)

est <- st_read("Output/est_filtered_no_birds.shp")
head(est)

birds <- st_read("Input/bird_sensitivity_combined.shp")

birds <- birds %>%
  rename(OBJECTI = OBJECTID,
         Snstvty = SENSITIVIT,
         Layer = THEME,
         Scntf_N = SENSFEAT) %>%
  select(OBJECTI, Snstvty, Layer, Scntf_N) %>%
  mutate(Scntf_N = case_when(
    Scntf_N == "Sensitive species 2" ~ "Aves-Balearica regulorum",
    Scntf_N == "Sensitive species 3" ~ "Aves-Poicephalus robustus",
    TRUE ~ as.character(Scntf_N)
  ))


head(est)
head(birds)

est_filtered <- bind_rows(est,birds)

# Write combined file that contains all species from all taxa
st_write(est_filtered, "Output/est_filtered_all.shp")