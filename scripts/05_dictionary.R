# ==========================================================
# DATA DICTIONARY SCRIPT
# File: scripts/04_dictionary.R
#
# Purpose:
# Generates a data dictionary describing
# all cleaned dataset variables including:
# type, missingness, and notes.
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

cat("\n--- DATA DICTIONARY STAGE STARTED ---\n")

# -----------------------------
# Load Cleaned Dataset
# -----------------------------

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
  Variable_Name = names(data_cleaned),
  
  Data_Type = sapply(
    data_cleaned,
    class
  ),
  
  Missing_Count = colSums(
    is.na(data_cleaned)
  ),
  
  Missing_Percent =
    round(
      colSums(
        is.na(data_cleaned)
      ) /
        nrow(data_cleaned) * 100,
      2
    ),
  
  Notes = ""
)

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

cat(
  "\nData dictionary created."
)

cat("\n--- DATA DICTIONARY COMPLETED ---\n")