# ==========================================================
# CLEANING SCRIPT
# File: scripts/03_cleaning.R
#
# Purpose:
# Performs data cleaning and standardisation on the
# diagnosed dataset including:
# - Patient identifier consistency
# - Date parsing
# - Categorical case normalisation
# - Free-text diagnosis normalisation
# - Near-duplicate name detection
# - Duplicate patient resolution
# ==========================================================

library(here)
library(dplyr)
library(stringr)
library(lubridate)
library(stringdist)
library(tibble)

# ==========================================================
# LOAD CONFIGURATION SETTINGS
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

cat(
  "\nColumns entering cleaning:",
  ncol(data)
)

# ==========================================================
# START LOGGING
# ==========================================================

sink(cleaning_log_file)

cat("\n===== DATA CLEANING =====\n")

cat(
  "\nRows entering cleaning:",
  nrow(data)
)

cat(
  "\nColumns entering cleaning:",
  ncol(data)
)

# ==========================================================
# STEP 1: PATIENT IDENTIFIER CONSISTENCY
# ==========================================================

cat("\n--- STEP 1: PATIENT IDENTIFIER CONSISTENCY ---\n")

data <- data %>%
  mutate(
    `Patient.Name` =
      `Patient.Name` %>%
      tolower() %>%
      str_trim() %>%
      str_replace_all("\\s+", " ") %>%
      str_replace_all("[[:punct:]]", "")
  )

cat("\nPatient names standardised.\n")

# ==========================================================
# STEP 2: CATEGORICAL NORMALISATION
# ==========================================================

cat("\n--- STEP 2: CATEGORICAL NORMALISATION ---\n")

data <- data %>%
  mutate(
    
    # -----------------------------
    # Gender Standardisation
    # -----------------------------
    
    Gender = tolower(Gender),
    
    Gender = case_when(
      Gender %in% c("m", "male") ~ "Male",
      Gender %in% c("f", "female") ~ "Female",
      Gender %in% c("other", "o") ~ "Other",
      TRUE ~ str_to_title(Gender)
    ),
    
    # -----------------------------
    # Condition Formatting
    # -----------------------------
    
    Condition = str_trim(Condition),
    Condition = str_to_title(Condition),
    
    # -----------------------------
    # Medication Standardisation
    # -----------------------------
    
    Medication = str_to_title(
      tolower(Medication)
    )
  )

cat("\nGender and medication categories standardised.\n")

# ==========================================================
# STEP 3: CONDITION NORMALISATION
# ==========================================================

cat("\n--- STEP 3: CONDITION NORMALISATION ---\n")

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

cat("\nCondition values normalised.\n")

# ==========================================================
# STEP 4: DATE PARSING
# ==========================================================

cat("\n--- STEP 4: DATE PARSING ---\n")

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

cat("\nVisit dates parsed successfully.\n")

# ==========================================================
# STEP 5: PHONE STANDARDISATION
# ==========================================================

cat("\n--- STEP 5: PHONE STANDARDISATION ---\n")

data <- data %>%
  mutate(
    
    Phone.Number = as.character(
      Phone.Number
    ),
    
    Phone.Number = trimws(
      Phone.Number
    ),
    
    Phone.Number = gsub(
      "[^0-9]",
      "",
      Phone.Number
    ),
    
    Phone.Number = na_if(
      Phone.Number,
      ""
    )
  )

cat("\nPhone numbers cleaned.\n")

# ==========================================================
# STEP 6: AGE CLEANING
# ==========================================================

cat("\n--- STEP 6: AGE CLEANING ---\n")

data$Age <- as.character(data$Age)

data$Age <- case_when(
  
  tolower(data$Age) == "forty" ~ "40",
  tolower(data$Age) == "thirty" ~ "30",
  tolower(data$Age) == "twenty" ~ "20",
  tolower(data$Age) == "fifty" ~ "50",
  
  tolower(data$Age) == "nan" ~ NA_character_,
  
  trimws(data$Age) == "" ~ NA_character_,
  
  TRUE ~ data$Age
)

data$Age <- as.numeric(data$Age)

cat("\nAge values cleaned and converted to numeric.\n")

# ==========================================================
# STEP 7: DETECT NEAR-DUPLICATE NAMES
# ==========================================================

cat("\n--- STEP 7: NEAR-DUPLICATE DETECTION ---\n")

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

cat(
  "\nPossible near-duplicate names detected:",
  sum(data$possible_duplicate_name)
)

# ==========================================================
# EXPORT NEAR-DUPLICATE NAMES
# ==========================================================

near_duplicates <- data %>%
  filter(
    possible_duplicate_name == TRUE
  )

write.csv(
  near_duplicates,
  file.path(
    output_path,
    "near_duplicate_names.csv"
  ),
  row.names = FALSE
)

cat("\nNear-duplicate names exported.\n")

# ==========================================================
# STEP 8: RESOLVE IDENTITY CONFLICTS
# ==========================================================

cat("\n--- STEP 8: RESOLVE IDENTITY CONFLICTS ---\n")

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

cat("\n--- STEP 9: REMOVE DUPLICATE VISITS ---\n")

data <- data %>%
  mutate(
    duplicate_visit =
      duplicated(
        paste(
          `Patient.Name`,
          `Visit.Date`,
          sep = "_"
        )
      )
  )

duplicates_removed <- sum(
  data$duplicate_visit,
  na.rm = TRUE
)

data_clean <- data %>%
  filter(!duplicate_visit) %>%
  ungroup()

cat(
  "\nDuplicate visits removed:",
  duplicates_removed
)

# ==========================================================
# STEP 10: REMOVE EXACT DUPLICATES
# ==========================================================

cat("\n--- STEP 10: REMOVE EXACT DUPLICATES ---\n")

rows_before <- nrow(data_clean)

data_clean <- data_clean %>%
  distinct()

rows_after <- nrow(data_clean)

cat(
  "\nExact duplicates removed:",
  rows_before - rows_after
)

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

cat("\nCleaning audit log created.\n")

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

cat("\nDuplicate summary exported.\n")

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

cat("\nValidation checks completed.\n")

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

cat(
  "\nRows after cleaning:",
  nrow(data_clean)
)

cat(
  "\nColumns after cleaning:",
  ncol(data_clean)
)

cat("\nCleaning completed successfully.\n")

# ==========================================================
# STOP LOGGING
# ==========================================================

sink()

cat("\n--- CLEANING STAGE COMPLETED ---\n")