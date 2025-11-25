withr::local_envvar(VITALS_LOG_DIR = "inst/runs/logs")
devtools::load_all()

tsk <- helper_task(epochs = 10)

tsk_gemini_2_5_flash <- tsk$clone()
tsk_gemini_2_5_flash$eval(
  solver_chat = ellmer::chat_openrouter(model = "google/gemini-2.5-flash")
)

save(tsk_gemini_2_5_flash, file = "inst/runs/tasks/tsk_gemini_2_5_flash.rda")
