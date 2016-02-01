from collections import Counter
import time
import argparse

def get_cutOff_words(tokens,k,startTime):
    '''
    Given a list of words from some cleaned file (i.e. all lowercase, with <s>
    and <\s> and no punctuation) and a cutoff number, k, return a set of the
    words which *did not* occur more than k times in the file.
    '''
    freqDict = Counter(tokens)
    cutOffWords = set()
    for key,value in freqDict.items():
        if value <= k:
            cutOffWords.add(key)
            
    numCutOffWords = len(cutOffWords)
    print('[  '+ str("%.2f" % (time.time()-startTime)) +'  \t]'+
          ' A total of '+ str(numCutOffWords) + ' words occurring less than '+
          str(k)+ ' time(s) identified')
    return cutOffWords


def replace_cutoff_with_UNK(lines, cutOffWords, startTime):
    '''
    Given all the lines in a file represented as a character string, lines, and
    a set of all words which should be replaced in the text, replace all those
    words in the character string, lines, with the string ' <UNK> '
    NB - string.replace() is twice as fast as re.sub()!
    '''
    for key in cutOffWords:
        lines = lines.replace(' '+key+' ',' <UNK> ')
            
    print('[  '+ str("%.2f" % (time.time()-startTime)) +'  \t]'+
          ' Cutoff Words replaced with <UNK> ')
    return lines


def parse_user_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i','--infile', type=str, help='the input text file')
    parser.add_argument('-k','--cutoff', type=int, default=1,
                        help='frequency count cutoff')
    args = parser.parse_args()
    return args

if __name__ == '__main__':
    args = parse_user_args()
    fileName = args.infile
    k = args.cutoff
    startTime = time.time()
    
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

    with open('cutoff-replaced-' + fileName, 'w', encoding='utf-8') as outFile:
        outFile.write(lines)
