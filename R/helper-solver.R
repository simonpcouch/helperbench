#' Helper solver
#'
#' Pass this function to `Task$new()` as the solver to process inputs from
#' [helper_dataset] with a specified language model.
#'
#' The solver creates isolated working directories for each input, initializes
#' side::kick() clients with appropriate tools, and prompts models to perform
#' the refactoring task. Results include both the model's response and the
#' modified R/ directory.
#'
#' @param inputs List of input objects from the helperbench dataset. Each input
#'   should have the refactoring prompt.
#' @param ... Additional arguments (currently unused).
#' @param solver_chat An ellmer Chat object to use for solving the prompts.
#'
#' @return A list with the following components:
#' \describe{
#'   \item{result}{Character vector of model responses, one for each input.}
#'   \item{solver_chat}{List of Chat objects used to generate each response.}
#'   \item{solver_metadata}{List containing the solver working directory for each
#'     input, which will be used and cleaned up by the scorer.}
#' }
#'
#' @export
helper_solver <- function(inputs, ..., solver_chat) {
  check_inherits(solver_chat, "Chat")

  solver_dirs <- purrr::map(inputs, function(input) {
    side_dir <- eval(parse(text = input$dir))
    prepare_solver_directory(side_dir)
  })

  mirai_tasks <- purrr::map2(solver_dirs, inputs, function(solver_dir, input) {
    mirai::mirai(
      {
        setwd(solver_dir)
        ch_i <- solver_chat$clone()
        tools <- side:::sidekick_tools(socket_url = NULL)
        ch_i$set_tools(tools)
        ch_i$set_system_prompt(paste(
          readLines(system.file("agents/main.md", package = "side")),
          collapse = "\n"
        ))
        ch_i$chat(input$prompt, echo = FALSE)
        ch_i
      },
      solver_dir = solver_dir,
      input = input,
      solver_chat = solver_chat
    )
  })

  res_chats <- purrr::map(mirai_tasks, function(m) {
    result <- m[]

    result
  })

  is_chat <- purrr::map_lgl(res_chats, inherits, "Chat")
  result <- purrr::map_chr(res_chats, function(ch) {
    if (inherits(ch, "Chat")) {
      ch$last_turn()@text
    } else {
      # in this case, it's a mirai error
      as.character(ch)
    }
  })

  solver_chats <- purrr::map2(
    res_chats, 
    result,
    function(res_chat, result) {
      if (inherits(res_chat, "Chat")) {
        res_chat
      } else {
        res <- solver_chat$clone()
        res$set_turns(mock_turns(inputs, res_chat))
      }
    }
  )

  list(
    result = result,
    solver_chat = solver_chats,
    solver_metadata = purrr::map(solver_dirs, function(solver_dir) {
      list(solver_directory = solver_dir)
    })
  )
}

mock_turns <- function(inputs, error) {
  list(
    ellmer::UserTurn(inputs[[1]]$prompt),
    ellmer::AssistantTurn(error)
  )
}

prepare_solver_directory <- function(side_dir) {
  solver_parent <- file.path("inst", "solver")
  dir.create(solver_parent, recursive = TRUE, showWarnings = FALSE)

  temp_dir <- file.path(solver_parent, paste0("helper_side_", sample(0:10000, 1)))
  dir.create(temp_dir, recursive = TRUE)

  fs::dir_copy(side_dir, temp_dir)

  solver_dir <- file.path(temp_dir, basename(side_dir))

  file.create(file.path(solver_dir, ".here"))

  solver_dir
}

check_inherits <- function(x, class, call = rlang::caller_env()) {
  if (!inherits(x, class)) {
    cli::cli_abort(
      "{.arg solver_chat} must be a {.cls {class}} object.",
      call = call
    )
  }
}
