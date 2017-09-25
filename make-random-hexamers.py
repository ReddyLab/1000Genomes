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
from NgramIterator import NgramIterator
import random

def loadBetas(filename):
    sums={}
    counts={}
    with open(filename,"rt") as IN:
        for i in range(3): IN.readline()
        for line in IN:
            fields=line.rstrip().split()
            (hex,score)=fields
            if(score=="."): score=0.0
            else: score=float(score)
            setSubstrings(hex,score,sums,counts)
    hash={}
    for kmer in sums.keys():
        hash[kmer]=sums[kmer]/counts[kmer]
    return hash

def setSubstrings(hex,score,sums,counts):
    L=len(hex)
    for i in range(0,L):
        for j in range(i+1,L+1):
            sub=hex[i:j]
            sums[sub]=sums.get(sub,0.0)+score
            counts[sub]=counts.get(sub,0.0)+1.0

def trimMotifs(motifs,size):
    new=[]
    for motif in motifs:
        L=len(motif)
        if(L<size): new.append(motif)
        else:
            for i in range(0,L-size+1):
                sub=motif[i:i+size]
                new.append(sub)
    return new

def IUPAC(motifs):
    new=set()
    for motif in motifs:
        alts=[motif]
        changes=True
        while(changes):
            changes=replace(alts,"N","ACGT")
            changes=replace(alts,"R","AG") or changes
            changes=replace(alts,"Y","CT") or changes
            changes=replace(alts,"D","AGT") or changes
            changes=replace(alts,"K","TG") or changes
            changes=replace(alts,"M","AC") or changes
            changes=replace(alts,"S","GC") or changes
            changes=replace(alts,"W","AT") or changes
            changes=replace(alts,"U","T") or changes
        for alt in alts: new.add(alt)
    asList=[]
    for alt in new: asList.append(alt)
    return asList

def replace(alts,symbol,replacements):
    i=0
    changes=False
    while(i<len(alts)):
        motif=alts[i]
        if(symbol not in motif):
            i+=1
            continue
        del alts[i]
        generate(motif,symbol,replacements,alts)
        changes=True
    return changes

def generate(motif,symbol,replacements,alts):
    L=len(motif)
    for i in range(L):
        if(motif[i]==symbol):
            for c in replacements:
                alt=motif[0:i]+c+motif[i+1:L]
                alts.append(alt)

def loadMotifs(filename):
    motifs=[]
    with open(filename,"rt") as IN:
        for line in IN:
            motif=line.rstrip()
            if(len(motif)>0): motifs.append(motif)
    return motifs

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=1):
    exit(ProgramName.get()+" \n")
#(motifFile,)=sys.argv[1:]

print("\n\n")
ngramIterator=NgramIterator("ATCG",6)
while(True):
    string=ngramIterator.nextString()
    if(string is None): break
    score=random.uniform(-1.0,1.0)
    print(string,score,sep="\t")


