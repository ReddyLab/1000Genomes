#!/bin/env python
#=========================================================================
# This is OPEN SOURCE SOFTWARE governed by the Gnu General Public
# License (GPL) version 3, as described at www.opensource.org.
# Copyright (C)2016 William H. Majoros (martiandna@gmail.com).
#=========================================================================
from __future__ import (absolute_import, division, print_function, 
   unicode_literals, generators, nested_scopes, with_statement)
from builtins import (bytes, dict, int, list, object, range, str, ascii,
   chr, hex, input, next, oct, open, pow, round, super, filter, map, zip)

MAX_INDIV=30
BASE="/home/bmajoros/hapmix"

CHROMS=list(range(1,23))
for chr in CHROMS:
    infile=BASE+"/data-prep/ref/AMRgenofile."+str(chr)
    outfile=BASE+"/data-prep/ref/admix."+str(chr)
    OUT=open(outfile,"w")
    IN=open(infile,"r")
    while(True):
        line=IN.readline()
        if(not line): break
        line=line.rstrip()
        numIndiv=len(line)/2
        if(numIndiv!=int(numIndiv)): raise Exception("numIndiv not int")
        if(numIndiv>MAX_INDIV): numIndiv=MAX_INDIV
        for i in range(0,numIndiv):
            g1,g2=line[i*2],line[i*2+1]
            count=0
            if(g1=="1"): count+=1
            if(g2=="1"): count+=1
            OUT.write(str(count))
        OUT.write("\n")
    IN.close()
    OUT.close()



