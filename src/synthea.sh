#! /bin/bash


### Run Synthea with CSV enabled
# ran this using Ubuntu
# basic run to generate CSV files of synthetic patient data
# match your Ubuntu Java version with your R version for csv file compatibility
# highly customizable options if needed
# csv files will be in /synthea/output/csv


```bash
java -jar synthea-with-dependencies.jar \
  -p 1000 \
  --exporter.csv.export=true