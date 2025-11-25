library(tidyverse)

process_results <- function() {
  task_files <- list.files("inst/runs/tasks", full.names = TRUE)

  load_object <- function(file) {
    tmp <- new.env()
    load(file = file, envir = tmp)
    tmp[[ls(tmp)[1]]]
  }

  tasks <- list()
  for (task in task_files) {
    tasks[[gsub(".rda", "", basename(task))]] <- load_object(task)
  }
  names(tasks) <- gsub("tsk_", "", names(tasks))

  vitals::vitals_bind(!!!tasks)
}


helper_results_raw <- process_results()

helper_results <-
  helper_results_raw %>%
  rename(model = task) %>%
  select(-id, -metadata) %>%
  mutate(
    model = case_when(
      model == "claude_4_5_haiku" ~ "Claude Haiku 4.5",
      model == "claude_4_5_sonnet" ~ "Claude Sonnet 4.5",
      model == "gemini_2_5_flash" ~ "Gemini Flash 2.5",
      model == "gemini_2_5_pro" ~ "Gemini Pro 2.5",
      model == "gpt_4_1_mini" ~ "GPT-4.1 Mini",
      model == "gpt_4_1" ~ "GPT-4.1",
      model == "gpt_oss_20b" ~ "GPT OSS 20B",
      model == "mistral_3_1_24b" ~ "Mistral 3.1 24B",
      model == "qwen_3_coder_30b" ~ "Qwen Coder 3 30B"
    ),
    type = case_when(
      model %in% c("Claude Sonnet 4.5", "Gemini Pro 2.5", "GPT-4.1") ~ "Frontier",
      model %in% c("Claude Haiku 4.5", "Gemini Flash 2.5", "GPT-4.1 Mini") ~ "Budget",
      model %in% c("GPT OSS 20B", "Mistral 3.1 24B", "Qwen Coder 3 30B") ~ "Local"
    )
  )

usethis::use_data(helper_results, overwrite = TRUE)
