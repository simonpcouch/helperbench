helper_dataset <- tibble::tibble(
  id = "refactor_yaml_frontmatter",
  input = list(
    tibble::tibble(
      prompt = "Refactor this line from the project into a helper:

```
# Remove YAML frontmatter if present
content_start <- 1
if (length(skill_content) > 0 && skill_content[1] == \"---\") {
  yaml_end <- which(skill_content == \"---\")
  if (length(yaml_end) >= 2) {
    content_start <- yaml_end[2] + 1
  }
}
```",
      dir = 'system.file("resources", "side", package = "helperbench")'
    )
  ),
  target = ""
)

usethis::use_data(helper_dataset, overwrite = TRUE)
