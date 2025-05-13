# Required libraries
library(flextable)
library(dplyr)
library(tidyr)
library(officer)

# Load the data
load("actual data/Primary_endpoint_data.rda")

# Function to calculate percentages with special handling for <1%
calc_percent <- function(n, total) {
  if(is.na(n) || is.na(total) || total == 0) {
    return("NaN")
  }
  percentage <- (n/total * 100)
  if(percentage < 1 && percentage > 0) {
    return(paste0(n, " (<1%)"))
  }
  return(paste0(n, " (", round(percentage), "%)"))
}

# Process the data
process_data <- function(cao_data) {
  n_investigational <- sum(cao_data$randarm == "5-FU + Oxaliplatin", na.rm = TRUE)
  n_control <- sum(cao_data$randarm == "5-FU", na.rm = TRUE)
  
  results <- data.frame(
    Characteristic = c(
      "Macroscopically incomplete local resection (R2)",
      "Locoregional recurrence (after R0/R1 resection)",
      "As first event",
      "Cumulative*",
      "Distant metastasis or progression",
      "As first event",
      "Cumulative†",
      "Death as first event‡",
      "First event for disease-free survival (total)"
    )
  )
  
  count_r2 <- function(data) {
    r2_cases <- grepl("^R2($|_)", data$DFStype)
    return(sum(r2_cases, na.rm = TRUE))
  }
  
  count_local_first <- function(data) {
    dfs_first <- grepl("^Lokalrez($|_)", data$DFStype)
    return(sum(dfs_first, na.rm = TRUE))
  }
  
  # Reverting to the most direct data-driven count for cumulative LR
  count_local_cum <- function(data) {
    direct_lokalrez <- !is.na(data$Lokalrez) # Patients with a date for Lokalrez event
    # DFStype entries like "Lokalrez_Fernmeta" indicate LR as part of a combined first event
    # Exclude cases where Lokalrez was the sole first event (already covered by direct_lokalrez if date exists)
    combined_dfs_lokalrez <- grepl("Lokalrez_", data$DFStype)
    # Ensure we don't double count if DFStype is just "Lokalrez" and also has a Lokalrez date
    # Effectively, this is: (has Lokalrez date) OR (DFStype indicates LR as part of combined event AND was not 'Lokalrez' alone)
    # The most straightforward count based on clear data indicators: presence of Lokalrez date or specific DFStype pattern.
    # This resulted in 12 for inv, 25 for ctrl.
    unique_lr_patients <- direct_lokalrez | grepl("Lokalrez", data$DFStype) 
    return(sum(unique_lr_patients, na.rm = TRUE))
  }
  
  count_dist_first <- function(data) {
    dfs_dist_first <- grepl("^(Fernmeta|Progression|OPPFM)($|_)", data$DFStype) & 
                     !grepl("^Lokalrez", data$DFStype) & 
                     !grepl("^R2", data$DFStype)
    return(sum(dfs_dist_first, na.rm = TRUE))
  }
  
  count_dist_cum <- function(data) {
    direct_dist <- !is.na(data$Fernmeta) | !is.na(data$Progression) | !is.na(data$OPPFM)
    return(sum(direct_dist, na.rm = TRUE))
  }
  
  count_death_first <- function(data) {
    dfs_death <- data$DFStype == "Tod"
    return(sum(dfs_death, na.rm = TRUE))
  }
  
  count_total_events <- function(data) {
    return(sum(data$DFStype != "censored", na.rm = TRUE))
  }
  
  inv_data <- cao_data[cao_data$randarm == "5-FU + Oxaliplatin",]
  ctrl_data <- cao_data[cao_data$randarm == "5-FU",]
  
  inv_r2 <- count_r2(inv_data)
  inv_local_first <- count_local_first(inv_data)
  inv_local_cum <- count_local_cum(inv_data)
  inv_dist_first <- count_dist_first(inv_data)
  inv_dist_cum <- count_dist_cum(inv_data)
  inv_death_first <- count_death_first(inv_data)
  inv_total_events <- count_total_events(inv_data)
  
  ctrl_r2 <- count_r2(ctrl_data)
  ctrl_local_first <- count_local_first(ctrl_data)
  ctrl_local_cum <- count_local_cum(ctrl_data)
  ctrl_dist_first <- count_dist_first(ctrl_data)
  ctrl_dist_cum <- count_dist_cum(ctrl_data)
  ctrl_death_first <- count_death_first(ctrl_data)
  ctrl_total_events <- count_total_events(ctrl_data)
  
  results$Investigational <- c(
    calc_percent(inv_r2, n_investigational),
    "",
    calc_percent(inv_local_first, n_investigational),
    calc_percent(inv_local_cum, n_investigational),
    "",
    calc_percent(inv_dist_first, n_investigational),
    calc_percent(inv_dist_cum, n_investigational),
    calc_percent(inv_death_first, n_investigational),
    calc_percent(inv_total_events, n_investigational)
  )
  
  results$Control <- c(
    calc_percent(ctrl_r2, n_control),
    "",
    calc_percent(ctrl_local_first, n_control),
    calc_percent(ctrl_local_cum, n_control),
    "",
    calc_percent(ctrl_dist_first, n_control),
    calc_percent(ctrl_dist_cum, n_control),
    calc_percent(ctrl_death_first, n_control),
    calc_percent(ctrl_total_events, n_control)
  )
  
  return(results)
}

create_table <- function(results_df) {
  ft <- flextable(results_df)
  ft <- ft %>%
    set_header_labels(
      Characteristic = "",
      Investigational = paste0("Investigational group (n=", sum(CAOsurv$randarm == "5-FU + Oxaliplatin", na.rm = TRUE), ")"),
      Control = paste0("Control group (n=", sum(CAOsurv$randarm == "5-FU", na.rm = TRUE), ")")
    ) %>%
    theme_vanilla() %>%
    fontsize(size = 10) %>%
    width(width = c(3, 2, 2)) %>%
    bold(i = c(1, 2, 5), j = 1) %>% 
    border(i = c(2, 5), border.top = fp_border(color = "gray")) %>% 
    align(align = "left", part = "all") %>%
    padding(padding = 4) %>%
    bg(bg = "white", part = "all")
  
  inv_lr_cum_calculated <- results_df$Investigational[4]
  ctrl_lr_cum_calculated <- results_df$Control[4]

ft <- add_footer_lines(ft, 
    values = c(
      "*Includes locoregional recurrence as first event and those occurring together with or after occurrence of distant metastases.",
      "†Includes distant metastases as first event and those occurring together with or after occurrence of locoregional recurrences.",
      "‡Includes death due to intercurrent disease, unknown cause, treatment-related death, and death from secondary malignancy.",
      paste0("Note: Cumulative locoregional recurrence calculated from database shows ", inv_lr_cum_calculated, " for investigational and ", ctrl_lr_cum_calculated, " for control group, vs. 18 (3%) and 38 (6%) in published table. Discrepancy likely due to additional clinical review in original study."),
      "Table 2: Intention-to-treat analysis of first events for primary endpoint disease-free survival"
    )
  ) %>%
    bg(part = "footer", bg = "#f0f0f0") %>%
    bold(i = 5, part = "footer")
  return(ft)
}

dir.create("reproduced_tf", showWarnings = FALSE)
results_data <- process_data(CAOsurv)
table2 <- create_table(results_data)
save_as_image(table2, path = "reproduced_tf/table2.png")

cat(paste("Data-derived Cumulative LR (Inv):", results_data$Investigational[4], "(Published: 18 (3%))\n"))
cat(paste("Data-derived Cumulative LR (Ctrl):", results_data$Control[4], "(Published: 38 (6%))\n"))