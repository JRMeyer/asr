#!/bin/bash

# INPUT:
#   (1) INFILE = cleaned text corpus with <s>'s
#   (2) OUFILE = filename to save arpa lm to

# FUNCTION:
#  Given a cleaned file with <s>'s, output an ARPA n-gram
#  model by using IRSTLM

INFILE=$1
OUTFILE=$2

export IRSTLM=/usr/local

build-lm.sh -i $INFILE -n 3 -o train.ilm.gz -k 5 -v

compile-lm --text=yes train.ilm.gz $OUTFILE

rm train.ilm.gz
