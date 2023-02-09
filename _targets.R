
# Load packages required to define the pipeline:

library(targets) # Crucial to any pipeline
suppressMessages(library(tidyverse) )
suppressMessages(library(here))

source(file.path(here(), "functions.R")) # Load functions

# Set target options:

tar_option_set(packages = c("tidyverse", "here"))

list(
  tar_target(file_a, 
             file.path(here(), "dataset_a.csv"),
             format = "file"),
  
  tar_target(file_b, 
             file.path(here(), "dataset_b.rds"),
             format = "file"),  
  
  tar_target(a_raw, read_csv(file_a, show_col_types = FALSE)),
  
  tar_target(b_raw, read_rds(file_b)),
  
  tar_target(a_clean, clean_a(a_raw)),
  
  tar_target(b_clean, clean_b(b_raw)),
  
  tar_target(ab, join_ab(a_clean, b_clean)),
  
  tar_target(qa_message, quality_checks(ab)),
  
  tar_target(summary_stats, summarise_ab(ab))
  
)



