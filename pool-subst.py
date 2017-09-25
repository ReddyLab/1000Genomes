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
from SummaryStats import SummaryStats
from Rex import Rex
rex=Rex()

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
        for field in fields[2:]:
            if(not rex.find("(\S+)=(\S+)",field)): raise Exception(field)
            subst=rex[1]; P=float(rex[2])
            if(hash.get(subst,None)==None): hash[subst]=[]
            hash[subst].append(P)
for key in hash.keys():
    array=hash[key]
    (mean,SD,min,max)=SummaryStats.roundedSummaryStats(array)
    print(key,mean,SD,sep="\t")





