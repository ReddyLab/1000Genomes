#!/usr/bin/env python
#=========================================================================
# This is OPEN SOURCE SOFTWARE governed by the Gnu General Public
# License (GPL) version 3, as described at www.opensource.org.
# Copyright (C)2016 William H. Majoros (martiandna@gmail.com).
#=========================================================================
from __future__ import (absolute_import, division, print_function, 
   unicode_literals, generators, nested_scopes, with_statement)
from builtins import (bytes, dict, int, list, object, range, str, ascii,
   chr, hex, input, next, oct, open, pow, round, super, filter, map, zip)
# The above imports should allow this program to run in both Python 2 and
# Python 3.  You might need to update your version of module "future".
import sys
import os
import math
import ProgramName
from Pipe import Pipe
from FastaReader import FastaReader
MUMMIE=os.environ["MUMMIE"]

if(len(sys.argv)!=4):
    exit(ProgramName.get()+" <rescaled-scores.txt> <shendure-scores.txt> <fastb-dir>\n")
(rescaledFile,shendureFile,fastbDir)=sys.argv[1:]

def arithmeticMean(seq,hexHash):
    L=len(seq)
    end=L-5
    sum=0.0
    for i in range(end):
        hex=seq[i:i+6]
        hexScore=hexHash[hex]
        sum+=hexScore
    mean=float(sum)/float(end)
    return mean

def product(seq,hexHash):
    L=len(seq)
    end=L-5
    product=1.0
    for i in range(end):
        hex=seq[i:i+6]
        hexScore=hexHash[hex]
        product*=hexScore
    product=product**(1.0/float(end))
    return product

shendureHash={}
with open(shendureFile,"rt") as IN:
    for line in IN:
        fields=line.rstrip().split()
        if(len(fields)!=2): continue
        (hex,score)=fields
        shendureHash[hex]=float(score)
        #print(hex,float(score))

rescaledHash={}
with open(rescaledFile,"rt") as IN:
    for line in IN:
        fields=line.rstrip().split()
        if(len(fields)!=2): continue
        (hex,score)=fields
        rescaledHash[hex]=float(score)
        #print(hex,math.log(float(score)))

files=os.listdir(fastbDir)
for file in files:
    (defline,seq)=FastaReader.firstSequence(fastbDir+"/"+file)
    length=len(seq)
    if(length<6): continue
    shendureScore=arithmeticMean(seq,shendureHash)
    rescaledScore=product(seq,rescaledHash)
    print(shendureScore,rescaledScore,sep="\t")
