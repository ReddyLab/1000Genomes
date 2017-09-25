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
import math
import ProgramName
from FastaReader import FastaReader

#LENGTH_NORMALIZE=False

def loadWeights(filename):
    hash={}
    largestAbs=0
    with open(filename,"rt") as IN:
        for line in IN:
            if("Intercept" in line): continue
            fields=line.rstrip().split()
            if(len(fields)!=2): continue
            if(fields[1]=="."): fields[1]="0"
            weight=float(fields[1])
            hash[fields[0]]=weight
            if(abs(weight)>largestAbs): largestAbs=abs(weight)
    #for key in hash.keys(): hash[key]=hash[key]/largestAbs
    return hash

def scoreSequence(seq,model):
    L=len(seq)
    end=L-5
    sum=0.0
    for i in range(end):
        sum+=model[seq[i:i+6]]
    return sum

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=5):
    exit(ProgramName.get()+" <hexamer-weights.txt> <in.fasta> <class> <length-normalize:0|1>\n")
(weightsFile,fastaFile,category,LENGTH_NORMALIZE)=sys.argv[1:]
LENGTH_NORMALIZE=int(LENGTH_NORMALIZE)

model=loadWeights(weightsFile)
reader=FastaReader(fastaFile)
while(True):
    (defline,seq)=reader.nextSequence()
    if(not defline): break
    L=len(seq)
    sum=scoreSequence(seq,model)
    if(LENGTH_NORMALIZE): sum/=float(L-5)
    print(sum,category,sep="\t")




