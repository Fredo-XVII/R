library(stats)
library(lattice)
library(RColorBrewer)

CalculateDelta <- function(stdev, nstores, nweeks, significance, power) {
  # Computes the minumum detectable delta of a two sample t-test given the
  # number of stores and weeks.
  #
  # Args:
  #   stdev: sample standard deviation
  #   nstores: [vector] number of stores in each group (control vs. test)
  #   nweeks: [vector] number of weeks to follow up each store
  #   significance: significance level of the test (alpha)
  #   power: power of the test (1 - beta)
  #
  # Returns:
  #   A data frame containing the minimum detectable delta given the number of
  # stores and weeks.  Records for the same number of stores are stored in a
  # block of consecutive rows.
  #
  minDelta <- matrix(nrow = length(nstores) * length(nweeks), ncol = 4)
  colnames(minDelta) <- c("stores", "weeks", "sampleSize", "minDelta")
  for (i in 1:length(nstores)) {
    for (j in 1:length(nweeks)) {
      # store counts and week counts are given in ascending order
      sampleSize <- nstores[i] * nweeks[j]  # one sample is one store one week
      index <- (i - 1) * length(nweeks) + j  # row index for the output
      pwrt <- power.t.test(n = sampleSize, delta = NULL, sd = stdev,
        significance, power, type = "two.sample", alternative = 'two.sided',
        strict = FALSE)
      minDelta[index, 1] <- nstores[i]
      minDelta[index, 2] <- nweeks[j]
      minDelta[index, 3] <- sampleSize
      minDelta[index, 4] <- pwrt$delta
    }
  }
  return(data.frame(minDelta))
}

CalculateSensitivity <- function(obs, dist, nstores, nweeks,
  significance = 0.05, power = 0.80) {
  # Computes the sensitivity of a store test in terms of minimum detectable
  # lift over the baseline.
  #
  # Args:
  #   obs: [vector] observations for estimating the stardard deviation
  #        and the baseline
  #   dist: distribution family (either 'normal' or 'lognormal')
  #   nstores: [vector] number of stores in each group (control vs. test)
  #   nweeks: [vector] number of weeks to follow up each store
  #   significance: significance level of the test (alpha)
  #   power: power of the test (1 - beta)
  #
  # Returns:
  #   A data frame containing the minimum detectable lift given the number of
  # stores and weeks.
  #
  if (dist == 'normal') {
    sampleMean <- mean(obs)
    sampleSD <- sd(obs)
    delta <- CalculateDelta(stdev = sampleSD, nstores, nweeks,
      significance, power)
    delta$minLift <- delta$minDelta / sampleMean
  } else if (dist == 'lognormal') {
    logSampleMean <- mean(log(obs))
    logSampleSD <- sd(log(obs))
    delta <- CalculateDelta(stdev = logSampleSD, nstores, nweeks,
      significance, power)
    delta$minLift <- (exp(logSampleMean + delta$minDelta)
      - exp(logSampleMean)) / exp(logSampleMean)
  } else {
    stop("Distribution family must be either 'normal' or 'lognormal'.")
  }
  sensitivity <- data.frame(stores = delta$stores, weeks = delta$weeks,
    minLift = delta$minLift)
  return(sensitivity)
}

LinePlotSensitivity <- function(sensitivity, xlimits, ylimits, title) {
  # Plots the sensitivity of store tests as a function of sample size
  # in a line chart.
  #
  # Args:
  #   sensitivity: a data frame containing the minimum detectable lift given
  #                the number of stores and weeks
  #   xlimits: limits of the x-axis (number of weeks) on the plot
  #   ylimits: limits of the y-axis (mimimum detectable lift) on the plot
  #   title: label on the top of the plot
  #
  # Returns:
  #   Plots the minimum detectable lift as a function of sample size (number
  # of stores and weeks).  No value is returned.
  #
  nstores <- sort(unique(sensitivity$stores))
  nweeks <- sort(unique(sensitivity$weeks))
  plot(c(0, 0), c(0, 0), col = 0, xlim = xlimits, ylim = ylimits, main = title,
    xlab = "Number of weeks", ylab = "Minimum detectable lift %")
  for (i in 1:length(nstores)) {
    index = (i - 1) * length(nweeks) + 1
    temp = sensitivity[index:(index + length(nweeks) - 1), ]
    lines(temp$weeks, 100 * temp$minLift, col = i + 1, lwd = 2)
  }
  legend("topright", legend = paste(nstores, "Stores"), lwd = 2,
    col = c(2:(length(nstores) + 1)))
}

ContourPlotSensitivity <- function(sensitivity, xlimits, ylimits, zlimits, title) {
  # Plots the sensitivity of store tests as a function of sample size
  # in a 2D contour chart.
  #
  # Args:
  #   sensitivity: a data frame containing the minimum detectable lift given
  #                the number of stores and weeks
  #   xlimits: limits of the x-axis (number of stores) on the plot
  #   ylimits: limits of the y-axis (number of weeks) on the plot
  #   title: label on the top of the plot
  #
  # Returns:
  #   Plots the minimum detectable lift as a function of sample size (number
  # of stores and weeks).  No value is returned.
  #
  x <- sort(unique(sensitivity$stores))
  y <- sort(unique(sensitivity$weeks))
  z = matrix(nrow = length(x), ncol = length(y))
  for (i in 1:length(x)) {
    for (j in 1:length(y)) {
      temp = (sensitivity$stores == x[i]) & (sensitivity$weeks == y[j])
      z[i,j] = 100 * sensitivity$minLift[temp]
    }
  }
  filled.contour(x, y, z, nlevels = 11, col = rev(brewer.pal(10, "Spectral")),
                 xlim = xlimits, ylim = ylimits, zlim = zlimits,
                 plot.title = title(main = title, xlab = "Number of stores",
                                    ylab = "Number of weeks"),
                 key.title = title(main = "Lift %"))
}

# ------------------------------------------------------------
# Usage Example:
#
# rawdata = read.csv("grp_weekly_sales.csv", header = TRUE)
# stores = c(100, 200, 250, 300, 350, 400, 450, 500)
# weeks = seq(1, 25, 1)
# sensitivity.sales = CalculateSensitivity(obs = rawdata$sales,
#   dist = 'normal', nstores = stores, nweeks = weeks)
# ContourPlotSensitivity(sensitivity, xlimits = c(100, 500),
#   ylimits = c(1, 25), zlimits = c(0, 20),
#   title = "Sensitivity Plot for Total Store Sales")
