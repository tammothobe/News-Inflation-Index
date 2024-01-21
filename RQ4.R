#--------------------------------------------------------
# Name  : RQ4 - Response of macroeconomic aggregates to
#               Inflation sentiment shocks
# Desc. : How do macroeconomic aggregates, especially
#         consumer spending respond to inflation news
#         sentiment shocks.
# Author: Tammo Thobe
# Course: Data Analysis Lab
# Date  : 19.01.2024
#--------------------------------------------------------

rm(list = ls())

# Libraries and packages
if(!require(lpirfs)){
  install.packages("lpirfs")
  library(lpirfs)
}

if(!require(dplyr)){
  install.packages("dplyr")
  library(dplyr)
}

if(!require(gridExtra)){
  install.packages("gridExtra")
  library(gridExtra)
}

if(!require(ggpubr)){
  install.packages("ggpubr")
  library(ggpubr)
}

# Data
Index <- read.csv("Inflation Sentiment Index.csv") %>%
  mutate(Date = as.Date(Date)) %>%
  mutate(Sentiment = score, 
         score     = NULL)

PC <- read.csv("PCEC96.csv") %>% # Real personal consumption expenditures
  mutate(Date = as.Date(DATE),  # Convert DATE to Date object
         DATE = NULL) 

FEDFUNDS <- read.csv("FEDFUNDS.csv") %>% # Federal Funds Rate
  mutate(Date = as.Date(DATE),  # Convert DATE to Date object
         DATE = NULL) 

PCEPI <- read.csv("PCEPI.csv") %>% # Personal Consumption Expenditures: Chain-type Price Index
  mutate(Date = as.Date(DATE),  # Convert DATE to Date object
         DATE = NULL) %>%
  mutate(PCEPI = log(PCEPI))

INDPRO <- read.csv("INDPRO.csv") %>% # Industrial production
  mutate(Date = as.Date(DATE),  # Convert DATE to Date object
         DATE = NULL)

CPI <- read.csv("CPALTT01USM659N.csv") %>%  # consumer price index: all items, growth period previous year
  mutate(Date = as.Date(DATE),  # Convert DATE to Date object
         DATE = NULL)

PCDG <- read.csv("PCEDGC96.csv") %>% # Real personal consumption expenditures: Durable goods
  mutate(Date = as.Date(DATE),  # Convert DATE to Date object
         DATE = NULL) 

PCNDG <- read.csv("PCENDC96.csv") %>% # Real personal consumption expenditures: Nondurable goods
  mutate(Date = as.Date(DATE),  # Convert DATE to Date object
         DATE = NULL) 

# Subsetting the data and merging into one data frame
Index <- Index[, c(1, 3)]

dfs <- list(Index, PC, INDPRO, PCEPI, FEDFUNDS)

df <- Reduce(function(x, y) merge(x, y, by = "Date", all = TRUE), dfs)


# Local Projection

endog_data <- df[-168, c(2, 3, 4, 5, 6)]

results_lin <- lp_lin(endog_data = endog_data,
                      lags_endog_lin = 4,
                      trend = 0,
                      shock_type = 0,
                      confint = 1,
                      use_nw = TRUE,
                      hor = 20)

plot(results_lin)

dg_baseline_plots <- plot_lin(results_lin)

plot_1 <- dg_baseline_plots[[6]] # Consumption

plot_2 <- dg_baseline_plots[[11]] # Output

plot_3 <- dg_baseline_plots[[16]] # Price level

plot_4 <- dg_baseline_plots[[21]] # Real Rate

# Make a list to save all plots
combine_plots <- list()

# Save plots in list
combine_plots[[1]] <- plot_1
combine_plots[[2]] <- plot_3
combine_plots[[3]] <- plot_2
combine_plots[[4]] <- plot_4

# Show all plots
plots_all <- sapply(combine_plots, ggplotGrob)
marrangeGrob(plots_all, nrow = 2, ncol = 2, top = NULL)


# Durable Goods
dfs <- list(Index, PCDG, INDPRO, PCEPI, FEDFUNDS)

df <- Reduce(function(x, y) merge(x, y, by = "Date", all = TRUE), dfs)

endog_data <- df[-168, c(2, 3, 4, 5, 6)]

results_lin <- lp_lin(endog_data = endog_data,
                      lags_endog_lin = 4,
                      trend = 0,
                      shock_type = 0,
                      confint = 1,
                      use_nw = TRUE,
                      hor = 20)

plot(results_lin)

dg_baseline_plots <- plot_lin(results_lin)

plot_1 <- dg_baseline_plots[[6]] # Consumption

plot_2 <- dg_baseline_plots[[11]] # Output

plot_3 <- dg_baseline_plots[[16]] # Price level

plot_4 <- dg_baseline_plots[[21]] # Real Rate

# Make a list to save all plots
combine_plots <- list()

# Save plots in list
combine_plots[[1]] <- plot_1
combine_plots[[2]] <- plot_3
combine_plots[[3]] <- plot_2
combine_plots[[4]] <- plot_4

# Show all plots
plots_all <- sapply(combine_plots, ggplotGrob)
marrangeGrob(plots_all, nrow = 2, ncol = 2, top = NULL)


# Nondurable goods
dfs <- list(Index, PCNDG, INDPRO, PCEPI, FEDFUNDS)

df <- Reduce(function(x, y) merge(x, y, by = "Date", all = TRUE), dfs)

endog_data <- df[-168, c(2, 3, 4, 5, 6)]

results_lin <- lp_lin(endog_data = endog_data,
                      lags_endog_lin = 4,
                      trend = 0,
                      shock_type = 0,
                      confint = 1,
                      use_nw = TRUE,
                      hor = 20)

plot(results_lin)

dg_baseline_plots <- plot_lin(results_lin)

plot_1 <- dg_baseline_plots[[6]] # Consumption

plot_2 <- dg_baseline_plots[[11]] # Output

plot_3 <- dg_baseline_plots[[16]] # Price level

plot_4 <- dg_baseline_plots[[21]] # Real Rate

# Make a list to save all plots
combine_plots <- list()

# Save plots in list
combine_plots[[1]] <- plot_1
combine_plots[[2]] <- plot_3
combine_plots[[3]] <- plot_2
combine_plots[[4]] <- plot_4

# Show all plots
plots_all <- sapply(combine_plots, ggplotGrob)
marrangeGrob(plots_all, nrow = 2, ncol = 2, top = NULL)
