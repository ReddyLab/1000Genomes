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
import os
import ProgramName
from Rex import Rex
rex=Rex()

THOUSAND="/home/bmajoros/1000G/assembly"
INDIR=THOUSAND+"/rna150/denovo-rna"

#=========================================================================
# main()
#=========================================================================
#if(len(sys.argv)!=2):
#    exit(ProgramName.get()+" <>\n")
#()=sys.argv[1:]

seen=set()
files=os.listdir(INDIR)
for file in files:
    if(not rex.find("(\S+).[12].txt",file)): continue
    indiv=rex[1]
    with open(INDIR+"/"+file,"rt") as IN:
        for line in IN:
            line=line.rstrip()
            fields=line.split()
            variant=fields[13]
            if(variant in seen): continue
            seen.add(variant)
            if(fields[0]!="denovo"): continue
            ratio=float(fields[14])
            if(ratio>0.5): print(line+"\t"+indiv)


