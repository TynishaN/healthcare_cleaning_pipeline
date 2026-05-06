# healthcare_cleaning_pipeline
Healthcare data cleaning pipeline
# Healthcare Data Cleaning and Analysis Pipeline

## Overview
This project is a structured data cleaning and analysis pipeline built in R for healthcare data. It automates the process of data ingestion, diagnostics, cleaning, imputation, dictionary generation, export, and reporting.

The pipeline is designed for reproducibility and can be executed end-to-end using a single script or run step-by-step for debugging or inspection.

---

## Pipeline Workflow

The project follows a structured multi-stage pipeline:

1. Configuration Setup  
2. Data Ingestion  
3. Data Diagnostics  
4. Data Cleaning  
5. Data Imputation  
6. Data Dictionary Generation  
7. Data Export  
8. Automated Reporting  

---

## Project Structure
project/ │ 
├── config/ 
│   └── 00_config.R               # Global settings and file paths 
│ 
├── scripts/                      # All scripts for the pipeline
│   ├── run_pipeline.R            # Master pipeline controller (run entire workflow)
│   ├── 01_ingest.R               # Load raw data 
│   ├── 02_diagnose.R             # Data quality checks 
│   ├── 03_clean.R                # Data cleaning & standardisation 
│   ├── 04_dictionary.R           # Data dictionary creation 
│   ├── 05_impute.R               # Missing value handling 
│   ├── 06_export.R               # Export to multiple formats 
│   
├── reports/                      # R markdown report(s) and outputs
│   └── 07_report.Rmd             # Automated analysis report 
│ 
├── data/ 
│   ├── raw/                      # Original unprocessed data
│   ├── interim/                  # Intermediate dataset during processing
│   └── processed/                # Final cleaned dataset ready for analysis
│ 
├── outputs/                      # Generated outputs(tables, files, charts)
│   ├── logs/                     # Pipeline logs and diagnostic outputs
│   ├── missing_summary.csv 
│   ├── data_dictionary.csv 
│   ├── near_duplicate_names.csv 
│   
└── exported datasets │ 
└── README.md

---

## How to Run the Project

### Option 1: Full Automated Pipeline (Recommended)

Run the entire workflow using:

```r
source("scripts/run_pipeline.R")
```
This executes all stages in the correct order: configuration → ingestion → diagnostics → cleaning → imputation → export → report generation.

Option 2: Manual Execution (Step-by-Step)
Run stages individually:

Run configuration (if required):
R
source("config/00_config.R")

Data ingestion:
R
source("scripts/01_ingest.R")

Diagnostics:
R
source("scripts/02_diagnose.R")

Cleaning:
R
source("scripts/03_clean.R")

Imputation:
R
source("scripts/04_impute.R")

Data dictionary generation:
R
source("scripts/05_dictionary.R")

Export:
R
source("scripts/06_export.R")

Generate report:
R
rmarkdown::render("reports/07_report.Rmd")

Key Processing Steps

Data Cleaning
Standardised patient names (lowercase, punctuation removed)
Normalised categorical variables (Gender, Condition, Medication)
Parsed multiple date formats into standard Date type
Cleaned phone numbers (digits only)
Converted age values (including text → numeric)
Removed duplicates using Patient Name + Visit Date

Data Quality Diagnostics
Missing value analysis (before cleaning)
Duplicate detection
Near-duplicate patient name detection (string distance method)
Categorical consistency checks
Visual missingness analysis

Imputation
Age missing values imputed using median value

Export Formats
The final dataset is exported in multiple formats:
.rds (R native format)
.csv
.xlsx (including data dictionary)
.sav (SPSS)
.dta (Stata)

Outputs Generated
Missing value reports
Unique category summaries
Near-duplicate name detection file
Data dictionary
Cleaned dataset in multiple formats
Automated Word report

Tools & Libraries Used
R Packages
tidyverse (dplyr, ggplot2, stringr)
readr
lubridate
stringdist
naniar
visdat
reshape2
rmarkdown
knitr
haven
openxlsx

Development Tools
R
RStudio
Git & GitHub
here (for reproducible file paths)

Limitations
Some missing values remain in non-critical fields
Median imputation may reduce variability in age distribution
Name matching may not capture all real-world duplicates

Conclusion
This pipeline successfully automates the full lifecycle of healthcare data cleaning and preparation, producing a structured, analysis-ready dataset with supporting documentation and reporting outputs.
The system is designed for reproducibility, scalability, and transparency in data processing workflows.