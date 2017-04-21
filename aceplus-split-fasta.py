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
from FastaWriter import FastaWriter
from GffTranscriptReader import GffTranscriptReader
from Rex import Rex
rex=Rex()

def writeTranscripts(transcripts,OUT):
    for transcript in transcripts:
        print(transcript.toGff(),file=OUT)

def getFilenames(outDir,hap,fileNum):
    outFasta=outDir+"/"+hap+".subset-"+str(fileNum)+".fasta"
    outRef=outDir+"/"+hap+".subset-"+str(fileNum)+".ref.fasta"
    outGFF=outDir+"/"+hap+".subset-"+str(fileNum)+".gff"
    return (outFasta,outRef,outGFF)

def getSubstrate(defline):
    if(not rex.find("^>(\S+)",defline)): raise Exception("can't parse "+defline)
    return rex[1]

def getTranscripts(transcripts,substrate):
    if(not rex.find("(\S+)_\d",substrate)): raise Exception(substrate)
    return transcripts[rex[1]]

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=7):
    exit(ProgramName.get()+
         " <in.fasta> <ref.fasta> <in.gff> <hap> <#subsets> <out-dir>\n")
(inFasta,refFasta,inGff,hap,numSubsets,outDir)=sys.argv[1:]

# Load pooled GFF file
reader=GffTranscriptReader()
bySubstrate=reader.hashBySubstrate(inGff)

# Count sequences in fasta file
N=FastaReader.countEntries(inFasta)
seqsPerBin=int(N/int(numSubsets)+1)

# Iterate over sequences in fasta file
reader=FastaReader(inFasta); refReader=FastaReader(refFasta)
writer=FastaWriter()
fileNum=1
(outFasta,outRef,outGFF)=getFilenames(outDir,hap,fileNum)
FASTA=open(outFasta,"wt")
REF=open(outRef,"wt")
GFF=open(outGFF,"wt")
nextBoundary=seqsPerBin
index=0
while(True):
    (defline,sequence)=reader.nextSequence()
    if(defline is None): break
    substrate=getSubstrate(defline)
    while(True):
        (refDef,refSeq)=refReader.nextSequence()
        if(refDef is None): raise Exception(substrate+" not found")
        if(getSubstrate(refDef)==substrate): break
    transcripts=getTranscripts(bySubstrate,substrate)
    writeTranscripts(transcripts,GFF)
    writer.addToFasta(defline,sequence,FASTA)
    writer.addToFasta(refDef,refSeq,REF)
    index+=1
    if(index>=nextBoundary):
        fileNum+=1
        (outFasta,outRef,outGFF)=getFilenames(outDir,hap,fileNum)
        FASTA.close(); REF.close(); GFF.close()
        FASTA=open(outFasta,"wt")
        REF=open(outRef,"wt")
        GFF=open(outGFF,"wt")
        nextBoundary+=seqsPerBin
FASTA.close(); REF.close(); GFF.close()

