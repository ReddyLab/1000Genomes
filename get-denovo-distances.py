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
from GffTranscriptReader import GffTranscriptReader
from Rex import Rex
rex=Rex()

def getMappedTranscript(gene):
    numTrans=gene.numTranscripts()
    for i in range(numTrans):
        transcript=gene.getIthTranscript(i)
        extra=transcript.parseExtraFields()
        hashExtra=transcript.hashExtraFields(extra)
        change=hashExtra.get("structure_change",None)
        if(change=="mapped-transcript"): return transcript
    return None

def getDistance(trans1,trans2):
    rawExons1=trans1.getRawExons()
    rawExons2=trans2.getRawExons()
    n=len(rawExons1)
    if(len(rawExons2)!=n): return None
    for i in range(n):
        exon1=rawExons1[i]; exon2=rawExons2[i]
        if(exon1.getBegin()!=exon2.getBegin() and
           exon1.getEnd()==exon2.getEnd()):
            return abs(exon1.getBegin()-exon2.getBegin())
        if(exon1.getEnd()!=exon2.getEnd() and
           exon1.getBegin()==exon2.getBegin()):
            return abs(exon1.getEnd()-exon2.getEnd())
    return None

def processGene(gene):
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
        distance=getDistance(transcript,mapped)
        if(distance is None): continue
        print(score,distance,sep="\t",flush=True)

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=2):
    exit(ProgramName.get()+" <in.gff>\n")
(gffFile,)=sys.argv[1:]

reader=GffTranscriptReader()
genes=reader.loadGenes(gffFile)
for gene in genes:
    processGene(gene)


