# Website for data science for openwashdata course 002

Find all details at: <https://ds4owd-002.github.io/website/>

This course is offered by the [openwashdata community](https://openwashdata.org/). 

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)](content/course/code_of_conduct.md)

## How to Sign Up

Ready to join the course? Sign up here: https://ee-eu.kobotoolbox.org/x/7V3qeDYD (it will take about 15 minutes)

**Course dates:** September 11 - December 4, 2025

## Development Setup

This project uses [renv](https://rstudio.github.io/renv/) for R package management to ensure reproducible environments.

### Setting up the R environment

1. Clone the repository
2. Open R/RStudio in the project directory
3. Run `renv::restore()` to install all required R packages

This will automatically install all packages specified in `renv.lock` into a project-local library.

### Building the website

```bash
# Render entire website
quarto render

# Preview with live reload
quarto preview
```

### Package management

- Add new packages: `renv::install("package_name")`
- Update lockfile: `renv::snapshot()`
- Restore environment: `renv::restore()`

## Attribution

The layout of the website and naming convention are based on [STA 210 at Duke University (Spring 2022)
](https://github.com/sta210-s22/website) by [Dr. Mine Çetinkaya-Rundel](https://mine-cr.com/).



