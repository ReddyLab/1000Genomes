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
from Interval import Interval
if(len(sys.argv)!=4): exit(sys.argv[0]+" <indiv> <hap> <in.essex>")
(indiv,hap,infile)=sys.argv[1:]

def printExons(exons):
    for exon in exons:
        print(exon.toGff())

def getInterval(pos,exons):
    numExons=len(exons)
    for i in range(numExons):
        exon=exons[i]
        interval=None
        if(pos+2==exon.getBegin()):
            interval=Interval(exons[i-1].end,exon.getEnd())
        elif(pos==exon.getEnd()):
            interval=Interval(exon.getBegin(),exons[i+1].getBegin())
        if(interval): 
            interval.exon=i
            return interval
    return None

#============================= main() =================================
parser=EssexParser(infile)
while(True):
    report=parser.nextElem()
    if(not report): break
    statusNode=report.findChild("status");
    if(not statusNode): continue
    siteType="donor"
    brokenNode=statusNode.findChild("broken-donor")
    if(not brokenNode):
        siteType="acceptor"
        brokenNode=statusNode.findChild("broken-acceptor")
    if(not brokenNode): continue
    sitePos=int(brokenNode.getIthElem(0))
    geneID=report.getAttribute("gene-ID")
    transID=report.getAttribute("transcript-ID")
    mappedNode=report.findChild("mapped-transcript")
    strand=mappedNode.getAttribute("strand")
    mappedTranscript=Transcript(mappedNode)
    mappedExons=mappedTranscript.getRawExons()
    mappedExons.sort(key=lambda exon: exon.begin)
    interval=getInterval(sitePos,mappedExons)
    #if(interval is None): print(mappedTranscript.toGff())
    if(interval is None): continue
    print(indiv,hap,geneID,transID,strand,interval.exon,siteType,
          interval.begin,sitePos,interval.end,sep="\t",flush=True)


