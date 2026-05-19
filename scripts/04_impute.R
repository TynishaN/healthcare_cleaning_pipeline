# ==========================================================
# IMPUTATION SCRIPT
# File: scripts/04_impute.R
#
# Purpose:
# Handles missing values in the cleaned dataset
# including:
# - Median imputation
# - Imputation tracking
# - Validation checks
# - Imputation summary export
# ==========================================================

library(here)
library(dplyr)
library(tibble)

# ==========================================================
# LOAD CONFIGURATION
# ==========================================================

source(
  here(
    "config",
    "00_config.R"
  )
)

cat("\n--- IMPUTATION STAGE STARTED ---\n")

# ==========================================================
# LOAD CLEANED DATASET
# ==========================================================

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

cat(
  "\nColumns entering imputation:",
  ncol(data_clean)
)

# ==========================================================
# START LOGGING
# ==========================================================

sink(imputation_log_file)

cat("\n===== DATA IMPUTATION =====\n")

cat(
  "\nRows entering imputation:",
  nrow(data_clean)
)

cat(
  "\nColumns entering imputation:",
  ncol(data_clean)
)

# ==========================================================
# STEP 1: PRESERVE ORIGINAL AGE VALUES
# ==========================================================

cat("\n--- STEP 1: PRESERVE ORIGINAL AGE VALUES ---\n")

# Store original Age values before imputation

data_clean$Age_Original <- data_clean$Age

cat("\nOriginal Age values preserved.\n")

# ==========================================================
# STEP 2: AGE IMPUTATION (MEDIAN)
# ==========================================================

cat("\n--- STEP 2: AGE IMPUTATION ---\n")

# Calculate median excluding missing values

median_age <- median(
  data_clean$Age,
  na.rm = TRUE
)

# Create imputation flag

data_clean$Age_Imputed_Flag <-
  is.na(data_clean$Age)

# Count missing values before imputation

missing_age_before <- sum(
  is.na(data_clean$Age)
)

# Replace missing Age values

data_clean$Age[
  is.na(data_clean$Age)
] <- median_age

# Count imputed values

values_imputed <- sum(
  data_clean$Age_Imputed_Flag
)

cat(
  "\nMedian age used:",
  median_age
)

cat(
  "\nAge values imputed:",
  values_imputed
)

# ==========================================================
# STEP 3: VALIDATION CHECKS
# ==========================================================

cat("\n--- STEP 3: VALIDATION CHECKS ---\n")

# Ensure no missing Age values remain

if(any(is.na(data_clean$Age))) {
  
  warning(
    "Some Age values remain missing after imputation."
  )
}

# Ensure Age is numeric

if(!is.numeric(data_clean$Age)) {
  
  stop(
    "Age variable is not numeric after imputation."
  )
}

# Check for impossible ages

if(any(
  data_clean$Age < 0,
  na.rm = TRUE
)) {
  
  warning(
    "Negative Age values detected."
  )
}

# Check for unrealistic ages

if(any(
  data_clean$Age > 120,
  na.rm = TRUE
)) {
  
  warning(
    "Age values above 120 detected."
  )
}

cat("\nValidation checks completed.\n")

# ==========================================================
# STEP 4: IMPUTATION SUMMARY EXPORT
# ==========================================================

cat("\n--- STEP 4: EXPORT IMPUTATION SUMMARY ---\n")

imputation_summary <- tibble(
  
  variable = "Age",
  
  method = "Median Imputation",
  
  missing_before_imputation =
    missing_age_before,
  
  values_imputed =
    values_imputed,
  
  median_used =
    median_age,
  
  missing_after_imputation =
    sum(is.na(data_clean$Age))
)

write.csv(
  imputation_summary,
  file.path(
    output_path,
    "imputation_summary.csv"
  ),
  row.names = FALSE
)

cat("\nImputation summary exported.\n")

# ==========================================================
# SAVE FINAL CLEANED DATA
# ==========================================================

saveRDS(
  data_clean,
  file.path(
    processed_data_path,
    "data_cleaned.rds"
  )
)

cat(
  "\nRows after imputation:",
  nrow(data_clean)
)

cat(
  "\nColumns after imputation:",
  ncol(data_clean)
)

cat("\nFinal cleaned dataset saved.\n")

# ==========================================================
# STOP LOGGING
# ==========================================================

sink()

cat("\n--- IMPUTATION STAGE COMPLETED ---\n")