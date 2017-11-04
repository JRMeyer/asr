#!/bin/bash

# INPUT:
#   (1) some messy text corpus

# FUNCTION:
#    clean the corpus
#    make the pronunciation dictionary and list of phones
#    make the ngram language model


if [ "$#" -ne 1 ]
then
    echo "# ERROR"
    echo "# USAGE: $0 <messy-text-corpus>"
    exit 1
fi


messy_corpus=$1

minSentenceLength=25
addSilence=1
clean_corpus="clean.txt"

phoneticDict="lexicon.txt"
phoneticDict_NOSIL="lexicon_nosil.txt"
phonesList="phones.txt"

silence_word="<SIL>"
silence_phone="SIL"
unknown_word="<unk>"
unknown_phone="SPOKEN_NOISE"

ngramOrder=3
ngramFile="task.arpabo"


# delete old versions of the files this script makes
# using -f just to supress error message if the files dont already exist
rm -f $clean_corpus $phoneticDict $phoneticDict_NOSIL $phonesList \
    $ngramFile 

# first clean the corpus
./clean_text.pl $messy_corpus $minSentenceLength $addSilence > $clean_corpus

# make the phonetic dictionary and list of phones
./make_dict.pl \
    --clean_corpus $clean_corpus \
    --phoneticDict $phoneticDict \
    --phoneticDict_NOSIL $phoneticDict_NOSIL \
    --phonesList $phonesList \
    --silence_word $silence_word \
    --silence_phone $silence_phone \
    --unknown_word $unknown_word \
    --unknown_phone $unknown_phone \
    --graphemes;
    #--stress;

# make the ngram language model
./make_lm.sh $clean_corpus $ngramFile $ngramOrder

# sort files by bytes (kaldi-style) and re-save them with orginal filename
for fileName in $phoneticDict $phoneticDict_NOSIL $phonesList; do 
    LC_ALL=C sort -i $fileName -o $fileName; 
done;

