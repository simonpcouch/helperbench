models <- c(
  "ornith-1.5-9b-q4",
  "granite4.2:8b",
  "granite4.2:3b",
  "lfm2.5-2.6b-q4",
  "qwen3.8-4b-distill-q4"
)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) > 0) {
  models <- args
}

riddle <- paste(
  "A man looks at a portrait and says:",
  '"Brothers and sisters I have none, but that man\'s father is',
  'my father\'s son." Who is in the portrait?',
  "Think through the relationships, then answer briefly."
)

check_thinking <- function(model, effort) {
  response <-
    httr2::request("http://localhost:11434/v1/chat/completions") |>
    httr2::req_body_json(list(
      model = model,
      messages = list(list(role = "user", content = riddle)),
      reasoning_effort = effort,
      temperature = 0,
      seed = 42,
      max_tokens = 4096
    )) |>
    httr2::req_timeout(600) |>
    httr2::req_perform()

  body <- httr2::resp_body_json(response, simplifyVector = FALSE)
  message <- body$choices[[1]]$message

  data.frame(
    model = model,
    effort = effort,
    prompt_tokens = body$usage$prompt_tokens,
    completion_tokens = body$usage$completion_tokens,
    reasoning_chars = nchar(message$reasoning %||% ""),
    answer_chars = nchar(message$content %||% "")
  )
}

`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

checks <- expand.grid(
  model = models,
  effort = c("none", "low", "medium", "high"),
  stringsAsFactors = FALSE
)

results <- purrr::map2_dfr(checks$model, checks$effort, check_thinking)

dir.create("inst/runs/thinking", recursive = TRUE, showWarnings = FALSE)
result_path <- "inst/runs/thinking/results.csv"

if (file.exists(result_path)) {
  old_results <- read.csv(result_path, stringsAsFactors = FALSE)
  results <- rbind(old_results, results)
  results <- results[!duplicated(results[c("model", "effort")], fromLast = TRUE), ]
}

write.csv(results, result_path, row.names = FALSE)
print(results)
