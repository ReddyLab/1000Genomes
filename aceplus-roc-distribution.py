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
import os
import sys
import ProgramName
import TempFilename

def makeRocInputFile(infile,outfile):
    OUT=open(outfile,"wt")
    with open(infile,"rt") as IN:
        for line in IN:
            fields=line.rstrip().split()
            support=int(fields[1])
            score=float(fields[2])
            category=1 if support>0 else 0
            print(score,category,sep="\t",file=OUT)
    OUT.close()

def readAUC(filename):
    with open(filename,"rt") as IN:
        line=IN.readline()
        auc=float(line.rstrip())
        return auc

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=3):
    exit(ProgramName.get()+" <support.txt> <num-samples>\n")
(infile,numSamples)=sys.argv[1:]
numSamples=int(numSamples)

rocInput=TempFilename.generate()
rocOutput=TempFilename.generate()
aucFile=TempFilename.generate()
makeRocInputFile(infile,rocInput)
for i in range(numSamples):
    os.system("roc.pl "+rocInput+" > "+rocOutput)
    os.system("area-under-ROC.pl "+rocOutput+" > "+aucFile)
    auc=readAUC(aucFile)
    print(auc)
os.remove(rocInput)
os.remove(rocOutput)
os.remove(aucFile)

