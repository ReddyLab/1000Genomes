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
from Rex import Rex
rex=Rex()

MIN_READS=3
ASSEMBLY="/home/bmajoros/1000G/assembly"
READS=ASSEMBLY+"/reads.txt-rev3"
EXPRESSED=ASSEMBLY+"/expressed.txt"

expressed={}
with open(EXPRESSED,"rt") as fh:
    for line in fh:
        fields=line.split()
        if(len(fields)!=4): continue
        (gene,trans,meanFPKM,SS)=fields
        expressed[trans]=True

hasAlts={}
supportedAlts={}
with open(READS,"rt") as fh:
    for line in fh:
        fields=line.split()
        if(len(fields)!=4): continue
        (indiv,hap,trans,reads)=fields
        if(not rex.find("(\S+)_(\S+)_(\d+)",trans)): raise Exception(trans)
        alt=rex[1]; baseTrans=rex[2]; happ=rex[3]
        if(not expressed.get(baseTrans,False)): continue
        key=indiv+" "+str(hap)+" "+baseTrans;
        hasAlts[key]=True
        if(int(reads)>=MIN_READS): supportedAlts[key]=True

numHasAlts=len(hasAlts.keys())
numSupportedAlts=len(supportedAlts.keys())
proportion=float(numSupportedAlts)/float(numHasAlts)
print(proportion,"=",numSupportedAlts,"/",numHasAlts)


