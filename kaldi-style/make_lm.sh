#!/bin/bash

# INPUT:
#   (1) INFILE = cleaned text corpus with <s>'s
#   (2) OUFILE = filename to save arpa lm to

# FUNCTION:
#  Given a cleaned file with <s>'s, output an ARPA n-gram
#  model by using IRSTLM

INFILE=$1
OUTFILE=$2
NGRAM_ORDER=$3

export IRSTLM=/usr/local/lib/irstlm

${IRSTLM}/bin/build-lm.sh -i $INFILE -n $NGRAM_ORDER -o train.ilm.gz -k 5

${IRSTLM}/bin/compile-lm --text=yes train.ilm.gz $OUTFILE

rm train.ilm.gz
