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

BASE="/home/bmajoros/hapmix"
CHROMS=list(range(1,23))

for chr in CHROMS:
    infile=BASE+"/data-prep/ref/EURsnpfile."+str(chr)
    outfile=BASE+"/data-prep/ref/rates."+str(chr)
    variants=[]
    with open(infile,"r") as fh:
        while(True):
            line=fh.readline()
            if(not line): break
            line=line.rstrip()
            line=line.lstrip()
            fields=line.split()
            centimorgans=fields[2]
            pos=fields[3]
            variants.append([pos,centimorgans])
    numVariants=len(variants)
    with open(outfile,"w") as fh:
        fh.write(":sites:"+str(numVariants)+"\n")
        for i in range(numVariants):
            fh.write(str(variants[i][0])+" ")
        fh.write("\n")
        for i in range(numVariants):
            fh.write(str(variants[i][1])+" ")
        fh.write("\n")
        
