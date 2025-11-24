the <- rlang::new_environment()

#' Write evaluation script
#'
#' Creates a script that runs an evaluation with a specified client and saves
#' the result. The script is written to a temporary file and can be executed
#' in a separate R process.
#'
#' @param client Character string containing code to initialize an ellmer Chat
#'   client, e.g. 'ellmer::chat_anthropic(model = "claude-sonnet-4-5-20250929")'.
#' @param name Character string used as the name for the task object and saved
#'   file, e.g. "claude_4_5_sonnet".
#'
#' @return Character string containing the path to the generated script file.
#' @noRd
#' @examples
#' script <- write_eval_script('ellmer::chat_anthropic(model = "claude-sonnet-4-5")', 'claude_4_5_sonnet')
#' 
#' file.edit(script)
#' 
#' source(script)
#' 
#' # To run the full evaluation script, use 
#' run_evals(epochs = 20)
write_eval_script <- function(client, name, epochs = 1, calling_wd = getwd(), progress_file = NULL) {
  if (is.null(progress_file)) {
    progress_file <- file.path(calling_wd, "inst", "runs", "progress", paste0(name, ".txt"))
  }

  script <- glue::glue('
withr::local_dir("{calling_wd}")

withr::local_envvar(VITALS_LOG_DIR = "inst/runs/logs")
devtools::load_all()

progress_file <- "{progress_file}"
dir.create(dirname(progress_file), recursive = TRUE, showWarnings = FALSE)
writeLines("0", progress_file)

tsk <- helper_task(epochs = {epochs})

tsk_{name} <- tsk$clone()
tsk_{name}$eval(
  solver_chat = {client},
  progress_file = progress_file
)

save(tsk_{name}, file = "inst/runs/tasks/tsk_{name}.rda")
')

  temp_file <- tempfile(pattern = paste0("eval_", name, "_"), fileext = ".R")
  writeLines(script, temp_file)

  temp_file
}

clients_to_evaluate <- function() {
  tibble::tribble(
    ~client, ~name,
    # 'ellmer::chat_claude(model = "claude-sonnet-4-5")', "claude_4_5_sonnet",
    # 'ellmer::chat_claude(model = "claude-haiku-4-5")', 'claude_4_5_haiku',
    # 'ellmer::chat_openai(model = "gpt-4.1")', 'gpt_4_1',
    # 'ellmer::chat_openai(model = "gpt-4.1-mini")', 'gpt_4_1_mini',
    'ellmer::chat_openrouter(model = "anthropic/claude-sonnet-4.5")', "claude_4_5_sonnet_openrouter",
    'ellmer::chat_openrouter(model = "anthropic/claude-haiku-4-5")', 'claude_4_5_haiku_openrouter',
    'ellmer::chat_openrouter(model = "openai/gpt-4.1")', 'gpt_4_1_openrouter',
    'ellmer::chat_openrouter(model = "openai/gpt-4.1-mini")', 'gpt_4_1_mini_openrouter',
    'ellmer::chat_openrouter(model = "openai/gpt-oss-20b")', 'gpt_oss_20b',
    'ellmer::chat_openrouter(model = "qwen/qwen3-coder-30b-a3b-instruct")', 'qwen_3_coder_30b',
    'ellmer::chat_openrouter(model = "mistralai/mistral-small-3.1-24b-instruct")', 'mistral_3_1_24b'
  )
}

monitor_eval_progress <- function(progress_files, processes, total_epochs, poll_interval = 0.5) {
  env <- rlang::current_env()
  cli::cli_progress_bar("Running evaluations", total = total_epochs, .envir = env, auto_terminate = FALSE)

  while (any(purrr::map_lgl(processes, ~.$is_alive()))) {
    current_total <- sum(purrr::map_dbl(progress_files, function(f) {
      if (file.exists(f)) {
        as.numeric(readLines(f, warn = FALSE))
      } else {
        0
      }
    }))

    cli::cli_progress_update(set = current_total, .envir = env)
    Sys.sleep(poll_interval)
  }

  cli::cli_progress_done(.envir = env)

  purrr::walk(progress_files, function(f) {
    if (file.exists(f)) unlink(f)
  })
}

run_evals <- function(clients = clients_to_evaluate(), epochs = 1) {
  calling_wd <- getwd()
  progress_dir <- file.path(calling_wd, "inst", "runs", "progress")
  dir.create(progress_dir, recursive = TRUE, showWarnings = FALSE)

  progress_files <- file.path(progress_dir, paste0(clients$name, ".txt"))

  scripts <- purrr::pmap(
    list(
      clients$client,
      clients$name,
      epochs,
      calling_wd = calling_wd,
      progress_file = progress_files
    ),
    write_eval_script
  )

  processes <- purrr::map(scripts, function(script) {
    callr::r_bg(
      function(script) source(script),
      args = list(script = script),
      supervise = TRUE
    )
  })

  the$processes <- processes

  total_epochs <- nrow(clients) * epochs

  monitor_eval_progress(progress_files, processes, total_epochs)
}

wipe_logs <- function() {
  unlink("inst/runs", recursive = TRUE)
  dir.create("inst/runs")
  dir.create("inst/runs/logs")
  dir.create("inst/runs/tasks")
  dir.create("inst/runs/progress")

  unlink("inst/solver", recursive = TRUE)
  dir.create("inst/solver")
}

helper_view <- function() {
  vitals::vitals_view("inst/runs/logs")
}
