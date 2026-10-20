# Keep measurements for the chosen outcome
outcome_labs <- measurements |>
  filter(
    measurement_concept_id %in% outcome_concept_ids,
    !is.na(value_as_number)
  ) |>
  select(
    person_id,
    measurement_date,
    value_as_number,
    unit_concept_id
  )

# Attach index dates; calculations remain database-side
labs_in_cohort <- cohort |>
  inner_join(outcome_labs, by = "person_id")

# Example: 365 days before index through the day before index
baseline <- labs_in_cohort |>
  filter(
    measurement_date >= index_date - 365,
    measurement_date < index_date
  ) |>
  group_by(person_id, index_date) |>
  summarise(
    baseline_mean = mean(value_as_number, na.rm = TRUE),
    baseline_n = n(),
    .groups = "drop"
  )

# Example: days 90–455 after index
followup <- labs_in_cohort |>
  filter(
    measurement_date >= index_date + 90,
    measurement_date <= index_date + 455
  ) |>
  group_by(person_id, index_date) |>
  summarise(
    followup_mean = mean(value_as_number, na.rm = TRUE),
    followup_n = n(),
    .groups = "drop"
  )

patient_outcomes <- baseline |>
  inner_join(
    followup,
    by = c("person_id", "index_date")
  ) |>
  mutate(
    change = followup_mean - baseline_mean
  )

# Inspect the query, then retrieve the smaller patient-level dataset
show_query(patient_outcomes)
outcome_data <- collect(patient_outcomes)