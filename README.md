# CAO/ARO/AIO-04 Clinical Trial Data Analysis

**Reproduction of Rödel et al. (2015) Lancet Study Results**

## Overview

This project reproduces the statistical analysis and results from the CAO/ARO/AIO-04 study published in *Rödel et al. (2015)* in The Lancet. The study is a multicentre, open-label, phase III randomized controlled trial that evaluated the efficacy of adding oxaliplatin to standard fluorouracil-based chemoradiotherapy for locally advanced rectal cancer.

### Study Background

- **Trial Name**: CAO/ARO/AIO-04
- **Study Type**: Multicentre, open-label, phase III randomized trial
- **Setting**: Germany
- **Population**: Patients with locally advanced rectal cancer
- **Interventions**:
  - **Control group**: Standard fluorouracil (5-FU) based chemoradiotherapy + postoperative chemotherapy
  - **Investigational group**: 5-FU + Oxaliplatin based chemoradiotherapy + postoperative chemotherapy

### Primary Objective

Evaluate whether adding oxaliplatin to standard therapy improves disease-free survival (DFS) in patients with locally advanced rectal cancer.

### Secondary Objectives

- Overall survival (OS) analysis
- Incidence of local and distant recurrences
- Safety and toxicity profiles
- Subgroup analyses

## Project Structure

```
datathlon1/
├── actual data/
│   └── Primary_endpoint_data.rda          # Main clinical trial dataset
├── figures_scripts/
│   └── figure2_script.r                   # Kaplan-Meier survival curves
├── tables_scripts/
│   ├── table1_script.r                    # Baseline characteristics
│   ├── table2_script.r                    # Primary endpoint analysis
│   └── table3_script.r                    # Overall survival analysis
├── reproduced_tf/                         # Output directory for reproduced tables/figures
│   ├── table1.png
│   ├── table2.png
│   ├── table3.png
│   └── figure2_survival.png
├── primary_endpoint_analysis.R             # Main statistical analysis script
├── Primary_endpoint.Rnw                   # Sweave document for detailed analysis
├── output.qmd                            # Quarto markdown report
├── Roedel et al 2015 Lancet PIIS147020451500159X.pdf  # Original publication
└── README.md                             # This file
```

## Reproduced Tables and Figures

### Tables

- **Table 1**: Baseline Characteristics and Demographics
  - Patient demographics by treatment arm
  - Disease characteristics and stratification factors
  - Prior treatments and medical history

- **Table 2**: Primary Endpoint Analysis (Disease-Free Survival)
  - Intention-to-treat analysis of first events for DFS
  - Hazard ratios and confidence intervals
  - Statistical significance testing

- **Table 3**: Overall Survival Analysis
  - Intention-to-treat analysis of all-cause deaths
  - Survival comparisons between treatment arms

### Figures

- **Figure 1**: CONSORT Diagram (Trial Profile)
  - Patient flow throughout the study
  - Randomization, treatment allocation, and follow-up

- **Figure 2**: Kaplan-Meier Survival Curves
  - Panel A: Disease-free survival curves
  - Panel B: Overall survival curves
  - Risk tables and statistical comparisons

- **Figure 3**: Cumulative Incidence Curves
  - Panel A: Locoregional recurrence (*Note: Missing data limitations*)
  - Panel B: Distant metastases

- **Figure 4**: Forest Plot
  - Hazard ratios for DFS in predefined subgroups
  - Subgroup analyses with confidence intervals

## Statistical Methods

### Primary Analysis

1. **Stratified Log-rank Test**
   - Stratification by study center and clinical N category
   - Permutation-based p-values (100,000 iterations)
   - Handling of small centers through merging

2. **Mixed-Effects Cox Proportional Hazards Model**
   - Random intercepts for study center and clinical N category
   - Hazard ratio estimation with 95% confidence intervals
   - Proportional hazards assumption testing

3. **Survival Analysis**
   - Kaplan-Meier estimation
   - 3-year and 5-year survival rates
   - Median follow-up time calculation

### Secondary Analyses

- Overall survival analysis using similar methodology
- Cumulative incidence analysis for competing risks
- Subgroup analyses with forest plots
- Proportional hazards assumption validation

## Requirements

### R Version
- R 3.1.1 or higher

### Required R Packages

```r
# Core survival analysis
survival (>= 2.37.7)
prodlim (>= 1.4.3)
coin (>= 1.0.24)
coxme (>= 2.2.3)

# Data manipulation and visualization
dplyr
ggplot2
survminer
gridExtra

# Table generation
flextable
officer

# Additional packages
rmeta (>= 2.16)
mgcv (>= 1.8.1)
multcomp (>= 1.3.6)
cmprsk (>= 2.2-7)
consort
forestplot
```

## Usage Instructions

### 1. Running the Complete Analysis

```r
# Run the main analysis script
source("primary_endpoint_analysis.R")
```

### 2. Generating Individual Tables

```r
# Table 1: Baseline characteristics
source("tables_scripts/table1_script.r")

# Table 2: Primary endpoint
source("tables_scripts/table2_script.r")

# Table 3: Overall survival
source("tables_scripts/table3_script.r")
```

### 3. Generating Figures

```r
# Figure 2: Kaplan-Meier curves
source("figures_scripts/figure2_script.r")
```

### 4. Generating Reports

```r
# Render Quarto report
quarto::quarto_render("output.qmd")

# Process Sweave document
Sweave("Primary_endpoint.Rnw")
```

## Key Results

### Primary Endpoint (Disease-Free Survival)

- **Hazard Ratio**: 5-FU + Oxaliplatin vs 5-FU alone
- **3-year DFS**: Comparison between treatment arms
- **5-year DFS**: Long-term outcomes
- **Statistical significance**: p-value from stratified log-rank test

### Treatment Effect

The analysis evaluates whether adding oxaliplatin to standard fluorouracil-based therapy provides a statistically significant improvement in disease-free survival for patients with locally advanced rectal cancer.

## Data Limitations

- **Missing Data**: Some variables have missing values affecting certain analyses
- **Figure 3A**: Locoregional recurrence curves could not be fully reproduced due to missing data
- **Table 2**: Minor discrepancies in some values due to data availability

## Reproducibility

### Session Information
All analyses include session information documenting:
- R version
- Package versions
- Operating system
- Computational environment

### Random Seed
- Set to 29 for all permutation tests and resampling procedures
- Ensures reproducible p-values and confidence intervals

### Version Control
- Package versions specified and checked
- Warnings generated for version mismatches

## Files Description

- **`primary_endpoint_analysis.R`**: Comprehensive analysis script with detailed statistical methodology
- **`output.qmd`**: Quarto markdown document generating HTML report with all tables and figures
- **`Primary_endpoint.Rnw`**: Sweave document for LaTeX-based reporting
- **`actual data/Primary_endpoint_data.rda`**: Clinical trial dataset containing patient-level data
- **`reproduced_tf/`**: Directory containing reproduced tables and figures as PNG files

## Authors

- Jifan
- Minoo  
- Yazid

## Reference

Rödel, C., et al. (2015). Oxaliplatin added to fluorouracil-based preoperative chemoradiotherapy and postoperative chemotherapy of locally advanced rectal cancer (the German CAO/ARO/AIO-04 study): final results of the multicentre, open-label, randomised, phase 3 trial. *The Lancet*, 385(9967), 1027-1038.

## License

See LICENSE file for details.

---

*This project was developed as part of a datathlon to demonstrate reproducible research practices in clinical trial analysis.*