#--------------------------------------------------------
# Name  : Consolidation NYT
# Desc. : The script consolidates the different .csv
#         from every year in the time frame into one
#         single file.
# Author: Tammo Thobe
# Course: Data Analysis Lab
# Date  : 02.12.2023
#--------------------------------------------------------

rm(list = ls())

# Data
articles_2010 <- read.csv("NYT_2010.csv")
articles_2011 <- read.csv("NYT_2011.csv")
articles_2012 <- read.csv("NYT_2012.csv")
articles_2013 <- read.csv("NYT_2013.csv")
articles_2014 <- read.csv("NYT_2014.csv")
articles_2015 <- read.csv("NYT_2015.csv")
articles_2016 <- read.csv("NYT_2016.csv")
articles_2017 <- read.csv("NYT_2017.csv")
articles_2018 <- read.csv("NYT_2018.csv")
articles_2019 <- read.csv("NYT_2019.csv")
articles_2020 <- read.csv("NYT_2020.csv")
articles_2021 <- read.csv("NYT_2021.csv")
articles_2022 <- read.csv("NYT_2022.csv")
articles_2023 <- read.csv("NYT_2023.csv")

# NYT data frame
NYT_inflation <- rbind(articles_2010, articles_2011, articles_2012, articles_2013, articles_2014,
                    articles_2015, articles_2016, articles_2017, articles_2018, articles_2019, 
                    articles_2020, articles_2021, articles_2022, articles_2023)

NYT_inflation$Date <- as.Date(NYT_inflation$Date)

# Order by date_column
NYT_inflation <- NYT_inflation[order(NYT_inflation$Date), ]

# Writing as csv
write.csv(NYT_inflation, file = "NYT_Inflation.csv", row.names = FALSE)
