#' Helper scorer
#'
#' Pass this function to `Task$new()` as the scorer to evaluate model responses
#' using deterministic grading.
#'
#' The scorer performs three checks:
#' 1. Can the relevant file still be parsed in R?
#' 2. Has the R/ directory changed at all?
#' 3. Does the unit test pass?
#'
#' @param samples The samples from a solver task, likely retrieved from
#'   `task$get_samples()`.
#' @param ... Additional arguments (currently unused).
#'
#' @return A list with the following components:
#' \describe{
#'   \item{score}{Factor vector of scores: "C" (correct) or "I" (incorrect).}
#'   \item{explanation}{Character vector explaining why each sample received its score.}
#' }
#'
#' @export
helper_scorer <- function(samples, ...) {
  results <- purrr::map(seq_len(nrow(samples)), function(i) {
    side_dir <- eval(parse(text = samples$input[[i]]$dir))
    solver_dir <- samples$solver_metadata[[i]]$solver_directory

    if (is.null(solver_dir) || !dir.exists(solver_dir)) {
      return(list(score = "I", explanation = "Solver directory not found."))
    }

    withr::defer(unlink(solver_dir, recursive = TRUE))

    target_file <- file.path(solver_dir, "R", "tool-fetch_skill.R")

    if (!file.exists(target_file)) {
      return(list(score = NA_character_, explanation = "Could not find target file."))
    }

    can_parse <- tryCatch({
      parse(target_file)
      TRUE
    }, error = function(e) FALSE)

    if (!can_parse) {
      return(list(score = "I", explanation = "File cannot be parsed."))
    }

    has_changed <- check_if_changed(
      file.path(side_dir, "R", "tool-fetch_skill.R"),
      target_file
    )

    if (!has_changed) {
      return(list(score = "I", explanation = "No changes were made to the relevant file."))
    }

    test_passes <- run_unit_tests(solver_dir)

    if (test_passes) {
      list(score = "C", explanation = "Unit tests passed.")
    } else {
      list(score = "I", explanation = "Unit tests failed.")
    }
  })

  list(
    score = factor(purrr::map_chr(results, "score"), levels = c("I", "C"), ordered = TRUE),
    explanation = as.list(purrr::map_chr(results, "explanation"))
  )
}

check_if_changed <- function(original_file, modified_file) {
  original_content <- readLines(original_file, warn = FALSE)
  modified_content <- readLines(modified_file, warn = FALSE)

  !identical(original_content, modified_content)
}

run_unit_tests <- function(package_dir) {
  test_result <- tryCatch({
    withr::local_dir(package_dir)

    results <- devtools::test()
    results_tbl <- tibble::as_tibble(as.data.frame(results))

    all(results_tbl$failed == 0)
  }, error = function(e) {
    FALSE
  })

  test_result
}
