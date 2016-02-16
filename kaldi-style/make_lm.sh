#!/bin/bash

# Use > 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
while [[ $# > 1 ]]
do
key="$1"

case $key in
    -i|--infile)
    INFILE="$2"
    shift # past argument
    ;;
    -o|--outfile)
    OUTFILE="$2"
    shift # past argument
    ;;
esac
shift # past argument or value
done


export IRSTLM=/usr/local

build-lm.sh -i $INFILE -n 3 -o train.ilm.gz -k 5 -v

compile-lm --text=yes train.ilm.gz $OUTFILE

rm train.ilm.gz
