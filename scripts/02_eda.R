# ==============================================================================
# EXPLORATORY DATA ANALYSIS (EDA)
# ==============================================================================
# Purpose: Explore patterns and relationships in cleaned data
# ==============================================================================

# Load packages
library(tidyverse)  # Data manipulation and visualization
library(corrplot)   # Correlation plots
library(scales)     # Scale functions for plots

cat("====================================\n")
cat("  EXPLORATORY DATA ANALYSIS\n")
cat("====================================\n\n")

# ==============================================================================
# 1. LOAD CLEANED DATA
# ==============================================================================

cat("[Step 1/6] Loading cleaned data...\n")

data <- read_csv("data/cleaned/clean_data.csv", show_col_types = FALSE)

cat("✓ Data loaded:", nrow(data), "rows,", ncol(data), "columns\n\n")

# ==============================================================================
# 2. SUMMARY STATISTICS
# ==============================================================================

cat("[Step 2/6] Calculating summary statistics...\n")

# Overall summary
summary_stats <- data %>%
  select(where(is.numeric), -farm_id) %>%
  summary()

print(summary_stats)

# Summary by region
regional_summary <- data %>%
  group_by(region) %>%
  summarise(
    n_farms = n(),
    avg_yield = round(mean(yield), 2),
    avg_fertilizer = round(mean(fertilizer), 2),
    avg_income = round(mean(income), 0)
  )

cat("\n")
print(regional_summary)
write_csv(regional_summary, "outputs/reports/regional_summary.csv")
cat("\n✓ Regional summary saved\n\n")

# ==============================================================================
# 3. DISTRIBUTION ANALYSIS
# ==============================================================================

cat("[Step 3/6] Analyzing distributions...\n")

# Histogram: Yield distribution
p1 <- ggplot(data, aes(x = yield)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white", alpha = 0.7) +
  geom_vline(aes(xintercept = mean(yield)), color = "red", linetype = "dashed", size = 1) +
  labs(title = "Distribution of Crop Yield",
       subtitle = "Red line = mean",
       x = "Yield",
       y = "Frequency") +
  theme_minimal()

ggsave("outputs/plots/03_yield_distribution.png", p1, width = 8, height = 5)

# Histogram: Income distribution
p2 <- ggplot(data, aes(x = income)) +
  geom_histogram(bins = 30, fill = "darkgreen", color = "white", alpha = 0.7) +
  geom_vline(aes(xintercept = mean(income)), color = "red", linetype = "dashed", size = 1) +
  labs(title = "Distribution of Farm Income",
       subtitle = "Red line = mean",
       x = "Income (USD)",
       y = "Frequency") +
  theme_minimal()

ggsave("outputs/plots/04_income_distribution.png", p2, width = 8, height = 5)

cat("✓ Distribution plots saved\n\n")

# ==============================================================================
# 4. CORRELATION ANALYSIS
# ==============================================================================

cat("[Step 4/6] Analyzing correlations...\n")

# Calculate correlation matrix
numeric_data <- data %>%
  select(where(is.numeric), -farm_id)

cor_matrix <- cor(numeric_data, use = "complete.obs")

# Print correlation with yield
yield_cor <- cor_matrix[, "yield"] %>%
  sort(decreasing = TRUE)

cat("\nCorrelations with Yield:\n")
print(round(yield_cor, 3))

# Correlation plot
png("outputs/plots/05_correlation_matrix.png", width = 800, height = 700)
corrplot(cor_matrix, method = "color", type = "upper",
         tl.col = "black", tl.srt = 45,
         addCoef.col = "black", number.cex = 0.8,
         col = colorRampPalette(c("#E74C3C", "white", "#3498DB"))(200),
         title = "Correlation Matrix",
         mar = c(0, 0, 2, 0))
dev.off()

cat("✓ Correlation matrix saved\n\n")

# ==============================================================================
# 5. GROUP COMPARISONS
# ==============================================================================

cat("[Step 5/6] Comparing groups...\n")

# Box plot: Yield by region
p3 <- ggplot(data, aes(x = region, y = yield, fill = region)) +
  geom_boxplot(alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.3, size = 1) +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Crop Yield by Region",
       x = "Region",
       y = "Yield") +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("outputs/plots/06_yield_by_region.png", p3, width = 8, height = 5)

# Bar plot: Average income by region
p4 <- ggplot(regional_summary, aes(x = reorder(region, avg_income), 
                                    y = avg_income, fill = region)) +
  geom_bar(stat = "identity", alpha = 0.7) +
  geom_text(aes(label = paste0("$", comma(avg_income))), 
            hjust = -0.1, size = 4) +
  coord_flip() +
  scale_fill_brewer(palette = "Set2") +
  labs(title = "Average Farm Income by Region",
       x = "Region",
       y = "Average Income (USD)") +
  theme_minimal() +
  theme(legend.position = "none")

ggsave("outputs/plots/07_income_by_region.png", p4, width = 8, height = 5)

cat("✓ Group comparison plots saved\n\n")

# ==============================================================================
# 6. RELATIONSHIP ANALYSIS
# ==============================================================================

cat("[Step 6/6] Analyzing relationships...\n")

# Scatter plot: Fertilizer vs Yield
p5 <- ggplot(data, aes(x = fertilizer, y = yield, color = region)) +
  geom_point(alpha = 0.6, size = 2) +
  geom_smooth(method = "lm", se = FALSE, color = "black", linetype = "dashed") +
  scale_color_brewer(palette = "Set1") +
  labs(title = "Relationship: Fertilizer Use and Crop Yield",
       subtitle = paste("Correlation:", round(cor(data$fertilizer, data$yield), 3)),
       x = "Fertilizer (kg/ha)",
       y = "Yield",
       color = "Region") +
  theme_minimal()

ggsave("outputs/plots/08_fertilizer_vs_yield.png", p5, width = 10, height = 6)

# Scatter plot: Rainfall vs Yield
p6 <- ggplot(data, aes(x = rainfall, y = yield, color = region)) +
  geom_point(alpha = 0.6, size = 2) +
  geom_smooth(method = "lm", se = TRUE, color = "black") +
  scale_color_brewer(palette = "Set1") +
  labs(title = "Relationship: Rainfall and Crop Yield",
       subtitle = paste("Correlation:", round(cor(data$rainfall, data$yield), 3)),
       x = "Rainfall (mm)",
       y = "Yield",
       color = "Region") +
  theme_minimal()

ggsave("outputs/plots/09_rainfall_vs_yield.png", p6, width = 10, height = 6)

# Scatter plot: Farm size vs Income
p7 <- ggplot(data, aes(x = farm_size, y = income, color = region)) +
  geom_point(alpha = 0.6, size = 2) +
  geom_smooth(method = "lm", se = FALSE, color = "black", linetype = "dashed") +
  scale_color_brewer(palette = "Set1") +
  scale_y_continuous(labels = dollar_format()) +
  labs(title = "Relationship: Farm Size and Income",
       subtitle = paste("Correlation:", round(cor(data$farm_size, data$income), 3)),
       x = "Farm Size (hectares)",
       y = "Income (USD)",
       color = "Region") +
  theme_minimal()

ggsave("outputs/plots/10_farmsize_vs_income.png", p7, width = 10, height = 6)

cat("✓ Relationship plots saved\n\n")

# ==============================================================================
# SUMMARY OF KEY INSIGHTS
# ==============================================================================

cat("====================================\n")
cat("  KEY INSIGHTS\n")
cat("====================================\n\n")

cat("1. DATA OVERVIEW:\n")
cat("   - Total farms analyzed:", nrow(data), "\n")
cat("   - Number of regions:", n_distinct(data$region), "\n")
cat("   - Average yield:", round(mean(data$yield), 2), "\n\n")

cat("2. STRONGEST CORRELATIONS WITH YIELD:\n")
top_cors <- head(yield_cor[names(yield_cor) != "yield"], 3)
for (i in seq_along(top_cors)) {
  cat("   -", names(top_cors)[i], ":", round(top_cors[i], 3), "\n")
}

cat("\n3. REGIONAL DIFFERENCES:\n")
cat("   - Highest yielding region:", 
    regional_summary$region[which.max(regional_summary$avg_yield)], "\n")
cat("   - Highest income region:", 
    regional_summary$region[which.max(regional_summary$avg_income)], "\n")

cat("\n4. VISUALIZATIONS CREATED:\n")
cat("   - 10 professional plots saved in outputs/plots/\n")
cat("   - 2 summary reports saved in outputs/reports/\n")

cat("\n✓ EXPLORATORY DATA ANALYSIS COMPLETE!\n")
cat("====================================\n\n")

cat("Next steps:\n")
cat("  → Review plots in outputs/plots/\n")
cat("  → Check summary reports in outputs/reports/\n")
cat("  → Use insights for further analysis\n\n")
