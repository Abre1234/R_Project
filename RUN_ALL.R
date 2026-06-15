# ==============================================================================
# RUN COMPLETE ANALYSIS
# ==============================================================================
# This script runs data cleaning and EDA in sequence
# ==============================================================================

cat("\n")
cat("========================================\n")
cat("  DATA CLEANING & EDA PROJECT\n")
cat("========================================\n\n")

# Check and install required packages
required_packages <- c("tidyverse", "naniar", "corrplot", "scales")

cat("Checking required packages...\n")
missing_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

if(length(missing_packages) > 0) {
  cat("Installing missing packages:", paste(missing_packages, collapse = ", "), "\n")
  install.packages(missing_packages, dependencies = TRUE)
}

cat("✓ All packages ready\n\n")

# Load packages
library(tidyverse)
library(naniar)
library(corrplot)
library(scales)

cat("========================================\n")
cat("  STEP 1: DATA CLEANING\n")
cat("========================================\n\n")

source("scripts/01_data_cleaning.R")

cat("\n")
cat("========================================\n")
cat("  STEP 2: EXPLORATORY ANALYSIS\n")
cat("========================================\n\n")

source("scripts/02_eda.R")

cat("\n")
cat("========================================\n")
cat("  ✓ ANALYSIS COMPLETE!\n")
cat("========================================\n\n")

cat("Outputs created:\n")
cat("  📁 data/cleaned/clean_data.csv\n")
cat("  📁 outputs/plots/ (10 visualizations)\n")
cat("  📁 outputs/reports/ (2 summary tables)\n\n")

cat("Next steps:\n")
cat("  1. Review plots in outputs/plots/\n")
cat("  2. Check cleaned data in data/cleaned/\n")
cat("  3. Read summary reports in outputs/reports/\n\n")
