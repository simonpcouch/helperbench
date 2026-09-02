withr::local_envvar(VITALS_LOG_DIR = "inst/runs/logs")
devtools::load_all()

tsk <- helper_task(epochs = 10)

tsk_granite_4_2_3b <- tsk$clone()
tsk_granite_4_2_3b$eval(
  solver_chat = ellmer::chat_ollama(
    model = "granite4.2:3b-helperbench",
    api_args = list(reasoning_effort = "low")
  ),
  delay = 0
)

save(tsk_granite_4_2_3b, file = "inst/runs/tasks/tsk_granite_4_2_3b.rda")
