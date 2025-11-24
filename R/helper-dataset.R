#' Dataset
#'
#' @description
#'
#' The dataset is a tibble with one row containing:
#'
#' * `id`: Unique identifier for the sample.
#' * `input`: A list-column where each element is a tibble with:
#'   - `prompt`: The refactoring prompt asking the model to extract code into a helper.
#'   - `dir`: Quoted expression that evaluates to the path of the package directory.
#' * `target`: Empty string (unused, required by vitals).
#'
#' @format A tibble with columns `id`, `input`, and `target`.
#'
#' @examples
#' helper_dataset
#'
"helper_dataset"
