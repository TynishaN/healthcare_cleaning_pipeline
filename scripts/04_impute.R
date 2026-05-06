# ==========================================================
# IMPUTATION SCRIPT
# File: scripts/05_impute.R
#
# Purpose:
# Handles missing values in the cleaned dataset
# ==========================================================

library(here)
library(dplyr)

# Load configuration
source(
  here(
    "config",
    "00_config.R"
  )
)

cat("\n--- IMPUTATION STAGE STARTED ---\n")

# -----------------------------
# Load cleaned dataset
# -----------------------------

data_clean <- readRDS(
  file.path(
    interim_data_path,
    "data_cleaned_pre_impute.rds"
  )
)

cat(
  "\nRows entering imputation:",
  nrow(data_clean)
)

# ==========================================
# AGE IMPUTATION (MEDIAN)
# ==========================================

median_age <- median(
  data_clean$Age,
  na.rm = TRUE
)

data_clean$Age[
  is.na(data_clean$Age)
] <- median_age

cat("\nMedian age used for imputation:", median_age)

# ==========================================
# SAVE FINAL CLEANED DATA
# ==========================================

saveRDS(
  data_clean,
  file.path(
    processed_data_path,
    "data_cleaned.rds"
  )
)

cat("\n--- IMPUTATION STAGE COMPLETED ---\n")