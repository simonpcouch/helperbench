withr::local_envvar(VITALS_LOG_DIR = "inst/runs/logs")
devtools::load_all()

tsk <- helper_task(epochs = 10)

tsk_lfm_2_5_2_6b <- tsk$clone()
tsk_lfm_2_5_2_6b$eval(
  solver_chat = ellmer::chat_ollama(
    model = "lfm2.5-2.6b-q4",
    api_args = list(reasoning_effort = "medium")
  ),
  delay = 0
)

save(tsk_lfm_2_5_2_6b, file = "inst/runs/tasks/tsk_lfm_2_5_2_6b.rda")
