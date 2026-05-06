# ==========================================================
# DATA DICTIONARY SCRIPT
# File: scripts/04_dictionary.R
# Purpose:
# Generates a complete data dictionary including:
# variable name, type, labels, valid values,
# missingness (before and after cleaning),
# imputation treatment, and notes.
# ==========================================================

library(here)
library(dplyr)

# -----------------------------
# Load configuration
# -----------------------------

source(
  here(
    "config",
    "00_config.R"
  )
)

cat("\n--- DATA DICTIONARY STAGE STARTED ---\n")

# -----------------------------
# Load Datasets
# -----------------------------

# Raw dataset (BEFORE cleaning)
data_raw <- readRDS(
  file.path(
    interim_data_path,
    "data_ingested.rds"
  )
)

# Cleaned dataset (AFTER cleaning)
data_cleaned <- readRDS(
  file.path(
    processed_data_path,
    "data_cleaned.rds"
  )
)

# -----------------------------
# Build Data Dictionary
# -----------------------------

data_dictionary <- data.frame(
  
  # Variable name
  Variable_Name = names(data_cleaned),
  
  # Data type
  Data_Type = sapply(
    data_cleaned, function(x)
    class(x)[1]
  ),
  
  # Missing % BEFORE cleaning
  Missing_Percent_Raw = round(
    colSums(is.na(data_raw)) /
      nrow(data_raw) * 100,
    2
  ),
  
  # Missing % AFTER cleaning
  Missing_Percent_Cleaned = round(
    colSums(is.na(data_cleaned)) /
      nrow(data_cleaned) * 100,
    2
  ),
  
  # Required fields (to be filled / partially defined)
  Label = "",
  Valid_Values = "",
  Imputation = "",
  Notes = ""
)

# -----------------------------
# OPTIONAL: Add Manual Definitions
# (Recommended for key variables)
# -----------------------------

data_dictionary$Label[
  data_dictionary$Variable_Name == "Age"
] <- "Patient age in years"

data_dictionary$Valid_Values[
  data_dictionary$Variable_Name == "Age"
] <- "0–120"

data_dictionary$Imputation[
  data_dictionary$Variable_Name == "Age"
] <- "Median imputation"

data_dictionary$Notes[
  data_dictionary$Variable_Name == "Age"
] <- "Converted from text where necessary"

data_dictionary$Label[
  data_dictionary$Variable_Name == "Gender"
] <- "Patient gender"

data_dictionary$Valid_Values[
  data_dictionary$Variable_Name == "Gender"
] <- "Male, Female, Other"

data_dictionary$Notes[
  data_dictionary$Variable_Name == "Gender"
] <- "Standardised values"

data_dictionary$Label[
  data_dictionary$Variable_Name == "Condition"
] <- "Patient medical condition"

data_dictionary$Notes[
  data_dictionary$Variable_Name == "Condition"
] <- "Normalised to consistent format"

data_dictionary$Label[
  data_dictionary$Variable_Name == "Phone.Number"
] <- "Patient contact number"

data_dictionary$Notes[
  data_dictionary$Variable_Name == "Phone.Number"
] <- "Non-digit characters removed"

data_dictionary$Label[
  data_dictionary$Variable_Name == "Visit.Date"
] <- "Date of patient visit"

data_dictionary$Notes[
  data_dictionary$Variable_Name == "Visit.Date"
] <- "Parsed from multiple formats"

# -----------------------------
# Save Dictionary
# -----------------------------

write.csv(
  data_dictionary,
  file.path(
    output_path,
    "data_dictionary.csv"
  ),
  row.names = FALSE
)

cat("\nData dictionary created successfully.")

cat("\n--- DATA DICTIONARY COMPLETED ---\n")