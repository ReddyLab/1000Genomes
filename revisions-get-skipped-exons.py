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

def hashExons(transcript):
    hash={}
    n=transcript.numExons()
    for i in range(n):
        exon=transcript.getIthExon(i)
        key=str(exon.getBegin())+"-"+str(exon.getEnd())
        hash[key]=i
    return hash

def findSkippedExon(transA,transB):
    numA=transA.numExons()
    numB=transB.numExons()
    if(numA!=numB-1): 
        print(transA.toGff(),"\n",transB.toGff())
        exit("exon count mismatch")
    for i in range(numA):
        exonA=transA.getIthExon(i)
        if(i==numB): return i
        exonB=transB.getIthExon(i)
        if(exonA.getBegin()!=exonB.getBegin()): return i
    exit("skipped exon not found")

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
    mappedTranscript=Transcript(mappedNode)
    transcripts=altsNode.findChildren("transcript")
    numTrans=len(transcripts)
    print(numTrans,"alt transcripts",flush=True)
    for transNode in transcripts:
        change=transNode.getAttribute("structure-change")
        if(change!="exon-skipping"): continue
        transcript=Transcript(transNode)
        index=findSkippedExon(mappedTranscript,transcript)
        exon=mappedTranscript.getIthExon(index)
        print(indiv,hap,geneID,transID,index,exon.getBegin(),exon.getEnd(),
              "skipped",sep="\t",flush=True)

