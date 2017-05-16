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
    for chrom in chroms:
        transcripts=hashTable[chrom]
        processGene(transcripts)

def getAnnotatedExons(refTranscripts):
    allExons=set()
    for transcript in refTranscripts.values():
        exons=transcript.getRawExons()
        for exon in exons:
            key=str(exon.begin)+" "+str(exon.end)
            allExons.add(key)
    return allExons

def getAnnotatedIntrons(refTranscripts):
    allIntrons=set()
    for transcript in refTranscripts.values():
        introns=transcript.getIntrons()
        for intron in introns:
            key=str(intron.begin)+" "+str(intron.end)
            allIntrons.add(key)
    return allIntrons

def getStructureChanges(transcript,attributes):
    changeString=attributes.get("structure_change","")
    fields=changeString.split(" ")
    changes=set()
    for field in fields: changes.add(field)
    return changes

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
        pairs=transcript.parseExtraFields()
        attributes=transcript.hashExtraFields(pairs)
        changes=getStructureChanges(transcript,attributes)
        if("mapped-transcript" in changes): continue
        changes=setToString(changes)
        found1=getUniqueJunctions(transcript,annotatedIntrons,changes,
                                  attributes)
        found2=getIntronRetentions(transcript,refTranscripts,changes,
                                   attributes)
        #if(not found1 and not found2):
        #   raise Exception("No unique features found for "+transcript.getID())

def setToString(s):
    r=""
    for elem in s:
        if(len(r)>0): r+=","
        r+=elem
    return r    

def getUniqueJunctions(transcript,annotatedIntrons,changes,attributes):
    introns=transcript.getIntrons()
    fate=attributes.get("fate","none")
    broken=attributes.get("broken-site")
    if(broken is None or broken==""): broken="false"
    found=False
    for intron in introns:
        key=str(intron.begin)+" "+str(intron.end)
        if(key not in annotatedIntrons):
            print(transcript.getGeneId(),transcript.getId(),"junction",
                  str(intron.begin)+"-"+str(intron.end),
                  transcript.getScore(),transcript.getStrand(),
                  changes,fate,broken,sep="\t")
            found=True
    return found

def exonIsAnnotated(exon,annotatedExons):
    key=str(exon.begin)+" "+str(exon.end)
    return key in annotatedExons

def getIntronRetentions(transcript,refTranscripts,changes,attributes):
    ref=refTranscripts[transcript.refID]
    refIntrons=ref.getIntrons()
    annotatedExons=getAnnotatedExons(refTranscripts)
    exons=transcript.getRawExons()
    fate=attributes.get("fate","none")
    broken=attributes.get("broken-site")
    if(broken is None or broken==""): broken="false"
    found=False
    for exon in exons:
        for refIntron in refIntrons:
            if(exon.asInterval().containsInterval(refIntron)):
                if(exonIsAnnotated(exon,annotatedExons)): continue
                print(transcript.getGeneId(),transcript.getId(),
                      "intron-retention",
                      str(refIntron.begin)+"-"+str(refIntron.end),
                      transcript.getScore(),transcript.getStrand(),
                      changes,fate,broken,sep="\t")
                found=True
    return found

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=2):
    exit(ProgramName.get()+" <in.gff>")
(gffFile,)=sys.argv[1:]

processGFF(gffFile)






