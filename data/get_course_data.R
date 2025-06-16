# header ------------------------------------------------------------------

# This script accesses the tables stored as Google Sheets which contain
# the course data. Each table is read and stored locally as a CSV.

# library -------------------------------------------------------------------

library(googlesheets4)
library(readr)
library(dplyr)

# script ------------------------------------------------------------------

# course-schedule

# gs4_auth()

link_schedule <- "https://docs.google.com/spreadsheets/d/199p3suC7ZfyP19F6uWaFeCOnZN1Idr8teMJx25c5VBA/edit?gid=264935232#gid=264935232"

googlesheets4::read_sheet(link_schedule) |> 
  mutate(title = case_when(
    is.na(page_link) == FALSE ~  paste0("[", title, "](", page_link, ")"),
    TRUE ~ title
  )) |>
  write_csv(here::here("data/tbl-01-ds4owd-002-course-schedule.csv"))

# learning-objectives

link_learning_objectives <- "https://docs.google.com/spreadsheets/d/1ud0QjaLenVRe4oyUXYuNjbw7yd5De2ryj7fOHn09ljY/edit?gid=623298307#gid=623298307"

googlesheets4::read_sheet(link_learning_objectives) |>
  select(date:learning_objectives) |> 
  write_csv(here::here("data/tbl-02-ds4owd-002-learning-objectives.csv"))

# capstone project

link_project <- "https://docs.google.com/spreadsheets/d/1CZGESzUGO9fWWM15gs_f1NLhB6tmfi_ubX6m7ZbRwL4/edit?gid=0#gid=0"

googlesheets4::read_sheet("18-onMxZi0sBf-fEMR7bR5RuT4Qy4t7D-bZ12gdoNYXI") |> 
  write_csv(here::here("data/tbl-03-ds4owd-002-capstone-project-elements"))


