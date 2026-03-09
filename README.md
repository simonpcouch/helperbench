
<!-- README.md is generated from README.Rmd. Please edit that file -->

# helperbench

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

helperbench evaluates whether language models can consistently perform a
simple refactoring task. Models are situated in a working directory with
tools to explore a codebase and asked to extract repeated code into a
helper function. The eval measures whether models make the requested
change without breaking unit tests.

helperbench is implemented in [ellmer](https://ellmer.tidyverse.org/)
with [vitals](https://vitals.tidyverse.org/).

## Installation

helperbench is implemented as an R package for ease of installation:

``` r
pak::pak("simonpcouch/helperbench")
```

Load it with:

``` r
library(helperbench)
```

helperbench will not go to CRAN.

## Example

The package ships with a data frame `helper_results` that contains
evaluation results:

``` r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

sample_n(helper_results, 10)
#> # A tibble: 10 × 6
#>    model            score type           cost  input output
#>    <chr>            <ord> <chr>         <dbl>  <dbl>  <dbl>
#>  1 Gemini Pro 2.5   C     Frontier  0.104      13818   8641
#>  2 Gemini Pro 2.5   C     Frontier  0.0801     27989   4509
#>  3 Qwen 3 14B       I     Local     0.00298    35268   3470
#>  4 GPT-4.1 Mini     C     Budget    0.193     477208   1584
#>  5 Qwen 3 14B       I     Local     0.00159    10929   3724
#>  6 Mistral 3.1 24B  I     Local    NA             NA     NA
#>  7 Mistral 3.1 24B  I     Local     0.000143    4054    192
#>  8 Mistral 3.1 24B  I     Local     0.0000207      1    188
#>  9 Gemini Flash 2.5 C     Budget    0.00738    17904    803
#> 10 Gemini Flash 2.5 C     Budget    0.0145     32975   1827
```

See `helper_task()` for more on how to run this eval yourself.

## How to add a new model benchmark

All models are evaluated via [OpenRouter](https://openrouter.ai/) for
consistency. Adding a new model benchmark involves four steps:

### 1. Register the model

Add a new row to `clients_to_evaluate()` in `R/run-eval.R` with the
OpenRouter model ID and a snake_case name:

``` r
clients_to_evaluate <- function() {
  tibble::tribble(
    ~client, ~name,
    # ... existing models ...
    'ellmer::chat_openrouter(model = "provider/model-name")', "model_name"
  )
}
```

### 2. Generate the eval script

Run `write_all_eval_files()` to regenerate all scripts (including your
new one) in `inst/runs/scripts/`:

``` r
devtools::load_all()
write_all_eval_files()
```

This creates `inst/runs/scripts/model_name.R` with the boilerplate to
run the evaluation and save the task result.

### 3. Run the evaluation

Source the generated script:

``` r
source("inst/runs/scripts/model_name.R")
```

This evaluates the model across all samples and epochs, saving the
result to `inst/runs/tasks/tsk_model_name.rda`.

### 4. Update the results dataset

In `data-raw/helper_results.R`, add entries for the new model in each of
the `case_when()` blocks:

- **Display name**: Map the snake_case name to a human-readable label
  (e.g., `model_name == "model_name" ~ "Model Name"`)
- **Type**: Categorize as `"Frontier"`, `"Budget"`, or `"Local"`
- **Cost**: Add the per-million-token input and output costs from
  OpenRouter

Then rebuild the dataset:

``` r
source("data-raw/helper_results.R")
```
