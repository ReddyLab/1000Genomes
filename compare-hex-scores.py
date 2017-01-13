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
    exit(ProgramName.get()+" <*.hmm> <hexamer-scores.txt> <fastb-dir>\n")
(hmmFile,hexFile,fastbDir)=sys.argv[1:]

def scoreHexamers(seq,hexHash):
    L=len(seq)
    end=L-6
    total=0
    for i in range(end):
        hex=seq[i:i+6]
        hexScore=hexHash[hex]
        total+=hexScore
    mean=float(total)/float(end)
    return mean

hexHash={}
with open(hexFile,"rt") as IN:
    for line in IN:
        fields=line.rstrip().split()
        if(len(fields)!=2): continue
        (hex,score)=fields
        hexHash[hex]=float(score)

files=os.listdir(fastbDir)
for file in files:
    cmd=MUMMIE+"/get-likelihood "+hmmFile+" "+fastbDir+"/"+file
    pipe=Pipe(cmd)
    line=pipe.readline();
    LL=float(line.rstrip())
    (defline,seq)=FastaReader.firstSequence(fastbDir+"/"+file)
    #print(fastbDir+"/"+file,seq)
    hexScore=scoreHexamers(seq,hexHash)
    length=len(seq)
    LL=LL**1.0/float(length)
    lik=math.exp(LL)
    print(hexScore,lik,sep="\t")
