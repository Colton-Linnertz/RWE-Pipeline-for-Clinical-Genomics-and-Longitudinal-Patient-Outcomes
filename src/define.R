# Populate these vectors after inspecting the OMOP vocabulary.
condition_concept_ids <- c(...)  # Target phenotype concepts
outcome_concept_ids   <- c(...)  # Target clinical measurement concepts

# Earliest qualifying diagnosis per person
cohort <- conditions |>
  filter(
    condition_concept_id %in% condition_concept_ids
  ) |>
  group_by(person_id) |>
  summarise(
    index_date = min(condition_start_date),
    .groups = "drop"
  )

# Inspect the SQL before executing
show_query(cohort)

# Only the final cohort identifiers and dates are collected
cohort_small <- cohort |>
  collect()

#Add baseline characteristics
cohort_with_person <- cohort |>
  inner_join(
    person |>
      select(
        person_id,
        year_of_birth,
        gender_concept_id
      ),
    by = "person_id"
  )

show_query(cohort_with_person)