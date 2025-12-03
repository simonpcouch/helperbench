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
  select(-id) %>%
  unnest(metadata) %>%
  rowwise() %>%
  mutate(
    tokens = list(solver_chat$get_tokens()),
    input = sum(tokens$input),
    output = sum(tokens$output)
  ) %>%
  ungroup() %>%
  select(model, input, output, score) %>%
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
      model == "qwen_3_14b" ~ "Qwen 3 14B"
    ),
    type = case_when(
      model %in% c("Claude Sonnet 4.5", "Gemini Pro 2.5", "GPT-4.1") ~ "Frontier",
      model %in% c("Claude Haiku 4.5", "Gemini Flash 2.5", "GPT-4.1 Mini") ~ "Budget",
      model %in% c("GPT OSS 20B", "Mistral 3.1 24B", "Qwen 3 14B") ~ "Local"
    ),
    cost_input = case_when(
      model == "Claude Haiku 4.5" ~ 1,
      model == "Claude Sonnet 4.5" ~ 3,
      model == "Gemini Flash 2.5" ~ 0.30,
      model == "Gemini Pro 2.5" ~ 1.25,
      model == "GPT-4.1 Mini" ~ 0.40,
      model == "GPT-4.1" ~ 2,
      model == "GPT OSS 20B" ~ 0.03,
      model == "Mistral 3.1 24B" ~ 0.03,
      model == "Qwen 3 14B" ~ 0.06
    ),
    cost_output = case_when(
      model == "Claude Haiku 4.5" ~ 5,
      model == "Claude Sonnet 4.5" ~ 15,
      model == "Gemini Flash 2.5" ~ 2.50,
      model == "Gemini Pro 2.5" ~ 10,
      model == "GPT-4.1 Mini" ~ 1.60,
      model == "GPT-4.1" ~ 8,
      model == "GPT OSS 20B" ~ 0.14,
      model == "Mistral 3.1 24B" ~ 0.11,
      model == "Qwen 3 14B" ~ 0.25
    ),
    cost = (input / 1e6) * cost_input + (output / 1e6) * cost_output
  ) %>%
  select(-cost_input, -cost_output) %>%
  relocate(c(input, output), .after = everything())

usethis::use_data(helper_results, overwrite = TRUE)
