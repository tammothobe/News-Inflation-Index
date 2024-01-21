'''
Program: Functions to calculate the news sentiment score of text files in mains_NS_score.py
Last Modified: 09/17/2020

This code was developed in the study "Measuring News Sentiment" by Adam Shapiro, 
Moritz Sudhof, and Daniel Wilson. Journal of Econometrics. Please cite accordingly. 

[Shapiro, Adam Hale, Moritz Sudhof, and Daniel J. Wilson. 2020. “Measuring News Sentiment.” 
FRB San Francisco Working Paper 2017-01. Available at https://doi.org/10.24148/wp2017-01.]

Copyright (c) 2020, Adam Shapiro, Moritz Sudhof, and Daniel Wilson and the Federal Reserve Bank of San Francisco. 
All rights reserved. 
'''

###################### - MANUAL SETTINGS - ####################################
lexicon_dir = "/Users/tammo/Desktop/Data Analysis Lab/news_sentiment_replication_code"

###################### - LIBRARIES - ##########################################
import os
import csv
import nltk
import pandas as pd
from nltk.tokenize import TweetTokenizer
from nltk.corpus import opinion_lexicon
from nltk.sentiment.vader import SentimentIntensityAnalyzer


# Common functions for parsing raw article files, loading and manipulating lexicons, etc.

###############################################################################
# Parsing news files

def parse_news_text_file(fn):
    lines = open(fn, encoding='iso-8859-1').read().splitlines()
    
    lines = [l for l in lines if l.strip()]
    # Strip metadata blocks, retain headline + article
    if len(lines) > 4:
        headline = lines[2]
        article = lines[4:-1]
        text = "\n".join([headline] + article)
    elif len(lines) > 1:
        text = "\n".join(lines)        
    elif len(lines) == 1:
        text = lines[0]
    elif len(lines) == 0:
        text = 'BLANK ARTICLE'
    return text


###############################################################################
# Loading lexicons
# Lexicons are simply dictionaries mapping words to their respective sentiment scores

def load_lm_lexicon():
    # Loughran McDonald
    fn = os.path.join(lexicon_dir, "LoughranMcDonald_2016.csv")
    reader = csv.DictReader(open(fn))
    words2weights = {}
    for r in reader:
        pos_score = 1. if r['Positive'] != "0" else 0.
        neg_score = 1. if r['Negative'] != "0" else 0.
        sentiment_score = pos_score - neg_score
        w = r['\ufeffWord'].lower() # weird header in this file
        #w = r['Word'].lower() 
        if sentiment_score:
            words2weights[w] = sentiment_score
    return words2weights


def load_hl_lexicon():
    # Bing Liu opinion lexicon
    words2weights = {w: 1.0 for w in opinion_lexicon.positive()}
    words2weights.update({w: -1.0 for w in opinion_lexicon.negative()})
    return words2weights

def load_news_pmi_lexicon(lexicon_fn):
    # The lexicon built on the full news corpus
    fn = os.path.join(lexicon_dir, lexicon_fn)
    df = pd.read_csv(fn)
    words2weights = dict(zip(df['word'].values, df['sentiment'].values))
    return words2weights


def combine_lexicons(lexicons):
    # Takes as input a list of lexicons (as defined above)
    # and returns the union
    lexicons.reverse()
    words2weights = {}

    for lex in lexicons:
        for w in lex:
            words2weights.setdefault(w, 0.0)
            words2weights[w] += lex[w]
    
    return words2weights


#########################
# Using lexicons for text scoring

TOKENIZE_FUNC = TweetTokenizer(preserve_case=False).tokenize
NEGATION_WORDS = set(['no', 'not', 'never', 'none', 'nobody', 'nowhere', 'nothing', 'neither', 'nor', 'hardly', 'scarcely', 'barely', 'doesn\'t', 'isn\'t', 'wasn\'t', 'shouldn\'t', 'wouldn\'t', 'couldn\'t', 'won\'t', 'can\'t', 'don\'t', 'didn\'t', 'hasn\'t', 'haven\'t', 'hadn\'t', 'isnt', 'wasnt', 'shouldnt', 'wouldnt', 'couldnt', 'wont', 'cant', 'dont', 'didnt', 'hasnt', 'havent', 'hadnt'])

def get_lexicon_scoring_func(lexicon):
    def lexicon_scoring_func(text):
        if isinstance(text, list):
            words = text
        else:
            words = TOKENIZE_FUNC(text)
        score = sum([lexicon.get(w.lower(), 0.0) for w in words])
        score = score/len(words)        
        # We're measuring net negativity, not positivity,
        # so let's flip the sign
        score *= -1.0
        return score
    return lexicon_scoring_func

def get_negated_lexicon_scoring_func(lexicon):
    def negated_lexicon_scoring_func(text):
        if isinstance(text, list):
            words = text
        else:
            words = TOKENIZE_FUNC(text)
        score = 0.0
        for i, w in enumerate(words):
            context = words[max(0,i-3):i]
            scalar = 1.0
            if set(context) & NEGATION_WORDS:
                scalar = -1.0
            score += (scalar*lexicon.get(w.lower(), 0.0))
        score = score/len(words)
        # We're measuring net negativity, not positivity,
        # so let's flip the sign
        score *= -1.0
        return score
    return negated_lexicon_scoring_func

