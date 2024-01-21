#--------------------------------------------------------
# Name  : RQ2 - Greater news coverage associated with 
#         more rational household expectations?
# Desc. : Relationship between Topic Index and the 
#         aquared gap between professional and consumer
#         expectations.
# Author: Tammo Thobe
# Course: Data Analysis Lab
# Date  : 16.01.2024
#--------------------------------------------------------

rm(list = ls())

# Libraries and packages
if(!require(dplyr)){
  install.packages("dplyr")
  library(dplyr)
}

if(!require(sandwich)){
  install.packages("sandwich")
  library(sandwich)
}

if(!require(lmtest)){
  install.packages("lmtest")
  library(lmtest)
}

# Data
Index <- read.csv("Inflation Topic Index.csv")

Index$Date <- as.Date(Index$Date)

MF  <- read.csv("MICH.csv") # Michigan Consumer Survey, Inflation Expectations

MF <- MF %>%
  mutate(Date = as.Date(DATE),  # Convert DATE to Date object
         DATE = NULL)   
  
SPF <- read.csv("EXPINF1YR.csv") # FED 1 Year expected inflation rate (Corresponding to Survey of Professional Forecasters)

SPF <- SPF %>%
  mutate(Date = as.Date(DATE),  # Convert DATE to Date object
         DATE = NULL) 

SPF <- SPF[SPF$Date <= "2023-11-01", ]
  
CPI <- read.csv("CPALTT01USM659N.csv") # consumer price index: all items, growth period previous year

CPI <- CPI %>%
  mutate(Date = as.Date(DATE),  # Convert DATE to Date object
         DATE = NULL) 

# Calculating the squared gap between average consumer forecast and professional forecasts
GAPMS <- MF %>%
  mutate(GAPMS = (MICH - SPF$EXPINF1YR)^2,
         Date = Date) %>%
  select(-c("MICH"))


# Plot all three Inflation related variables

plot(CPI$Date, CPI$CPALTT01USM659N, type = "l", ylim = range(c(CPI$CPALTT01USM659N, MF$MICH, SPF$EXPINF1YR)),
     xlab = "", ylab = "Percent", xaxt = "n")

# Add lines for other variables
lines(MF$Date, MF$MICH, lty = 2)
lines(SPF$Date, SPF$EXPINF1YR, lty = 3)

axis(1, at = seq(min(MF$Date), max(MF$Date), by = "2 years"), labels = format(seq(min(MF$Date), max(MF$Date), by = "2 years"), "%Y"))

# Add legend
legend("topleft", legend = c("CPI", "Michigan Forecast", "FED Forecast"), lty = 1:3)


# Model
plot(GAPMS$GAPMS ~ Index[Index$Date <= "2023-11-01", ]$Index, xlab = "Index",
     ylab = "GAPMS", main = "All sample observations")

# All observations
model <- lm(GAPMS$GAPMS ~ Index[Index$Date <= "2023-11-01", ]$Index)
summary(model)
vcov_nw <- NeweyWest(model, lag = NULL)
coeftest(model, vcov = vcov_nw)

# 2010 - 2022
model <- lm(GAPMS[GAPMS$Date <= "2021-12-01", ]$GAPMS ~ Index[Index$Date <= "2021-12-01", ]$Index)
summary(model)
vcov_nw <- NeweyWest(model, lag = NULL)
coeftest(model, vcov = vcov_nw)

# 2010 - 2021
model <- lm(GAPMS[GAPMS$Date <= "2020-12-01", ]$GAPMS ~ Index[Index$Date <= "2020-12-01", ]$Index)
summary(model)
vcov_nw <- NeweyWest(model, lag = NULL)
coeftest(model, vcov = vcov_nw)

# 2010 - 2020
model <- lm(GAPMS[GAPMS$Date <= "2019-12-01", ]$GAPMS ~ Index[Index$Date <= "2019-12-01", ]$Index)
summary(model)
vcov_nw <- NeweyWest(model, lag = NULL)
coeftest(model, vcov = vcov_nw)

# 2010 - 2019
model <- lm(GAPMS[GAPMS$Date <= "2018-12-01", ]$GAPMS ~ Index[Index$Date <= "2018-12-01", ]$Index)
summary(model)
vcov_nw <- NeweyWest(model, lag = NULL)
coeftest(model, vcov = vcov_nw)

# 2020 - 2022
model <- lm(GAPMS[GAPMS$Date >= "2020-01-01" & GAPMS$Date <= "2021-12-01", ]$GAPMS ~ Index[Index$Date >= "2020-01-01" & Index$Date <= "2021-12-01", ]$Index)
summary(model)
vcov_nw <- NeweyWest(model, lag = NULL)
coeftest(model, vcov = vcov_nw)


