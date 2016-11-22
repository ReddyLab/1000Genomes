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

BASE="/home/bmajoros/1000G/assembly"
#BROKEN=BASE+"/broken-counts.txt"
#UNBROKEN=BASE+"/unbroken-counts.txt"
BROKEN=BASE+"/broken-counts-unfiltered.txt"
UNBROKEN=BASE+"/unbroken-counts-unfiltered.txt"

def load(filename):
    sum={}
    sampleSizes={}
    with open(filename,"rt") as fh:
        while(True):
            line=fh.readline()
            if(line==""): break
            fields=line.split()
            if(len(fields)<13): continue
            (indiv,hap,gene,trans,strand,exon,siteType,begin,pos,end,reads,
             geneReads,TotalReads)=fields
            if(int(geneReads)<10 or int(reads)==0): continue
            if(sum.get(gene,None)==None):
                sum[gene]=0.0
                sampleSizes[gene]=0
            sum[gene]+=float(reads)/float(geneReads) # Normalized reads
            #sum[gene]+=float(reads) # Raw reads
            sampleSizes[gene]+=1
    hash={}
    keys=sum.keys()
    for gene in keys:
        p=sum[gene]/float(sampleSizes[gene])
        hash[gene]=p
    return hash

#================================= main() =================================
broken=load(BROKEN)
unbroken=load(UNBROKEN)
genes=broken.keys()
for gene in genes:
    if(broken.get(gene,None) is None or unbroken.get(gene,None) is None):
        continue
    brokenValue=broken[gene]
    unbrokenValue=unbroken[gene]
    print(unbrokenValue,brokenValue,sep="\t")




