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

def getKey(transcript):
    #key=""
    key=transcript.substrate+" "
    exons=transcript.getRawExons()
    for exon in exons:
        key+=str(exon.begin)+"-"+str(exon.end)+" "
    return key

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=2):
    exit(ProgramName.get()+" <in.gff>\n")
(infile,)=sys.argv[1:]

totalDup=0
totalDedup=0
reader=GffTranscriptReader()
reader.exonsAreCDS=True
bySubstrate=reader.hashBySubstrate(infile)
chroms=bySubstrate.keys()
for chrom in chroms:
    transcripts=bySubstrate[chrom]
    seen=set()
    for transcript in transcripts:
        if(transcript.getID()[:3]=="ALT"): continue
        totalDup+=1
        key=getKey(transcript)
        if(key in seen): continue
        seen.add(key)
        gff=transcript.toGff()
        print(gff)
        totalDedup+=1
    for transcript in transcripts:
        if(transcript.getID()[:3]!="ALT"): continue
        totalDup+=1
        key=getKey(transcript)
        if(key in seen): continue
        seen.add(key)
        gff=transcript.toGff()
        print(gff)
        totalDedup+=1
#print(totalDup,"with duplicates,\t",totalDedup,"without duplicates",
#      file=sys.stderr)


