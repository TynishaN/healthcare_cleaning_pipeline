# ==========================================================
# EXPORT SCRIPT
# File: scripts/05_export.R
#
# Purpose:
# Export cleaned dataset into required formats:
# .sav, .dta, .xlsx, .rds
# ==========================================================

library(here)
library(haven)
library(openxlsx)

# Load config
source(
  here(
    "config",
    "00_config.R"
  )
)

cat("\n--- EXPORT STAGE STARTED ---\n")

# Load cleaned dataset

data_cleaned <- readRDS(
  file.path(
    processed_data_path,
    "data_cleaned.rds"
  )
)

# ==========================================
# FIX COLUMN NAMES FOR EXPORT
# ==========================================

names(data_cleaned) <- names(data_cleaned) %>%
  tolower() %>%
  gsub("\\.", "_", .) %>%     # replace . with _
  gsub("\\s+", "_", .)        # replace spaces with _

# Load dictionary

data_dictionary <- read.csv(
  file.path(
    output_path,
    "data_dictionary.csv"
  )
)

# -----------------------------
# Export RDS (already done but safe)
# -----------------------------

saveRDS(
  data_cleaned,
  file.path(
    output_path,
    "data_cleaned.rds"
  )
)

# -----------------------------
# Export SPSS (.sav)
# -----------------------------

write_sav(
  data_cleaned,
  file.path(
    output_path,
    "data_cleaned.sav"
  )
)

# -----------------------------
# Export Stata (.dta)
# -----------------------------

write_dta(
  data_cleaned,
  file.path(
    output_path,
    "data_cleaned.dta"
  )
)

# -----------------------------
# Export Excel (.xlsx)
# -----------------------------

wb <- createWorkbook()

addWorksheet(wb, "Cleaned_Data")

writeData(
  wb,
  "Cleaned_Data",
  data_cleaned
)

addWorksheet(wb, "Data_Dictionary")

writeData(
  wb,
  "Data_Dictionary",
  data_dictionary
)

saveWorkbook(
  wb,
  file.path(
    output_path,
    "data_cleaned.xlsx"
  ),
  overwrite = TRUE
)

cat("\n--- EXPORT STAGE COMPLETED ---\n")
