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

THOUSAND="/home/bmajoros/1000G/assembly"
COMBINED=THOUSAND+"/combined"
DENOVO_IN=THOUSAND+"/rna150/denovo-rna"
OUT_DIR=THOUSAND+"/rna150/denovo-rna-freqs"
FREQS=THOUSAND+"/allele-freqs.txt.gz"

def storeDenovo(byVariant,variant,score,rec):
    prevRec=byVariant.get(variant,None)
    if(prevRec is None or score>float(prevRec[8])):
        byVariant[variant]=rec

def loadDenovo(filename):
    byVariant={}
    IN=open(filename,"rt")
    for line in IN:
        fields=line.rstrip().split()
        if(len(fields)!=17): continue
        (event,siteType,geneID,hap,geneType,transID,altID,strand,
         score,sitePos,seqLen,fate,identity,variantID,ratio,counts,
         totalCounts)=fields
        storeDenovo(byVariant,variantID,float(score),fields)
    IN.close()
    return byVariant

def processFreqs(table,variants):
    IN=gzip.open(FREQS,"rt")
    for line in IN:
        fields=line.rstrip().split()
        (variant,freq)=fields[:2]
        rec=table.get(variant,None)
        if(rec is None): continue
        line="\t".join(rec)+"\t"+"\t".join(fields[1:])
        print(line)
    IN.close()

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=3):
    exit(ProgramName.get()+" <indiv> <hap>\n")
(indiv,hap)=sys.argv[1:]

denovoFile=DENOVO_IN+"/"+indiv+"."+hap+".txt"
table=loadDenovo(denovoFile)
variants=table.keys()
processFreqs(table,variants)





