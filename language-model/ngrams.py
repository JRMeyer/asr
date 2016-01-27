'''
Author: Joshua Meyer

USAGE:$ python3 ngrams.py -i INFILE -s SMOOTHING -b BACKOFF -k FREQUENCY_CUTOFF 

DESCRIPTION: Given a cleaned corpus (text file), output a model of n-grams 
in ARPA format


#####################
The MIT License (MIT)

Copyright (c) 2016 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#####################
'''

from corpus_stats import get_frequency_dict, get_conditional_dict
from backoff import get_brants_bow_dict
import argparse
import operator
import numpy as np
from collections import Counter
import re
import time
import sys

def parse_user_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i','--infile', type=str, help='the input text file')
    parser.add_argument('-s','--smoothing',type=str, help='flavor of smoothing',
                        choices = ['none','laplace','turing'], default='none')
    parser.add_argument('-bo','--backoff', action='store_true',
                        help='add backoff weights')
    parser.add_argument('-k','--cutoff', type=int, default=1,
                        help='frequency count cutoff')
    args = parser.parse_args()
    return args


def get_cutOff_words(tokens,k,startTime):
    uniFreqDict = Counter(tokens)
    cutOffWords=[]
    for key,value in uniFreqDict.items():
        if value <= k:
            cutOffWords.append(key)
            
    numCutOffWords = len(cutOffWords)
    print('[  '+ str("%.2f" % (time.time()-startTime)) +'  \t]'+
          ' A total of '+ str(numCutOffWords) + ' words occurring less than '+
          str(k)+ ' time(s) identified')
    return cutOffWords


def replace_cutoff_with_UNK(lines, cutOffWords, startTime):
    # string.replace() is twice as fast as re.sub()!
    for key in cutOffWords:
        lines = lines.replace(' '+key+' ',' <UNK> ')
            
    print('[  '+ str("%.2f" % (time.time()-startTime)) +'  \t]'+
          ' Cutoff Words replaced with <UNK> ')
    return lines


def get_ngram_tuples(lines,startTime,lenSentenceCutoff):
    unigrams=[]
    bigrams=[]
    trigrams=[]
    for line in lines.split('\n'):
        line = line.split(' ')
        if len(line) >lenSentenceCutoff:
            unigrams+=get_ngrams_from_line(line,1)
            bigrams+=get_ngrams_from_line(line,2)
            trigrams+=get_ngrams_from_line(line,3)
    print('[  '+ str("%.2f" % (time.time()-startTime)) +'  \t]'+
          ' A total of ' +str(len(unigrams))+
          ' unigrams found')
    print('[  '+ str("%.2f" % (time.time()-startTime)) +'  \t]'+ ' A total of '+
          str(len(bigrams)) + ' bigrams found')
    print('[  '+ str("%.2f" % (time.time()-startTime)) +'  \t]'+ ' A total of '+
          str(len(trigrams)) + ' trigrams found')
    return unigrams, bigrams, trigrams


def get_ngrams_from_line(tokens, n):
    '''
    Given a list of tokens, return a list of tuple ngrams
    '''
    ngrams=[]
    # special case for unigrams
    if n==1:
        for token in tokens:
            # we need parentheses and a comma to make a tuple
            ngrams.append((token,))
    # general n-gram case
    else:
        for i in range(len(tokens)-(n-1)):
            ngrams.append(tuple(tokens[i:i+n]))
    return ngrams


def main():
    # get user input
    args = parse_user_args()
    fileName = args.infile
    smoothing = args.smoothing
    backoff = args.backoff
    k = args.cutoff
    
    startTime = time.time()
    print('[  '+ str("%.2f" % (time.time()-startTime)) +'  \t]'+ ' running')

    # open previously cleaned file
    f = open(fileName)

    lines = ''
    for line in f:
        lines += line
        
    tokens = [token for line in lines.split('\n')
              for token in line.strip().split(' ')]

    # make the cutOff
    cutOffWords = get_cutOff_words(tokens,k,startTime)
    lines = replace_cutoff_with_UNK(lines,cutOffWords,startTime)

    # get lists of tuples of ngrams
    unigrams, bigrams, trigrams = get_ngram_tuples(lines,startTime,
                                                   lenSentenceCutoff=4)

    # get probability dictionaries
    uniProbDict = get_frequency_dict(unigrams,1,smoothing,startTime)
    biProbDict = get_frequency_dict(bigrams,2,smoothing,startTime)
    triProbDict = get_frequency_dict(trigrams,3,smoothing,startTime)

    biCondDict = get_conditional_dict(uniProbDict,biProbDict,2)
    triCondDict = get_conditional_dict(biProbDict,triProbDict,3)

    uniBowDict = get_brants_bow_dict(uniProbDict)
    biBowDict = get_brants_bow_dict(biCondDict)
    
    if backoff:
        backedOff = 'yes'
    else:
        backedOff = 'no'
        
    with open(('lm_smoothing-' + smoothing +
               '_backoff-' + backedOff +
               '_cutoff-' + str(k)+
               '.txt'),
              'w', encoding = 'utf-8') as outFile:
        # Print ARPA preamble
        outFile.write('\n\data\\\n')
        outFile.write('ngram 1=' + str(len(uniProbDict)) +'\n')
        outFile.write('ngram 2=' + str(len(biProbDict)) +'\n')
        outFile.write('ngram 3=' + str(len(triProbDict)) +'\n')

        ## print unigrams
        outFile.write('\n\\1-grams:\n')
        sortedUni = sorted(uniBowDict.items(), key=operator.itemgetter(1),
                          reverse=True)
        for key,value in sortedUni:
            if backoff:
                entry = (str(value[0]) +' '+ key[0] +' '+
                         str(value[1]))
            else:
                entry = (str(value[0]) +' '+ key[0])
            outFile.write(entry+'\n')
            
        ## print bigrams
        outFile.write('\n\\2-grams:\n')
        sortedBi = sorted(biBowDict.items(), key=operator.itemgetter(1),
                           reverse=True)
        for key,value in sortedBi:
            if backoff:
                entry = (str(value[0]) +' '+ key[0] +' '+ key[1] +' '+
                         str(value[1]))
            else:
                entry = (str(value[0]) +' '+ key[0] +' '+ key[1])
            outFile.write(entry+'\n')

        ## print trigrams
        outFile.write('\n\\3-grams:\n')
        sortedTri = sorted(triCondDict.items(), key=operator.itemgetter(1),
                           reverse=True)
        for key,value in sortedTri:
            entry = (str(value) +' '+ key[0] +' '+ key[1] +' '+ key[2])
            outFile.write(entry+'\n')
        outFile.write('\n\end\\')
    print('[  '+ str("%.2f" % (time.time()-startTime)) +'  \t]'+
          ' successfully printed model to file!')


if __name__ == "__main__":
    main()
