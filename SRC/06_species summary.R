# Initial run -------------------------------------------------------------

# library(sf)
# load("Output/AllSens.RData")
# sens_table <- AllSens %>% st_drop_geometry()
# write_csv(sens_table, "Output/est_threats_all.csv")

# Libraries ---------------------------------------------------------------
library(tidyverse)
library(readxl)

# Import data -------------------------------------------------------------
sens_table <- read_csv("Output/est_threats_all.csv")

spp_list <- sens_table %>%
  pull(Scntf_N) %>%
  unique()

threat_table <- read_xlsx("Input/IUCN_Threat_Details_Jan2022.xlsx") %>%
  janitor::clean_names() %>%
  filter(scientific_name %in% spp_list)


# Summaries ---------------------------------------------------------------
threat_table %>%
  distinct(class, scientific_name) %>%
  group_by(class) %>%
  tally() %>%
  write_csv("Output/Mapping/tables & lists/class_tally.csv")

threat_table %>%
  group_by(class, scientific_name) %>%
  tally() %>%
  write_csv("Output/Mapping/tables & lists/species_list.csv")

# Figures -----------------------------------------------------------------
threat_table %>%
  # filter(ewt_strategic_site == "Y") %>%
  group_by(class, level_one_threat) %>%
  tally() %>%
  filter(!level_one_threat  %in% c("NA", "Other options")) %>%
  ggplot()+
  aes(x = reorder(level_one_threat, desc(level_one_threat)),
      y = n,
      fill = class)+
  geom_bar(stat = "identity", position = position_dodge2(reverse = TRUE))+
  coord_flip() +
  xlab(NULL)+
  ylab("Frequency")+
  theme(legend.title = element_blank(),
        axis.text = element_text(size = 16),
        legend.text = element_text(size = 14),
        axis.title = element_text(size = 14))

ggsave("Output/Mapping/tables & lists/threat_breakdown.jpg", width = 12, height = 9)


threat_table %>%
  # filter(ewt_strategic_site == "Y") %>%
  distinct(class, scientific_name, level_one_threat) %>%
  group_by(level_one_threat, class) %>%
  tally() %>%
  filter(!level_one_threat  %in% c("NA", "Other options")) %>%
  ggplot()+
  aes(x = reorder(level_one_threat, desc(level_one_threat)),
      y = n,
      fill = class)+
  geom_bar(stat = "identity", position = position_dodge2(reverse = TRUE))+
  coord_flip() +
  xlab(NULL)+
  ylab("Number of species")+
  theme(legend.title = element_blank(),
        axis.text = element_text(size = 16),
        legend.text = element_text(size = 14),
        axis.title = element_text(size = 14))

ggsave("Output/Mapping/tables & lists/species_breakdown.jpg", width = 12, height = 9)



# Misc --------------------------------------------------------------------

threat_table %>%
  # filter(ewt_strategic_site == "Y") %>%
  group_by(class, scientific_name, level_one_threat) %>%
  tally()

