withr::local_envvar(VITALS_LOG_DIR = "inst/runs/logs")
devtools::load_all()

tsk <- helper_task(epochs = 10)

tsk_gpt_4_1 <- tsk$clone()
tsk_gpt_4_1$eval(
  solver_chat = ellmer::chat_openrouter(model = "openai/gpt-4.1")
)

save(tsk_gpt_4_1, file = "inst/runs/tasks/tsk_gpt_4_1.rda")
