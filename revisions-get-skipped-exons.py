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
from EssexParser import EssexParser
from Transcript import Transcript
if(len(sys.argv)!=4): exit(sys.argv[0]+" <indiv> <hap> <in.essex>")
(indiv,hap,infile)=sys.argv[1:]

def printExons(exons):
    for exon in exons:
        print(exon.toGff())

def findSkippedExon(exonsA,exonsB,transA,transB):
    numA=len(exonsA)
    numB=len(exonsB)
    if(numA!=numB+1): 
        return None
    for i in range(numA):
        exonA=exonsA[i]
        if(i==numB): return i
        exonB=exonsB[i]
        if(exonA.getBegin()!=exonB.getBegin()): return i
    exit("skipped exon not found")

def getJunction(exons,strand,i):
    if(strand=="+"):
        return (exons[i-1].getEnd(),exons[i+1].getBegin())
    return (exons[i+1].getEnd(),exons[i-1].getBegin())

#============================= main() =================================
parser=EssexParser(infile)
while(True):
    report=parser.nextElem()
    if(not report): break
    statusNode=report.findChild("status")
    if(not statusNode): continue
    if(not statusNode.hasDescendentOrDatum("splicing-changes")): continue
    altsNode=statusNode.findChild("alternate-structures")
    if(not altsNode): continue
    geneID=report.getAttribute("gene-ID")
    transID=report.getAttribute("transcript-ID")
    mappedNode=report.findChild("mapped-transcript")
    strand=mappedNode.getAttribute("strand")
    mappedTranscript=Transcript(mappedNode)
    transcripts=altsNode.findChildren("transcript")
    numTrans=len(transcripts)
    for transNode in transcripts:
        change=transNode.getAttribute("structure-change")
        if(change!="exon-skipping"): continue
        transcript=Transcript(transNode)
        mappedExons=mappedTranscript.getRawExons()
        altExons=transcript.getRawExons()
        index=findSkippedExon(mappedExons,altExons,mappedTranscript,transcript)
        if(index is None): break
        if(index>=len(mappedExons)-1): break
        (begin,end)=getJunction(mappedExons,strand,index)
        print(indiv,hap,geneID,transID,index,begin,end,"skipped",
              sep="\t",flush=True)
        break

