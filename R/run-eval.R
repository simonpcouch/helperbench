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
write_eval_file <- function(client, name, epochs = 10) {
  dir.create("inst/runs/scripts", recursive = TRUE, showWarnings = FALSE)
  file <- file.path("inst/runs/scripts", paste0(name, ".R"))

  script <- glue::glue(
    '
withr::local_envvar(VITALS_LOG_DIR = "inst/runs/logs")
devtools::load_all()

tsk <- helper_task(epochs = {epochs})

tsk_{name} <- tsk$clone()
tsk_{name}$eval(
  solver_chat = {client}
)

save(tsk_{name}, file = "inst/runs/tasks/tsk_{name}.rda")
'
  )

  writeLines(script, file)

  file
}

clients_to_evaluate <- function() {
  tibble::tribble(
    ~client                                                                       , ~name               ,
    'ellmer::chat_openrouter(model = "google/gemini-2.5-pro")'                    , "gemini_2_5_pro"    ,
    'ellmer::chat_openrouter(model = "google/gemini-2.5-flash")'                  , "gemini_2_5_flash"  ,
    'ellmer::chat_openrouter(model = "anthropic/claude-sonnet-4.5")'              , "claude_4_5_sonnet" ,
    'ellmer::chat_openrouter(model = "anthropic/claude-haiku-4.5")'               , 'claude_4_5_haiku'  ,
    'ellmer::chat_openrouter(model = "openai/gpt-4.1")'                           , 'gpt_4_1'           ,
    'ellmer::chat_openrouter(model = "openai/gpt-4.1-mini")'                      , 'gpt_4_1_mini'      ,
    'ellmer::chat_openrouter(model = "openai/gpt-oss-20b")'                       , 'gpt_oss_20b'       ,
    'ellmer::chat_openrouter(model = "qwen/qwen3-14b")'                           , 'qwen_3_14b'        ,
    'ellmer::chat_openrouter(model = "qwen/qwen3.5-35b-a3b")'                     , 'qwen_3_5_35b_a3b'  ,
    'ellmer::chat_openrouter(model = "mistralai/mistral-small-3.1-24b-instruct")' , 'mistral_3_1_24b'   ,
    'ellmer::chat_openai_compatible(base_url = paste0(Sys.getenv("GEMMA4_BASE_URL"), "/v1"), model = "google/gemma-4-26B-A4B-it", credentials = function() Sys.getenv("BASETEN_API_KEY"))' , 'gemma_4_26b_a4b'
  )
}

write_all_eval_files <- function(clients = clients_to_evaluate(), epochs = 10) {
  purrr::walk2(
    clients$client,
    clients$name,
    ~ write_eval_file(.x, .y, epochs = epochs)
  )

  cli::cli_alert_success(
    "Wrote {nrow(clients)} eval scripts to inst/runs/scripts"
  )
}

wipe_logs <- function() {
  unlink("inst/runs/logs", recursive = TRUE)
  unlink("inst/runs/tasks", recursive = TRUE)
  unlink("inst/runs/progress", recursive = TRUE)

  dir.create("inst/runs/logs")
  dir.create("inst/runs/tasks")
  dir.create("inst/runs/progress")

  unlink("inst/solver", recursive = TRUE)
  dir.create("inst/solver")
}

helper_view <- function() {
  vitals::vitals_view("inst/runs/logs")
}
