#--------------------------------------------------------
# Name  : RQ1 - Correlation Inflation and Inflation 
#               reporting
# Desc. : When does the media report about inflation
#         and what patterns can be identified
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

Index <- Index[Index$Date <= "2023-10-01", ] # Since data for CPI only available up to 10-23

Index$Date <- as.Date(Index$Date)

CPI <- read.csv("CPALTT01USM659N.csv") # consumer price index: all items, growth period previous year

CPI$Date <- as.Date(CPI$DATE)

data <- left_join(Index, CPI, by = c("Date"))

data <- data[, c(2, 1, 4)]

# Plotting Index and CPI
## add extra space to right margin of plot within frame
par(mar=c(5, 4, 4, 6) + 0.1)

## Plot first set of data and draw its axis
plot(Index$Date, Index$Index, pch=16, axes=FALSE, ylim=c(0,1), xlab="", ylab="", 
     type="l",col="black")
axis(2, ylim=c(0,1),col="black",las=1)  ## las=1 makes horizontal labels
mtext("Topic Index",side=2,line=3)
box()

## Allow a second plot on the same graph
par(new=TRUE)

## Plot the second plot and put axis scale on right
plot(CPI$Date, CPI$CPALTT01USM659N, pch=15,  xlab="", ylab="", ylim=c(-0.5,10), 
     axes=FALSE, type="l", lty = 2, col="blue")
## a little farther out (line=4) to make room for labels
mtext("CPI growth (previous period, in %)",side=4,col="black",line=2.5) 
axis(4, ylim=c(-0.5,10), col="black",col.axis="black",las=1)

## Draw the time axis
axis(1, at = seq(min(Index$Date), max(Index$Date), by = "2 years"), labels = format(seq(min(Index$Date), max(Index$Date), by = "2 years"), "%Y"))

## Add Legend
legend("topleft",legend=c("Inflation Topic Index","Consumer Price Index: All Items"),
       text.col=c("black","blue"),lty = c(1, 2),col=c("black","blue"))


# Correlation between actual inflation and inflation news
plot(CPI$CPALTT01USM659N ~ Index$Index, xlab = "Topic Index",
     ylab = "CPI growth (previous period, in %)")

correlation <- cor(Index$Index, CPI$CPALTT01USM659N, method = "pearson")

model <- lm(Index ~ CPALTT01USM659N, data = data)
summary(model)

# Compute Newey-West standard errors, to adjust for heteroscedacticity and serially correlated error terms
vcov_nw <- NeweyWest(model, lag = NULL)
coeftest(model, vcov = vcov_nw)

# Categorical Variable indicating whether inflation is above or below the mean
data <- data %>%
  mutate(IndexIntensity = ifelse(CPALTT01USM659N > mean(CPALTT01USM659N), 1, 0))

data_larger  <- data[data$IndexIntensity == 1, ] 
data_smaller <- data[data$IndexIntensity == 0, ] 

model <- lm(Index ~ CPALTT01USM659N, data = data_larger)
summary(model)
vcov_nw <- NeweyWest(model, lag = NULL)
coeftest(model, vcov = vcov_nw)

model <- lm(Index ~ CPALTT01USM659N, data = data_smaller)
summary(model)
vcov_nw <- NeweyWest(model, lag = NULL)
coeftest(model, vcov = vcov_nw)

