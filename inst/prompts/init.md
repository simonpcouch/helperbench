I've just initialized an R package directory. In it, we'd like to implement an LLM evaluation called helperbench. The evaluation will measure how well models can do a simple refactoring task consistently.

## Dataset

The dataset would just be one row with columns input and target. The input would be this question:

> Refactor this into a helper:
>
> ```
> # Remove YAML frontmatter if present
> content_start <- 1
> if (length(skill_content) > 0 && skill_content[1] == "---") {
>   yaml_end <- which(skill_content == "---")
>   if (length(yaml_end) >= 2) {
>     content_start <- yaml_end[2] + 1
>   }
> }
> ```

The target would be a path to the repository, using `system.file()`.

## Solver

The solver would initialize the side::kick() client and create a temp directory for the client to work in—a copy of the side directory. The side::kick() client would be able to call tools inside that directory in order to try to solve the problem.

We want to be able to run the evaluation in parallel—do so by using parallel_chat (parallel_chat?) inside the solver from ellmer. Note that in order not to conflict with each other, each parallel instantiation of the chat will need to have its own side::kick() directory to work in and will need to be working inside that directory. The solver directory should be deleted once the solver finishes, but the scorer will still need access to the solver's changes. The solution to this is to return the R/ directory in the results metadata of the solver. Then when running the scoring, copy the side::kick() directory into a folder, then copy the metadata in place of the R/ directory in the new copy, then run the unit test. Ensure that once the scorer is finished running, that additional copy is deleted. Don't worry about running the scorer in parallel since it is all deterministic.

## Scorer

The scorer would use deterministic grading. The deterministic grading would happen first by running tests on the side::kick() copy. The test would first check that the relevant file can still be parsed in the target language. If not, the grade is a failure. Next, the score would check whether the R/ directory has changed at all. If it has not changed, that is also a failure. Finally, the last deterministic check would run a unit test on the relevant function. If the test fails, that is a failure. Otherwise, it's a pass

## Notes 

A number of repositories have been cloned into the folder inst/resources. They are intended for you to explore and search inside, rather than to edit.

- vitals implements large language model evaluation. Our benchmark will be implemented with this package.
- There are a couple example evaluations implemented with Ellmer as well. 
    - `bluffbench` implements an evaluation that measures models' ability to read plots. 
    - `predictivebench` implements an evaluation that measures how well models can build predictive models and has an example of creating temporary directories for evaluations in solvers. Use both of those examples as inspiration for how to structure an evaluation package. 
    - The source code for the `side` package is also included in that directory. You will need to make use of it in two different ways. 
         * First, you will need to explore how the side::kick() package creates the client. The evaluation will need to initialize the client so that it has access to the same tools and system prompt. Create a minimal script that creates the side::kick() client inspired by the contents of the _kick_file. 
         * Next, you will use the package by copying its contents into a temporary directory each time a new solver is initiated.


Like bluffbench and predictivebench, the package should export a dataset, a solver, and a scorer, as well as an object that is a container for the three. Importantly, write code and structure the package in the way that I do in those packages.
