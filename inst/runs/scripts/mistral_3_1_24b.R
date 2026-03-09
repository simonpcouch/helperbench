withr::local_envvar(VITALS_LOG_DIR = "inst/runs/logs")
devtools::load_all()

tsk <- helper_task(epochs = 10)

tsk_mistral_3_1_24b <- tsk$clone()
tsk_mistral_3_1_24b$eval(
  solver_chat = ellmer::chat_openrouter(
    model = "mistralai/mistral-small-3.1-24b-instruct"
  )
)

save(tsk_mistral_3_1_24b, file = "inst/runs/tasks/tsk_mistral_3_1_24b.rda")
