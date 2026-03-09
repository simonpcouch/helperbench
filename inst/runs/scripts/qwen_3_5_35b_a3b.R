withr::local_envvar(VITALS_LOG_DIR = "inst/runs/logs")
devtools::load_all()

tsk <- helper_task(
  epochs = 10,
  dir = "inst/runs/logs"
)

tsk_qwen_3_5_35b_a3b <- tsk$clone()
tsk_qwen_3_5_35b_a3b$eval(
  solver_chat = ellmer::chat_openrouter(model = "qwen/qwen3.5-35b-a3b")
)

save(tsk_qwen_3_5_35b_a3b, file = "inst/runs/tasks/tsk_qwen_3_5_35b_a3b.rda")
