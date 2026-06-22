# ==============================================================================
# TEST SETUP - Check if everything is ready to run
# ==============================================================================

cat("\n========================================\n")
cat("  TESTING YOUR SETUP\n")
cat("========================================\n\n")

# Test 1: Check R version
cat("[1/5] Checking R version...\n")
cat("  R version:", R.version.string, "\n")
if (as.numeric(R.version$major) >= 4) {
  cat("  ✓ R version is good!\n\n")
} else {
  cat("  ⚠ Consider updating R (recommended 4.0+)\n\n")
}

# Test 2: Check if packages are installed
cat("[2/5] Checking required packages...\n")
required_packages <- c("tidyverse", "naniar", "corrplot", "scales")

for (pkg in required_packages) {
  if (pkg %in% installed.packages()[,"Package"]) {
    cat("  ✓", pkg, "is installed\n")
  } else {
    cat("  ✗", pkg, "is NOT installed\n")
    cat("    Run: install.packages('", pkg, "')\n", sep = "")
  }
}

# Test 3: Try loading packages
cat("\n[3/5] Testing package loading...\n")
tryCatch({
  suppressPackageStartupMessages({
    library(tidyverse)
    library(naniar)
    library(corrplot)
    library(scales)
  })
  cat("  ✓ All packages loaded successfully!\n\n")
}, error = function(e) {
  cat("  ✗ Error loading packages:\n")
  cat("  ", e$message, "\n\n")
})

# Test 4: Check working directory
cat("[4/5] Checking working directory...\n")
cat("  Current directory:", getwd(), "\n")
if (file.exists("scripts/01_data_cleaning.R")) {
  cat("  ✓ Scripts found - you're in the right place!\n\n")
} else {
  cat("  ⚠ Scripts not found. Make sure you opened the .Rproj file\n\n")
}

# Test 5: Check folder structure
cat("[5/5] Checking folder structure...\n")
folders <- c("scripts", "data", "outputs")
for (folder in folders) {
  if (!dir.exists(folder)) {
    dir.create(folder, recursive = TRUE)
    cat("  ✓ Created", folder, "folder\n")
  } else {
    cat("  ✓", folder, "folder exists\n")
  }
}

cat("\n========================================\n")
cat("  SETUP TEST COMPLETE!\n")
cat("========================================\n\n")

# Check if ready
all_packages_installed <- all(required_packages %in% installed.packages()[,"Package"])
scripts_exist <- file.exists("scripts/01_data_cleaning.R")

if (all_packages_installed && scripts_exist) {
  cat("✓ EVERYTHING IS READY!\n\n")
  cat("To run the analysis, type:\n")
  cat("  source('RUN_ALL.R')\n\n")
} else {
  cat("⚠ SETUP INCOMPLETE\n\n")
  if (!all_packages_installed) {
    cat("Install missing packages first:\n")
    cat("  install.packages(c('tidyverse', 'naniar', 'corrplot', 'scales'))\n\n")
  }
}
