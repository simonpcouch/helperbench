#' The helper task
#'
#' Combines the [helper_dataset], [helper_solver], and [helper_scorer] into a
#' [vitals::Task] for evaluating language models' ability to perform consistent
#' refactoring tasks.
#'
#' @param epochs Number of evaluation epochs to run. Default is 1.
#' @param dir Directory for logging evaluation results. Default is
#'   `vitals::vitals_log_dir()`.
#' @param samples Row indices from helper_dataset to evaluate. Default is all rows.
#'
#' @return A vitals Task object combining the helper dataset, solver, and scorer.
#' The task takes parameter `solver_chat` (required).
#'
#' @seealso [helper_dataset] for the dataset, [helper_solver] for the solver,
#'   [helper_scorer] for the scorer, and [vitals::Task] for the task object.
#'
#' @export
helper_task <- function(
  epochs = 1,
  dir = vitals::vitals_log_dir(),
  samples = seq_len(nrow(helper_dataset))
) {
  vitals::Task$new(
    dataset = helper_dataset[samples, ],
    solver = helper_solver,
    scorer = helper_scorer,
    epochs = epochs,
    name = "helperbench",
    dir = dir
  )
}
