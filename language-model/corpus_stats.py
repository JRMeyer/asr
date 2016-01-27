from collections import Counter
import numpy as np
import time

def get_frequency_dict(ngrams, ngramOrder, smoothing, startTime):
    '''
    Make a dictionary of frequency counts, where the key is the ngram.
    Without smoothing, we have: p(X) = freq(X)/NUMBER_OF_NGRAMS
    '''
    
    if smoothing == 'none':
        denominator = len(ngrams)
        probDict={}
        for key, value in Counter(ngrams).items():
            probDict[key] = value/denominator

    elif smoothing == "laplace":
        numSmooth = .0001
        denominator = (len(ngrams)+ len(ngrams)**ngramOrder)
        probDict={}
        for key, value in Counter(ngrams).items():
            probDict[key] = (value + numSmooth) / denominator

    elif smoothing == 'turing':
        # N = total number of n-grams in text
        # N_1 = number of hapaxes
        # r = frequency of an n-gram
        # n_r = number of n-grams which occured r times
        # P_T = r*/N, the probability of an n-gram which occured r times
        # r* = (r+1) * ( (n_{r+1}) / (n_r) ), the smoothed count for an ngram
        N = len(ngrams)
        freqDist_ngrams={}
        for key,value in Counter(ngrams).items():
            # key = n-gram, value = r
            freqDist_ngrams[key] = value
        freqDist_freqs={}
        for key,value in Counter(freqDist_ngrams.values()).items():
            # key = r, value = n_r
            freqDist_freqs[key] = value
        probDict={}
        for key,value in freqDist_ngrams.items():
            r = value
            n_r = freqDist_freqs[r]
            try:
                n_r_plus_1 = freqDist_freqs[r+1]
            except KeyError as exception:
                print('There are no n-grams with frequency ' +str(exception)+
                      '... using ' +str(r)+ ' instead')
                n_r_plus_1 = n_r
            r_star = (r+1)*((n_r_plus_1)/(n_r))
            probDict[key] = r_star/N
        
    print('[  '+ str("%.2f" % (time.time()-startTime)) +'  \t] '+
          str(ngramOrder) + '-gram probability dictionary made')
    
    return probDict


def get_conditional_dict(nMinus1GramDict,ngramDict,ngramOrder):
    '''
    Given a dictionary of ngrams and one of n-1-grams with their 
    frequencies for some corpus, compute the conditional probabilities for
    ngrams.
    
    p(N|N_MINUS_ONE) = p(N)/p(N_MINUS_ONE)
    p(B|A) =  p(A,B)/p(A)
    log(p(B|A)) = log(p(A,B)) - log(p(A))
    '''
    ngramCondDict={}
    for ngram, ngramProb in ngramDict.items():
        nMinus1Gram = ngram[:ngramOrder-1]
        nMinus1GramProb = nMinus1GramDict[nMinus1Gram]
        condNGramProb = np.log(ngramProb) - np.log(nMinus1GramProb)
        ngramCondDict[ngram] = condNGramProb
    return ngramCondDict
