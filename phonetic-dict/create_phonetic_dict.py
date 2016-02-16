from lookup_tables import kyrgyz_table, kazakh_table
import argparse
import re

def save_pronunciation_dict(tokens,lookupTable,lang):
    outFile = open((lang+'.dict'), mode='wt', encoding='utf-8')
    for token in sorted(set(tokens)):
        # pass the token along, substituting letters for phones, and end up with
        # a character string of phones with whitespace in between
        phonemes = token
        if lang == 'kyrgyz':
            # syllable onset plosives followed by front/back vowels
            phonemes = re.sub(r'к([аоуы])', r'kh \1', phonemes)
            phonemes = re.sub(r'к([иеэөү])', r'k \1', phonemes)
            phonemes = re.sub(r'г([аоуы])', r'gh \1', phonemes)
            phonemes = re.sub(r'г([иеэөү])', r'g \1', phonemes)
            # syllable final plosives preceded by front/back vowels
            phonemes = re.sub(r'([аоуы])к([^аоуыиеэөү])', r'\1kh \2', phonemes)
            phonemes = re.sub(r'([иеэөү])к([^аоуыиеэөү])', r'\1k \2', phonemes)
            phonemes = re.sub(r'([аоуы])г([^аоуыиеэөү])', r'\1gh \2', phonemes)
            phonemes = re.sub(r'([иеэөү])г([^аоуыиеэөү])', r'\1g \2', phonemes)
            # word final plosives preceded by front/back vowels
            phonemes = re.sub(r'([аоуы])к($)', r'\1kh', phonemes)
            phonemes = re.sub(r'([иеэөү])к($)', r'\1k', phonemes)
            phonemes = re.sub(r'([аоуы])г($)', r'\1gh', phonemes)
            phonemes = re.sub(r'([иеэөү])г($)', r'\1g', phonemes)
        elif lang == 'kazakh':
            # no context-dependent rules for kazakh
            pass
        # replace all letters left over after context-dependent rules applied
        for character in phonemes:
            if character in lookupTable:
                phonemes = re.sub(character, lookupTable[character], phonemes)
        # in case we added a space to the end of the sequence
        phonemes = phonemes.strip()
        # print new line with the original cyrillic word and its phonemes
        print((token +' '+ phonemes), end='\n', file=outFile)
    outFile.close()

def parse_user_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i','--infile', type=str, help='the input text file')
    parser.add_argument('-l','--language', type=str, default='kyrgyz',
                        choices=['kyrgyz','kazakh'], help='language of corpus')
    args = parser.parse_args()
    return args
        
if __name__ == '__main__':
    args = parse_user_args()
    fileName = args.infile
    lang = args.language
    # This script assumes that your corpus is already cleaned 
    # (i.e. all words should be lowercase without any punctuation or numbers)
    f = open(fileName)

    tokens=set()
    for line in f:
        for token in line[4:-6].split():
            tokens.add(token)

    if lang == 'kyrgyz':
        lookupTable=kyrgyz_table
    elif lang == 'kazakh':
        lookupTable=kazakh_table

    save_pronunciation_dict(tokens,lookupTable,lang)
