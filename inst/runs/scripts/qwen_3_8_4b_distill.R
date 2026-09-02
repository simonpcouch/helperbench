withr::local_envvar(VITALS_LOG_DIR = "inst/runs/logs")
devtools::load_all()

tsk <- helper_task(epochs = 10)

tsk_qwen_3_8_4b_distill <- tsk$clone()
tsk_qwen_3_8_4b_distill$eval(
  solver_chat = ellmer::chat_ollama(
    model = "qwen3.8-4b-distill-q4",
    api_args = list(reasoning_effort = "none")
  ),
  delay = 0
)

save(
  tsk_qwen_3_8_4b_distill,
  file = "inst/runs/tasks/tsk_qwen_3_8_4b_distill.rda"
)
