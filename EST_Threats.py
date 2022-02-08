# NB the input files are as follows:
# "Species_AllSens_Clean_No_Birds.shp" - should be in the output folder in your project folder following initial R code
# "IUCN_Threat_Details.xlsx" - NB NB - you must place this in the output folder of your project folder - see line 14

# Modules/libraries
import os
import arcpy
import pandas as pd

# Overwrite outputs
arcpy.env.overwriteOutput = True

gdb_dir = r"Species_Threats.gdb"

arcpy.env.workspace = gdb_dir
arcpy.ListFeatureClasses()

# Convert EST Data (as wrangled in R) to feature layer
arcpy.MakeFeatureLayer_management("Output/est_all_04.shp", "EST_Species_Layer")
# arcpy.MakeFeatureLayer_management("Output/est_filtered_all.shp", "EST_Species_Layer")
# arcpy.MakeFeatureLayer_management("Output/est_filtered_no_birds.shp", "EST_Species_Layer")

# dissolve boundaries so that for each species there is a multipart polygon
arcpy.Dissolve_management("EST_Species_Layer", "EST_Species_Dissolved", "Scntf_N", "", "MULTI_PART", "DISSOLVE_LINES")

# Add Threat Data and convert from excel to GDB table for further analysis
# arcpy.env.workspace
arcpy.env.workspace = os.getcwd()
excel_dir = r"C:\Users\DominicH\Desktop\scc-threat-maps\Input\IUCN_Threat_Details_Jan2022.xlsx"
# excel_dir = r"G:\My Drive\EWT\Analysis\scc-threat-maps\Input\IUCN_Threat_Details_Jan2022.xlsx"

arcpy.ExcelToTable_conversion(Input_Excel_File=excel_dir,
                              Output_Table=r"Species_Threats.gdb\Species_Threats", Sheet="Sheet1",
                              field_names_row=1, cell_range='')

# Join threat data to EST Species Data with multiple threats linked to each species:
# first list the tables to join
arcpy.env.workspace = gdb_dir
TableList = ["EST_Species_Dissolved", "Species_Threats"]

# second, define the 'where' query for matching
whereClause = "EST_Species_Dissolved.Scntf_N = Species_Threats.Scientific_Name"

# name the temporary layer name that will be created by MakeQueryTable
lyrName = "Species_Threats_Layer"

# name the output feature class name
# outFeatureClass = os.path.join("Output", "Species_All_Clean_Threat_Data_No_Birds")
outFeatureClass = os.path.join("Output", "est_threats_04")

# Join threats to species with MakeQueryTable
arcpy.MakeQueryTable_management(TableList, lyrName, "USE_KEY_FIELDS", "", "", whereClause)

# since lyrName created by MakeQueryTable is temporary, save it as permanent shapefile
# This step took over an hour, but eventually worked.
arcpy.CopyFeatures_management(lyrName, outFeatureClass)

print("PROCESS COMPLETE")
