# Libraries ---------------------------------------------------------------
library(raster)
library(tidyverse)
library(readxl)
library(sf)
library(leaflet)

# Import ------------------------------------------------------------------
latlongCRS <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

# Protected areas
PAs <- st_read("Input/PAs_in_EPAs.shp")

## Priority areas
prior_areas <- st_read("Input/EWT_PrioritySites_2019_proj.shp") %>%
  st_transform(crs = latlongCRS) %>%
  filter(Selected == 1)

# LEVEL 1 THREATS  ---------------------------------------------------------

## Read and summarise rasters ----
l1_files <- list.files("Output/EWT_PA_rasters/", pattern = "_L1_", full.names = TRUE) %>%
  str_subset(., "tif.", negate = TRUE)

l1_layers <- map(.x = l1_files,
                 .f = raster)

jpeg("Output/Mapping/EPA/level1_hist.jpeg", width = 1200, height = 900)
par(mfrow = c(4,3))
walk(.x = l1_layers,
     .f = function (x){
       hist(x)
     }
)
dev.off()

raster_summary <- function(x){

  ras_quants <- quantile(x, ncells = 220000, names = FALSE)

  return(tibble(threat = names(x),
                mean = mean(values(x), na.rm = TRUE),
                quant_0 = ras_quants[1],
                quant_25 = ras_quants[2],
                quant_50 = ras_quants[3],
                quant_75 = ras_quants[4],
                quant_100 = ras_quants[5]
                )
         )

}

l1_table <- map_df(.x = l1_layers,
                   .f = raster_summary)

## Identify most important threats ----
l1_table %>%
  arrange(desc(mean))

top_threats <- glue::glue('PA_L1_{c("AGR", "BIO", "NAT", "RES", "ENE", "POL")}')

ref_keep <- which(c(map(l1_layers, names) %>% unlist()) %in% top_threats)
l1 <- l1_layers[ref_keep]
l1 <- stack(l1)

## Map high frequency threats ----
ras_bins_high <- colorBin(palette = "viridis",
                     domain = values(l1$PA_L1_AGR), bins = 5, pretty = TRUE,
                     na.color = "transparent")

map1 <- leaflet() %>%
  addTiles()

c("PA_L1_AGR", "PA_L1_BIO", "PA_L1_NAT") %>%
  walk(function(x)
    map1 <<-
      map1 %>% addRasterImage(
        x = l1[[x]],
        group = x,
        colors = ras_bins_high,
        opacity = 0.8))


map1 <- map1 %>%
  addPolygons(data = prior_areas, fill = TRUE, fillColor = "transparent",
              color = "black", weight = 2, opacity = 1.0,
              label = ~Name) %>%
  addPolygons(data = PAs, fill = TRUE, fillColor = c("#FF7F00"),
              color = "black", weight = 2, opacity = 0.7, fillOpacity = 0.5,
              label = ~CUR_NME, group = "PAs") %>%
  addLayersControl(
    baseGroups = c("PA_L1_AGR", "PA_L1_BIO", "PA_L1_NAT"),
    overlayGroups = "PAs",
    options = layersControlOptions(collapsed = FALSE)
  )

map1 <- map1 %>%
  addLegend(position = "topright", colors = "#FF7F00", labels = "Protected areas",
            opacity = 0.5, title = "") %>%
  addLegend(pal = ras_bins_high, values = values(l1$PA_L1_AGR),opacity = 0.8,
             title = "Species threat frequency")

# map1 <- map1 %>%
#   clearControls()

map1

## Map low frequency threats ----
ras_bins_low <- colorBin(palette = "viridis",
                         domain = values(l1$PA_L1_RES), bins = 5, pretty = TRUE,
                         na.color = "transparent")

map2 <- leaflet() %>%
  addTiles()

c("PA_L1_ENE", "PA_L1_POL", "PA_L1_RES") %>%
  walk(function(x)
    map2 <<-
      map2 %>% addRasterImage(
        x = l1[[x]],
        group = x,
        colors = ras_bins_low,
        opacity = 0.8))


map2 <- map2 %>%
  addLayersControl(
    baseGroups = c("PA_L1_ENE", "PA_L1_POL", "PA_L1_RES"),
    overlayGroups = "PAs",
    options = layersControlOptions(collapsed = FALSE)
  ) %>%
  addPolygons(data = prior_areas, fill = TRUE, fillColor = "transparent",
              color = "black", weight = 2,
              label = ~Name) %>%
  addPolygons(data = PAs, fill = TRUE, fillColor = c("#FF7F00"),
              color = "black", weight = 2, opacity = 0.7, fillOpacity = 0.5,
              label = ~CUR_NME, group = "PAs")

map2 <- map2 %>%
  addLegend(position = "topright", colors = "#FF7F00", labels = "Protected areas",
            opacity = 0.5, title = "") %>%
  addLegend(pal = ras_bins_low, values = values(l1$PA_L1_RES),opacity = 0.8,
            title = "Species frequency")


## Export as HTML files ----
htmlwidgets::saveWidget(
  widget = map1,
  file = "Output/Mapping/EPA/Lev1_high.html",
  selfcontained = T
)

htmlwidgets::saveWidget(
  widget = map2,
  file = "Output/Mapping/EPA/Lev1_low.html",
  selfcontained = T
)

saveRDS(object = map1, file = "Output/Mapping/EPA/Lev1_high.rds")
saveRDS(object = map2, file = "Output/Mapping/EPA/Lev1_low.rds")


# LEVEL 2 THREATS ---------------------------------------------------------

## Read and summarise rasters ----

## At this stage only dealing with AGR sub-threats
l2_files <- list.files("Output/EWT_PA_rasters/", pattern = "_L2_", full.names = TRUE) %>%
  str_subset(., "tif.", negate = TRUE)

agr_threats <- c("LFR", "WPP", "NTC")

l2_files <- str_subset(l2_files, "NTC|LFR|WPP")

l2_layers <- map(.x = l2_files,
                 .f = raster)

l2_table <- map_df(.x = l2_layers,
                   .f = raster_summary)

jpeg("Output/Mapping/EPA/level2_AGR_hist.jpeg", width = 1200, height = 900)
par(mfrow = c(3,1))
walk(.x = l2_layers,
     .f = function (x){
       hist(x)
     }
)
dev.off()
par(mfrow = c(1,1))

l2_table %>%
  arrange(desc(mean))

l2 <- stack(l2_layers)

## Map threat frequencies ----
ras_bins <- colorBin(palette = "viridis",
                          domain = values(l2$PA_L2_WPP), bins = 5, pretty = TRUE,
                          na.color = "transparent")

map3 <- leaflet() %>%
  addTiles()

names(l2) %>%
  walk(function(x)
    map3 <<-
      map3 %>% addRasterImage(
        x = l2[[x]],
        group = x,
        colors = ras_bins,
        opacity = 0.8))

map3 <- map3 %>%
  addPolygons(data = prior_areas, fill = TRUE, fillColor = "transparent",
              color = "black", weight = 2, opacity = 1.0,
              label = ~Name) %>%
  addPolygons(data = PAs, fill = TRUE, fillColor = c("#FF7F00"),
              color = "black", weight = 2, opacity = 0.7, fillOpacity = 0.5,
              label = ~CUR_NME, group = "PAs") %>%
  addLayersControl(
    baseGroups = names(l2),
    overlayGroups = "PAs",
    options = layersControlOptions(collapsed = FALSE)
  )

map3 <- map3 %>%
  addLegend(position = "topright", colors = "#FF7F00", labels = "Protected areas",
           opacity = 0.5, title = "") %>%
  addLegend(pal = ras_bins, values = values(l2$PA_L2_WPP),opacity = 0.8,
            title = "Species frequency")

map3

## Export as HTML file ----
htmlwidgets::saveWidget(
  widget = map3,
  file = "Output/Mapping/EPA/Lev2_AGR.html",
  selfcontained = T
)
saveRDS(object = map3, file = "Output/Mapping/EPA/Lev2_AGR.rds")


# SUM OF ALL THREATS ------------------------------------------------------
all_threats <- stack(l1_layers)
all_threats <- raster::calc(all_threats, sum)
plot(all_threats)

# all_threats[which(values(all_threats) == 0)] <- NA

ras_bins <- colorBin(palette = "viridis",
                     domain = values(all_threats), bins = 10, pretty = TRUE,
                     na.color = "transparent")

map4 <- leaflet() %>%
  addTiles() %>%
  addRasterImage(x = all_threats, group = "All threats", colors = ras_bins, opacity = 0.8) %>%
  addPolygons(data = prior_areas, fill = TRUE, fillColor = "transparent",
              color = "black", weight = 2, opacity = 1.0,
              label = ~Name) %>%
  addPolygons(data = PAs, fill = TRUE, fillColor = c("#FF7F00"),
              color = "black", weight = 2, opacity = 0.7, fillOpacity = 0.5,
              label = ~CUR_NME, group = "PAs")


map4 <- map4 %>%
  addLayersControl(
    overlayGroups =  c("All threats","PAs"),
    options = layersControlOptions(collapsed = FALSE)
  )

map4 <- map4 %>%
  addLegend(position = "topright", colors = "#FF7F00", labels = "Protected areas",
            opacity = 0.5, title = "") %>%
  addLegend(pal = ras_bins, values = values(all_threats),opacity = 0.8,
            title = "Species frequency")

map4

## Export as HTML file ----
htmlwidgets::saveWidget(
  widget = map4,
  file = "Output/Mapping/EPA/All_threats.html",
  selfcontained = T
)
saveRDS(object = map4, file = "Output/Mapping/EPA/All_threats.rds")


# HOTSPOTS ----------------------------------------------------------------
all_quants <- quantile(all_threats, ncells = 220000, names = TRUE)
all_quants

# plot(all_threats > all_quants[4])
# plot(all_threats > 100)

threshold <- 100
hotspots <- reclassify(all_threats, c(0,threshold,NA,threshold,215,1))

# plot(hotspots)
# unique(values(hotspots))

map5 <- leaflet() %>%
  addTiles() %>%
  addRasterImage(x = hotspots, group = "Hotspots", colors = c("transparent","red"), opacity = 0.8) %>%
  addPolygons(data = prior_areas, fill = TRUE, fillColor = "transparent",
              color = "black", weight = 2, opacity = 1.0,
              label = ~Name) %>%
  addPolygons(data = PAs, fill = TRUE, fillColor = c("#FF7F00"),
              color = "black", weight = 2, opacity = 0.7, fillOpacity = 0.5,
              label = ~CUR_NME, group = "PAs")

map5 <- map5 %>%
  addLayersControl(
    overlayGroups = c("Hotspots","PAs"),
    options = layersControlOptions(collapsed = FALSE)
  )

map5 <- map5 %>%
  addLegend(position = "topright", colors = "#FF7F00", labels = "Protected areas",
            opacity = 0.5, title = "") %>%
  addLegend(position = "topright", colors = "red", labels = "Threat hotspot",
          opacity = 0.8, title = "")

## Export as HTML file ----
htmlwidgets::saveWidget(
  widget = map5,
  file = "Output/Mapping/EPA/Hotspots.html",
  selfcontained = T
)
saveRDS(object = map5, file = "Output/Mapping/EPA/Hotspots.rds")

