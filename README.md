# CAO/ARO/AIO-04 Clinical Trial Data Analysis

**Reproduction of Rödel et al. (2015) Lancet Study Results**

## Grant Information

**Horizon-MSCA-2022-DN-01**  
**Project: 101120360**

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

### Objectives

**Primary Objective**: Evaluate whether adding oxaliplatin to standard therapy improves disease-free survival (DFS) in patients with locally advanced rectal cancer.

**Secondary Objectives**:
- Overall survival (OS) analysis
- Incidence of local and distant recurrences
- Safety and toxicity profiles
- Subgroup analyses

## Project Structure

```
datathlon1/
├── output.qmd                            # Main Quarto document with complete analysis
├── tables_scripts/                       # Individual R scripts for tables
│   ├── table1_script.r                   # Baseline characteristics
│   ├── table2_script.r                   # Primary endpoint analysis
│   └── table3_script.r                   # Overall survival analysis
├── reproduced_tf/                        # Generated tables and figures (PNG)
│   ├── table1.png
│   ├── table2.png
│   └── table3.png
├── output_files/                         # Generated HTML output and assets
│   ├── figure-html/                      # Generated figures from Quarto
│   └── libs/                            # Bootstrap and other web assets
├── output_cache/                         # Quarto cache files
├── SAP_team1.pdf                        # Statistical Analysis Plan
├── README.md                            # This file
└── LICENSE                              # License information
```

**Note**: The clinical trial dataset (`actual_data/Primary_endpoint_data.rda`) is required but not included in the repository for data privacy reasons.

## Data Requirements

This analysis requires the following data file (not included in repository):
- `actual_data/Primary_endpoint_data.rda` - Main clinical trial dataset containing patient-level data

The dataset should contain the following key data objects:
- `CAOsurv` - Main patient dataset with survival and clinical variables
- `CONSORT` - Trial flow data for CONSORT diagram generation

## Reproduced Tables and Figures

### Tables

- **Table 1**: Baseline Characteristics and Demographics
  - Patient demographics by treatment arm
  - Disease characteristics and stratification factors
  - Clinical staging and tumor characteristics

- **Table 2**: Primary Endpoint Analysis (Disease-Free Survival)
  - Intention-to-treat analysis of first events for DFS
  - Event types and cumulative incidences
  - Statistical comparisons between treatment arms

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
  - Panel A: Locoregional recurrence
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
- R 4.4.3 or compatible version

### Required R Packages

```r
# Core survival analysis
survival
prodlim
coin
coxme

# Data manipulation and visualization
dplyr
ggplot2
survminer
tidycmprsk
ggsurvfit

# Table generation
flextable
knitr
kableExtra

# Additional packages
consort
forestplot
tidyr
here
```

## Usage Instructions

### 1. Data Setup
```r
# Ensure the data file is placed in the correct location:
# actual_data/Primary_endpoint_data.rda
```

### 2. Generate Complete Report
```r
# Render the main Quarto document (recommended)
quarto::quarto_render("output.qmd")
```

### 3. Generate Individual Tables
```r
# Table 1: Baseline characteristics
source("tables_scripts/table1_script.r")

# Table 2: Primary endpoint
source("tables_scripts/table2_script.r")

# Table 3: Overall survival
source("tables_scripts/table3_script.r")
```

### 4. View Generated Output
- Open `output_files/output.html` in a web browser to view the complete analysis
- Individual table images are saved in `reproduced_tf/`

## Key Results

### Primary Endpoint (Disease-Free Survival)

The analysis reproduces the key findings from the original study:
- Stratified log-rank test results for treatment comparison
- Hazard ratios with 95% confidence intervals
- 3-year and 5-year disease-free survival rates
- Kaplan-Meier survival curves matching the original publication

### Reproducibility Notes

- **Median follow-up**: Approximately 4.2 years (IQR: 5 years)
- **Statistical software**: R version 4.4.3 with updated packages
- **Random seed**: Set to 29 for reproducible permutation tests
- **Computational environment**: Modern R setup due to compatibility issues with original R 3.1.2

### Minor Discrepancies

Some minor discrepancies with the original paper were noted:
- **Table 2**: Cumulative locoregional recurrence counts differ slightly (data availability)
- **Figure 1**: Small differences in adjuvant chemotherapy flow numbers
- All primary statistical results (p-values, hazard ratios) match the original publication

## Technical Details

### Session Information
All analyses include comprehensive session information documenting R version, package versions, and computational environment for full reproducibility.

### Version Control
- Package versions documented in analysis output
- Code includes comprehensive comments explaining methodology
- Statistical assumptions and limitations clearly documented

## Authors

- **Jifan Wang**
- **Yazid Zalai** 
- **Minoo Matbouriahi**

## Reference

Rödel, C., et al. (2015). Oxaliplatin added to fluorouracil-based preoperative chemoradiotherapy and postoperative chemotherapy of locally advanced rectal cancer (the German CAO/ARO/AIO-04 study): final results of the multicentre, open-label, randomised, phase 3 trial. *The Lancet*, 385(9967), 1027-1038.

## License

See LICENSE file for details.

---

*This project was developed as part of a datathlon to demonstrate reproducible research practices in clinical trial analysis.*