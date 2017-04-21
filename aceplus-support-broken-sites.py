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
from SlurmWriter import SlurmWriter

INFILE="support10.txt" # "support.txt"
THOUSAND="/home/bmajoros/1000G/assembly"
GEUVADIS=THOUSAND+"/geuvadis.txt"

def loadSupportFile(filename):
    array=[]
    with open(filename,"rt") as IN:
        for line in IN:
            fields=line.rstrip().split()
            if(len(fields)!=8): continue
            (featureType,support,score,geneID,interval,essex,
             fate,broken)=fields
            if(broken!="true"): continue
            if(fate=="NMD" or fate=="nonstop-decay"): continue
            if(featureType!="junction"): continue
            array.append([geneID,interval,support,score])
    return array

#=========================================================================
# main()
#=========================================================================

dirs=[]
with open(GEUVADIS,"rt") as IN:
    for line in IN:
        id=line.rstrip()
        dir=THOUSAND+"/combined/"+id
        dirs.append(dir)

seen=set()
for dir in dirs:
    predictions=loadSupportFile(dir+"/RNA3/"+INFILE)
    seenLocal=set()
    for elem in predictions:
        (geneID,interval,support,score)=elem
        if(geneID in seen): continue
        print(support,score,sep="\t")
        seenLocal.add(geneID)
    seen.update(seenLocal)

