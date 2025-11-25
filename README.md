
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

## Example

The package ships with a data frame `helper_results` that contains
evaluation results:

``` r
helper_results
#>                model score     type       cost   input output
#> 1   Claude Haiku 4.5     C   Budget 0.12157400  112549   1805
#> 2   Claude Haiku 4.5     C   Budget 0.08676700   79532   1447
#> 3   Claude Haiku 4.5     C   Budget 0.08670200   79107   1519
#> 4   Claude Haiku 4.5     C   Budget 0.08755300   80678   1375
#> 5   Claude Haiku 4.5     C   Budget 2.07757300 1972513  21012
#> 6   Claude Haiku 4.5     C   Budget 0.11589900  108134   1553
#> 7   Claude Haiku 4.5     C   Budget 1.27359400 1203269  14065
#> 8   Claude Haiku 4.5     C   Budget 0.42084300  394098   5349
#> 9   Claude Haiku 4.5     C   Budget 0.44581500  419075   5348
#> 10  Claude Haiku 4.5     C   Budget 0.12902100  120186   1767
#> 11 Claude Sonnet 4.5     C Frontier 0.53697300  169231   1952
#> 12 Claude Sonnet 4.5     C Frontier 0.40586100  128192   1419
#> 13 Claude Sonnet 4.5     C Frontier 0.44471100  140982   1451
#> 14 Claude Sonnet 4.5     C Frontier 0.38066400  119498   1478
#> 15 Claude Sonnet 4.5     C Frontier 0.38160600  119537   1533
#> 16 Claude Sonnet 4.5     C Frontier 0.32934600  103512   1254
#> 17 Claude Sonnet 4.5     C Frontier 0.41979900  131668   1653
#> 18 Claude Sonnet 4.5     C Frontier 0.30083400   93883   1279
#> 19 Claude Sonnet 4.5     C Frontier 0.29565900   92228   1265
#> 20 Claude Sonnet 4.5     C Frontier 0.37896600  119242   1416
#> 21  Gemini Flash 2.5     C   Budget 0.01075780   23851   1441
#> 22  Gemini Flash 2.5     I   Budget 0.00089620     254    328
#> 23  Gemini Flash 2.5     I   Budget 0.00292850    9045     86
#> 24  Gemini Flash 2.5     I   Budget 0.03175950   68865   4440
#> 25  Gemini Flash 2.5     I   Budget 0.00289590    9028     75
#> 26  Gemini Flash 2.5     I   Budget 0.00286060    9002     64
#> 27  Gemini Flash 2.5     I   Budget 0.03038090   77478   2855
#> 28  Gemini Flash 2.5     C   Budget 0.01188380   27646   1436
#> 29  Gemini Flash 2.5     I   Budget 0.00014530      26     55
#> 30  Gemini Flash 2.5     C   Budget 0.06445630  124396  10855
#> 31    Gemini Pro 2.5     C Frontier 0.13513125   42993   8139
#> 32    Gemini Pro 2.5     I Frontier 0.07199625   37381   2527
#> 33    Gemini Pro 2.5     C Frontier 0.25807250   69874  17073
#> 34    Gemini Pro 2.5     C Frontier 0.22636125   56857  15529
#> 35    Gemini Pro 2.5     I Frontier 0.09656875   21295   6995
#> 36    Gemini Pro 2.5     C Frontier 0.12308750   33966   8063
#> 37    Gemini Pro 2.5     C Frontier 0.24053875   51623  17601
#> 38    Gemini Pro 2.5     C Frontier 0.16254375   37355  11585
#> 39    Gemini Pro 2.5     C Frontier 0.22292875   95055  10411
#> 40    Gemini Pro 2.5     C Frontier 0.42125625  172413  20574
#> 41      GPT-4.1 Mini     C   Budget 0.19789160  478637   4023
#> 42      GPT-4.1 Mini     C   Budget 0.05387760  132374    580
#> 43      GPT-4.1 Mini     I   Budget 0.05069200  123710    755
#> 44      GPT-4.1 Mini     I   Budget 0.07197680  177578    591
#> 45      GPT-4.1 Mini     C   Budget 0.13313840  328314   1133
#> 46      GPT-4.1 Mini     I   Budget 0.02693000   65405    480
#> 47      GPT-4.1 Mini     I   Budget 0.32615080  791021   6089
#> 48      GPT-4.1 Mini     I   Budget 0.03699000   89891    646
#> 49      GPT-4.1 Mini     I   Budget 0.09551640  228895   2474
#> 50      GPT-4.1 Mini     I   Budget 0.00871880   20801    249
#> 51           GPT-4.1     C Frontier 1.40091400  682725   4433
#> 52           GPT-4.1     C Frontier 0.51027600  249266   1468
#> 53           GPT-4.1     C Frontier 1.11466000  541730   3900
#> 54           GPT-4.1     C Frontier 2.46101800 1203569   6735
#> 55           GPT-4.1     C Frontier 2.07632400 1016354   5452
#> 56           GPT-4.1     C Frontier 0.97175200  472708   3292
#> 57           GPT-4.1     C Frontier 1.23391000  598747   4552
#> 58           GPT-4.1     C Frontier 0.49342800  239966   1687
#> 59           GPT-4.1     I Frontier 0.44179200  217512    846
#> 60           GPT-4.1     I Frontier 0.02208200   10321    180
#> 61       GPT OSS 20B     I    Local 0.00057636   17588    348
#> 62       GPT OSS 20B     I    Local 0.00113562   36510    288
#> 63       GPT OSS 20B     I    Local 0.00101346   27790   1284
#> 64       GPT OSS 20B     I    Local 0.00028060    8784    122
#> 65       GPT OSS 20B     I    Local 0.00029205    8811    198
#> 66       GPT OSS 20B     I    Local 0.00092014   28632    437
#> 67       GPT OSS 20B     I    Local 0.00039381    8745    939
#> 68       GPT OSS 20B     I    Local 0.00111506   35442    370
#> 69       GPT OSS 20B     I    Local 0.00060869   17681    559
#> 70       GPT OSS 20B     I    Local 0.00057226   18646     92
#> 71   Mistral 3.1 24B     I    Local 0.00002126       1    193
#> 72   Mistral 3.1 24B     I    Local 0.00001686       1    153
#> 73   Mistral 3.1 24B     I    Local 0.00001543       1    140
#> 74   Mistral 3.1 24B     I    Local         NA      NA     NA
#> 75   Mistral 3.1 24B     I    Local         NA      NA     NA
#> 76   Mistral 3.1 24B     I    Local 0.00001862       1    169
#> 77   Mistral 3.1 24B     I    Local 0.00004414       1    401
#> 78   Mistral 3.1 24B     I    Local         NA      NA     NA
#> 79   Mistral 3.1 24B     I    Local         NA      NA     NA
#> 80   Mistral 3.1 24B     I    Local 0.00001972       1    179
#> 81  Qwen Coder 3 30B     I    Local 0.02294750  367025   3704
#> 82  Qwen Coder 3 30B     I    Local 0.03663647  591287   4637
#> 83  Qwen Coder 3 30B     I    Local 0.02670173  431008   3365
#> 84  Qwen Coder 3 30B     I    Local 0.03519580  562680   5740
#> 85  Qwen Coder 3 30B     I    Local 0.03225713  522523   3623
#> 86  Qwen Coder 3 30B     I    Local 0.00002081       1     83
#> 87  Qwen Coder 3 30B     I    Local 0.04289276  688171   6410
#> 88  Qwen Coder 3 30B     I    Local 0.00002006       1     80
#> 89  Qwen Coder 3 30B     I    Local 0.02413136  387256   3584
#> 90  Qwen Coder 3 30B     I    Local 0.03180338  504723   6080
```

See `helper_task()` for more on how to run this eval yourself.
