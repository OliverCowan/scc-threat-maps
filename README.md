scc-threat-maps
================

## Input files required

``` r
list.files("Input")
```

    ##  [1] "animal_combined_sensitivity.dbf"                
    ##  [2] "animal_combined_sensitivity.prj"                
    ##  [3] "animal_combined_sensitivity.sbn"                
    ##  [4] "animal_combined_sensitivity.sbx"                
    ##  [5] "animal_combined_sensitivity.shp"                
    ##  [6] "animal_combined_sensitivity.shx"                
    ##  [7] "bird_sensitivity_combined.dbf"                  
    ##  [8] "bird_sensitivity_combined.prj"                  
    ##  [9] "bird_sensitivity_combined.shp"                  
    ## [10] "bird_sensitivity_combined.shx"                  
    ## [11] "EST sensitive species reference 18-05-2021.xlsx"
    ## [12] "EWT_PrioritySites_2019_proj.cpg"                
    ## [13] "EWT_PrioritySites_2019_proj.dbf"                
    ## [14] "EWT_PrioritySites_2019_proj.prj"                
    ## [15] "EWT_PrioritySites_2019_proj.sbn"                
    ## [16] "EWT_PrioritySites_2019_proj.sbx"                
    ## [17] "EWT_PrioritySites_2019_proj.shp"                
    ## [18] "EWT_PrioritySites_2019_proj.shp.xml"            
    ## [19] "EWT_PrioritySites_2019_proj.shx"                
    ## [20] "IUCN_Threat_Details.xlsx"                       
    ## [21] "IUCN_Threat_Details_Jan2022.xlsx"               
    ## [22] "IUCN_Threat_Details_old.xlsx"                   
    ## [23] "PAs_in_EPAs.dbf"                                
    ## [24] "PAs_in_EPAs.prj"                                
    ## [25] "PAs_in_EPAs.shp"                                
    ## [26] "PAs_in_EPAs.shx"                                
    ## [27] "RSA_Outline.cpg"                                
    ## [28] "RSA_Outline.dbf"                                
    ## [29] "RSA_Outline.prj"                                
    ## [30] "RSA_Outline.sbn"                                
    ## [31] "RSA_Outline.sbx"                                
    ## [32] "RSA_Outline.shp"                                
    ## [33] "RSA_Outline.shp.xml"                            
    ## [34] "RSA_Outline.shx"                                
    ## [35] "RSA_provinces.dbf"                              
    ## [36] "RSA_provinces.prj"                              
    ## [37] "RSA_provinces.sbn"                              
    ## [38] "RSA_provinces.sbx"                              
    ## [39] "RSA_provinces.shp"                              
    ## [40] "RSA_provinces.shx"                              
    ## [41] "SAPAD_Q3_2020_Terrestrial.cpg"                  
    ## [42] "SAPAD_Q3_2020_Terrestrial.dbf"                  
    ## [43] "SAPAD_Q3_2020_Terrestrial.prj"                  
    ## [44] "SAPAD_Q3_2020_Terrestrial.sbn"                  
    ## [45] "SAPAD_Q3_2020_Terrestrial.sbx"                  
    ## [46] "SAPAD_Q3_2020_Terrestrial.shp"                  
    ## [47] "SAPAD_Q3_2020_Terrestrial.shp.xml"              
    ## [48] "SAPAD_Q3_2020_Terrestrial.shx"                  
    ## [49] "Slope_Degrees_30s.tif"                          
    ## [50] "Threat_Codes_L1.csv"                            
    ## [51] "Threat_Codes_L2.csv"                            
    ## [52] "Threat_Codes_reference.csv"

## Output folders

``` r
list.files("Output")
```

    ##  [1] "AllSens.RData"             "est_all_01.dbf"           
    ##  [3] "est_all_01.prj"            "est_all_01.shp"           
    ##  [5] "est_all_01.shx"            "est_all_02.dbf"           
    ##  [7] "est_all_02.prj"            "est_all_02.shp"           
    ##  [9] "est_all_02.shx"            "est_all_03.dbf"           
    ## [11] "est_all_03.prj"            "est_all_03.shp"           
    ## [13] "est_all_03.shx"            "est_all_04.dbf"           
    ## [15] "est_all_04.prj"            "est_all_04.shp"           
    ## [17] "est_all_04.shx"            "est_filtered_all.dbf"     
    ## [19] "est_filtered_all.prj"      "est_filtered_all.shp"     
    ## [21] "est_filtered_all.shx"      "est_filtered_no_birds.dbf"
    ## [23] "est_filtered_no_birds.prj" "est_filtered_no_birds.shp"
    ## [25] "est_filtered_no_birds.shx" "est_threats_01.cpg"       
    ## [27] "est_threats_01.dbf"        "est_threats_01.prj"       
    ## [29] "est_threats_01.sbn"        "est_threats_01.sbx"       
    ## [31] "est_threats_01.shp"        "est_threats_01.shp.xml"   
    ## [33] "est_threats_01.shx"        "est_threats_02.cpg"       
    ## [35] "est_threats_02.dbf"        "est_threats_02.prj"       
    ## [37] "est_threats_02.sbn"        "est_threats_02.sbx"       
    ## [39] "est_threats_02.shp"        "est_threats_02.shp.xml"   
    ## [41] "est_threats_02.shx"        "est_threats_03.cpg"       
    ## [43] "est_threats_03.dbf"        "est_threats_03.prj"       
    ## [45] "est_threats_03.sbn"        "est_threats_03.sbx"       
    ## [47] "est_threats_03.shp"        "est_threats_03.shp.xml"   
    ## [49] "est_threats_03.shx"        "est_threats_04.cpg"       
    ## [51] "est_threats_04.dbf"        "est_threats_04.prj"       
    ## [53] "est_threats_04.sbn"        "est_threats_04.sbx"       
    ## [55] "est_threats_04.shp"        "est_threats_04.shp.xml"   
    ## [57] "est_threats_04.shx"        "est_threats_all.csv"      
    ## [59] "EWT_PA_rasters"            "L1_PA_AGR.tif"            
    ## [61] "L1_PA_AGR.tif.ovr"         "Mapping"                  
    ## [63] "SA_rasters"

## Mapping folders

``` r
list.files("Output/Mapping")
```

    ## [1] "EPA"            "RSA"            "tables & lists"

## Species tables

``` r
list.files("Output/Mapping/tables & lists/")
```

    ## [1] "class_tally.csv"       "species_breakdown.jpg" "species_list.csv"     
    ## [4] "threat_breakdown.jpg"
