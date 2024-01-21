#--------------------------------------------------------
# Name  : Geographical Classification of NYT articles
# Desc. : Using the newsmap library, the data is 
#         classified s.t. only articles corresponding 
#         to the United States are kept.
# Author: Tammo Thobe
# Course: Data Analysis Lab
# Date  : 21.12.2023
#--------------------------------------------------------

rm(list = ls())

# Libraries and packages

if(!require(devtools)){
  install.packages("devtools")
  library(devtools)
}

devtools::install_github("koheiw/newsmap")
library(newsmap)

if(!require(quanteda)){
  install.packages("quanteda")
  library(quanteda)
}

if(!require(dplyr)){
  install.packages("dplyr")
  library(dplyr)
}

if(!require(stringr)){
  install.packages("stringr")
  library(stringr)
}

if(!require(lubridate)){
  install.packages("lubridate")
  library(lubridate)
}

# New York Times Data
NYT <- read.csv("NYT_Inflation.csv")


# Training Newsmap Classifier as outlined by K. Watanabe
# https://eprints.lse.ac.uk/69525/1/Watanabe_Newsmap_semi-supervised_approach.pdf

corp <- corpus(NYT, text_field = 'body')


# Custom stopwords
month <- c('January', 'February', 'March', 'April', 'May', 'June',
           'July', 'August', 'September', 'October', 'November', 'December')
day <- c('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')

comma <- "\u0097"


# Tokenize
toks <- tokens(corp)
toks <- tokens_remove(toks, stopwords('english'), valuetype = 'fixed', padding = TRUE)
toks <- tokens_remove(toks, c(month, day, comma), valuetype = 'fixed', padding = TRUE)

# quanteda v1.5 introduced 'nested_scope' to reduce ambiguity in dictionary lookup
toks_label <- tokens_lookup(toks, data_dictionary_newsmap_en, 
                            levels = 3, nested_scope = "dictionary") # level 3 is countries
dfmt_label <- dfm(toks_label)

dfmt_feat  <- dfm(toks, tolower = FALSE)
dfmt_feat_select <- dfm_select(dfmt_feat, selection = "keep", '^[A-Z][A-Za-z1-2]+', 
                        valuetype = 'regex', case_insensitive = FALSE) # include only proper nouns to model
dfmt_feat_select <- dfm_trim(dfmt_feat_select, min_termfreq = 10)

model <- textmodel_newsmap(dfmt_feat_select, y = dfmt_label)

# Features with largest weights
coef(model, n = 25)[c("us", "gb", "fr", "br", "jp")]

# Predicting the actual model
pred_nm <- predict(model)
head(pred_nm, 20)

count <- sort(table(factor(pred_nm, levels = colnames(dfmt_label))), decreasing = TRUE)
head(count, 20)

# Adding predicted country values to the original data frame
NYT$country <- pred_nm

# Everything that contains Wall Street should also be labelled as United States
NYT <- NYT %>%
  mutate(country = factor(ifelse(str_detect(body, "Wall Street"), "us", as.character(country)), levels = levels(NYT$country)))

# Subset for United States
NYT_us <- NYT %>%
  filter(str_detect(country, "us"))

NYT_us$Date <- as.Date(NYT_us$Date)

# Check for accuracy of Date values
date_counts <- table(NYT_us$Date)

barplot(date_counts, main = "Date Frequencies", xlab = "Date", ylab = "Frequency")

# Extracting date parts from URL to update the Date column, since some values were not correct
NYT_us <- NYT_us %>%
  mutate(Date_from_URL = str_extract(URL, "\\d{4}/\\d{2}/\\d{2}")) %>%
  mutate(Date_from_URL = ymd(Date_from_URL))

# Updating the Date column
NYT_us$Date <- coalesce(NYT_us$Date_from_URL, NYT_us$Date)

# Removing the temporary column
NYT_us <- NYT_us %>% select(-Date_from_URL)

# Saving as csv
write.csv(NYT_us, file = "NYT_us.csv", row.names = FALSE)


