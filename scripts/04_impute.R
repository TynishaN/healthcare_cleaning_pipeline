# ==========================================================
# IMPUTATION SCRIPT
# File: scripts/04_impute.R
#
# Purpose:
# Handles missing values in the cleaned dataset
# including median imputation and imputation
# tracking for reporting purposes.
# ==========================================================

library(here)
library(dplyr)

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

# ==========================================================
# STEP 1: PRESERVE ORIGINAL AGE VALUES
# ==========================================================

# Store original Age variable before imputation
# for reporting and comparison purposes

data_clean$Age_Original <- data_clean$Age

# ==========================================================
# STEP 2: AGE IMPUTATION (MEDIAN)
# ==========================================================

# Calculate median age excluding missing values

median_age <- median(
  data_clean$Age,
  na.rm = TRUE
)

# Create imputation flag

data_clean$Age_Imputed_Flag <-
  is.na(data_clean$Age)

# Replace missing ages with median age

data_clean$Age[
  is.na(data_clean$Age)
] <- median_age

cat(
  "\nMedian age used for imputation:",
  median_age
)

cat(
  "\nNumber of Age values imputed:",
  sum(data_clean$Age_Imputed_Flag)
)

# ==========================================================
# STEP 3: VALIDATION CHECKS
# ==========================================================

# Ensure no missing Age values remain

if(any(is.na(data_clean$Age))) {
  
  warning(
    "Some Age values remain missing after imputation."
  )
}

# Ensure Age values are numeric

if(!is.numeric(data_clean$Age)) {
  
  stop(
    "Age variable is not numeric after imputation."
  )
}

# Check for impossible age values

if(any(
  data_clean$Age < 0,
  na.rm = TRUE
)) {
  
  warning(
    "Negative Age values detected after imputation."
  )
}

# ==========================================================
# STEP 4: IMPUTATION SUMMARY EXPORT
# ==========================================================

imputation_summary <- tibble(
  
  variable = "Age",
  
  method = "Median Imputation",
  
  median_used = median_age,
  
  values_imputed =
    sum(data_clean$Age_Imputed_Flag)
)

write.csv(
  imputation_summary,
  file.path(
    output_path,
    "imputation_summary.csv"
  ),
  row.names = FALSE
)

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

cat("\n--- IMPUTATION STAGE COMPLETED ---\n")
