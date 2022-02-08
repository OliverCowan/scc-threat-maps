# Load required packages
library(tidyverse)
library(sf)

est <- read_sf("Input/animal_combined_sensitivity.shp")

est_filtered <- est %>%
  select(-tmp4) %>%
  rename(
    Sensitivity = tmp1,
    Layer = tmp2,
    Scientific_Name = tmp3
  ) %>%
  filter(str_detect(Scientific_Name, "Amphibia|Insecta|Mammalia|Reptilia|Sensitive"))


est_filtered <- est_filtered %>%
  mutate(Scientific_Name = case_when(
    Scientific_Name == "Sensitive species 19" ~ "Insecta-Alaena margaritacea",
    Scientific_Name == "Sensitive species 2" ~ "Aves-Balearica regulorum",
    Scientific_Name == "Sensitive species 18" ~ "Reptilia-Bitis albanica",
    Scientific_Name == "Sensitive species 15" ~ "Reptilia-Bitis armata",
    Scientific_Name == "Sensitive species 13" ~ "Reptilia-Chersobius signatus",
    Scientific_Name == "Sensitive species 4" ~ "Insecta-Chrysoritis dicksoni",
    Scientific_Name == "Sensitive species 9" ~ "Insecta-Chrysoritis thysbe schloszae",
    Scientific_Name == "Sensitive species 1" ~ "Reptilia-Crocodylus niloticus",
    Scientific_Name == "Sensitive species 10" ~ "Insecta-Erikssonia edgei",
    Scientific_Name == "Sensitive species 5" ~ "Insecta-Kedestes barberae bunta",
    Scientific_Name == "Sensitive species 12" ~ "Reptilia-Kinixys lobatsiana",
    Scientific_Name == "Sensitive species 14" ~ "Insecta-Lepidochrysops lotana",
    Scientific_Name == "Sensitive species 8" ~ "Insecta-Orachrysops niobe",
    Scientific_Name == "Sensitive species 7" ~ "Mammalia-Philantomba monticola",
    Scientific_Name == "Sensitive species 3" ~ "Aves-Poicephalus robustus",
    Scientific_Name == "Sensitive species 16" ~ "Reptilia-Psammobates geometricus",
    Scientific_Name == "Sensitive species 6" ~ "Insecta-Thestor brachycerus brachycerus",
    Scientific_Name == "Sensitive species 17" ~ "Insecta-Trimenia malagrida malagrida",
    Scientific_Name == "Sensitive species 11" ~ "Insecta-Trimenia wallengrenii wallengrenii",
    TRUE ~ as.character(Scientific_Name)
  ))

est_filtered <- est_filtered %>%
  separate(Scientific_Name, c(NA, "Scientific_Name"), sep = "-")

# write and export for further analyses in Python
st_write(est_filtered, "Output/est_filtered_no_birds.shp")
