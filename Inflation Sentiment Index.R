#--------------------------------------------------------
# Name  : Inflation Sentiment Index 
# Desc. : Aggregating the news article sentiment scores
#         into a monthly index.
# Author: Tammo Thobe
# Course: Data Analysis Lab
# Date  : 13.01.2024
#--------------------------------------------------------

rm(list = ls())

# Libraries and packages
if(!require(zoo)){
  install.packages("zoo")
  library(zoo)
}

if(!require(tseries)){
  install.packages("tseries")
  library(tseries)
}

# Loading Data
NYT <- read.csv("NYT_Final.csv")

# Data preparation
NYT <- NYT[, c("Date", "score")]

NYT$Date <- as.Date(NYT$Date)

NYT <- NYT[order(NYT$Date), ]

# Simple aggregation by month

NYT$YearMonth <- format(NYT$Date, "%Y-%m")

Index <- aggregate(score ~ YearMonth, data = NYT, sum)

Index$normalized_score <- (Index$score - mean(Index$score)) / sd(Index$score)

# Convert 'YearMonth' to Date format
Index$Date <- as.Date(paste0(Index$YearMonth, "-01"), format = "%Y-%m-%d")

Index <- Index[, c(4, 2, 3)]

# Saving Index 
write.csv(Index, file = "Inflation Sentiment Index.csv", row.names = FALSE)
