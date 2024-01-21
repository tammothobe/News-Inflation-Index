#--------------------------------------------------------
# Name  : Topic Index
# Desc. : From the final data frame a topic index is
#         constructed, which captures the degree of 
#         inflation reporting in a given month.
# Author: Tammo Thobe
# Course: Data Analysis Lab
# Date  : 14.01.2024
#--------------------------------------------------------

rm(list = ls())

# Libraries and packages
if(!require(zoo)){
  install.packages("zoo")
  library(zoo)
}

# Data
NYT <- read.csv("NYT_Final.csv")

NYT$Date <- as.Date(NYT$Date)

NYT <- NYT[order(NYT$Date), ]

# Aggregate counts on a monthly basis
monthly_counts <- as.data.frame(table(year_month = floor_date(NYT$Date, "month")))

# Convert 'year_month' to Date type
monthly_counts$year_month <- as.Date(paste(monthly_counts$year_month, "-01", sep = ""))


# Index creation
# min/max conversion
Index_minmax <- data.frame((monthly_counts$Freq - min(monthly_counts$Freq)) / (max(monthly_counts$Freq) - min(monthly_counts$Freq)))
colnames(Index_minmax) <- "Index"
Index_minmax$Date <- monthly_counts$year_month

# mean/sd conversion
Index_meansd <- data.frame((monthly_counts$Freq - mean(monthly_counts$Freq)) / sd(monthly_counts$Freq))
colnames(Index_meansd) <- "Index"
Index_meansd$Date <- monthly_counts$year_month

# min/max conversion more sensible, as it does not include negative values for the index

# Save Index
write.csv(Index_minmax, file = "Inflation Topic Index.csv", row.names = FALSE)
