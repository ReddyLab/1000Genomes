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
import ProgramName
from Rex import Rex
rex=Rex()

if(len(sys.argv)!=4):
    exit(ProgramName.get()+" <in.hmm> <hex-scores.txt> <out.hmm>\n")
(inHMM,hexFile,outHMM)=sys.argv[1:]

hexes={}
with open(hexFile,"rt") as IN:
    for line in IN:
        fields=line.rstrip().split()
        if(len(fields)!=2): continue
        (hex,score)=fields
        hexes[hex]=score

IN=open(inHMM,"rt")
OUT=open(outHMM,"wt")
substituting=False
for line in IN:
    line=line.rstrip()
    if(rex.find("alphabet:",line)):
        print(line,file=OUT) # alphabet:
        print(IN.readline().rstrip(),file=OUT) # ACGT
        substituting=True
        continue
    if(substituting):
        fields=line.split()
        if(len(fields)!=2): continue
        LLR=1.0
        if(len(fields[0])==6): LLR=hexes[fields[0]]
        print(fields[0],LLR,sep="\t",file=OUT)
    else:
        print(line,file=OUT)
IN.close()
OUT.close()



