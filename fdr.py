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
from Rex import Rex
rex=Rex()

if(len(sys.argv)!=2):
    exit(sys.argv[0]+" <p-values.txt>")
infile=sys.argv[1]

values=[]
with open(infile,"rt") as fh:
    for line in fh:
        if(rex.find("(\S+\d\S+)",line)):
            values.append(float(rex[1]))

values.sort()
L=len(values)
qValues=(0.1,0.05,0.01,0.005,0.001)
for q in qValues:
    bestP=None
    for i in range(L):
        P=values[i]
        threshold=float(i+1)/float(L)*q;
        if(P>threshold):
            if(i>0): bestP=values[i-1]
            break
    print("q="+str(q)+" p="+str(bestP))
