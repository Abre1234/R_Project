# ==============================================================================
# DATA CLEANING SCRIPT
# ==============================================================================
# Purpose: Clean and prepare agricultural data for analysis
# Author: Your Name
# ==============================================================================

# Load packages
library(tidyverse)  # Data manipulation
library(naniar)     # Missing data visualization

cat("====================================\n")
cat("  DATA CLEANING PIPELINE\n")
cat("====================================\n\n")

# ==============================================================================
# 1. CREATE SAMPLE DATASET (Replace with your own data)
# ==============================================================================

cat("[Step 1/7] Creating sample dataset...\n")

set.seed(123)
n <- 500

# Generate realistic agricultural data
raw_data <- tibble(
  farm_id = paste0("F", str_pad(1:n, 4, pad = "0")),
  region = sample(c("North", "South", "East", "West"), n, replace = TRUE),
  farm_size = rgamma(n, shape = 2, scale = 5),
  yield = rnorm(n, mean = 5, sd = 1.5),
  fertilizer = rgamma(n, shape = 2, scale = 50),
  rainfall = rnorm(n, mean = 800, sd = 150),
  income = rnorm(n, mean = 3000, sd = 800)
)

# Introduce data quality issues
raw_data$fertilizer[sample(1:n, 30)] <- NA  # Missing values
raw_data$rainfall[sample(1:n, 15)] <- NA
raw_data$yield[sample(1:n, 3)] <- raw_data$yield[sample(1:n, 3)] * 10  # Outliers
raw_data <- bind_rows(raw_data, raw_data[1:5, ])  # Duplicates

cat("✓ Sample data created:", nrow(raw_data), "rows\n\n")

# Create folders
dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
dir.create("data/cleaned", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/plots", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/reports", recursive = TRUE, showWarnings = FALSE)

# Save raw data
write_csv(raw_data, "data/raw/raw_data.csv")

# ==============================================================================
# 2. MISSING VALUE ANALYSIS
# ==============================================================================

cat("[Step 2/7] Analyzing missing values...\n")

# Count missing values
missing_summary <- raw_data %>%
  summarise(across(everything(), ~sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "missing_count") %>%
  mutate(
    total = nrow(raw_data),
    percent_missing = round((missing_count / total) * 100, 2)
  ) %>%
  arrange(desc(missing_count))

print(missing_summary)

# Visualize missing data
p_missing <- gg_miss_var(raw_data, show_pct = TRUE) +
  labs(title = "Missing Values by Variable",
       x = "Number of Missing",
       y = "Variable") +
  theme_minimal()

ggsave("outputs/plots/01_missing_values.png", p_missing, width = 8, height = 5)
cat("✓ Missing values plot saved\n\n")

# ==============================================================================
# 3. REMOVE DUPLICATES
# ==============================================================================

cat("[Step 3/7] Removing duplicate records...\n")

n_before <- nrow(raw_data)
clean_data <- raw_data %>%
  distinct(farm_id, .keep_all = TRUE)

n_removed <- n_before - nrow(clean_data)
cat("✓ Duplicates removed:", n_removed, "\n")
cat("  Remaining records:", nrow(clean_data), "\n\n")

# ==============================================================================
# 4. OUTLIER DETECTION
# ==============================================================================

cat("[Step 4/7] Detecting outliers...\n")

# Function to detect outliers using IQR method
detect_outliers <- function(x) {
  q1 <- quantile(x, 0.25, na.rm = TRUE)
  q3 <- quantile(x, 0.75, na.rm = TRUE)
  iqr <- q3 - q1
  lower <- q1 - 1.5 * iqr
  upper <- q3 + 1.5 * iqr
  return(x < lower | x > upper)
}

# Detect outliers in yield
outliers_yield <- detect_outliers(clean_data$yield)
cat("  Outliers in yield:", sum(outliers_yield, na.rm = TRUE), "\n")

# Visualize outliers
p_outliers <- ggplot(clean_data, aes(x = region, y = yield)) +
  geom_boxplot(fill = "steelblue", alpha = 0.7) +
  labs(title = "Yield Distribution by Region (Outliers Visible)",
       x = "Region",
       y = "Yield") +
  theme_minimal()

ggsave("outputs/plots/02_outliers_boxplot.png", p_outliers, width = 8, height = 5)
cat("✓ Outlier plot saved\n\n")

# Cap outliers (winsorize)
cap_outliers <- function(x) {
  q1 <- quantile(x, 0.01, na.rm = TRUE)
  q99 <- quantile(x, 0.99, na.rm = TRUE)
  x[x < q1] <- q1
  x[x > q99] <- q99
  return(x)
}

clean_data <- clean_data %>%
  mutate(yield = cap_outliers(yield))

cat("✓ Outliers capped at 1st and 99th percentile\n\n")

# ==============================================================================
# 5. HANDLE MISSING VALUES
# ==============================================================================

cat("[Step 5/7] Handling missing values...\n")

# Simple imputation: replace with median
clean_data <- clean_data %>%
  mutate(
    fertilizer = ifelse(is.na(fertilizer), median(fertilizer, na.rm = TRUE), fertilizer),
    rainfall = ifelse(is.na(rainfall), median(rainfall, na.rm = TRUE), rainfall)
  )

cat("✓ Missing values imputed with median\n")
cat("  Remaining missing values:", sum(is.na(clean_data)), "\n\n")

# ==============================================================================
# 6. DATA VALIDATION
# ==============================================================================

cat("[Step 6/7] Validating cleaned data...\n")

validation_report <- tibble(
  check = c("Total records", "Complete records", "Duplicate IDs", 
            "Negative values", "Missing values"),
  result = c(
    nrow(clean_data),
    sum(complete.cases(clean_data)),
    nrow(clean_data) - n_distinct(clean_data$farm_id),
    sum(clean_data %>% select(where(is.numeric)) < 0, na.rm = TRUE),
    sum(is.na(clean_data))
  ),
  status = c("✓", "✓", "✓", "✓", "✓")
)

print(validation_report)
write_csv(validation_report, "outputs/reports/data_quality_report.csv")
cat("\n✓ Validation report saved\n\n")

# ==============================================================================
# 7. SAVE CLEANED DATA
# ==============================================================================

cat("[Step 7/7] Saving cleaned data...\n")

write_csv(clean_data, "data/cleaned/clean_data.csv")

cat("✓ Clean data saved to: data/cleaned/clean_data.csv\n")

# Summary
cat("\n====================================\n")
cat("  CLEANING SUMMARY\n")
cat("====================================\n")
cat("Original records:", n_before, "\n")
cat("Final records:", nrow(clean_data), "\n")
cat("Records removed:", n_removed, "\n")
cat("Outliers treated:", sum(outliers_yield, na.rm = TRUE), "\n")
cat("Missing values handled:", sum(missing_summary$missing_count), "\n")
cat("\n✓ DATA CLEANING COMPLETE!\n")
cat("====================================\n\n")
