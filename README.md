# Healthcare Data Cleaning and Analysis Pipeline

## Overview

This project is a structured healthcare data cleaning and analysis pipeline developed in R. The pipeline automates the process of:

- data ingestion,
- data diagnostics,
- data cleaning,
- missing value imputation,
- data dictionary generation,
- multi-format dataset export,
- and automated reporting.

The workflow is designed to support reproducibility, transparency, portability, and end-to-end execution using a single master script.

---

# Pipeline Workflow

The project follows a structured multi-stage workflow:

1. Configuration Setup  
2. Data Ingestion  
3. Data Diagnostics  
4. Data Cleaning  
5. Data Imputation  
6. Data Dictionary Generation  
7. Data Export  
8. Automated Reporting  

---

# Project Structure

```text
project/
│
├── run_pipeline.R
│   # Master pipeline controller (single entry point)
│
├── config/
│   └── 00_config.R
│
├── scripts/
│   ├── 01_ingest.R
│   ├── 02_diagnose.R
│   ├── 03_clean.R
│   ├── 04_impute.R
│   ├── 05_dictionary.R
│   └── 06_export.R
│
├── reports/
│   ├── 07_report.Rmd
│   ├── 07_report.docx
│   ├── Weekly_Report_Week1.docx
│   ├── Weekly_Report_Week2.docx
│   └── Weekly_Report_Week3.docx
│
├── presentation/
│   └── healthcare_pipeline_presentation.pptx
│
├── data/
│   ├── raw/
│   ├── interim/
│   └── processed/
│
├── outputs/
│   ├── logs/
│   │   ├── diagnostic_log.txt
│   │   ├── cleaning_log.txt
│   │   └── imputation_log.txt
│   │
│   ├── data_cleaned.xlsx
│   ├── data_cleaned.sav
│   ├── data_cleaned.dta
│   ├── data_cleaned.rds
│   │
│   ├── missing_summary.csv
│   ├── duplicate_summary.csv
│   ├── imputation_summary.csv
│   ├── data_dictionary.csv
│   ├── diagnosis_unique_values.csv
│   ├── gender_unique_values.csv
│   ├── unique_patient_names.csv
│   ├── near_duplicate_names.csv
│   └── missingness_plot.png
│
└── README.md
```

---

# How to Run the Project

## Option 1: Full Automated Pipeline (Recommended)

Run the complete workflow using:

```r
source("scripts/run_pipeline.R")
```

This executes all stages in the correct order:

1. Configuration  
2. Ingestion  
3. Diagnostics  
4. Cleaning  
5. Imputation  
6. Dictionary Generation  
7. Export  
8. Report Rendering  

---

## Option 2: Manual Execution (Step-by-Step)

### Load Configuration

```r
source("config/00_config.R")
```

### Data Ingestion

```r
source("scripts/01_ingest.R")
```

### Diagnostics

```r
source("scripts/02_diagnose.R")
```

### Cleaning

```r
source("scripts/03_cleaning.R")
```

### Imputation

```r
source("scripts/04_impute.R")
```

### Data Dictionary Generation

```r
source("scripts/05_dictionary.R")
```

### Export

```r
source("scripts/06_export.R")
```

### Generate Report

```r
rmarkdown::render("reports/07_report.Rmd")
```

---

# Key Processing Steps

## Data Cleaning

The cleaning stage performs:

- patient name standardisation:
  - lowercase conversion,
  - punctuation removal,
  - whitespace trimming

- categorical normalisation:
  - Gender,
  - Condition,
  - Medication

- date parsing from multiple formats into standard date objects

- phone number cleaning:
  - removal of non-digit characters,
  - conversion of blanks to missing values

- age cleaning:
  - text-to-numeric conversion,
  - conversion of `"nan"` values to proper missing values

- duplicate patient visit resolution using:
  - Patient Name
  - Visit Date

---

## Data Quality Diagnostics

The diagnostics stage includes:

- missing value analysis
- duplicate detection
- near-duplicate patient name detection
- categorical consistency checks
- visual missingness analysis

---

## Imputation

Missing values in the Age variable are handled using:

- median imputation

The pipeline also stores:
- original Age values,
- imputation flags,
- imputation summaries for reporting.

---

# Export Formats

The final cleaned dataset is exported in multiple formats:

- `.rds`
- `.csv`
- `.xlsx`
- `.sav` (SPSS)
- `.dta` (Stata)

---

# Outputs Generated

The pipeline generates:

- cleaned datasets
- missing value summaries
- duplicate summaries
- imputation summaries
- near-duplicate detection outputs
- data dictionary
- automated Word report

---

# Tools and Libraries Used

## R Packages

- tidyverse
  - dplyr
  - ggplot2
  - stringr

- readr
- lubridate
- stringdist
- naniar
- visdat
- reshape2
- rmarkdown
- knitr
- haven
- openxlsx
- here

---

## Development Tools

- R
- RStudio
- Git
- GitHub

---

# Reproducibility Features

The project incorporates several reproducibility practices:

- modular script structure
- configuration-driven file paths
- use of `here()` for portability
- single-entry pipeline execution
- automated reporting
- exported audit summaries
- intermediate dataset preservation

---

# Limitations

Some limitations remain within the dataset and cleaning process:

- some missing values remain in non-critical variables
- median imputation may reduce variability in Age
- near-duplicate name detection may not capture all real-world duplicate cases
- some inconsistencies may persist due to real-world data entry issues

---

# Conclusion

This project successfully automates the full healthcare data cleaning lifecycle using a structured and reproducible pipeline.

The system produces:
- analysis-ready datasets,
- supporting documentation,
- audit summaries,
- and automated reporting outputs.

The pipeline is designed to support:
- transparency,
- reproducibility,
- scalability,
- and efficient healthcare data preparation workflows.
