# ==========================================================
# DIAGNOSTIC SCRIPT
# File: scripts/02_diagnose.R
#
# Purpose:
# Performs exploratory diagnostics on the dataset
# including missing values, duplicates, categorical
# consistency, and near-duplicate name detection.
# ==========================================================

# -----------------------------
# Load Required Packages
# -----------------------------


library(dplyr)
library(stringr)
library(naniar)
library(visdat)
library(stringdist)

# Load configuration settings
source(
  here(
    "config",
    "00_config.R"
  )
)

cat("\n--- DIAGNOSTIC STAGE STARTED ---\n")

# -----------------------------
# Load Interim Dataset
# -----------------------------

data_raw <- readRDS(
  file.path(
    interim_data_path,
    "data_ingested.rds"
  )
)

cat("\nRows entering diagnostics:", nrow(data_raw))
# -----------------------------
# Start Logging Output
# -----------------------------

sink(diagnostic_log_file)

cat("\n===== DATA DIAGNOSTICS =====\n")

cat("\nRow count:", nrow(data_raw))
cat("\nColumn count:", ncol(data_raw))

# ==========================================================
# Missing Values Analysis
# ==========================================================

cat("\n\n--- Missing Values Summary ---\n")

missing_summary <- data.frame(
  Variable = names(data_raw),
  Missing_Count = colSums(is.na(data_raw)),
  Missing_Percent =
    round(
      colSums(is.na(data_raw)) /
        nrow(data_raw) * 100,
      2
    )
)

print(missing_summary)

write.csv(
  missing_summary,
  file.path(
    output_path,
    "missing_summary.csv"
  ),
  row.names = FALSE
)

# ==========================================================
# Duplicate Row Detection
# ==========================================================

cat("\n\n--- Duplicate Rows ---\n")

duplicate_rows <- duplicated(data_raw)

cat(
  "\nNumber of duplicate rows:",
  sum(duplicate_rows)
)

# ==========================================================
# Unique Patient Name Analysis
# ==========================================================

cat("\n\n--- Unique Patient Names ---\n")

unique_names <- unique(
  data_raw$Patient.Name
)

cat(
  "\nNumber of unique patient names:",
  length(unique_names)
)

write.csv(
  unique_names,
  file.path(
    output_path,
    "unique_patient_names.csv"
  ),
  row.names = FALSE
)

# ==========================================================
# Near-Duplicate Name Detection
# ==========================================================

cat("\n\n--- Near Duplicate Names ---\n")

distance_matrix <- stringdistmatrix(
  unique_names,
  unique_names,
  method = "jw"
)

near_dup_pairs <- which(
  distance_matrix <
    name_distance_threshold &
    distance_matrix > 0,
  arr.ind = TRUE
)

near_duplicates <- data.frame(
  name1 =
    unique_names[
      near_dup_pairs[,1]
    ],
  name2 =
    unique_names[
      near_dup_pairs[,2]
    ]
)

write.csv(
  near_duplicates,
  file.path(
    output_path,
    "near_duplicate_names.csv"
  ),
  row.names = FALSE
)

cat(
  "\nNear duplicate pairs:",
  nrow(near_duplicates)
)

# ==========================================================
# Categorical Variable Checks
# ==========================================================

cat("\n\n--- Gender Values ---\n")

gender_values <- unique(
  data_raw$Gender
)

print(gender_values)

write.csv(
  gender_values,
  file.path(
    output_path,
    "gender_unique_values.csv"
  ),
  row.names = FALSE
)

cat("\n\n--- Diagnosis Values ---\n")

diagnosis_values <- unique(
  data_raw$Condition
)

print(diagnosis_values)

write.csv(
  diagnosis_values,
  file.path(
    output_path,
    "diagnosis_unique_values.csv"
  ),
  row.names = FALSE
)

# ==========================================================
# Visit Date Summary
# ==========================================================

cat("\n\n--- Visit Date Summary ---\n")

print(
  summary(
    data_raw$Visit.Date
  )
)

# ==========================================================
# Missingness Visualization
# ==========================================================

cat("\n\n--- Creating Missingness Plot ---\n")

png(
  file.path(
    output_path,
    "missingness_plot.png"
  ),
  width = 1000,
  height = 600
)

print(
  gg_miss_var(data_raw)
)

dev.off()

sink()

# -----------------------------
# Save diagnosed data set
# -----------------------------

saveRDS(
  data_raw,
  file.path(
    interim_data_path,
    "data_diagnosed.rds"
  )
)

cat("\n--- DIAGNOSTIC STAGE COMPLETED ---\n")
