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
from FastaReader import FastaReader

MAX_LEN=200

def loadBetas(filename):
    betas={}
    with open(filename,"rt") as IN:
        for i in range(3): IN.readline()
        for line in IN:
            fields=line.rstrip().split()
            if(len(fields)!=2): continue
            (hexamer,score)=fields
            if(score=="."): score=0.0
            else: score=float(score)
            betas[hexamer]=score
    return betas

def process_old(seq,filename,betas):
    OUT=open(filename,"wt")
    L=len(seq)
    for i in range(0,L-6):
        score=betas[seq[i:i+6]]
        print(i,score,sep="\t",file=OUT)
    OUT.close()

def process_old2(seq,filename,betas):
    OUT=open(filename,"wt")
    L=len(seq)
    labels=[0]*L
    for i in range(0,L-6):
        score=betas[seq[i:i+6]]
        if(score<0):
            for j in range(i,i+6):
                if(labels[j]==0): labels[j]=-1
        elif(score>0):
            for j in range(i,i+6): labels[j]=1
    for i in range(0,L):
        print(i,labels[i],sep="\t",file=OUT)
    OUT.close()

def process(seq,filename,betas):
    OUT=open(filename,"wt")
    L=len(seq)
    labels=[0]*L
    for i in range(0,L-6):
        score=betas[seq[i:i+6]]
        for j in range(i,i+6): labels[j]+=score
    for i in range(0,L):
        print(i,labels[i],sep="\t",file=OUT)
    OUT.close()

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=5):
    exit(ProgramName.get()+" <betas.txt> <exons.fasta> <num-exons> <output-filestem>\n")
(betaFile,exonFile,maxExons,outStem)=sys.argv[1:]

maxExons=int(maxExons)
betas=loadBetas(betaFile)
exonNum=0
reader=FastaReader(exonFile)
while(exonNum<maxExons):
    exonNum+=1
    (defline,seq)=reader.nextSequence()
    if(defline is None): break
    if(len(seq)>MAX_LEN):
        mid=int(len(seq)/2)
        begin=mid-int(MAX_LEN/2)
        seq=seq[begin:begin+MAX_LEN]
    outfile=outStem+"-"+str(exonNum)+".txt"
    process(seq,outfile,betas)

