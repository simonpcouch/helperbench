withr::local_envvar(VITALS_LOG_DIR = "inst/runs/demonstrate-issue/logs")
devtools::load_all()

tsk <- helper_task(epochs = 2)

# openrouter -------------------------------------------------------------------
tsk_haiku_openrouter <- tsk$clone()
tsk_haiku_openrouter$eval(
  solver_chat = ellmer::chat_openrouter(model = "anthropic/claude-haiku-4.5")
)

tsk_haiku_openrouter$get_samples()$solver_chat[[1]]$get_tokens()
#> # A tibble: 7 × 5
#>   input output cached_input cost      input_preview
#>   <dbl>  <dbl>        <dbl> <ellmr_d> <chr>        
#> 1 11942    168            0 NA        Text[Refacto…
#> 2 12185    146            0 NA        btw::BtwTool…
#> 3 12883    283            0 NA        ToolResult   
#> 4 13209    155            0 NA        ToolResult   
#> 5 13402    123            0 NA        ToolResult   
#> 6 13673    235            0 NA        ToolResult   
#> 7 13964    152            0 NA        ToolResult  

save(
  tsk_haiku_openrouter, 
  file = "inst/runs/demonstrate-issue/tasks/tsk_haiku_openrouter.rda"
)

# anthropic --------------------------------------------------------------------
tsk_haiku_anthropic <- tsk$clone()
tsk_haiku_anthropic$eval(
  solver_chat = ellmer::chat_anthropic(model = "claude-haiku-4-5")
)

tsk_haiku_anthropic$get_samples()$solver_chat[[1]]$get_tokens()
#> # A tibble: 4 × 5
#>    input output cached_input cost     input_preview
#>    <dbl>  <dbl>        <dbl> <ellmr_> <chr>        
#> 1 14657.    135            0 $0.02    Text[Refacto…
#> 2   240.    103        11723 $0.00    btw::BtwTool…
#> 3  2672.    759        11910 $0.01    ToolResult   
#> 4   989.    107        14043 $0.00    ToolResult 

save(
  tsk_haiku_anthropic, 
  file = "inst/runs/demonstrate-issue/tasks/tsk_haiku_anthropic"
)
