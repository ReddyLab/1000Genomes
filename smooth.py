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
import ProgramName

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=2):
    exit(ProgramName.get()+" <infile>\n")
(infile,)=sys.argv[1:]

hash={}
with open(infile,"rt") as IN:
    for line in IN:
        fields=line.rstrip().split()
        if(len(fields)!=2): continue
        x=float(fields[0]); y=float(fields[1])
        if(hash.get(x,None) is None): hash[x]=y
        if(y>hash[x]): hash[x]=y
array=[]
for key in hash.keys():
    value=hash[key]
    array.append([key,value])
array.sort(key=lambda x:x[0])
for pair in array:
    (x,y)=pair
    print(x,y,sep="\t")

