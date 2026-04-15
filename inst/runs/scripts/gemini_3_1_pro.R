withr::local_envvar(VITALS_LOG_DIR = "inst/runs/logs")
devtools::load_all()

tsk <- helper_task(epochs = 10)

tsk_gemini_3_1_pro <- tsk$clone()
tsk_gemini_3_1_pro$eval(
  solver_chat = ellmer::chat_openrouter(model = "google/gemini-3.1-pro-preview", api_args = list(reasoning = list(effort = "medium")))
)

save(tsk_gemini_3_1_pro, file = "inst/runs/tasks/tsk_gemini_3_1_pro.rda")
