# NB-NOTE-NB: lines 23 and 47 require manual input of file names prior to running code
# see lines 20-22, and line 46 for explanation
# Modules/libraries
import os
import arcpy

# Overwrite outputs
arcpy.env.overwriteOutput = True

# Define directories (I know its counterintuitive but this where the output from the initial R wrangling went)
gdb_dir = r"Species_Threats.gdb"
input_dir = r"Output"
output_dir = r"Input"


# Set workspace
arcpy.env.workspace = gdb_dir

# Convert EST Data (as wrangled in R) to feature layer
EST_data = os.path.join(input_dir, "Species_AllSens_Clean_No_Birds.shp")
arcpy.MakeFeatureLayer_management(EST_data, "EST_Species_Layer")

arcpy.Dissolve_management("EST_Species_Layer", "EST_Species_Dissolved", "Scntf_N", "", "MULTI_PART", "DISSOLVE_LINES")

# Add Threat Data and convert from excel to GDB table for further analysis
Threat_data = os.path.join(input_dir, "IUCN_Threat_Details.xlsx")
arcpy.ExcelToTable_conversion(Threat_data, "Species_Threats")


# Join threat data to EST Species Data with multiple threats linked to each species
# first list the tables to join
TableList = ["EST_Species_Dissolved", "Species_Threats"]

# second, define the 'where' query for matching
whereClause = "EST_Species_Dissolved.Scntf_N = Species_Threats.Scientific_Name"

# name the temporary layer name that will be created by MakeQueryTable
lyrName = "Species_Threats_Layer"

# name the output feature class name
outFeatureClass = os.path.join(output_dir, "Species_All_Clean_No_Birds_Threat_Data")

# Join threats to species with MakeQueryTable
arcpy.MakeQueryTable_management(TableList, lyrName, "USE_KEY_FIELDS", "", "", whereClause)

# since lyrName created by MakeQueryTable is temporary, save it as permanent shapefile
arcpy.CopyFeatures_management(lyrName, outFeatureClass)
