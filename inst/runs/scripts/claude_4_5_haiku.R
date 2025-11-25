withr::local_envvar(VITALS_LOG_DIR = "inst/runs/logs")
devtools::load_all()

tsk <- helper_task(epochs = 10)

tsk_claude_4_5_haiku <- tsk$clone()
tsk_claude_4_5_haiku$eval(
  solver_chat = ellmer::chat_openrouter(model = "anthropic/claude-haiku-4.5")
)

save(tsk_claude_4_5_haiku, file = "inst/runs/tasks/tsk_claude_4_5_haiku.rda")
