## OHDSI ETL-Synthea
#===================
# NOTES:
# We are loading a version 5.4 CDM into a local PostgreSQL database called "syntheadb".
# The ETLSyntheaBuilder package leverages the OHDSI/CommonDataModel package for CDM creation.
# Valid CDM versions are determined by executing CommonDataModel::listSupportedVersions().
# The strings representing supported CDM versions are currently "5.3" and "5.4". 
# The schema to load the Synthea tables is called "native".
# The schema to load the Vocabulary and CDM tables is "cdm_syntheadb".  


# load libraries
# ==============
library(ETLSyntheaBuilder)
library(DatabaseConnector)

cd <- DatabaseConnector::createConnectionDetails(
  dbms     = "postgresql", 
  server   = "localhost/syntheadb",
  user     = "postgres", 
  password = "clinical", 
  port     = 5432, 
  pathToDriver = "/drivers"  
)

# create schema
# =============
conn <- DatabaseConnector::connect(cd)
DBI::dbExecute(conn,"CREATE SCHEMA IF NOT EXISTS cdm_syntheadb")
DBI::dbExecute(conn,"CREATE SCHEMA IF NOT EXISTS native")
DatabaseConnector::disconnect(conn)

cdmSchema      <- "cdm_syntheadb"
syntheaSchema  <- "native"
cdmVersion     <- "5.4"

# set to match version of synthea used to create clinical data csv files
# =====================================================================
syntheaVersion <- "3.3.0" 

# set paths to clinical csv files & vocab from Athena
# ===================================================
syntheaFileLoc <- "/synthea/output/csv"
vocabFileLoc   <- "/vocab"

# create tables
# =============
ETLSyntheaBuilder::CreateCDMTables(connectionDetails = cd, cdmSchema = cdmSchema, cdmVersion = cdmVersion)

ETLSyntheaBuilder::CreateSyntheaTables(connectionDetails = cd, syntheaSchema = syntheaSchema, syntheaVersion = syntheaVersion)

ETLSyntheaBuilder::LoadSyntheaTables(connectionDetails = cd, syntheaSchema = syntheaSchema, syntheaFileLoc = syntheaFileLoc)

ETLSyntheaBuilder::LoadVocabFromCsv(connectionDetails = cd, cdmSchema = cdmSchema, vocabFileLoc = vocabFileLoc,delimiter='\t')

ETLSyntheaBuilder::CreateMapAndRollupTables(connectionDetails = cd, cdmSchema = cdmSchema, syntheaSchema = syntheaSchema, cdmVersion = cdmVersion, syntheaVersion = syntheaVersion)

# create extra indices
# ====================
ETLSyntheaBuilder::CreateExtraIndices(connectionDetails = cd, cdmSchema = cdmSchema, syntheaSchema = syntheaSchema, syntheaVersion = syntheaVersion)

ETLSyntheaBuilder::LoadEventTables(connectionDetails = cd, cdmSchema = cdmSchema, syntheaSchema = syntheaSchema, cdmVersion = cdmVersion, syntheaVersion = syntheaVersion)