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
from Translation import Translation
from GffTranscriptReader import GffTranscriptReader
from Rex import Rex
rex=Rex()

nucs=("A","C","G","T")
alphabet=set()
for nuc in nucs: alphabet.add(nuc)

def clear(subst):
    for a in alphabet:
        second=subst[a]={}
        for b in alphabet:
            second[b]=0

def emit(subst,chr,prevPos,pos):
    print("chr"+chr,prevPos,pos,sep="\t",end="")
    total=0
    for a in alphabet:
        second=subst[a]
        for b in alphabet:
            count=second[b]
            total+=count
    for a in alphabet:
        second=subst[a]
        for b in alphabet:
            count=second[b]
            P=round(float(count)/float(total),3)
            print("\t"+a+"->"+b+"="+str(P),end="")
    print()

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=4):
    exit(ProgramName.get()+" <in.gff> <in.vcf.gz> <window-size>\n")
(gffFile,vcfFile,windowSize)=sys.argv[1:]
windowSize=int(windowSize)

degenerateCodons=Translation.getFourfoldDegenerateCodons()
gffReader=GffTranscriptReader()
genesbyChrom=gffReader.hashGenesBySubstrate(gffFile)


subst={}
clear(subst)
prevPos=0
with gzip.open(vcfFile,"rt") as IN:
    for line in IN:
        if(len(line)<10): continue
        if(line[0]=="#" or line[:5]=="CHROM"): continue
        fields=line.rstrip().split()
        (chr,pos,variant,ref,alt)=fields[:5]
        if(len(ref)!=1 or len(alt)!=1): continue
        pos=int(pos)
        subst[ref][alt]+=1
        if(pos-prevPos>=windowSize):
            emit(subst,chr,prevPos+1,pos)
            clear(subst)
            prevPos=pos
            

