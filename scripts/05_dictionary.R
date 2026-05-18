# ==========================================================
# DATA DICTIONARY SCRIPT
# File: scripts/05_dictionary.R
#
# Purpose:
# Generates a complete data dictionary including:
# variable name, data type, labels,
# valid values, missingness before and after
# cleaning, imputation treatment, and notes.
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

cat("\n--- DATA DICTIONARY STAGE STARTED ---\n")

# ==========================================================
# LOAD DATASETS
# ==========================================================

# Raw dataset (before cleaning)

data_raw <- readRDS(
  file.path(
    interim_data_path,
    "data_ingested.rds"
  )
)

# Final cleaned dataset (after imputation)

data_cleaned <- readRDS(
  file.path(
    processed_data_path,
    "data_cleaned.rds"
  )
)

cat(
  "\nVariables in cleaned dataset:",
  ncol(data_cleaned)
)

# ==========================================================
# BUILD DATA DICTIONARY
# ==========================================================

# Create raw missingness vector aligned
# to cleaned dataset variables

missing_raw <- sapply(
  names(data_cleaned),
  function(var) {
    
    if(var %in% names(data_raw)) {
      
      round(
        sum(is.na(data_raw[[var]])) /
          nrow(data_raw) * 100,
        2
      )
      
    } else {
      
      NA
    }
  }
)

# Create cleaned missingness vector

missing_cleaned <- sapply(
  names(data_cleaned),
  function(var) {
    
    round(
      sum(is.na(data_cleaned[[var]])) /
        nrow(data_cleaned) * 100,
      2
    )
  }
)

# Build dictionary dynamically

data_dictionary <- tibble(
  
  Variable_Name =
    names(data_cleaned),
  
  Data_Type =
    sapply(
      data_cleaned,
      function(x)
        class(x)[1]
    ),
  
  Missing_Percent_Raw =
    missing_raw,
  
  Missing_Percent_Cleaned =
    missing_cleaned
)

# ==========================================================
# ADD METADATA FIELDS
# ==========================================================

data_dictionary <- data_dictionary %>%
  
  mutate(
    
    Label = case_when(
      
      Variable_Name == "Patient.Name"
      ~ "Patient Name",
      
      Variable_Name == "Gender"
      ~ "Patient Gender",
      
      Variable_Name == "Condition"
      ~ "Medical Condition",
      
      Variable_Name == "Medication"
      ~ "Medication Name",
      
      Variable_Name == "Visit.Date"
      ~ "Visit Date",
      
      Variable_Name == "Phone.Number"
      ~ "Patient Contact Number",
      
      Variable_Name == "Age"
      ~ "Patient Age",
      
      Variable_Name == "Blood.Pressure"
      ~ "Blood Pressure Reading",
      
      Variable_Name == "Cholesterol"
      ~ "Cholesterol Level",
      
      Variable_Name == "Email"
      ~ "Patient Email Address",
      
      Variable_Name == "Age_Original"
      ~ "Original Age Before Imputation",
      
      Variable_Name == "Age_Imputed_Flag"
      ~ "Age Imputation Indicator",
      
      TRUE ~ Variable_Name
    ),
    
    Valid_Values = case_when(
      
      Variable_Name == "Gender"
      ~ "Male, Female, Other",
      
      Variable_Name == "Age"
      ~ "0-120",
      
      Variable_Name == "Age_Imputed_Flag"
      ~ "TRUE/FALSE",
      
      TRUE ~ "See dataset documentation"
    ),
    
    Imputation = case_when(
      
      Variable_Name == "Age"
      ~ "Median imputation",
      
      Variable_Name == "Age_Original"
      ~ "Reference variable only",
      
      Variable_Name == "Age_Imputed_Flag"
      ~ "Generated during imputation",
      
      TRUE ~ "None"
    ),
    
    Notes = case_when(
      
      Variable_Name == "Patient.Name"
      ~ "Names standardised and deduplicated",
      
      Variable_Name == "Gender"
      ~ "Categorical values standardised",
      
      Variable_Name == "Condition"
      ~ "Condition names normalised",
      
      Variable_Name == "Medication"
      ~ "Medication names standardised",
      
      Variable_Name == "Visit.Date"
      ~ "Parsed from multiple date formats",
      
      Variable_Name == "Phone.Number"
      ~ "Non-digit characters removed",
      
      Variable_Name == "Age"
      ~ "Text converted to numeric",
      
      Variable_Name == "Age_Original"
      ~ "Stored for imputation comparison",
      
      Variable_Name == "Age_Imputed_Flag"
      ~ "Indicates imputed observations",
      
      TRUE ~ ""
    )
  )

# ==========================================================
# VALIDATION CHECKS
# ==========================================================

# Ensure dictionary rows match variables

if(
  nrow(data_dictionary) !=
  ncol(data_cleaned)
) {
  
  warning(
    "Dictionary row count does not match dataset variables."
  )
}

# Ensure no blank labels remain

if(any(data_dictionary$Label == "")) {
  
  warning(
    "Some variable labels are blank."
  )
}

# ==========================================================
# SAVE DATA DICTIONARY
# ==========================================================

write.csv(
  data_dictionary,
  file.path(
    output_path,
    "data_dictionary.csv"
  ),
  row.names = FALSE
)

cat(
  "\nData dictionary created successfully."
)

cat(
  "\nDictionary saved to outputs folder."
)

cat("\n--- DATA DICTIONARY COMPLETED ---\n")
