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
from Transcript import Transcript
from Interval import Interval
from GffTranscriptReader import GffTranscriptReader
from Rex import Rex
rex=Rex()

if(len(sys.argv)!=8):
    exit(sys.argv[0]+
         " <indiv> <hap> <in.broken-sites> <junctions.bed> <in.gff> <in.readcounts> <all-broken-sites.txt>")
(indiv,hap,infile,junctionsFile,gffFile,readCountsFile,masterFile)=sys.argv[1:]

#============================= main() =================================

# Read the readcounts file
totalMappedReads=None
readCounts={}
with open(readCountsFile,"rt") as IN:
    while(True):
        line=IN.readline()
        if(line==""): break
        if(rex.find("TOTAL MAPPED READS:\s*(\d+)",line)):
            totalMappedReads=rex[1]
        else:
            fields=line.split()
            (gene,count)=fields
            readCounts[gene]=count

# Read GFF file to find annotated sites to exclude
gff={}
exclude={}
reader=GffTranscriptReader()
transcripts=reader.loadGFF(gffFile)
for transcript in transcripts:
    if(transcript.getID()[0:3]=="ALT"): continue
    if(rex.find("(\S+)_\d",transcript.getID())): gff[rex[1]]=transcript
    substrate=transcript.getSubstrate()
    exclusions=exclude.get(substrate,None)
    if(exclusions is None): exclusions=exclude[substrate]={}
    exons=transcript.getRawExons()
    exons.sort(key=lambda exon:exon.begin)
    numExons=len(exons)
    for i in range(numExons-1):
        key=str(exons[i].getEnd())+"-"+str(exons[i+1].getBegin())
        exclusions[key]=True

# Read broken-sites file
brokenSubstrates={}
with open(infile,"rt") as IN:
    while(True):
        line=IN.readline()
        if(line==""): break
        fields=line.split()
        if(len(fields)<10): continue
        (indiv,hap,geneID,transID,strand,exonNum,siteType,begin,pos,end)=fields
        substrate=geneID+"_"+hap
        brokenSubstrates[substrate]=True

# Read junctions file
junctions={}
with open(junctionsFile,"rt") as IN:
    while(True):
        line=IN.readline()
        if(line==""): break;
        fields=line.split()
        if(len(fields)<12): continue
        (substrate,begin,end,juncID,count,strand,begin2,end2,color,two,
         offsets,last)=fields
        begin=int(begin); end=int(end)
        array=junctions.get(substrate,None)
        if(array is None): array=junctions[substrate]=[]
        (left,right)=offsets.split(",")
        left=int(left); right=int(right)
        array.append([substrate,begin+left,end-right,count])

# Process the master broken-sites file
brokenSites=[]
with open(masterFile,"rt") as IN:
    while(True):
        line=IN.readline()
        if(line==""): break
        fields=line.split()
        if(len(fields)!=3): continue
        brokenSites.append(fields)
for brokenSite in brokenSites:
    (transID,exonIndex,siteType)=brokenSite
    exonIndex=int(exonIndex)
    transcript=gff.get(transID,None)
    if(not transcript): continue
    geneID=transcript.getGeneId()
    strand=transcript.getStrand()
    substrate=transcript.getSubstrate()
    if(brokenSubstrates.get(substrate,None)): continue
    exons=transcript.getRawExons()
    exons.sort(key=lambda exon: exon.begin)
    if(exonIndex>=len(exons)): 
        print(exonIndex,">=",len(exons))
        print(transcript.toGff())
    exon=exons[exonIndex]
    if(strand=="+"):
        if(siteType=="donor"):
            begin=exon.getBegin()
            pos=exon.getEnd()
            end=exons[exonIndex+1].getBegin()
        else:
            begin=exons[exonIndex-1].getEnd()
            pos=exon.getBegin()-2
            end=exon.getEnd()
    else:
        if(siteType=="donor"):
            begin=exons[exonIndex-1].getEnd()
            pos=exon.getBegin()-2
            end=exon.getEnd()
        else:
            begin=exon.getBegin()
            pos=exon.getEnd()
            end=exons[exonIndex+1].getBegin()
    exclusions=exclude.get(substrate,{})
    begin=int(begin); pos=int(pos); end=int(end)
    interval=Interval(pos-70,pos+70)
    if(interval.begin<begin): interval.begin=begin
    if(interval.end>end): interval.end=end
    juncs=junctions.get(substrate,[])
    #print("substrate=",substrate)
    sum=0
    for junc in juncs:
        (substrate,begin,end,count)=junc
        key=str(begin)+"-"+str(end)
        if(exclusions.get(key,False)): 
            continue
        if(interval.contains(begin) or interval.contains(end)): sum+=int(count)
    geneCount=readCounts.get(geneID,0)
    #print("gene=",geneID)
    if(rex.find("(\S+)_\d",geneID)): geneID=rex[1]
    print(indiv,hap,geneID,transID,strand,exonIndex,siteType,interval.begin,pos,
          interval.end,sum,geneCount,totalMappedReads,sep="\t",flush=True)


