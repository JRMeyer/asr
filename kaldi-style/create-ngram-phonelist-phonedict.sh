#!/bin/bash

# INPUT:
#   (1) some messy text corpus

# FUNCTION:
#    clean the corpus
#    make the pronunciation dictionary and list of phones
#    make the ngram language model

messy_corpus=$1
minSentenceLength=0
addSilence=1
clean_corpus="clean.txt"

pronunciationDict="lexicon.txt"
pronunciationDict_NOSIL="lexicon_nosil.txt"
phonesList="phones.txt"

silence_word="<SIL>"
silence_phone="SIL"
unknown_word="<unk>"
unknown_phone="SPOKEN_NOISE"

ngramFile="task.arpabo"


# delete old versions of the files this script makes
# using -f just to supress error message if the files dont already exist
rm -f $clean_corpus $pronunciationDict $pronunciationDict_NOSIL $phonesList \
    $ngramFile 

# first clean the corpus
./clean_text.pl $messy_corpus $minSentenceLength $addSilence > $clean_corpus

# make the pronunciation dictionary and list of phones
./phonetic_dict.pl $clean_corpus $pronunciationDict $pronunciationDict_NOSIL \
    $phonesList $silence_word $silence_phone $unknown_word $unknown_phone

# make the ngram language model
./make_lm.sh $clean_corpus $ngramFile

# sort files by bytes (kaldi-style) and re-save them with orginal filename
for fileName in $pronunciationDict $pronunciationDict_NOSIL $phonesList; do 
    LC_ALL=C sort -i $fileName -o $fileName; 
done;

