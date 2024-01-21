#--------------------------------------------------------
# Name  : Inflation Topic Classification
# Desc. : Topic Classification based on LDA, to ensure
#         that articles contents actually correspond
#         to the general topic of inflation.
# Author: Tammo Thobe
# Course: Data Analysis Lab
# Date  : 14.01.2024
#--------------------------------------------------------

rm(list = ls())

# Libraries and packages
if(!require(quanteda)){
  install.packages("quanteda")
  library(quanteda)
}

if(!require(seededlda)){
  install.packages("seededlda")
  library(seededlda)
}

if(!require(lubridate)){
  install.packages("lubridate")
  library(lubridate)
}

if(!require(quanteda.corpora)){
  install.packages("quanteda.corpora")
  library(quanteda.corpora)
}


# Loading the required data
NYT <- read.csv("NYT_us.csv")

# Tokenize and create a dfm
corp <- corpus(NYT, text_field = 'body')

month <- c('January', 'February', 'March', 'April', 'May', 'June',
           'July', 'August', 'September', 'October', 'November', 'December')
day <- c('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday')

comma <- "\u0097"

toks_news <- tokens(corp, remove_punct = TRUE, remove_numbers = TRUE, remove_symbol = TRUE)
toks_news <- tokens_remove(toks_news, pattern = c(stopwords("en"), comma, month, day))
dfmat_news <- dfm(toks_news) %>% 
  dfm_trim(min_termfreq = 0.8, termfreq_type = "quantile",
           max_docfreq = 0.1, docfreq_type = "prop")

# LDA classification
tmod_lda <- textmodel_lda(dfmat_news, k = 10)

terms(tmod_lda, 30)

head(topics(tmod_lda), 20)

table(topics(tmod_lda))

# topic 2; home prices, consumer goods, services
# topic 3; company finances, professional finance
# topic 4; student loans, tuition fees, universities and schools
# topic 5; medical prices, drugs, premiums etc
# topic 6; politics
# topic 7; main inflation topic, forecasts, monetary policy etc.
# topic 8; income, private finances
# topic 9; other inflation related topics
# Remove topic1 (general politics), topic10 (energy)

dfmat_news$topic <- topics(tmod_lda)

NYT$topic <- topics(tmod_lda)

# Main Corpus with all inflation related topics
NYT_main <- NYT[NYT$topic %in% c("topic2", "topic3", "topic4", "topic5",
                                 "topic6", "topic7", "topic8", "topic9"), ]

# Saving  as csv file
write.csv(NYT_main, file = "NYT_main.csv", row.names = FALSE)


