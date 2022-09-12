#!/usr/bin/env Rscript

# ===================================================
# Description:
#   Generates the calibration plots
# Input:
#   - sample size
#   - auc
#   - value
# Output:
#   - figures/calibration_*.tiff
# Depends:
#   - data/processed/analysisIds.csv
#   - data/processed/calibration.csv
#   - code/helpers/CreateManuscriptPlots.R
#   - code/helpers/PlotResult.R
# ===================================================

args <- commandArgs(trailingOnly = TRUE)
args_base <- as.character(args[1])
args_sampleSize <- as.numeric(args[2])
args_auc <- as.numeric(args[3])
args_value <- as.character(args[4])

library(tidyverse)
library(glue)
library(ggtext)
source("code/helpers/CreateManuscriptPlots.R")
source("code/helpers/PlotResult.R")

scenarioIds <- readr::read_csv("data/processed/analysisIds.csv") %>%
  filter(
    base == args_base,
    harm != "negative",
    !(type %in% c("quadratic-moderate", "linear-moderate")),
    sampleSize == args_sampleSize,
    auc == args_auc
  ) 

metric    <- "calibration"

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

metricFile <- paste(metric, "csv", sep = ".")

f <- function(x) x * 100

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
scenarios <- scenarioIds %>%
  filter(harm == "absent") %>%
  select(scenario) %>%
  unlist()
names(scenarios) <- NULL

plotList <- plotResult(scenarios, processed, titles, metric = metric, limits = c(0, 6, 1))

left.grob <- grid::textGrob(
    expression(
      paste(
        "Integrated calibration index (x",
        10^-2,
        ")"
      )
    ),
    rot = 90
)

res <- gridExtra::grid.arrange(
  plotList[[1]] +
    theme(
      plot.title = element_text(size = 7),
      axis.title = element_blank(),
      legend.direction = "horizontal",
      legend.title = element_text(size = 5.5),
      legend.text = element_text(size = 5),
      legend.position = c(.325, .862),
      panel.grid.minor = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_text(size = 6)
    ),
  plotList[[2]] +
    theme(
      plot.title = element_text(size = 7),
      axis.title = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      legend.position = "none",
      panel.grid.minor = element_blank()
    ),
  plotList[[3]] +
    theme(
      plot.title = element_text(size = 7),
      axis.title = element_blank(),
      axis.text.x = element_text(size = 6),
      axis.text.y = element_text(size = 6),
      panel.grid.minor = element_blank(),
      legend.position = "none"
    ),
  plotList[[4]] +
    theme(
      plot.title = element_text(size = 7),
      axis.title = element_blank(),
      axis.text.x = element_text(size = 6),
      axis.text.y = element_blank(),
      panel.grid.minor = element_blank(),
      legend.position = "none"
    ),
  heights = c(1, 1.05),
  nrow = 2,
  ncol = 2,
  left = left.grob
)

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
