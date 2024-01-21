#--------------------------------------------------------
# Name  : Constructing final data for Index building
# Desc. : Appending the sentiment scores to the data 
#         frame and doing final variable preparations.
# Author: Tammo Thobe
# Course: Data Analysis Lab
# Date  : 10.01.2024
#--------------------------------------------------------

rm(list = ls())

# Libraries and packages
if(!require(dplyr)){
  install.packages("dplyr")
  library(dplyr)
}


# Loading Data
NYT <- read.csv("NYT_main.csv")
NYT$Date <- as.Date(NYT$Date)

NS_scores <- read.csv("ns_scores.csv")
NS_scores <- NS_scores[, c(2, 3)]

# Adding filename to the NYT object
NYT$filename <- NA

for (i in 1:nrow(NYT)) {
  # Create filename
  filename <- paste0("text_", i, ".txt")
  
  # Store filename in new column
  NYT$filename[i] <- filename
}

# Merging 'scores' to NYT
NYT <- left_join(NYT, NS_scores, by = c("filename" = "file"))

# Removing duplicates
NYT <- NYT[, c(1, 2, 3, 4, 5, 7)]

duplicated_rows <- duplicated(NYT) # 251 duplicates

NYT <- NYT[!duplicated_rows, ]

# Saving final Data
write.csv(NYT, file = "NYT_Final.csv", row.names = FALSE)

