'''
Program: Calculates the news sentiment score of text files
Last Modified: 09/17/2020

This code was developed in the study "Measuring News Sentiment" by Adam Shapiro, 
Moritz Sudhof, and Daniel Wilson. Journal of Econometrics. Please cite accordingly. 

[Shapiro, Adam Hale, Moritz Sudhof, and Daniel J. Wilson. 2020. “Measuring News Sentiment.” 
FRB San Francisco Working Paper 2017-01. Available at https://doi.org/10.24148/wp2017-01.]

Copyright (c) 2020, Adam Shapiro, Moritz Sudhof, and Daniel Wilson and the Federal Reserve Bank of San Francisco. 
All rights reserved. 
'''

###################### - MANUAL SETTINGS - ####################################
function_dir = '/Users/tammo/Desktop/Data Analysis Lab/news_sentiment_replication_code'
data_dir = '/Users/tammo/Desktop/Data Analysis Lab/news_sentiment_replication_code/TXT_files'
output_dir = '/Users/tammo/Desktop/Data Analysis Lab/news_sentiment_replication_code'
#doc_types = [TXT_files]

###################### - LIBRARIES - ##########################################
import os
import numpy as np
import pandas as pd
from collections import Counter
import nltk
nltk.download('opinion_lexicon')

# Set directory to load in aux functions
os.chdir(function_dir)
import NS_functions
import importlib
importlib.reload(NS_functions)


##################### - START OF CODE - #######################################

# Function that loads in the texts and applies the scoring function
def score_all_articles(scoring_func):
    scores = []
    
    # Remove the loop over doc_types
    doc_dir = data_dir
    os.chdir(doc_dir)
    fns = [fn for fn in os.listdir(doc_dir) if fn.endswith(".txt")]

    for fn in fns:
        fn = os.path.join(doc_dir, fn)
        text = NS_functions.parse_news_text_file(fn)
        score = scoring_func(text)
        scores.append({
            "file": os.path.basename(fn),
            "sentiment": score,
            "text": text
        })
    return scores



# Set up our scoring function -- Vader augmented with the LM and HL lexicons
lm_lexicon = NS_functions.load_lm_lexicon()
hl_lexicon = NS_functions.load_hl_lexicon()


# News PMI + LM + HL Lexicon
news_lexicon_fn = "ns.vader.sentences.20k.csv"
news_lexicon = NS_functions.load_news_pmi_lexicon(news_lexicon_fn)
news_lm_hl_lexicon = NS_functions.combine_lexicons([lm_lexicon, hl_lexicon, news_lexicon])
news_lm_hl_scoring_func = NS_functions.get_lexicon_scoring_func(news_lm_hl_lexicon)
news_lm_hl_negated_scoring_func = NS_functions.get_negated_lexicon_scoring_func(news_lm_hl_lexicon)


# Get the new-win scores
scored_articles = score_all_articles(news_lm_hl_negated_scoring_func)

# Create df of scores
scores = [d['sentiment'] for d in scored_articles]
files = [d['file'] for d in scored_articles]
df = pd.DataFrame({'file':files, 'score':scores})


# Output .csv of news sentiment to data folder
os.chdir(output_dir)
df.to_csv('ns_scores.csv')


