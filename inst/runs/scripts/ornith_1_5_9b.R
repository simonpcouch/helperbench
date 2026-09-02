withr::local_envvar(VITALS_LOG_DIR = "inst/runs/logs")
devtools::load_all()

tsk <- helper_task(epochs = 10)

tsk_ornith_1_5_9b <- tsk$clone()
tsk_ornith_1_5_9b$eval(
  solver_chat = ellmer::chat_ollama(
    model = "ornith-1.5-9b-q4",
    api_args = list(reasoning_effort = "medium")
  ),
  delay = 0
)

save(tsk_ornith_1_5_9b, file = "inst/runs/tasks/tsk_ornith_1_5_9b.rda")
