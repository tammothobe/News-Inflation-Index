**The Impact of Media Inflation Narratives**

This project gathers articles using the New York Times API corresponding to the topic of inflation. The data is classified geographically using the newsmap classifier corresponding to the United States and then a topic classification using LDA is done to ensure the topic corresponds to inflation.


Based on the final data two indeces are created, the Inflation Topic Index which captures the degree of news reporting on inflation and the Inflation Sentiment Index, that captures the sentiment on inflation news.
The indeces reach from January 2010 to December 2023.

The indeces are further used to analyze the impact of media inflation narratives on inflation, inflation expectations and economic outcomes respectively.

Project steps:
1. Data gathering and preprocessing
    - Web Scraping NYT per year.R (obtaining data from https://www.nytimes.com, M1/M2)
    - Consolidation NYT.R (consolidating yearly files into one data set, M1)
    - Geographical Classification of NYT articles.R (classifying articles corresponding to the US, M1/M3)
    - Topic Classification.R (additional classification to the inflation topic, M1/M3)
    - Final Data Preparation.R (final adjustments, M1/M2)
    - Sentiment Analysis Preparation.R (preparation for the sentiment analysis, M1/M2)
2. Data analysis
    - Topic Index.R (Creating the Inflation Topic Index, M1/M3)
    - NS\_functions.py (Functions necessary for the sentiment score file, M1)
    - main\_NS\_score.py (Calculating the sentiment score for each article, M1/M3)
    - Inflation Sentiment Index.R (Creating the Inflation Sentiment Index, M1/M3)
3. Results 
    - RQ1.R (Answering Research Question 1, M3)
    - RQ2.R (Answering Research Question 2, M3)
    - RQ3.R (Answering Research Question 3, M3)
    - RQ4.R (Answering Research Question 4, M3)


Data, Plots and Documents can be found in the respective folders.


