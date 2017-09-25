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
import random
import ProgramName
import TempFilename
from GffTranscriptReader import GffTranscriptReader
from FastaReader import FastaReader
from FastaWriter import FastaWriter
from Translation import Translation
from Rex import Rex
rex=Rex()

MIDDLE_ONLY=False
MAX_SEQS=100000
STOP="ATAAT"
FRAME=2
REFERENCE="/home/bmajoros/1000G/assembly/combined/ref/1.fasta"
AUGUSTUS_DIR="/home/bmajoros/splicing/augustus"
AUGUSTUS=AUGUSTUS_DIR+"/bin/augustus"
OPTIONS=" --strand=forward --genemodel=exactlyone --species=human "

def runAugustus(fastaFile):
    cmd=AUGUSTUS+" "+OPTIONS+" "+fastaFile+" > "+tempGFF
    os.system(cmd)
    transcripts=gffReader.loadGFF(tempGFF)
    if(len(transcripts)!=1): return None
    return transcripts[0]

def pickExon(transcript):
    numExons=transcript.numExons()
    i=None
    if(MIDDLE_ONLY):
        if(numExons<3): return None
        i=int(numExons/2)
    else:
        if(numExons<2): return None
        i=random.randint(0,numExons-1)
    return transcript.getIthExon(i)

def insertStop(transcript,seq,exon):
    stopLen=len(STOP)
    exonLen=exon.getLength()
    exonBegin=exon.getBegin()
    exonEnd=exon.getEnd()
    begin=random.randint(exonBegin,exonEnd-stopLen)
    offset=begin-exonBegin
    frame=(exon.getFrame()+offset)%3
    if(frame!=FRAME): begin+=FRAME-frame
    end=begin+stopLen
    if(begin<exonBegin): begin+=3; end+=3
    if(end>exonEnd): begin-=3; end-=3
    if(begin<exon.getBegin() or end>exon.getEnd()): return None
    newSeq=seq[0:begin]+STOP+seq[end:len(seq)]
    transcriptCoord=transcript.mapToTranscript(begin)
    return (newSeq,transcriptCoord)
    
def insertStop_old(seq,exon):
    stopLen=len(STOP)
    begin=exon.getBegin()
    frame=exon.getFrame()
    if(frame!=FRAME): begin+=FRAME-frame
    end=begin+stopLen
    if(begin<exon.getBegin() or end>=exon.getEnd()):
        raise Exception("insertStop()")
    newSeq=seq[0:begin]+STOP+seq[end:len(seq)]
    return newSeq

def getSpliceSites(transcript):
    sites=[]
    introns=transcript.getIntrons()
    for intron in introns:
        sites.append(intron.begin)
        sites.append(intron.end)
    return sites

def identical(sites1,sites2):
    n1=len(sites1)
    n2=len(sites2)
    if(n1!=n2): return False
    for i in range(n1):
        if(sites1[i]!=sites2[i]): return False
    return True

#=========================================================================
# main()
#=========================================================================

# Initialization
tempGFF=TempFilename.generate(".augustus.gff")
tempFasta=TempFilename.generate(".augustus.fasta")
gffReader=GffTranscriptReader()

# Iterate through sequences in FASTA file
fastaWriter=FastaWriter()
fastaReader=FastaReader(REFERENCE)
n=0
noPrediction=0
noSecondPrediction=0
numSame=0
numDiff=0
POS_SAME=open("pos-same.txt","wt")
POS_DIFF=open("pos-different.txt","wt")
while(True):
    if(MAX_SEQS>0 and n>=MAX_SEQS): break
    (defline,seq)=fastaReader.nextSequence()
    if(defline is None): break
    (id,attributes)=FastaReader.parseDefline(defline)
    coord=attributes.get("coord",None)
    if(coord is None): raise Exception("no coord attrigbute in "+id)
    if(not rex.find("\S+:\d+-\d+:(.)",coord)):
        raise Exception("can't parse coord "+coord)
    strand=rex[1]
    if(strand=="-"):
        seq=Translation.reverseComplement(seq)

    # Run Augustus to get first prediction
    fastaWriter.writeFasta(">"+id,seq,tempFasta)
    prediction1=runAugustus(tempFasta)
    if(prediction1 is None): noPrediction+=1; continue
    if(prediction1.getStrand()!="+"): continue

    # Insert stop codon
    exon=pickExon(prediction1)
    if(exon is None): continue
    if(exon.getLength()<30): continue
    (seq,transcriptCoord)=insertStop(prediction1,seq,exon)
    if(seq is None): continue
    L=prediction1.getLength()
    relativePos=float(transcriptCoord)/float(L)

    # Re-run with stop codon inserted
    fastaWriter.writeFasta(">"+id,seq,tempFasta)
    prediction2=runAugustus(tempFasta)
    if(prediction2 is None): noSecondPrediction+=1; continue
    if(prediction2.getStrand()!="+"): continue

    # See if start codon changed
    prediction1.sortExons(); prediction2.sortExons()
    (begin1,end1)=prediction1.getCDSbeginEnd()
    (begin2,end2)=prediction2.getCDSbeginEnd()
    startChanged="different-ATG" if begin1!=begin2 else "same-ATG"

    # Compare new and old predictions
    #print("old prediction: ",prediction1.toGff())
    #print("new prediction: ",prediction2.toGff())
    sites1=getSpliceSites(prediction1)
    sites2=getSpliceSites(prediction2)
    if(identical(sites1,sites2)):
        numSame+=1
        print(relativePos,startChanged,sep="\t",file=POS_SAME,flush=True)
    else:
        numDiff+=1
        print(relativePos,startChanged,sep="\t",file=POS_DIFF,flush=True)
    n+=1

    # Report results
    ratioDiff=float(numDiff)/float(numDiff+numSame)
    print("n=",n,"%diff=",ratioDiff,"same:",numSame,", different:",numDiff,
          ",no prediction:",noPrediction,"no second prediction:",
          noSecondPrediction)

# Clean up
POS_SAME.close()
POS_DIFF.close()
os.remove(tempGFF)
os.remove(tempFasta)
