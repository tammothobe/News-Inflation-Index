#--------------------------------------------------------
# Name  : Sentiment Analysis - Preparation
# Desc. : The script creates a folder containing each
#         article in the data as a separate .txt file
#         to then be able to calculate the respective 
#         sentiment score.
# Author: Tammo Thobe
# Course: Data Analysis Lab
# Date  : 04.01.2024
#--------------------------------------------------------

rm(list = ls())

# Libraries and packages
if(!require(dplyr)){
  install.packages("dplyr")
  library(dplyr)
}

if(!require(lubridate)){
  install.packages("lubridate")
  library(lubridate)
}

# Loading Data
NYT <- read.csv("NYT_main.csv")

NYT$Date <- as.Date(NYT$Date)

# Saving each element of 'body' as a txt file, to use replication code of Shapiro et al.
output_folder <- "/Users/tammo/Desktop/Data Analysis Lab/news_sentiment_replication_code/TXT_files" # Change destination to specific folder

# Check if the folder exists, create if it does not
if (!file.exists(output_folder)) {
  dir.create(output_folder)
}

# Loop through each row of the df
for (i in 1:nrow(NYT)) {
  # Create a filename based on the index (or any unique identifier in your DataFrame)
  filename <- paste0(output_folder, "/text_", i, ".txt")
  
  # Write the 'body' content to the text file
  writeLines(NYT$body[i], con = filename)
}

# Optionally, you can print a message indicating the process is complete
cat("Text files saved to", output_folder, "\n")
