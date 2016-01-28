from collections import Counter
import numpy as np
import time

def get_count_dict(ngrams):
    '''
    Make a dictionary of ngram counts (number of times an ngram appeared in the 
    training data). The key is the ngram, and the value is the count.
    '''
    countDict = Counter(ngrams)
    return countDict

def get_MLE_dict(nMinus1GramDict,ngramDict,ngramOrder):
    '''
    Input:
        (1) a dictionary of n-grams and their counts  
        (2) a dictionary of n-1-grams and their counts
        (2) the ngram order of the ngrams (an interger value)
    Function:
        compute the conditional probabilities, aka the maximum 
        likelihood estimate (MLE) for the n-grams.
    '''
    MLEdict={}
    for ngram, ngramCount in ngramDict.items():
        nMinus1Gram = ngram[:ngramOrder-1]
        nMinus1GramCount = nMinus1GramDict[nMinus1Gram]
        MLE = np.log(ngramCount/nMinus1GramCount)
        MLEdict[ngram] = MLE
    return MLEdict

