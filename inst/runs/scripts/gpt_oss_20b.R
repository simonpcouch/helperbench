withr::local_envvar(VITALS_LOG_DIR = "inst/runs/logs")
devtools::load_all()

tsk <- helper_task(epochs = 10)

tsk_gpt_oss_20b <- tsk$clone()
tsk_gpt_oss_20b$eval(
  solver_chat = ellmer::chat_openrouter(model = "openai/gpt-oss-20b")
)

save(tsk_gpt_oss_20b, file = "inst/runs/tasks/tsk_gpt_oss_20b.rda")
