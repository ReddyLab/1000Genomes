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
from GffTranscriptReader import GffTranscriptReader

MIN_READS=3
MIN_COVERED=30
MIN_COVERAGE=0.1

def loadGFF(filename,intoHash):
    reader=GffTranscriptReader()
    h=reader.hashBySubstrate(filename)
    for key in h.keys():
        to=intoHash[key]=[]
        for transcript in h[key]:
            if(transcript.getID()[0:3]=="ALT"): continue
            to.append(transcript)
    reader=None

def getIntrons(transcriptHash):
    intronHash={}
    for substrate in transcriptHash.keys():
        transcripts=transcriptHash[substrate]
        seen=set()
        for transcript in transcripts:
            introns=transcript.getIntrons()
            for intron in introns:
                key=str(intron.begin)+" "+str(intron.end)
                if(key in seen): continue
                seen.add(key)
                array=intronHash.get(key,None)
                if(array is None): array=intronHash[key]=[]
                array.append(intron)
    return intronHash

def loadLengths(filename,hash):
    with open(filename,"rt") as IN:
        for line in IN:
            fields=line.rstrip().split()
            if(len(fields)!=3): continue
            (index,substrate,L)=fields
            hash[substrate]=int(L)

def processGene(chrom,intronHash,pileup):
    introns=intronHash[chrom]
    for intron in introns:
        checkIntron(intron,pileup,chrom)

def getCoverage(intron,pileup,minReads):
    covered=0
    for i in range(N):
        if(pileup[i]>=minReads): covered+=1
    return covered

def checkIntron(intron,pileup,chrom):
    covered=getCoverage(intron,pileup,MIN_READS)
    if(covered<MIN_COVERED): return
    cov=float(covered)/float(intron.length())
    print(chrom,cov,sep="\t")
    if(cov<MIN_COVERAGE): return

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=6):
    exit(ProgramName.get()+" <1.gff> <2.gff> <1.lengths> <2.lengths> <pileup.gz>\n")
(gffFile1,gffFile2,lengthFile1,lengthFile2,pileupFile)=sys.argv[1:]

# Load lengths
lengthHash={}
print("loading length file 1",file=sys.stderr)
loadLengths(lengthFile1,lengthHash)
print("loading length file 2",file=sys.stderr)
loadLengths(lengthFile2,lengthHash)

# Load introns from GFF files
print("loading gff file 1",file=sys.stderr)
transcriptHash={}
loadGFF(gffFile1,transcriptHash)
print("loading gff file 2",file=sys.stderr)
loadGFF(gffFile2,transcriptHash)
print("hashing introns",file=sys.stderr)
intronHash=getIntrons(transcriptHash)

# Process pileup file
print("processing pileup file")
prevPos=-1
chrom=None
pileup=None
with gzip.open(pileupFile,"rt") as IN:
    for line in IN:
        fields=line.split()
        if(len(fields)<3): continue
        (substrate,pos,reads)=fields[:3]
        pos=int(pos); reads=int(reads)
        if(substrate!=chrom):
            if(chrom is not None): processGene(chrom,intronHash,pileup)
            chrom=substrate
            pileup=[0]*lengthHash[chrom]
        prevPos=int(pos)
        pileup[pos]=reads
    processGene(chrom,intronHash,pileup)
