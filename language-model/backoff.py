import numpy as np


def get_brants_bow_dict(ngramDict, alpha=.4):
    ''' 
    based on Brants etal 2007, assuming that 
    the original probabilities are already logged.
    '''
    bow_dict={}
    for key,value in ngramDict.items():
        bow_dict[key] = (value, np.log(alpha)+value)
    return bow_dict


def get_katz_bow_dict(uniProbDict,biProbDict,triProbDict,startTime):
    ''' based on Katz 1987 '''
    bowDict={}
    for uniKey,uniValue in uniProbDict.items():
        numerator = 0
        denominator = 0
        for biKey,biValue in biProbDict.items():
            if biKey[0] == uniKey[0]:
                numerator += biValue
                denominator += uniValue
        alpha = (1-numerator/1-denominator)
        bowDict[uniKey] = alpha*uniValue
    print('[  '+ str("%.2f" % (time.time()-startTime)) +'  \t]'+
          ' 2-gram backoff model made')
    for biKey,biValue in biProbDict.items():
        numerator=0
        denominator=0
        for triKey,triValue in triProbDict.items():
            if triKey[0:2] == biKey[:]:
                numerator += triValue
                denominator += biValue
        alpha = 1-(numerator/denominator)
        bowDict[biKey] = alpha*biValue
        
    print('[  '+ str("%.2f" % (time.time()-startTime)) +'  \t]'+
          ' 3-gram backoff model made')
    return bowDict
