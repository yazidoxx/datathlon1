# Load required libraries
if (!require("flextable")) install.packages("flextable", repos = "https://cloud.r-project.org")

# Load the data
load("actual data/Primary_endpoint_data.rda")

# Define the groups
investigational_group <- CAOsurv$randarm == "5-FU + Oxaliplatin" # investigational group
control_group <- CAOsurv$randarm == "5-FU" # control group

# Count the number of subjects in each group
n_investigational <- sum(investigational_group)
n_control <- sum(control_group)

# Function to check if a date column is not NA (meaning death occurred)
has_death <- function(x) {
  return(!is.na(x))
}

# Calculate all-cause deaths
all_cause_deaths_inv <- sum(has_death(CAOsurv$Tod[investigational_group]))
all_cause_deaths_ctrl <- sum(has_death(CAOsurv$Tod[control_group]))

# Calculate deaths by cause
rectal_cancer_deaths_inv <- sum(CAOsurv$COD[investigational_group] == "Tumor", na.rm = TRUE)
rectal_cancer_deaths_ctrl <- sum(CAOsurv$COD[control_group] == "Tumor", na.rm = TRUE)

toxicity_deaths_inv <- sum(CAOsurv$COD[investigational_group] == "Tox", na.rm = TRUE)
toxicity_deaths_ctrl <- sum(CAOsurv$COD[control_group] == "Tox", na.rm = TRUE)

postop_deaths_inv <- sum(CAOsurv$COD[investigational_group] == "post-OP", na.rm = TRUE)
postop_deaths_ctrl <- sum(CAOsurv$COD[control_group] == "post-OP", na.rm = TRUE)

secondary_malignancy_deaths_inv <- sum(CAOsurv$COD[investigational_group] == "zweittumor", na.rm = TRUE)
secondary_malignancy_deaths_ctrl <- sum(CAOsurv$COD[control_group] == "zweittumor", na.rm = TRUE)

intercurrent_disease_deaths_inv <- sum(CAOsurv$COD[investigational_group] == "sonstige", na.rm = TRUE)
intercurrent_disease_deaths_ctrl <- sum(CAOsurv$COD[control_group] == "sonstige", na.rm = TRUE)

# For unknown/missing, we count:
# 1. Those marked as "unklar" (unknown)
# 2. Those who died (Tod is not NA) but have no cause of death (COD is NA)
unknown_deaths_inv <- sum(CAOsurv$COD[investigational_group] == "unklar", na.rm = TRUE)
unknown_deaths_ctrl <- sum(CAOsurv$COD[control_group] == "unklar", na.rm = TRUE)

missing_deaths_inv <- sum(has_death(CAOsurv$Tod[investigational_group]) & is.na(CAOsurv$COD[investigational_group]))
missing_deaths_ctrl <- sum(has_death(CAOsurv$Tod[control_group]) & is.na(CAOsurv$COD[control_group]))

unknown_missing_deaths_inv <- unknown_deaths_inv + missing_deaths_inv
unknown_missing_deaths_ctrl <- unknown_deaths_ctrl + missing_deaths_ctrl

# Create a function to format the count and percentage
format_count_pct <- function(count, total) {
  # Ensure we have valid numbers
  if (is.na(count) || is.na(total) || total == 0) {
    return("0 (0%)")
  }
  
  pct <- round(count / total * 100)
  if (pct < 1 && count > 0) {
    return(paste0(count, " (<1%)"))
  } else {
    return(paste0(count, " (", pct, "%)"))
  }
}

# Create the data structure for the table
table_data <- data.frame(
  Cause = c("All-cause deaths", 
            "Rectal cancer", 
            "Toxicity from neoadjuvant or adjuvant chemotherapy",
            "Postoperative death within 60 days after surgery", 
            "Secondary malignancy",
            "Intercurrent disease", 
            "Unknown or missing"),
  Investigational = c(
    format_count_pct(all_cause_deaths_inv, n_investigational),
    format_count_pct(rectal_cancer_deaths_inv, n_investigational),
    format_count_pct(toxicity_deaths_inv, n_investigational),
    format_count_pct(postop_deaths_inv, n_investigational),
    format_count_pct(secondary_malignancy_deaths_inv, n_investigational),
    format_count_pct(intercurrent_disease_deaths_inv, n_investigational),
    format_count_pct(unknown_missing_deaths_inv, n_investigational)
  ),
  Control = c(
    format_count_pct(all_cause_deaths_ctrl, n_control),
    format_count_pct(rectal_cancer_deaths_ctrl, n_control),
    format_count_pct(toxicity_deaths_ctrl, n_control),
    format_count_pct(postop_deaths_ctrl, n_control),
    format_count_pct(secondary_malignancy_deaths_ctrl, n_control),
    format_count_pct(intercurrent_disease_deaths_ctrl, n_control),
    format_count_pct(unknown_missing_deaths_ctrl, n_control)
  )
)

# Print the table
cat("Table 3: Intention-to-treat analysis of all-cause deaths\n\n")
cat(sprintf("%-45s %-25s %-25s\n", "", 
           paste0("Investigational group (n=", n_investigational, ")"),
           paste0("Control group (n=", n_control, ")")))
cat(paste(rep("-", 95), collapse = ""), "\n")
for (i in 1:nrow(table_data)) {
  cat(sprintf("%-45s %-25s %-25s\n", table_data$Cause[i], table_data$Investigational[i], table_data$Control[i]))
}
cat(paste(rep("-", 95), collapse = ""), "\n")

# Create column headers with group sizes
colnames(table_data) <- c("Cause", 
                         paste0("Investigational\ngroup (n=", n_investigational, ")"),
                         paste0("Control\ngroup (n=", n_control, ")"))

# Create a flextable
ft <- flextable::flextable(table_data)
ft <- flextable::set_caption(ft, caption = "Table 3: Intention-to-treat analysis of all-cause deaths")

# Format the table
ft <- flextable::theme_vanilla(ft)
ft <- flextable::bg(ft, bg = "#f8ecec")
ft <- flextable::bg(ft, bg = "#e0e0e0", part = "header")  # Light grey header
ft <- flextable::bold(ft, part = "header")
ft <- flextable::align(ft, align = "left", part = "all")
ft <- flextable::padding(ft, padding = 5, part = "all")
ft <- flextable::autofit(ft)
ft <- flextable::width(ft, width = c(3, 1.5, 1.5))

# Add footer with bold title
ft <- flextable::add_footer_row(ft, values = "Table 3: Intention-to-treat analysis of all-cause deaths", colwidths = 3)
ft <- flextable::bold(ft, bold = TRUE, part = "footer")
ft <- flextable::bg(ft, bg = "white", part = "footer")

# Save the table as an image
flextable::save_as_image(ft, path = "reproduced_tf/table3.png", zoom = 2, expand = 0)

print("Table 3 has been reproduced and saved to PNG format in the reproduced_tf folder.")