withr::local_envvar(VITALS_LOG_DIR = "inst/runs/logs")
devtools::load_all()

tsk <- helper_task(epochs = 10)

tsk_gemini_2_5_pro <- tsk$clone()
tsk_gemini_2_5_pro$eval(
  solver_chat = ellmer::chat_openrouter(model = "google/gemini-2.5-pro")
)

save(tsk_gemini_2_5_pro, file = "inst/runs/tasks/tsk_gemini_2_5_pro.rda")
