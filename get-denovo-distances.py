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
from GffTranscriptReader import GffTranscriptReader
from Rex import Rex
rex=Rex()

ASSEMBLY="/home/bmajoros/1000G/assembly/"
#RNA_FILE="/home/bmajoros/1000G/assembly/rna150/denovo-rna-nofilter/HG00096.1.txt"

def loadRNA():
    keep=set()
    with open(RNA_FILE,"rt") as IN:
        for line in IN:
            fields=line.rstrip().split()
            (denovo,spliceType,gene,hap,coding,transID,altID,strand,
             score,junctionBegin,junctionEnd,fate,identity,variant,
             splicingActivity,newCount,oldCount)=fields
            if(denovo!="denovo"): continue
            if(splicingActivity==0.0): continue
            keep.add(gene+" "+str(junctionBegin))
            keep.add(gene+" "+str(junctionEnd))
            #print("adding",gene+" "+str(junctionBegin))
            #print("adding",gene+" "+str(junctionEnd))
    return keep

def getMappedTranscript(gene):
    numTrans=gene.numTranscripts()
    for i in range(numTrans):
        transcript=gene.getIthTranscript(i)
        extra=transcript.parseExtraFields()
        hashExtra=transcript.hashExtraFields(extra)
        change=hashExtra.get("structure_change",None)
        if(change=="mapped-transcript"): return transcript
    return None

def getDistance(trans1,trans2,rna):
    rawExons1=trans1.getRawExons()
    rawExons2=trans2.getRawExons()
    geneID=trans1.getGeneId()
    if(rex.find("(\S+)_\d+",geneID)): geneID=rex[1]
    n=len(rawExons1)
    if(len(rawExons2)!=n): return None
    for i in range(n):
        exon1=rawExons1[i]; exon2=rawExons2[i]
        if(exon1.getBegin()!=exon2.getBegin() and
           exon1.getEnd()==exon2.getEnd()):
            if(geneID+" "+str(exon1.getBegin()) in rna):
                return abs(exon1.getBegin()-exon2.getBegin())
            #else: 
                #print("NOT FOUND:",geneID+" "+str(exon1.getBegin()),flush=True)
                #os.system("grep "+geneID+" "+RNA_FILE)
        if(exon1.getEnd()!=exon2.getEnd() and
           exon1.getBegin()==exon2.getBegin()):
            if(geneID+" "+str(exon1.getEnd()) in rna):
                return abs(exon1.getEnd()-exon2.getEnd())
            #else: 
                #print("NOT FOUND:",geneID+" "+str(exon1.getEnd()),flush=True)
                #os.system("grep "+geneID+" "+RNA_FILE)
    return None

def System(cmd):
    print(cmd,flush=True)
    os.system(cmd)

def processGene(gene,rna,indiv):
    mapped=getMappedTranscript(gene)
    if(mapped is None): return
    numTrans=gene.numTranscripts()
    for i in range(numTrans):
        transcript=gene.getIthTranscript(i)
        extra=transcript.parseExtraFields()
        hashExtra=transcript.hashExtraFields(extra)
        change=hashExtra.get("structure_change",None)
        if(change!="denovo-site"): continue
        score=transcript.getScore()
        distance=getDistance(transcript,mapped,rna)
        if(distance is None): continue
        print(score,distance,gene.getStrand(),gene.getId(),indiv,
              sep="\t",flush=True)

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=3):
    exit(ProgramName.get()+" <indiv> <hap>\n")
(indiv,hap)=sys.argv[1:]

RNA_FILE=ASSEMBLY+"rna150/denovo-rna-nofilter/"+indiv+"."+hap+".txt"
gffFile=ASSEMBLY+"combined/"+indiv+"/"+hap+".logreg.gff"

reader=GffTranscriptReader()
genes=reader.loadGenes(gffFile)
rna=loadRNA()
for gene in genes:
    processGene(gene,rna,indiv)


