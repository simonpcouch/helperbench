withr::local_envvar(VITALS_LOG_DIR = "inst/runs/logs")
devtools::load_all()

tsk <- helper_task(epochs = 10)

tsk_gpt_4_1_mini <- tsk$clone()
tsk_gpt_4_1_mini$eval(
  solver_chat = ellmer::chat_openrouter(model = "openai/gpt-4.1-mini")
)

save(tsk_gpt_4_1_mini, file = "inst/runs/tasks/tsk_gpt_4_1_mini.rda")
