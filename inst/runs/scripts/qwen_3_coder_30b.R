withr::local_envvar(VITALS_LOG_DIR = "inst/runs/logs")
devtools::load_all()

tsk <- helper_task(epochs = 10)

tsk_qwen_3_coder_30b <- tsk$clone()
tsk_qwen_3_coder_30b$eval(
  solver_chat = ellmer::chat_openrouter(model = "qwen/qwen3-coder-30b-a3b-instruct")
)

save(tsk_qwen_3_coder_30b, file = "inst/runs/tasks/tsk_qwen_3_coder_30b.rda")
