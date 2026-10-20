# Install the core ETL packages:
# ==============================

install.packages(c(
  "DatabaseConnector",
  "SqlRender",
  "devtools",
  "renv"
))

devtools::install_github("OHDSI/CommonDataModel")
devtools::install_github("OHDSI/ETL-Synthea")


# Build the R-to-PostgreSQL connection:
# Install the R packages you'll use for database access, queries, and reporting.
# ==============================================================================

install.packages(c(
  "DBI",
  "RPostgres",
  "dbplyr",
  "dplyr",
  "ggplot2",
  "broom",
  "survival",
  "rmarkdown",
  "knitr"
))


# Download the PostgreSQL driver from R:
# ======================================

library(DatabaseConnector)

downloadJdbcDrivers(
  dbms = "postgresql",
  pathToDriver = "/drivers"
)




