# ==========================================================
# INGESTION SCRIPT
# File: scripts/01_ingest.R
#
# Purpose:
# Reads raw healthcare dataset,
# performs initial validation,
# and saves an interim copy.
# ==========================================================

# -----------------------------
# Load Required Packages
# -----------------------------

library(readr)
library(dplyr)

# Load configuration settings
source(
  here::here(
    "config",
    "00_config.R"
  )
)

cat("\n--- INGEST STAGE STARTED ---\n")

# -----------------------------
# Read Raw Dataset
# -----------------------------

data_raw <- read.csv(
  raw_data_path,
  na = c(
    "",
    "NA",
    "NaN",
    "nan"
  )
)

# -----------------------------
# Display Dataset Structure
# -----------------------------

cat("\nDataset structure:\n")
print(str(data_raw))

# -----------------------------
# Dataset Dimensions
# -----------------------------

n_rows <- nrow(data_raw)
n_cols <- ncol(data_raw)

cat("\nRow count:", n_rows, "\n")
cat("Column count:", n_cols, "\n")

# -----------------------------
# Save Interim Dataset
# -----------------------------

saveRDS(
  data_raw,
  file = file.path(
    interim_data_path,
    "data_ingested.rds"
  )
)

cat("\n--- INGEST STAGE COMPLETED ---\n")
