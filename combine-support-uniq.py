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
import gzip
from Rex import Rex
rex=Rex()

THOUSAND="/home/bmajoros/1000G/assembly"
COMBINED=THOUSAND+"/combined"
RNA=THOUSAND+"/rna150"
ID_LIST=RNA+"/IDs.txt"

def loadIDs(filename):
    IDs=[]
    with open(filename,"rt") as IN:
        for line in IN:
            ID=line.rstrip()
            IDs.append(ID)
    return IDs

def loadSupport(filename):
    global seen
    with gzip.open(filename,"rt") as IN:
        for line in IN:
            fields=line.rstrip().split("\t")
            if(len(fields)!=8): continue
            (junc,count,score,gene_hap,coords,type,diff,last)=fields
            if(not rex.find("(\S+)_\d+",gene_hap)): raise Exception(gene_hap)
            gene=rex[1]
            if(gene in seen): continue
            print(line,end="")
            seen.add(gene)

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=2):
    exit(ProgramName.get()+" <predictor>\n")
(predictor,)=sys.argv[1:]
IDs=loadIDs(ID_LIST)
seen=set()
for id in IDs:
    for hap in (1,2):
        infile=COMBINED+"/"+id+"/RNA6/temp/"+str(hap)+"."+predictor+\
            ".support.gz"
        loadSupport(infile)




