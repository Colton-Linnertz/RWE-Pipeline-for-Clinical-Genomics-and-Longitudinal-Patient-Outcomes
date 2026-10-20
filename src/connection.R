# Link genomic samples to Synthea patients
# ========================================

library(DBI)
library(RPostgres)
library(dplyr)
library(dbplyr)
library(readr)

# 1. Connect to your Synthea PostgreSQL database
con <- dbConnect(
  RPostgres::Postgres(),
  dbname = "syntheadb",
  host = "localhost",
  port = 5432,
  user = "user_name",
  password = "password"
)

# Create the genomics schema 
conn <- DatabaseConnector::connect(cd)
DBI::dbExecute(conn,"CREATE SCHEMA IF NOT EXISTS genomics")
DatabaseConnector::disconnect(conn)

# 2. Set the database schemas
# Change these if your actual schema names differ.
clinical_schema <- "cdm_syntheadb"
genomics_schema <- "genomics"

# 3. Read the synthetic genomic sample metadata
sample_file <- read_csv(
  "path/to/sample.csv",
  show_col_types = FALSE
)

# 4. Create an explicit mapping between synthetic genomic
#    person IDs and real Synthea patient IDs.
#
# Replace the example Synthea IDs below with patient IDs
# from your own Synthea database.
patient_map <- tibble(
  person_id = c("SYN-P001", "SYN-P002", "SYN-P003"),
  synthea_patient_id = c(
    "REPLACE-WITH-SYNTHEA-UUID-1",
    "REPLACE-WITH-SYNTHEA-UUID-2",
    "REPLACE-WITH-SYNTHEA-UUID-3"
  )
)

# 5. Save the mapping and sample metadata in PostgreSQL
dbWriteTable(
  con, Id(schema = genomics_schema, table = "patient_map"),
  patient_map,
  overwrite = TRUE,
  row.names = FALSE
)

dbWriteTable(
  con, Id(schema = genomics_schema, table = "sample"),
  sample_file,
  overwrite = TRUE,
  row.names = FALSE
)

# 6. Reference the tables with dbplyr
samples_db <- tbl(
  con, in_schema(genomics_schema, "sample")
)

mapping_db <- tbl(
  con, in_schema(genomics_schema, "patient_map")
)

patients_db <- tbl(
  con, in_schema(clinical_schema, "person")
)

# 7. Link genomic samples to Synthea patient records
linked_samples <- samples_db %>%
  inner_join(
    mapping_db,
    by = "person_id"
  ) %>%
  inner_join(
    patients_db,
    by = c("synthea_patient_id" = "person_id")
  ) %>%
  select(
    sample_id,
    person_id,
    synthea_patient_id,
    sample_type,
    genome_build
  )

# 8. Inspect the results
linked_samples %>%
  show_query()

linked_samples %>%
  collect()

# 9. Check for genomic IDs that have no mapping
unmapped_samples <- samples_db %>%
  anti_join(mapping_db, by = "person_id")

unmapped_samples %>%
  collect()
