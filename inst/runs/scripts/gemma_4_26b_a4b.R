withr::local_envvar(VITALS_LOG_DIR = "inst/runs/logs")
devtools::load_all()

tsk <- helper_task(epochs = 10)

tsk_gemma_4_26b_a4b <- tsk$clone()
tsk_gemma_4_26b_a4b$eval(
  solver_chat = ellmer::chat_openai_compatible(base_url = paste0(Sys.getenv("GEMMA4_BASE_URL"), "/v1"), model = "google/gemma-4-26B-A4B-it", credentials = function() Sys.getenv("BASETEN_API_KEY"))
)

save(tsk_gemma_4_26b_a4b, file = "inst/runs/tasks/tsk_gemma_4_26b_a4b.rda")
