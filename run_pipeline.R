# ==========================================================
# MAIN PIPELINE RUNNER
# File: run_pipeline.R
#
# Purpose:
# Executes all pipeline stages in sequence.
# ==========================================================

library(here)

cat("\n===== PIPELINE STARTED =====\n")

# =====================================
# Load configuration
# =====================================

source(
  here(
    "config",
    "00_config.R"
  )
)

# =====================================
# Run ingestion stage
# =====================================

source(
  here(
    "scripts",
    "01_ingest.R"
  )
)

# =====================================
# Run diagnostic stage
# =====================================

source(
  here(
    "scripts",
    "02_diagnose.R"
  )
)

# =====================================
# Run cleaning stage
# =====================================

source(
  here(
    "scripts",
    "03_clean.R"
  )
)

# =====================================
# Run impute stage
# =====================================

source(
  here(
    "scripts",
    "04_impute.R"
  )
)

# =====================================
# Run Dictionary
# =====================================

source(
  here(
    "scripts",
    "05_dictionary.R"
  )
)
# =====================================
# Run Export
# =====================================

source(
  here(
    "scripts",
    "06_export.R"
  )
)

# =====================================
# Run Automated Report
# =====================================

rmarkdown::render(
  here("reports","07_report.Rmd")
)

cat("\n===== PIPELINE COMPLETED =====\n")


data_final <- readRDS("data/processed/data_cleaned.rds")
nrow(data_final)
ncol(data_final)

colSums(is.na(data_final))

unique(data_final$Gender)
unique(data_final$Condition)
unique(data_final$Medication)
