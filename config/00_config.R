# ==========================================================
# CONFIGURATION FILE
# Project: Healthcare Data Cleaning Pipeline
# File: config/config.R
#
# Purpose:
# Defines file paths, logging settings, and global parameters
# used throughout the data cleaning pipeline.
# ==========================================================

# -----------------------------
# Load Required Packages
# -----------------------------

library(here)

# -----------------------------
# File Path Configuration
# -----------------------------

# Raw dataset location
raw_data_path <- here(
  "data",
  "raw",
  "healthcare_messy_data.csv"
)

# Interim data storage
interim_data_path <- here(
  "data",
  "interim"
)

#Processed data storage
processed_data_path <- here(
  "data", 
  "processed"
)

# Output files directory
output_path <- here(
  "outputs"
)

# Log file directory
log_path <- here(
  "outputs",
  "logs"
)

# -----------------------------
# Directory Creation
# -----------------------------

dirs <- c(
  interim_data_path,
  output_path,
  log_path
)

for (d in dirs) {
  if (!dir.exists(d)) {
    dir.create(
      d,
      recursive = TRUE
    )
  }
}

# -----------------------------
# Logging Configuration
# -----------------------------

diagnostic_log_file <- here(
  "outputs",
  "logs",
  "diagnostics_log.txt"
)

# -----------------------------
# Matching Thresholds
# -----------------------------

# Threshold for near-duplicate
# name detection using
# Jaro-Winkler distance

name_distance_threshold <- 0.1

