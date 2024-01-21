#--------------------------------------------------------
# Name  : RQ3 - Impact of Sentiment on Inflation and
#               Inflation expectations
# Desc. : Correlation between Inflation and Inflation
#         Expectations and Inflation News Sentiment. 
#         Forecasting Inflation and Inflation
#         Expectations using Nes Sentiment.
# Author: Tammo Thobe
# Course: Data Analysis Lab
# Date  : 18.01.2024
#--------------------------------------------------------

rm(list = ls())

# Libraries and packages
if(!require(dplyr)){
  install.packages("dplyr")
  library(dplyr)
}

if(!require(forecast)){
  install.packages("forecast")
  library(forecast)
}

if(!require(tseries)){
  install.packages("tseries")
  library(tseries)
}

# Data
Index <- read.csv("Inflation Sentiment Index.csv")

Index$Date <- as.Date(Index$Date)

Topic_Index <- read.csv("Inflation Topic Index.csv")

Topic_Index$Date <- as.Date(Topic_Index$Date)

MF  <- read.csv("MICH.csv")

MF <- MF %>%
  mutate(Date = as.Date(DATE),  # Convert DATE to Date object
         DATE = NULL)   

SPF <- read.csv("EXPINF1YR.csv")

SPF <- SPF %>%
  mutate(Date = as.Date(DATE),  # Convert DATE to Date object
         DATE = NULL) 

CPI <- read.csv("CPALTT01USM659N.csv") # consumer price index: all items, growth period previous year

CPI <- CPI %>%
  mutate(Date = as.Date(DATE),  # Convert DATE to Date object
         DATE = NULL) 

# Analysis

cor(Index[Index$Date <= max(CPI$Date), ]$score, CPI$CPALTT01USM659N)
cor(Index[Index$Date <= max(MF$Date), ]$score, MF$MICH)
cor(Index[Index$Date <= max(SPF$Date), ]$score, SPF$EXPINF1YR)

model <- lm(CPI$CPALTT01USM659N ~ Index[Index$Date <= max(CPI$Date), ]$score)
summary(model)
vcov_nw <- NeweyWest(model, lag = NULL)
coeftest(model, vcov = vcov_nw)

model <- lm(MF$MICH ~ Index[Index$Date <= max(MF$Date), ]$score)
summary(model)
vcov_nw <- NeweyWest(model, lag = NULL)
coeftest(model, vcov = vcov_nw)

model <- lm(SPF$EXPINF1YR ~ Index[Index$Date <= max(SPF$Date), ]$score)
summary(model)
vcov_nw <- NeweyWest(model, lag = NULL)
coeftest(model, vcov = vcov_nw)


# Forecasting Inflation and Inflation Expectations

# (Partial) Autocorrelations
acf(CPI$CPALTT01USM659N)
pacf(CPI$CPALTT01USM659N)

adf.test(CPI$CPALTT01USM659N)
kpss.test(CPI$CPALTT01USM659N)

auto.arima(CPI$CPALTT01USM659N, ic = "aic", stationary = FALSE,
           max.p = 2, max.q = 2, max.P = 0, max.Q = 0,
           stepwise = FALSE, trace = TRUE, approximation = FALSE)

# Arima (1, 1, 0)

acf(MF$MICH)
pacf(MF$MICH)

adf.test(MF$MICH)
kpss.test(CPI$CPALTT01USM659N)

auto.arima(MF$MICH, ic = "aic", stationary = FALSE,
           max.p = 2, max.q = 2, max.P = 0, max.Q = 0,
           stepwise = FALSE, trace = TRUE, approximation = FALSE)
# auto.arima selected Arima(0, 1, 1) but based on the plots i would
# argue for a Arima(1, 1, 0) process

acf(SPF$EXPINF1YR, lag.max = 100)
pacf(SPF$EXPINF1YR)

adf.test(SPF$EXPINF1YR)
kpss.test(SPF$EXPINF1YR)

auto.arima(SPF$EXPINF1YR, ic = "aic", stationary = FALSE,
           max.p = 2, max.q = 2, max.P = 0, max.Q = 0,
           stepwise = FALSE, trace = TRUE, approximation = FALSE)
# ARIMA (1, 1, 2) or ARIMA (1, 1, 1)

# Estimation and forecast in general
CPI_arima <- arima(CPI$CPALTT01USM659N, order = c(1, 1, 0))
CPI_fc <- forecast(CPI_arima, h = 3)
CPI_fc
plot(CPI_fc, shaded = FALSE)
plot(CPI_fc, shadecols = gray(c(0.8, 0.6)))

MF_arima <- arima(MF$MICH, order = c(1, 1, 0))
MF_fc <- forecast(MF_arima, h = 3)
MF_fc
plot(MF_fc, shaded = FALSE)
plot(MF_fc, shadecols = gray(c(0.8, 0.6)))

SPF_arima <- arima(MF$MICH, order = c(1, 1, 1))
SPF_fc <- forecast(SPF_arima, h = 3)
SPF_fc
plot(SPF_fc, shaded = FALSE)
plot(SPF_fc, shadecols = gray(c(0.8, 0.6)))

## Inflation Topic Index
# Lagged Indeces for the respective forecasting exercise
TIndex_lag_CPI <- lag(Topic_Index[Topic_Index$Date <= "2023-10-01", ]$Index, 1)
TIndex_lag_MF <- lag(Topic_Index[Topic_Index$Date <= "2023-11-01", ]$Index, 1)
TIndex_lag_SPF <- lag(Topic_Index$Index, 1)

# CPI
data_combined <- cbind(CPI$CPALTT01USM659N, TIndex_lag_CPI)
data_combined <- na.omit(data_combined)

CPI_arima <- arima(CPI[2:163, ]$CPALTT01USM659N, order = c(1, 1, 0))
CPI_fc <- forecast(CPI_arima, h = 3)

train_cpi = data_combined[1:162, 1]
train_index = data_combined[1:162, 2]
new_train_index <- data_combined[163:165, 2]

CPI_arima_tindex <- arima(train_cpi, order = c(1, 1, 0), xreg=train_index)
CPI_TIndex_pred  <- predict(CPI_arima_tindex, newxreg = new_train_index)

MSE_CPI_pred       <- mean((CPI[164:166, ]$CPALTT01USM659N - CPI_fc$mean)^2)
MSE_CPI_TIndex_pred <- mean((data_combined[163:165, 1] - CPI_TIndex_pred$pred)^2)


# MF
data_combined <- cbind(MF$MICH, TIndex_lag_MF)
data_combined <- na.omit(data_combined)

MF_arima <- arima(MF[2:164, ]$MICH, order = c(1, 1, 0))
MF_fc <- forecast(MF_arima, h = 3)

train_mf = data_combined[1:163, 1]
train_index = data_combined[1:163, 2]
new_train_index <- data_combined[164:166, 2]

MF_arima_tindex <- arima(train_mf, order = c(1, 1, 0), xreg=train_index)
MF_TIndex_pred  <- predict(MF_arima_tindex, newxreg = new_train_index)

MSE_MF_pred       <- mean((MF[165:167, ]$MICH - MF_fc$mean)^2)
MSE_MF_TIndex_pred <- mean((data_combined[164:166, 1] - MF_TIndex_pred$pred)^2)


# SPF
data_combined <- cbind(SPF$EXPINF1YR, TIndex_lag_SPF)
data_combined <- na.omit(data_combined)

SPF_arima <- arima(SPF[2:165, ]$EXPINF1YR, order = c(1, 1, 1))
SPF_fc <- forecast(SPF_arima, h = 3)

train_spf = data_combined[1:164, 1]
train_index = data_combined[1:164, 2]
new_train_index <- data_combined[165:167, 2]

SPF_arima_tindex <- arima(train_spf, order = c(1, 1, 1), xreg=train_index)
SPF_TIndex_pred  <- predict(SPF_arima_tindex, newxreg = new_train_index)

MSE_SPF_pred       <- mean((SPF[166:168, ]$EXPINF1YR - SPF_fc$mean)^2)
MSE_SPF_TIndex_pred <- mean((data_combined[165:167, 1] - SPF_TIndex_pred$pred)^2)

## Inflation Sentiment Index
# Lagged Indeces for the respective forecasting exercise
Index_lag_CPI <- lag(Index[Index$Date <= "2023-10-01", ]$score, 1)
Index_lag_MF <- lag(Index[Index$Date <= "2023-11-01", ]$score, 1)
Index_lag_SPF <- lag(Index$score, 1)

# CPI
data_combined <- cbind(CPI$CPALTT01USM659N, Index_lag_CPI)
data_combined <- na.omit(data_combined)

CPI_arima <- arima(CPI[2:163, ]$CPALTT01USM659N, order = c(1, 1, 0))
CPI_fc <- forecast(CPI_arima, h = 3)

train_cpi = data_combined[1:162, 1]
train_index = data_combined[1:162, 2]
new_train_index <- data_combined[163:165, 2]

CPI_arima_index <- arima(train_cpi, order = c(1, 1, 0), xreg=train_index)
CPI_Index_pred  <- predict(CPI_arima_index, newxreg = new_train_index)

MSE_CPI_pred       <- mean((CPI[164:166, ]$CPALTT01USM659N - CPI_fc$mean)^2)
MSE_CPI_Index_pred <- mean((data_combined[163:165, 1] - CPI_Index_pred$pred)^2)


# MF
data_combined <- cbind(MF$MICH, Index_lag_MF)
data_combined <- na.omit(data_combined)

MF_arima <- arima(MF[2:164, ]$MICH, order = c(1, 1, 0))
MF_fc <- forecast(MF_arima, h = 3)

train_mf = data_combined[1:163, 1]
train_index = data_combined[1:163, 2]
new_train_index <- data_combined[164:166, 2]

MF_arima_index <- arima(train_mf, order = c(1, 1, 0), xreg=train_index)
MF_Index_pred  <- predict(MF_arima_index, newxreg = new_train_index)

MSE_MF_pred       <- mean((MF[165:167, ]$MICH - MF_fc$mean)^2)
MSE_MF_Index_pred <- mean((data_combined[164:166, 1] - MF_Index_pred$pred)^2)


# SPF
data_combined <- cbind(SPF$EXPINF1YR, Index_lag_SPF)
data_combined <- na.omit(data_combined)

SPF_arima <- arima(SPF[2:165, ]$EXPINF1YR, order = c(1, 1, 1))
SPF_fc <- forecast(SPF_arima, h = 3)

train_spf = data_combined[1:164, 1]
train_index = data_combined[1:164, 2]
new_train_index <- data_combined[165:167, 2]

SPF_arima_index <- arima(train_spf, order = c(1, 1, 1), xreg=train_index)
SPF_Index_pred  <- predict(SPF_arima_index, newxreg = new_train_index)

MSE_SPF_pred       <- mean((SPF[166:168, ]$EXPINF1YR - SPF_fc$mean)^2)
MSE_SPF_Index_pred <- mean((data_combined[165:167, 1] - SPF_Index_pred$pred)^2)
