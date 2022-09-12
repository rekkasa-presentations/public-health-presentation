#!/usr/bin/env Rscript

# ===================================================
# Description:
#   Generates the RMSE plots for the base case
# Input:
#   - sample size
#   - auc
#   - value
# Output:
#   - figures/rmse_base.tiff
# Depends:
#   - data/processed/analysisIds.csv
#   - data/processed/rmse.csv
#   - code/helpers/CreateManuscriptPlots.R
#   - code/helpers/PlotResult.R
#   - code/helpers/Absolute.R
# ===================================================

args <- commandArgs(trailingOnly = TRUE)
args_base <- as.character(args[1])
args_sampleSize <- as.numeric(args[2])
args_auc <- as.numeric(args[3])
args_value <- as.character(args[4])

library(tidyverse)
library(glue)
library(ggtext)
library(gridExtra)
library(grid)
library(ggside)

# --------------------------------------
# Sourcing helper files:
#   1. Generates single boxplot
#   2. Generates the boxplot list
#   3. Generates the absolute plots
# --------------------------------------
source("code/helpers/CreateManuscriptPlots.R") 
source("code/helpers/PlotResult.R")
source("code/helpers/Absolute.R")

scenarioIds <- readr::read_csv("data/processed/analysisIds.csv") %>%
  filter(
    base == args_base,
    !(type %in% c("quadratic-moderate", "linear-moderate")),
    sampleSize == args_sampleSize,
    auc == args_auc
  ) 

metric    <- "rmse"

titles <- scenarioIds %>%
  mutate(
    title = ifelse(
      type == "constant",
      str_to_sentence(glue("{str_replace_all(type, '-', ' ')} treatment effect")),
      str_to_sentence(glue("{str_replace_all(type, '-', ' ')} deviation"))
    )
  ) %>%
  select(title) %>%
  unlist() %>%
  unique()

names(titles) <- NULL

titlePrefix <- paste0(
  "**",
  LETTERS[1:5],
  ".**"
)

# titles <- paste(
#   titlePrefix,
#   titles
# )


metricFile <- paste(metric, "csv", sep = ".")

f <- function(x) x * 100

limitsHigh <- ifelse(
  args_base == "high",
  yes = .2,
  no = .15
)

processed <- readr::read_csv(
  file = file.path("data/processed", metricFile)
) %>% 
  mutate_at(
    c(
      "constant_treatment_effect",
      "stratified",
      "linear_predictor",
      "rcs_3_knots",
      "rcs_4_knots",
      "rcs_5_knots",
      "adaptive"
    ),
    f
  )

# --------------------
# Create the boxplots
# --------------------
scenarios <- scenarioIds %>%
  filter(harm == "absent") %>%
  select(scenario) %>%
  unlist()

names(scenarios) <- NULL

plotList <- plotResult(scenarios, processed, titles, metric = metric, limits = c(0, 10, 2.5))


# ------------------------------------
# Put them all together:
#   - create a list of plots
#   - combine the list with cowplot
# ------------------------------------
gridList <- list(
  plotList[[1]] +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(size = 7),
      axis.title.x = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_text(size = 6),
      legend.direction = "horizontal",
      legend.title = element_text(size = 5.5),
      legend.text = element_text(size = 5),
      legend.position = c(.331, .862)
    ),
  plotList[[2]] + 
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(size = 7),
      axis.title = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      ggside.line = element_blank(),
      ggside.rect = element_blank(),
      ggside.axis.text = element_blank(),
      ggside.axis.ticks.length = unit(0, "pt"),
      ggside.panel.scale = .07,
      legend.position = "none"
    ),
  plotList[[3]] +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(size = 7),
      axis.title = element_blank(),
      axis.text.x = element_text(size = 6),
      axis.text.y = element_text(size = 6),
      legend.position = "none"
    ),
  plotList[[4]] +
    theme(
      panel.grid.minor = element_blank(),
      axis.title = element_blank(),
      axis.text.x = element_text(size = 6),
      axis.text.y = element_blank(),
      legend.position = "none",
      plot.title = element_text(size = 7)
    )
)

pp <- cowplot::plot_grid(
  gridList[[1]],
  gridList[[2]],
  gridList[[3]],
  gridList[[4]],
  ncol = 2
)

left.grob <- grid::textGrob(
    expression(
      paste(
        "Root mean squared error (x",
        10^-2,
        ")"
      )
    ),
    rot = 90
)



res <- grid.arrange(arrangeGrob(pp, left = left.grob))

fileName <- paste0(
  paste(
    metric,
    args_base,
    args_value,
    sep = "_"
  ),
  ".png"
)
  ggplot2::ggsave(
    file.path("figures", fileName), 
    plot = res,
    dpi = 600,
    width = 9, 
    height = 3.8
  )
  
