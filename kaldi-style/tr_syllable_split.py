# -*- coding: utf-8 -*-
#
# Author: Josh Meyer 2016
#
# USAGE: $python3 tr_syllable_split.py clean_corpus.txt
#
#
# INPUT: (1) a cleaned text corpus (command line argument)
#
# OUTPUT: (1) words broken up by syllable (output.txt)
#

#

import re
import sys

inFile = open(sys.argv[1], "r", encoding="utf-8")
outFile = open("output.txt", "w", encoding="utf-8")


consonant = "b|c|ç|d|f|g|ğ|h|j|k|l|m|n|p|r|s|ş|t|v|y|z"
vowel = "a|â|e|ı|i|î|o|ö|u|û|ü"

# VCV --> V@ @CV
vcv = re.compile("("+vowel+")("+consonant+")("+vowel+")")
# VCCV --> VC@ @CV
vccv = re.compile("("+vowel+")("+consonant+")("+consonant+")("+vowel+")")
# VCCC --> VCC@ @C
vccc = re.compile("("+vowel+")("+consonant+")("+consonant+")("+consonant+")")


for line in inFile:
    for word in line.lower().split():
        lenWord = len(word)+1

        # VCV --> V@ @CV
        i=0
        j=3
        while j<lenWord:
            if re.match(vcv,word[i:j]):
                word = word[:i+1] + "@ @" + word[i+1:]
                i+=3
                j+=3
                lenWord+=3                
            else:
                i+=1
                j+=1

        # VCCV --> VC@ @CV
        i=0
        j=4
        while j<lenWord:
            if re.match(vccv,word[i:j]):
                word = word[:i+2] + "@ @" + word[i+2:]
                i+=3
                j+=3
                lenWord+=3                
            else:
                i+=1
                j+=1

        # VCCC --> VCC@ @C
        i=0
        j=4
        while j<lenWord:
            if re.match(vccc,word[i:j]):
                word = word[:i+3] + "@ @" + word[i+3:]
                i+=3
                j+=3
                lenWord+=3                
            else:
                i+=1
                j+=1

        print(word, file=outFile, end=' ')
    print("\n", file=outFile, end='')

outFile.close()
