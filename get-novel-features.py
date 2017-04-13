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

def processGFF(filename):
    reader=GffTranscriptReader()
    hashTable=reader.hashBySubstrate(filename)
    chroms=hashTable.keys()
    for chrom in keys:
        transcripts=hashTable[chrom]
        processGene(transcripts)

def getAnnotatedIntrons(refTranscripts):
    allIntrons=set()
    for transcript in refTranscripts:
        introns=transcript.getIntrons()
        for intron in introns:
            key=str(intron.begin)+" "+str(intron.end)
            allIntrons.add(key)
    return allIntrons

def processGene(transcripts):
    refTranscripts={}; altTranscripts=[]
    for transcript in transcripts:
        id=transcript.getID()
        if(rex.find("ALT\d+_(\S+)",id)):
            transcript.refID=rex[1]
            altTranscripts.append(transcript)
        else: refTranscripts[id]=transcript
    annotatedIntrons=getAnnotatedIntrons(refTranscripts)
    for transcript in altTranscripts:
        found1=getUniqueJunctions(transcript,annotatedIntrons)
        found2=getIntronRetentions(transcript,refTranscripts)
        if(not found1 and not found2):
            raise Exception("No unique features found for "+transcript.getID())

def getUniqueJunctions(transcript,annotatedIntrons):
    introns=transcript.getIntrons()
    found=False
    for intron in introns:
        key=str(intron.begin)+" "+str(intron.end)
        if(key not in annotatedIntrons):
            print(transcript.getGeneId(),transcript.getId(),"junction",
                  str(intron.begin)+"-"+str(intron.end),transcript.getStrand(),
                  sep="\t")
            found=True
    return found

def getIntronRetentions(transcript,refTranscripts):
    ref=refTranscripts[transcript.refID]
    refIntrons=ref.getIntrons()
    exons=transcript.getRawExons()
    found=False
    for exon in exons:
        for refIntron in refIntrons:
            if(exon.containsInterval(refIntron)):
                print(ranscript.getGeneId(),transcript.getId(),
                      "intron-retention",str(intron.begin)+"-"+str(intron.end),
                      transcript.getStrand(),sep="\t")
                found=True
    return found

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=2):
    exit(ProgramName.get()+" <in.gff>")
(gffFile,)=sys.argv[1:]

processGFF(gffFile)






