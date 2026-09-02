withr::local_envvar(VITALS_LOG_DIR = "inst/runs/logs")
devtools::load_all()

tsk <- helper_task(epochs = 10)

tsk_granite_4_2_8b <- tsk$clone()
tsk_granite_4_2_8b$eval(
  solver_chat = ellmer::chat_ollama(
    model = "granite4.2:8b",
    params = ellmer::params(reasoning_effort = "medium")
  ),
  delay = 0
)

save(tsk_granite_4_2_8b, file = "inst/runs/tasks/tsk_granite_4_2_8b.rda")
