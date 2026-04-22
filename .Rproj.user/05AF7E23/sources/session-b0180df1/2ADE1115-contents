# config/config.R

# Load required packages
#install.packages("here")
library(here)

# Paths
raw_data_path <- here("data", "raw", "healthcare_messy_data.csv")

interim_data_path <- here("data", "interim")

output_path <- here("outputs")

log_path <- here("outputs", "logs")

# Create directories if missing
dirs <- c(interim_data_path, output_path, log_path)

for (d in dirs) {
  if (!dir.exists(d)) {
    dir.create(d, recursive = TRUE)
  }
}

# Logging file
diagnostic_log_file <- here(
  "outputs",
  "logs",
  "diagnostics_log.txt"
)

# String distance threshold
name_distance_threshold <- 0.1

# scripts/01_ingest.R
#install.packages("readr")
#install.packages("dp")
library(readr)
library(dplyr)

source(here::here("config", "config.R"))

cat("\n--- INGEST STAGE STARTED ---\n")

# Read raw dataset
data_raw <- read.csv(raw_data_path, na =c("","NA","NaN", "nan"))

# Print structure
cat("\nDataset structure:\n")
print(str(data_raw))

# Row and column counts
n_rows <- nrow(data_raw)
n_cols <- ncol(data_raw)

cat("\nRow count:", n_rows, "\n")
cat("Column count:", n_cols, "\n")

# Save interim copy
saveRDS(
  data_raw,
  file = file.path(
    interim_data_path,
    "data_ingested.rds"
  )
)

cat("\n--- INGEST STAGE COMPLETED ---\n")

# scripts/02_diagnose.R
install.packages("naniar")
install.packages("visdat")
install.packages("stringdist")
library(dplyr)
library(stringr)
library(naniar)
library(visdat)
library(stringdist)

source(here("config", "config.R"))

cat("\n--- DIAGNOSTIC STAGE STARTED ---\n")

# Load data
data_raw <- readRDS(
  file.path(
    interim_data_path,
    "data_ingested.rds"
  )
)

# Start logging
sink(diagnostic_log_file)

cat("\n===== DATA DIAGNOSTICS =====\n")

cat("\nRow count:", nrow(data_raw))
cat("\nColumn count:", ncol(data_raw))

# -------------------------
# Missingness Summary
# -------------------------

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

# -------------------------
# Duplicate Row Check
# -------------------------

cat("\n\n--- Duplicate Rows ---\n")

duplicate_rows <- duplicated(data_raw)

cat(
  "\nNumber of duplicate rows:",
  sum(duplicate_rows)
)

# -------------------------
# Unique Patient Names
# -------------------------

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

# -------------------------
# Near-Duplicate Names
# -------------------------

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

# -------------------------
# Gender Values
# -------------------------

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

# -------------------------
# Diagnosis Values
# -------------------------

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

# -------------------------
# Visit Date Check
# -------------------------

cat("\n\n--- Visit Date Summary ---\n")

print(
  summary(
    data_raw$Visit.Date
  )
)

# -------------------------
# Missingness Plot
# -------------------------

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

cat("\n--- DIAGNOSTIC STAGE COMPLETED ---\n")

# run_pipeline.R

library(here)

cat("\n===== PIPELINE STARTED =====\n")

# Run ingest
source(
  here(
    "scripts",
    "01_ingest.R"
  )
)

# Run diagnostics
source(
  here(
    "scripts",
    "02_diagnose.R"
  )
)

cat("\n===== PIPELINE COMPLETED =====\n")

source("run_pipeline.R")
