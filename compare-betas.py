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

def load(filename):
    hash={}
    with open(filename,"rt") as IN:
        for i in range(3): IN.readline()
        for line in IN:
            fields=line.rstrip().split()
            if(len(fields)!=2): continue
            (hexamer,score)=fields
            #if(score=="."): score="0"
            if(score=="."): continue
            hash[hexamer]=score
    return hash
 

if(len(sys.argv)!=3):
    exit(ProgramName.get()+" <betas1.txt> <betas2.txt>\n")
(file1,file2)=sys.argv[1:]

hash1=load(file1)
hash2=load(file2)
for key in hash1.keys():
    x=hash1[key]
    if(hash2.get(key,None) is None): continue
    y=hash2[key]
    print(x,y,sep="\t")


