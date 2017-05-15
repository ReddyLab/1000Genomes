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
import TempFilename
from GffTranscriptReader import GffTranscriptReader
from FastaReader import FastaReader
from FastaWriter import FastaWriter

AUGUSTUS_DIR="/home/bmajoros/splicing/augustus"
AUGUSTUS=AUGUSTUS_DIR+"/bin/augustus"
#EXTRINSIC=AUGUSTUS_DIR+"/config/extrinsic/extrinsic.cfg"
EXTRINSIC=AUGUSTUS_DIR+"/config/extrinsic/extrinsic.MPE.cfg"

def writeHints(id,transcript,L,hintsFile):
    OUT=open(hintsFile,"wt")
    substrate=transcript.getSubstrate()
    strand=transcript.getStrand()
    numExons=transcript.numExons()
    for i in range(numExons):
        exon=transcript.getIthExon(i)
        print(substrate,"annotation","CDSpart",exon.getBegin()+1,
              exon.getEnd(),".",strand,exon.getFrame(),"source=P",
              sep="\t",file=OUT)
    numUTR=transcript.numUTR()
    for i in range(numUTR):
        utr=transcript.getIthUTR(i)
        print(substrate,"annotation","UTRpart",utr.getBegin()+1,utr.getEnd(),
              ".",strand,".","source=E",sep="\t",file=OUT)
    introns=transcript.getIntrons()
    for intron in introns:
        print(substrate,"annotation","intronpart",intron.getBegin()+1,
              intron.getEnd(),".",strand,".","source=E",sep="\t",file=OUT)
    print(substrate,"annotation","irpart",1,transcript.getBegin(),
          ".",strand,".","source=E",sep="\t",file=OUT)
    print(substrate,"annotation","irpart",transcript.getEnd()+1,L,
          ".",strand,".","source=E",sep="\t",file=OUT)
    OUT.close()

def runAugustus(fastaFile,hintsFile):
    cmd=AUGUSTUS+" --species=human --hintsfile="+hintsFile+\
        " --extrinsicCfgFile="+EXTRINSIC+" "+fastaFile+\
        " --alternatives-from-sampling=true --sample=100 --UTR=on"
    os.system(cmd)

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=3):
    exit(ProgramName.get()+" <in.gff> <in.fasta>\n")
(gffFile,fastaFile)=sys.argv[1:]

# Create temp files
hintsFile=TempFilename.generate(".hints")
tempFasta=TempFilename.generate(".fasta")

# Load GFF
reader=GffTranscriptReader()
bySubstrate=reader.hashBySubstrate(gffFile)

# Iterate through sequences in FASTA file
writer=FastaWriter()
reader=FastaReader(fastaFile)
while(True):
    (defline,seq)=reader.nextSequence()
    if(defline is None): break
    (id,attributes)=FastaReader.parseDefline(defline)
    writer.writeFasta(defline,seq,tempFasta)
    transcripts=bySubstrate.get(id,[])
    for transcript in transcripts:
        if(transcript.getID()[:3]=="ALT"): continue
        writeHints(id,transcript,len(seq),hintsFile)
        runAugustus(tempFasta,hintsFile)

# Clean up
os.remove(hintsFile)
os.remove(tempFasta)

