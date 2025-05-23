# Install and load required packages
if (!require("flextable")) install.packages("flextable")
if (!require("dplyr")) install.packages("dplyr")
if (!require("officer")) install.packages("officer")
if (!require("survival")) install.packages("survival")

library(flextable)
library(dplyr)
library(officer)
library(survival)

# Create directory for output if it doesn't exist
dir.create("reproduced_tf", showWarnings = FALSE)

# Load and examine data
tryCatch({
  # Load data
  load("actual data/Primary_endpoint_data.rda")
  print("Data loaded successfully")
  
  # Examine key variables
  print("Treatment groups:")
  print(table(as.character(CAOsurv$randarm)))
  
  print("Location categories:")
  print(table(as.character(CAOsurv$bentf)))
  
  print("Histology categories:")
  print(table(as.character(CAOsurv$histo)))
  
  print("T categories:")
  print(table(as.character(CAOsurv$gesamt_t)))
  
  print("N categories:")
  print(table(as.character(CAOsurv$gesamt_n)))
  
}, error = function(e) {
  stop("Error examining data: ", e$message)
})

# Function to calculate percentages
calc_percent <- function(n, total) {
  n_sum <- sum(n, na.rm=TRUE)
  pct <- 100 * n_sum/total
  if (pct < 1 && pct > 0) {
    sprintf("%.0f (<1%%)", n_sum)
  } else {
    sprintf("%.0f (%.0f%%)", n_sum, round(pct))
  }
}

# Function to calculate statistics for numeric variables
calc_stats <- function(x) {
  if(all(is.na(x))) {
    return(list(mean_sd="NA (NA)", median_iqr="NA (NA-NA)"))
  }
  mean_sd <- sprintf("%.0f (%.0f)", mean(x, na.rm=TRUE), sd(x, na.rm=TRUE))
  q <- quantile(x, c(0.25, 0.5, 0.75), na.rm=TRUE)
  median_iqr <- sprintf("%.0f (%.0f-%.0f)", q[2], q[1], q[3])
  return(list(mean_sd=mean_sd, median_iqr=median_iqr))
}

# Function to map location categories
map_location <- function(bentf) {
  case_when(
    bentf == "< 6cm" ~ "0-5 cm",
    bentf == "6 - 10cm" ~ ">5-10 cm",
    bentf == ">10cm" ~ ">10 cm",
    TRUE ~ NA_character_
  )
}

# Function to map histology categories
map_histology <- function(histo) {
  case_when(
    histo == "Adeno-Ca." ~ "Adenocarcinoma",
    histo == "muzinöses Adeno-Ca." ~ "Mucinous adenocarcinoma",
    histo == "Siegelringkarzinom" ~ "Signet-ring cell carcinoma",
    histo %in% c("andere", "undifferenziertes Ca.") ~ "Other",
    TRUE ~ NA_character_
  )
}

# Function to map N categories
map_n_category <- function(n_cat) {
  case_when(
    n_cat == "cN0" | n_cat == "negativ" ~ "cN0",
    n_cat %in% c("cN1", "cN2", "positiv") ~ "cN1-2",
    TRUE ~ NA_character_
  )
}

# Function to map UICC stage
map_uicc_stage <- function(t_stage, n_stage) {
  n_stage_mapped <- map_n_category(n_stage)
  case_when(
    n_stage_mapped == "cN0" ~ "Stage II",
    n_stage_mapped == "cN1-2" & t_stage %in% c("cT1", "cT2") ~ "cT1-2 N1-2",
    n_stage_mapped == "cN1-2" & t_stage %in% c("cT3", "cT4") ~ "cT3-4 N1-2",
    TRUE ~ NA_character_
  )
}

# Create the base table structure
table1_data <- data.frame(
  Characteristic = c(
    "Age (years)", "Mean (SD)", "Median (IQR)",
    "Sex", "Male", "Female",
    "ECOG performance status", "0", "1-2", "Missing",
    "Clinical T category", "cT2", "cT3", "cT4", "Missing",
    "Clinical N category", "cN0", "cN1-2", "Missing",
    "Clinical disease stage", "Stage II", "Stage III", "  cT1-2 N1-2", "  cT3-4 N1-2", "Missing",
    "Location from anal verge", "0-5 cm", ">5-10 cm", ">10 cm", "Missing",
    "Histology", "Adenocarcinoma", "Mucinous adenocarcinoma", "Signet-ring cell carcinoma", "Other or missing",
    "Tumour differentiation", "Well differentiated (G1)", "Moderately differentiated (G2)", 
    "Poorly differentiated (G3)", "Missing data"
  ),
  stringsAsFactors = FALSE
)

# Calculate statistics for both groups
tryCatch({
  # Split data into investigational and control groups
  investigational <- CAOsurv$randarm == "5-FU + Oxaliplatin"
  control <- CAOsurv$randarm == "5-FU"
  
  print("Number of patients in each group:")
  print(paste("Investigational:", sum(investigational)))
  print(paste("Control:", sum(control)))
  
  n_investigational <- sum(investigational)
  n_control <- sum(control)
  
  # Print tumor differentiation distribution
  print("Tumor differentiation distribution:")
  print("Control group:")
  print(table(CAOsurv$grading_b[control]))
  print("Missing in control:", sum(is.na(CAOsurv$grading_b[control])))
  print("\nInvestigational group:")
  print(table(CAOsurv$grading_b[investigational]))
  print("Missing in investigational:", sum(is.na(CAOsurv$grading_b[investigational])))
  
  # Map categories
  CAOsurv$location <- map_location(CAOsurv$bentf)
  CAOsurv$histology <- map_histology(CAOsurv$histo)
  CAOsurv$n_category <- map_n_category(CAOsurv$gesamt_n)
  CAOsurv$stage <- map_uicc_stage(CAOsurv$gesamt_t, CAOsurv$gesamt_n)
  
  # Print stage distribution for debugging
  print("Stage distribution:")
  stage_dist <- table(CAOsurv$stage)
  print(stage_dist)
  
  # Print detailed stage information
  print("Detailed stage information:")
  print("T categories by N categories:")
  print(table(CAOsurv$gesamt_t, CAOsurv$gesamt_n))
  print("T categories by mapped N categories:")
  print(table(CAOsurv$gesamt_t, CAOsurv$n_category))
  print("Stage distribution by treatment group:")
  print(table(CAOsurv$stage, CAOsurv$randarm))
  
  # Calculate statistics for each group
  stats_investigational <- c(
    "", 
    calc_stats(CAOsurv$age[investigational])$mean_sd,
    calc_stats(CAOsurv$age[investigational])$median_iqr,
    "",
    calc_percent(CAOsurv$geschlecht[investigational] == "männlich", n_investigational),
    calc_percent(CAOsurv$geschlecht[investigational] == "weiblich", n_investigational),
    "",
    calc_percent(CAOsurv$ecog_b[investigational] == "Grad 0", n_investigational),
    calc_percent(CAOsurv$ecog_b[investigational] %in% c("Grad 1", "Grad 2"), n_investigational),
    calc_percent(is.na(CAOsurv$ecog_b[investigational]), n_investigational),
    "",
    calc_percent(CAOsurv$gesamt_t[investigational] == "cT2", n_investigational),
    calc_percent(CAOsurv$gesamt_t[investigational] == "cT3", n_investigational),
    calc_percent(CAOsurv$gesamt_t[investigational] == "cT4", n_investigational),
    calc_percent(is.na(CAOsurv$gesamt_t[investigational]), n_investigational),
    "",
    calc_percent(CAOsurv$n_category[investigational] == "cN0", n_investigational),
    calc_percent(CAOsurv$n_category[investigational] == "cN1-2", n_investigational),
    calc_percent(is.na(CAOsurv$n_category[investigational]), n_investigational),
    "",
    calc_percent(CAOsurv$stage[investigational] == "Stage II", n_investigational),
    "",  # Empty string for Stage III header
    calc_percent(CAOsurv$stage[investigational] == "cT1-2 N1-2", n_investigational),
    calc_percent(CAOsurv$stage[investigational] == "cT3-4 N1-2", n_investigational),
    calc_percent(is.na(CAOsurv$stage[investigational]), n_investigational),
    "",
    calc_percent(CAOsurv$location[investigational] == "0-5 cm", n_investigational),
    calc_percent(CAOsurv$location[investigational] == ">5-10 cm", n_investigational),
    calc_percent(CAOsurv$location[investigational] == ">10 cm", n_investigational),
    calc_percent(is.na(CAOsurv$location[investigational]), n_investigational),
    "",
    calc_percent(CAOsurv$histology[investigational] == "Adenocarcinoma", n_investigational),
    calc_percent(CAOsurv$histology[investigational] == "Mucinous adenocarcinoma", n_investigational),
    calc_percent(CAOsurv$histology[investigational] == "Signet-ring cell carcinoma", n_investigational),
    calc_percent(CAOsurv$histology[investigational] %in% c("Other", NA), n_investigational),
    "",
    calc_percent(CAOsurv$grading_b[investigational] == "G1", n_investigational),
    calc_percent(CAOsurv$grading_b[investigational] == "G2", n_investigational),
    calc_percent(CAOsurv$grading_b[investigational] == "G3", n_investigational),
    calc_percent(is.na(CAOsurv$grading_b[investigational]) | 
                 CAOsurv$grading_b[investigational] == "" | 
                 CAOsurv$grading_b[investigational] == "unbekannt" |
                 CAOsurv$grading_b[investigational] == "G2 und G3", n_investigational)
  )
  
  stats_control <- c(
    "", 
    calc_stats(CAOsurv$age[control])$mean_sd,
    calc_stats(CAOsurv$age[control])$median_iqr,
    "",
    calc_percent(CAOsurv$geschlecht[control] == "männlich", n_control),
    calc_percent(CAOsurv$geschlecht[control] == "weiblich", n_control),
    "",
    calc_percent(CAOsurv$ecog_b[control] == "Grad 0", n_control),
    calc_percent(CAOsurv$ecog_b[control] %in% c("Grad 1", "Grad 2"), n_control),
    calc_percent(is.na(CAOsurv$ecog_b[control]), n_control),
    "",
    calc_percent(CAOsurv$gesamt_t[control] == "cT2", n_control),
    calc_percent(CAOsurv$gesamt_t[control] == "cT3", n_control),
    calc_percent(CAOsurv$gesamt_t[control] == "cT4", n_control),
    calc_percent(is.na(CAOsurv$gesamt_t[control]), n_control),
    "",
    calc_percent(CAOsurv$n_category[control] == "cN0", n_control),
    calc_percent(CAOsurv$n_category[control] == "cN1-2", n_control),
    calc_percent(is.na(CAOsurv$n_category[control]), n_control),
    "",
    calc_percent(CAOsurv$stage[control] == "Stage II", n_control),
    "",  # Empty string for Stage III header
    calc_percent(CAOsurv$stage[control] == "cT1-2 N1-2", n_control),
    calc_percent(CAOsurv$stage[control] == "cT3-4 N1-2", n_control),
    calc_percent(is.na(CAOsurv$stage[control]), n_control),
    "",
    calc_percent(CAOsurv$location[control] == "0-5 cm", n_control),
    calc_percent(CAOsurv$location[control] == ">5-10 cm", n_control),
    calc_percent(CAOsurv$location[control] == ">10 cm", n_control),
    calc_percent(is.na(CAOsurv$location[control]), n_control),
    "",
    calc_percent(CAOsurv$histology[control] == "Adenocarcinoma", n_control),
    calc_percent(CAOsurv$histology[control] == "Mucinous adenocarcinoma", n_control),
    calc_percent(CAOsurv$histology[control] == "Signet-ring cell carcinoma", n_control),
    calc_percent(CAOsurv$histology[control] %in% c("Other", NA), n_control),
    "",
    calc_percent(CAOsurv$grading_b[control] == "G1", n_control),
    calc_percent(CAOsurv$grading_b[control] == "G2", n_control),
    calc_percent(CAOsurv$grading_b[control] == "G3", n_control),
    calc_percent(is.na(CAOsurv$grading_b[control]) | 
                 CAOsurv$grading_b[control] == "" | 
                 CAOsurv$grading_b[control] == "unbekannt" |
                 CAOsurv$grading_b[control] == "G2 und G3", n_control)
  )
  
  # Add statistics to the table
  table1_data$`Investigational group (n=613)` <- stats_investigational
  table1_data$`Control group (n=623)` <- stats_control
  
}, error = function(e) {
  print("Error in calculation:")
  print(e)
  stop(e)
})

# Create and save the flextable
ft <- flextable(table1_data) %>%
  theme_vanilla() %>%
  set_caption("Table 1: Baseline characteristics") %>%
  add_footer_lines("Data are number of patients (%) unless otherwise stated. ECOG=Eastern Cooperative Oncology Group.") %>%
  add_footer_lines("Table 1: Baseline characteristics") %>%  # Add title at bottom
  align(j = 1, align = "left") %>%
  align(j = 2:3, align = "center") %>%
  padding(padding = 4) %>%
  bold(i = c(1,4,7,11,16,20,26,31,36), part = "body") %>%  # Bold the main category headers
  bold(i = 2, part = "footer") %>%  # Bold the title in footer
  fontsize(size = 10) %>%
  width(j = 1, width = 4) %>%
  width(j = 2:3, width = 2) %>%
  border(i = c(1,4,7,11,16,20,26,31,36), border.top = fp_border(color = "gray")) %>%  # Add lines before main categories
  bg(bg = "white", part = "all") %>%  # Set background to white for all parts
  autofit()

# Save as png with higher resolution
save_as_image(ft, path = "reproduced_tf/table1.png", res = 300)

print("Table has been created and saved in the reproduced_tf folder")
