# 🚀 HOW TO RUN THIS PROJECT

## Super Simple - 3 Steps!

### Step 1: Install R and RStudio
1. Download R: https://cran.r-project.org/bin/windows/base/
2. Download RStudio: https://posit.co/download/rstudio-desktop/
3. Install both (just click Next, Next, Next...)

### Step 2: Open the Project
1. Double-click `data-cleaning-eda-project.Rproj`
2. RStudio will open

### Step 3: Run Everything
In RStudio console (bottom-left), type:
```r
source("RUN_ALL.R")
```
Press Enter. Wait 2-3 minutes. Done! ✓

---

## What You'll Get

### Files Created:
- `data/cleaned/clean_data.csv` - Your cleaned dataset
- `outputs/plots/` - 10 beautiful charts
- `outputs/reports/` - 2 summary reports

### Plots Created:
1. Missing values chart
2. Outliers box plot
3. Yield distribution
4. Income distribution  
5. Correlation matrix
6. Yield by region
7. Income by region
8. Fertilizer vs Yield scatter
9. Rainfall vs Yield scatter
10. Farm size vs Income scatter

---

## Alternative: Run Step by Step

```r
# Step 1: Data Cleaning
source("scripts/01_data_cleaning.R")

# Step 2: EDA
source("scripts/02_eda.R")
```

---

## Using Your Own Data

Replace the data creation part in `scripts/01_data_cleaning.R`:

```r
# Instead of generating fake data, load yours:
raw_data <- read_csv("data/raw/your_data.csv")
```

Then run everything normally!

---

## Need Help?

If you get errors:
1. Make sure R and RStudio are installed
2. Check you opened the `.Rproj` file
3. Try installing packages manually:
   ```r
   install.packages(c("tidyverse", "naniar", "corrplot", "scales"))
   ```

---

## For Your Portfolio

This project shows:
- ✅ Data cleaning skills
- ✅ EDA skills
- ✅ Data visualization
- ✅ Professional code structure
- ✅ Documentation

Perfect for Data Analyst job applications! 🎯
