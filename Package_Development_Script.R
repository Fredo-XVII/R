# Package Development Script

# Some useful keyboard shortcuts for package authoring:
#
#   Build and Reload Package:  'Ctrl + Shift + B'
#   Check Package:             'Ctrl + Shift + E'
#   Test Package:              'Ctrl + Shift + T'

library(usethis)
library(devtools)
library(roxygen2)
library(testthat)
library(purrr)

# Is the pkg_name available in github

library(available)
available("pkg_name")

# Create Package, versioning, and documentation

# Create Package, versioning, and documentation
#tmp <- file.path("FILEPATH", "pkg_name")
usethis::create_package(path = 'C:\\XXX\\USER\\Documents\\R\\pkg_name')

usethis::use_tidy_description() # add `Roxygen: list(markdown = TRUE)` to use markdown in Roxygen comments

usethis::use_tidy_versions()

usethis::use_readme_rmd()

usethis::use_namespace()

usethis::use_news_md()
usethis::use_news_md(open = interactive())
usethis::use_pkgdown() # creates _pkgdown yaml.

#usethis::use_git()
#usethis::use_github()

#usethis::use_mit_license("Alfredo G Marquez")
#usethis::use_gpl3_license()
#usethis::use_apl2_license()
#usethis::use_cc0_license()

#usethis::use_travis()
#usethis::use_appveyor()
#usethis::use_coverage(type = c("codecov"))
#usethis::use_badge(badge_name,href,src)

# After adding roxygen2 params to function in R folder

roxygen2::roxygenise()
devtools::document()
devtools::load_all()

# Add Packages

usethis::use_package("dplyr")

usethis::use_package( "tidyverse", type = "Import")

import_pkg_list <- c("RPostgres","stringr","dbplyr","dplyr","rlang","tidyr","askpass","ssh",
                     "glue", "purrr")
purrr::map2(import_pkg_list, .y = "Imports", .f = usethis::use_package)

## Import functions
usethis::use_roxygen_md()
usethis::use_pipe()

## Suggests

### remotes for appveyor build
suggests_pkg_list <- c("roxygen2","kableExtra","remotes","knitr","rmarkdown","testthat","covr")

purrr::map2(suggests_pkg_list, .y = "Suggests", .f = usethis::use_package)

# Add Functions

usethis::use_r("function_name")

usethis::use_r("function_name")

usethis::use_data_raw()

# Build Tests

usethis::use_testthat()
usethis::use_test("file_name")

# Build Vignettes - use package name for pkgdown build
usethis::use_vignette("pkg_name")

# Spell Check

usethis::use_spell_check()

# Update Version
usethis::use_version()

# Build pkgdown site
pkgdown::build_site()

# Buildignore: Add directory
usethis::use_build_ignore("docs")
usethis::use_build_ignore(".Rhistory")

# Functions Roxygen format
#' @title
#'
#' @description
#'
#' @details
#'
#' @param
#'
#' @return
#'
#' @examples
#'
#' @export
