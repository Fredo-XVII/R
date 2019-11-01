# Package Development Script

library(devtools)
library(roxygen2)
library(usethis)
library(testthat)

# Is the pkg_name available in github

library(available)
available("pkg_name")

# Create Package, versioning, and documentation

#tmp <- file.path("FILEPATH", "TestContR")
usethis::create_package(path = 'C:\\XXX\\USER\\Documents\\R\\pkg_name')

usethis::use_tidy_description() # add `Roxygen: list(markdown = TRUE)` to use markdown in Roxygen comments

usethis::use_tidy_versions()

usethis::use_readme_rmd()

usethis::use_news_md()

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

devtools::load_all()

# Add Packages

usethis::use_package("dplyr")

usethis::use_package( "tidyverse", type = "Import")

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
