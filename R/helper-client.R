create_helper_client <- function(working_dir) {
  side_dir <- system.file("resources", "side", package = "helperbench")

  main_config <- file.path(side_dir, "inst", "agents", "main.md")
  system_prompt <- paste(readLines(main_config, warn = FALSE), collapse = "\n")

  client <- ellmer::chat_anthropic(
    model = "claude-sonnet-4-5-20250929",
    system_prompt = system_prompt
  )

  client$set_tools(side:::sidekick_tools(socket_url = NULL))

  client
}
