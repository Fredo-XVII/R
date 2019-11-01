# this will install the package where SparkR is located.
withr::with_libpaths(new = c(file.path(Sys.getenv("SPARK_HOME"), "R", "lib")) , install_github("SKKU-SKT/ggplot2.SparkR"))
