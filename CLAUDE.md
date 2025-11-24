This repository implements anLLM evaluation that measures how reliably a model can perform a simple refactoring task.

## helperbench

Future AI assistants should read:

* `ellmer::Chat()`
* `vitals::Task()`
* `side::kick()`

Also, read all of R/.

## Resources

A number of repositories have been cloned into the folder inst/resources. They are intended for you to explore and search inside, rather than to edit.

- `ellmer` makes it easy call LLMs from R.
- `vitals` implements large language model evaluation. Our benchmark is implemented with this package.
- There are a couple example evaluations implemented with ellmer as well. 
    - `bluffbench` implements an evaluation that measures models' ability to read plots. 
    - `predictivebench` implements an evaluation that measures how well models can build predictive models and has an example of creating temporary directories for evaluations in solvers.
- The source code for the `side` package, a coding agent for RStudio, is also included in that directory. 
