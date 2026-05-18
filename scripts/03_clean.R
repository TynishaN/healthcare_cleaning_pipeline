# ==========================================================
# CLEANING SCRIPT
# File: scripts/03_cleaning.R
#
# Purpose:
# Performs data cleaning and standardisation on the
# diagnosed dataset including patient identifier
# consistency, date parsing, categorical case
# normalisation, free-text diagnosis normalisation,
# and resolution of duplicate patient records under
# near-duplicate names.
# ==========================================================

library(here)
library(dplyr)
library(stringr)
library(lubridate)
library(stringdist)
library(tibble)

# ==========================================================
# Load configuration settings
# ==========================================================

source(
  here(
    "config",
    "00_config.R"
  )
)

cat("\n--- CLEANING STAGE STARTED ---\n")

# ==========================================================
# LOAD DIAGNOSED DATASET
# ==========================================================

data <- readRDS(
  file.path(
    interim_data_path,
    "data_diagnosed.rds"
  )
)

cat(
  "\nRows entering cleaning:",
  nrow(data)
)

# ==========================================================
# STEP 1: PATIENT IDENTIFIER CONSISTENCY
# ==========================================================

data <- data %>%
  mutate(
    `Patient.Name` =
      `Patient.Name` %>%
      tolower() %>%
      str_trim() %>%
      str_replace_all("\\s+", " ") %>%
      str_replace_all("[[:punct:]]", "")
  )

# ==========================================================
# STEP 2: CATEGORICAL NORMALISATION
# ==========================================================

data <- data %>%
  mutate(
    
    # ---- Gender ----
    
    Gender = tolower(Gender),
    
    Gender = case_when(
      Gender %in% c("m", "male") ~ "Male",
      Gender %in% c("f", "female") ~ "Female",
      Gender %in% c("other", "o") ~ "Other",
      TRUE ~ Gender
    ),
    
    # ---- Condition ----
    
    Condition = str_trim(Condition),
    Condition = str_to_title(Condition),
    
    # ---- Medication ----
    
    Medication = str_to_title(
      tolower(Medication)
    )
  )

# ==========================================================
# STEP 3: CONDITION NORMALISATION
# ==========================================================

data <- data %>%
  mutate(
    Condition = tolower(Condition),
    
    Condition = case_when(
      Condition == "heart disease" ~ "Heart Disease",
      Condition == "diabetes" ~ "Diabetes",
      Condition == "asthma" ~ "Asthma",
      Condition == "hypertension" ~ "Hypertension",
      Condition %in% c(
        "none",
        "no condition",
        ""
      ) ~ "None",
      TRUE ~ str_to_title(Condition)
    )
  )

# ==========================================================
# STEP 4: DATE PARSING
# ==========================================================

data <- data %>%
  mutate(
    `Visit.Date` =
      parse_date_time(
        `Visit.Date`,
        orders = c(
          "ymd",
          "dmy",
          "mdy",
          "Y-m-d",
          "d/m/Y",
          "m/d/Y"
        )
      )
  )

# ==========================================================
# STEP 5: PHONE STANDARDISATION
# ==========================================================

data <- data %>%
  mutate(
    Phone.Number = as.character(Phone.Number),
    
    # Remove spaces
    Phone.Number = trimws(Phone.Number),
    
    # Remove non-digits
    Phone.Number = gsub(
      "[^0-9]",
      "",
      Phone.Number
    ),
    
    # Convert blanks to NA
    Phone.Number = na_if(
      Phone.Number,
      ""
    )
  )

# ==========================================================
# STEP 6: AGE CLEANING
# ==========================================================

data$Age <- as.character(data$Age)

# Convert word ages to numbers

data$Age <- case_when(
  
  tolower(data$Age) == "forty" ~ "40",
  tolower(data$Age) == "thirty" ~ "30",
  tolower(data$Age) == "twenty" ~ "20",
  tolower(data$Age) == "fifty" ~ "50",
  
  # Convert "nan" to real NA
  tolower(data$Age) == "nan" ~ NA_character_,
  
  # Convert blanks to NA
  trimws(data$Age) == "" ~ NA_character_,
  
  TRUE ~ data$Age
)

# Convert to numeric

data$Age <- as.numeric(data$Age)

# ==========================================================
# STEP 7: DETECT NEAR-DUPLICATE NAMES
# ==========================================================

name_vector <- data$`Patient.Name`

dist_matrix <- stringdistmatrix(
  name_vector,
  name_vector,
  method = "lv"
)

duplicate_flags <- apply(
  dist_matrix,
  1,
  function(x)
    any(x > 0 & x <= 2)
)

data$possible_duplicate_name <-
  duplicate_flags

# ==========================================================
# STEP 8: RESOLVE IDENTITY CONFLICTS
# ==========================================================

data <- data %>%
  group_by(
    `Patient.Name`,
    `Visit.Date`
  ) %>%
  mutate(
    
    gender_count =
      n_distinct(Gender),
    
    age_count =
      n_distinct(Age),
    
    phone_count =
      n_distinct(`Phone.Number`)
  )

# ==========================================================
# STEP 9: REMOVE DUPLICATE VISITS
# ==========================================================

# Flag duplicate patient visits

data <- data %>%
  mutate(
    duplicate_visit =
      duplicated(
        paste(
          `Patient.Name`,
          `Visit.Date`
        )
      )
  )

# Count duplicates before removal

duplicates_removed <- sum(
  data$duplicate_visit,
  na.rm = TRUE
)

# Remove duplicate visit records

data_clean <- data %>%
  filter(!duplicate_visit) %>%
  ungroup()

# ==========================================================
# STEP 10: REMOVE EXACT DUPLICATES
# ==========================================================

data_clean <- data_clean %>%
  distinct()

# ==========================================================
# REMOVE HELPER COLUMNS
# ==========================================================

data_clean <- data_clean %>%
  select(
    -gender_count,
    -age_count,
    -phone_count,
    -possible_duplicate_name,
    -duplicate_visit
  )

cat(
  "\nRows after deduplication:",
  nrow(data_clean)
)

cat(
  "\nDuplicate visits removed:",
  duplicates_removed
)

# ==========================================================
# CLEANING AUDIT LOG
# ==========================================================

row_log <- tibble(
  
  stage = c(
    "Raw Dataset",
    "After Cleaning"
  ),
  
  rows = c(
    nrow(data),
    nrow(data_clean)
  )
)

saveRDS(
  row_log,
  file.path(
    interim_data_path,
    "row_log.rds"
  )
)

# ==========================================================
# DUPLICATE SUMMARY EXPORT
# ==========================================================

duplicate_summary <- tibble(
  
  total_rows_before = nrow(data),
  
  total_rows_after = nrow(data_clean),
  
  duplicates_removed =
    duplicates_removed
)

write.csv(
  duplicate_summary,
  file.path(
    output_path,
    "duplicate_summary.csv"
  ),
  row.names = FALSE
)

# ==========================================================
# VALIDATION CHECKS
# ==========================================================

if(nrow(data_clean) == 0) {
  
  stop(
    "Cleaning process removed all rows."
  )
}

if(any(is.na(data_clean$`Visit.Date`))) {
  
  warning(
    "Some Visit.Date values failed parsing."
  )
}

if(any(
  data_clean$Age < 0,
  na.rm = TRUE
)) {
  
  warning(
    "Negative age values detected."
  )
}

# ==========================================================
# SAVE CLEANED DATA
# ==========================================================

saveRDS(
  data_clean,
  file.path(
    interim_data_path,
    "data_cleaned_pre_impute.rds"
  )
)

cat("\n--- CLEANING STAGE COMPLETED ---\n")
