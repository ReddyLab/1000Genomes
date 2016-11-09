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
import os
from Rex import Rex
rex=Rex()
COMBINED="/home/bmajoros/1000G/assembly/combined"

def process(indiv,dir,hap):
    infile=dir+"/"+str(hap)+".readcounts-rev3"
    with open(infile,"rt") as fh:
        for line in fh:
            fields=line.split()
            if(len(fields)!=2): continue
            (trans,reads)=fields
            print(indiv,hap,trans,reads,sep="\t")

dirs=os.listdir(COMBINED)
for indiv in dirs:
    indiv=indiv.rstrip()
    if(not rex.find("^HG\d+$",indiv) and not rex.find("^NA\d+$",indiv)):
        continue
    if(not os.path.exists(COMBINED+"/"+indiv+"/RNA/stringtie.gff")):
        continue
    dir=COMBINED+"/"+indiv
    process(indiv,dir,1)
    process(indiv,dir,2)


