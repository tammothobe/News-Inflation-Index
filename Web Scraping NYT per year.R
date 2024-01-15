#--------------------------------------------------------
# Name  : Web Scraping NYT per year
# Desc. : Scraping Article Information using the New 
#         York Times API and extracting article bodies 
#         from the respective URLs.
#         Since a for loop ran into errors, the scraping
#         is done on a yearly basis, which in turn is
#         divided into three parts and then merged.
# Author: Tammo Thobe
# Course: Data Analysis Lab
# Date  : 02.12.2023
#--------------------------------------------------------

rm(list = ls())

# Libraries
library(jsonlite)
library(dplyr)
library(httr)
library(rvest)
library(dplyr)      
library(stringr) 


#Function to extract Article body from NYT
get_article_body <- function (url) {
  
  # download article page
  response <- GET(url)
  
  # check if request was successful
  if (response$status_code != 200) return(NA)
  
  # extract html
  html <- content(x        = response,
                  type     = "text",
                  encoding = "UTF-8")
  
  # parse html
  parsed_html <- read_html(html)
  
  # define paragraph DOM selector
  selector <- "article#story div.StoryBodyCompanionColumn div p"
  
  # parse content
  parsed_html %>%
    html_nodes(selector) %>%      # extract all paragraphs within class 'article-section'
    html_text() %>%               # extract content of the <p> tags
    str_replace_all("\n", "") %>% # replace all line breaks
    paste(collapse = " ")         # join all paragraphs into one string
}



NYTIMES_KEY <-  "nfI2F190wdewpmEbWNng7luJn7znGny9" # Change to specific key if necessary
term <- "inflation" # terms can also be specified differently

# Part 1

begin_date <- "20100101"
end_date <- "20100430"

baseurl <- paste0("https://api.nytimes.com/svc/search/v2/articlesearch.json?q=",term,
                  "&begin_date=",begin_date,"&end_date=",end_date,
                  "&facet_filter=true&api-key=",NYTIMES_KEY, sep="")

initialQuery <- fromJSON(baseurl)
maxPages <- round((initialQuery$response$meta$hits[1] / 10)-1) 

pages_NYT <- vector("list",length=maxPages)

for(i in 0:maxPages){
  nytSearch <- fromJSON(paste0(baseurl, "&page=", i), flatten = TRUE) %>% data.frame() 
  pages_NYT[[i+1]] <- nytSearch 
  Sys.sleep(12) # Wait 12 seconds between calls
}

inflation_2010_1_articles <- rbind_pages(pages_NYT)

URL <- inflation_2010_1_articles$response.docs.web_url

articles <- as.data.frame(URL)

articles$body <- NA

articles$Date <- inflation_2010_1_articles$response.docs.pub_date

articles <- articles %>%
  filter(grepl("^https://www.nytimes.com/2010/", URL))

# initialize progress bar
pb <- txtProgressBar(min     = 1,
                     max     = nrow(articles),
                     initial = 1,
                     style   = 3)


# loop through articles and "apply" function
for (i in 1:nrow(articles)) {
  
  # "apply" function to i url
  articles$body[i] <- get_article_body(articles$URL[i])
  
  # update progress bar
  setTxtProgressBar(pb, i)
  
  # sleep for 12 sec
  Sys.sleep(12)
}


articles_2010_1 <- articles


# Part 2

begin_date <- "20100501"
end_date <- "20100831"

baseurl <- paste0("https://api.nytimes.com/svc/search/v2/articlesearch.json?q=",term,
                  "&begin_date=",begin_date,"&end_date=",end_date,
                  "&facet_filter=true&api-key=",NYTIMES_KEY, sep="")

initialQuery <- fromJSON(baseurl)
maxPages <- round((initialQuery$response$meta$hits[1] / 10)-1) 

pages_NYT <- vector("list",length=maxPages)

for(i in 0:maxPages){
  nytSearch <- fromJSON(paste0(baseurl, "&page=", i), flatten = TRUE) %>% data.frame() 
  pages_NYT[[i+1]] <- nytSearch 
  Sys.sleep(12) # Wait 12 seconds between calls
}

inflation_2010_2_articles <- rbind_pages(pages_NYT)

URL <- inflation_2010_2_articles$response.docs.web_url

articles <- as.data.frame(URL)

articles$body <- NA

articles$Date <- inflation_2010_2_articles$response.docs.pub_date

articles <- articles %>%
  filter(grepl("^https://www.nytimes.com/2010/", URL))

# initialize progress bar
pb <- txtProgressBar(min     = 1,
                     max     = nrow(articles),
                     initial = 1,
                     style   = 3)


# loop through articles and "apply" function
for (i in 1:nrow(articles)) {
  
  # "apply" function to i url
  articles$body[i] <- get_article_body(articles$URL[i])
  
  # update progress bar
  setTxtProgressBar(pb, i)
  
  # sleep for 12 sec
  Sys.sleep(12)
}


articles_2010_2 <- articles



# Part 3

begin_date <- "20100901"
end_date <- "20101231"

baseurl <- paste0("https://api.nytimes.com/svc/search/v2/articlesearch.json?q=",term,
                  "&begin_date=",begin_date,"&end_date=",end_date,
                  "&facet_filter=true&api-key=",NYTIMES_KEY, sep="")

initialQuery <- fromJSON(baseurl)
maxPages <- round((initialQuery$response$meta$hits[1] / 10)-1) 

pages_NYT <- vector("list",length=maxPages)

for(i in 0:maxPages){
  nytSearch <- fromJSON(paste0(baseurl, "&page=", i), flatten = TRUE) %>% data.frame() 
  pages_NYT[[i+1]] <- nytSearch 
  Sys.sleep(12) # Wait 12 seconds between calls
}

inflation_2010_3_articles <- rbind_pages(pages_NYT)

URL <- inflation_2010_3_articles$response.docs.web_url

articles <- as.data.frame(URL)

articles$body <- NA

articles$Date <- inflation_2010_3_articles$response.docs.pub_date

articles <- articles %>%
  filter(grepl("^https://www.nytimes.com/2010/", URL))

# initialize progress bar
pb <- txtProgressBar(min     = 1,
                     max     = nrow(articles),
                     initial = 1,
                     style   = 3)


# loop through articles and "apply" function
for (i in 1:nrow(articles)) {
  
  # "apply" function to i url
  articles$body[i] <- get_article_body(articles$URL[i])
  
  # update progress bar
  setTxtProgressBar(pb, i)
  
  # sleep for 12 sec
  Sys.sleep(12)
}


articles_2010_3 <- articles

# Binding all articles into one df
articles_2010 <- rbind(articles_2010_1, articles_2010_2, articles_2010_3)

# Saving the data frame as a csv file
write.csv(articles_2010, file = "NYT_2010.csv", row.names = FALSE)
