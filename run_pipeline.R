# ==========================================================
# MAIN PIPELINE RUNNER
# File: run_pipeline.R
#
# Purpose:
# Executes all pipeline stages in sequence.
# ==========================================================

library(here)

cat("\n===== PIPELINE STARTED =====\n")

#load config
source(
  here(
    "config",
    "00_config.R"
  )
)


# Run ingestion stage
source(
  here(
    "scripts",
    "01_ingest.R"
  )
)

# Run diagnostic stage
source(
  here(
    "scripts",
    "02_diagnose.R"
  )
)

cat("\n===== PIPELINE COMPLETED =====\n")
