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
from Pipe import Pipe
from Rex import Rex
from SummaryStats import SummaryStats
rex=Rex()

BASE="/home/bmajoros/1000G/assembly"
#BROKEN=BASE+"/broken-counts.txt"
#UNBROKEN=BASE+"/unbroken-counts.txt"
BROKEN=BASE+"/broken-counts-unfiltered.txt"
UNBROKEN=BASE+"/unbroken-counts-unfiltered.txt"

def save(set1,filename):
    with open(filename,"wt") as fh:
        for x in set1:
            fh.write(str(x)+"\n")

def wilcox(set1,set2):
    save(set1,"w.1")
    save(set2,"w.2")
    pipe=Pipe("/home/bmajoros/1000G/src/wilcox.R w.1 w.2 two.sided")
    p=None
    while(True):
        line=pipe.readline()
        if(line is None): break
        if(rex.find("p-value\s*=\s*(\S+)",line)): p=rex[1]
        elif(rex.find("p-value\s*<\s*(\S+)",line)): p=rex[1]
    return p

def load(filename):
    hash={}
    with open(filename,"rt") as fh:
        while(True):
            line=fh.readline()
            if(line==""): break
            fields=line.split()
            if(len(fields)<13): continue
            (indiv,hap,gene,trans,strand,exon,siteType,begin,pos,end,reads,
             geneReads,TotalReads)=fields
            if(int(geneReads)<10): continue
            if(hash.get(gene,None) is None):
                hash[gene]=[]
            hash[gene].append(float(reads)/float(geneReads))
    return hash

#================================= main() =================================
broken=load(BROKEN)
unbroken=load(UNBROKEN)
genes=broken.keys()
for gene in genes:
    if(broken.get(gene,None) is None or unbroken.get(gene,None) is None):
        continue
    N1=len(broken[gene])
    N2=len(unbroken[gene])
    #print("N",N1,N2)
    P=wilcox(broken[gene],unbroken[gene])
    if(P=="NA"): continue
    (meanBroken,SDbroken,minBroken,maxBroken)= \
        SummaryStats.summaryStats(broken[gene])
    (meanUnbroken,SDunbroken,minUnbroken,maxUnbroken)= \
        SummaryStats.summaryStats(unbroken[gene])
    print(meanUnbroken,meanBroken,P,sep="\t")




