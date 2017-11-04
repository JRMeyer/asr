'''
USE: python3 clean_text.py /path/to/corpus.txt

FUNCTION:
  Given a path to a text file, this script will:
   (1) split file into lines where sentences should be (see regex object)
   (2) tokenize each line (see function tokenize_line()
   (3) print new, cleaned lines to output file

OUTPUT: output.txt (text file with one sentence per line, no non-alphabetic
                    characters, all lowercase words, only Kyrgyz characters)
'''


import re

def split_sentences_in_file(fileName):
    '''
    Given a path to a text file:
    (1) split file into lines where sentences should be (see regex object)
    (2) add each line as a character string to 'lines'
    '''
    regex = re.compile(r'([.!?\n])')
    outFile = open('output.txt', 'w')
    with open(fileName) as inFile:
        content = inFile.read()
        for line in re.split(regex,content):
            if line != '':
                print(line)
                print(line, file=outFile)
            else:
                pass
    outFile.close()


def clean_lines_in_file(fileName,kyrgyzLetters):
    '''
    Given a path to a text file:
    (1) split file into lines where sentences should be (see regex object)
    (2) tokenize each line (see function tokenize_line())
    (3) add each line as a character string to 'lines'
    '''
    regex = re.compile(r'[.+!?\n]')
    outFile = open('output.txt', 'w')
    with open(fileName) as inFile:
        content = inFile.read()
        for line in re.split(regex,content):
            line = tokenize_line(line,kyrgyzLetters)
            if line != '':
                print(line, file=outFile)
            else:
                pass
    outFile.close()


def tokenize_line(line,kyrgyzLetters):
    '''
    (1) lower all text, strip whitespace and newlines
    (2) replace everything that isn't a letter or space
    (3) split line on whitespace
    (4) pad the line
    (5) return tokens
    '''
    line = line.lower().strip().rstrip()
    # regex pattern to match everything that isn't a letter
    pattern = re.compile('[\W_0-9]+', re.UNICODE)
    # replace everything that isn't a letter or space
    line = (' ').join([pattern.sub('', token) for token in line.split(' ')])
    tokens=[]
    for token in line.split(' '):
        if token == '':
            pass
        # make sure we only have Kyrgyz letters in token
        elif all(char in kyrgyzLetters for char in token):
            tokens.append(token)
    # check if there are tokens, then pad the line
    if tokens:
        line = (' ').join(tokens)
        line = '<s> ' + line + ' </s>'
    else:
        line = ''
    return line

kyrgyzLetters = ['а','о','у','ы','и','е','э',
                'ө','ү','ю','я','ё','п','б',
                'д','т','к','г','х','ш','щ',
                'ж','з','с','ц','ч','й','л',
                'м','н','ң','ф','в','р','ъ',
                'ь']

def main():
    import sys
    infile = sys.argv[1]
    clean_lines_in_file(infile, kyrgyzLetters)

if __name__ == "__main__":
    main()
