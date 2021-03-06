#!/usr/bin/env python
#=========================================================================
# This is OPEN SOURCE SOFTWARE governed by the Gnu General Public
# License (GPL) version 3, as described at www.opensource.org.
# Copyright (C)2017 William H. Majoros (martiandna@gmail.com).
#=========================================================================
from __future__ import (absolute_import, division, print_function, 
   unicode_literals, generators, nested_scopes, with_statement)
from builtins import (bytes, dict, int, list, object, range, str, ascii,
   chr, hex, input, next, oct, open, pow, round, super, filter, map, zip)
# The above imports should allow this program to run in both Python 2 and
# Python 3.  You might need to update your version of module "future".
import sys
import ProgramName
import random
import gzip

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=3):
    exit(ProgramName.get()+" <support.gz> <num-samples>\n")
(infile,numSamples)=sys.argv[1:]
numSamples=int(numSamples)

POS=0
array=[]
IN=gzip.open(infile,"rt")
for line in IN:
    fields=line.rstrip().split()
    if(len(fields)<2): continue
    cat=1 if int(fields[1])>0 else 0
    score=float(fields[2])
    rec=[score,cat]
    array.append(rec)
    if(rec[1]==1): POS+=1
IN.close()
N=len(array)
NEG=N-POS;

for i in range(numSamples):
    # Randomize first -- very important!  Otherwise we can
    # get artifacts due to ties, which can drastically alter
    # the AUC:
    for i in range(N):
        j=int(random.randint(i,N-1))
        temp=array[i]; array[i]=array[j]; array[j]=temp
    array.sort(key=lambda x:x[0])

    # Make the ROC
    seen={}
    TP=POS; FP=NEG; TN=0; FN=0
    for i in range(N):
        rec=array[i]
        (score,clas)=rec
        if(clas==1): 
            TP-=1
            FN+=1
        else:
            FP-=1
            TN+=1
        TPR=float(TP)/float(TP+FN)
        FPR=float(FP)/float(FP+TN)
        TPR=int(TPR*1000+5.0/9.0)/1000
        FPR=int(FPR*1000+5.0/9.0)/1000
        line=str(FPR)+"\t"+str(TPR)
        if(seen.get(line,None) is not None): continue
        seen[line]=True
        print(line)
    print()



