import sys
import re

infile=sys.argv[1]
regex = re.compile("dim=96 \[ ([0-9]*) ")





def extract_windows(eg, line, outfile, win_size=29):
    '''
    given a line of labels, and the saved block of feature vectors,
    this function will extract windows of a given size and assign them
    to their label in a label -- flattened_data file
    '''
    
    for i, label in enumerate(regex.findall(line)):
        
        rowVector=''
        for row in eg[i:i+win_size]:
            rowVector += (row[0] + ' ')

        print(label, rowVector, file=outfile)




eg=[]
with open(infile,"r") as f:
    with open("output.txt","a") as outfile:
        for line in f:
            # the first line of the eg
            if 'input' in line:
                eg=[]
                pass
            # if we've hit the labels then we're at the end of the data
            elif 'output' in line:
                extract_windows(eg, line, outfile)
                # this should be one frame of data
            else:
                eg.append([line.strip()])
                



    
