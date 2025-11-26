
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
#>    model             score type          cost   input output
#>    <chr>             <ord> <chr>        <dbl>   <dbl>  <dbl>
#>  1 GPT-4.1           I     Frontier 0.442      217512    846
#>  2 Claude Haiku 4.5  C     Budget   0.421      394098   5349
#>  3 Claude Sonnet 4.5 C     Frontier 0.406      128192   1419
#>  4 Qwen Coder 3 30B  I     Local    0.0323     522523   3623
#>  5 Claude Haiku 4.5  C     Budget   0.122      112549   1805
#>  6 Gemini Flash 2.5  I     Budget   0.0304      77478   2855
#>  7 Gemini Flash 2.5  C     Budget   0.0645     124396  10855
#>  8 Gemini Pro 2.5    I     Frontier 0.0966      21295   6995
#>  9 Mistral 3.1 24B   I     Local    0.0000197       1    179
#> 10 GPT-4.1           C     Frontier 2.46      1203569   6735
```

See `helper_task()` for more on how to run this eval yourself.
