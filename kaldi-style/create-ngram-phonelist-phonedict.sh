#!/bin/bash

# INPUT:
#   (1) some messy text corpus

# FUNCTION:
#    clean the corpus
#    make the pronunciation dictionary and list of phones
#    make the ngram language model

messy_corpus=$1
clean_corpus="clean.txt"
pronunciationDict="pronunciation.txt"
phonesList="phones.txt"
ngramFile="task.arpabo"
minSentenceLength=0
addSilence=1

# delete old versions of the files this script makes
rm $clean_corpus $pronunciationDict $phonesList $ngramFile 

# first clean the corpus
./clean_text.pl $messy_corpus $minSentenceLength $addSilence > $clean_corpus

# make the pronunciation dictionary and list of phones
./phonetic_dict.pl $clean_corpus $pronunciationDict $phonesList

# make the ngram language model
./make_lm.sh $clean_corpus $ngramFile

# sort files by bytes (kaldi-style) and re-save them with orginal filename
for fileName in $pronunciationDict $phonesList; do 
    LC_ALL=C sort -i $fileName -o $fileName; 
done;
