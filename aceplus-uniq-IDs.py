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

def getStructureChanges(transcript,attributes):
    changeString=attributes.get("structure_change","")
    fields=changeString.split(" ")
    changes=set()
    for field in fields: changes.add(field)
    return changes

def isMapped(transcript):
    pairs=transcript.parseExtraFields()
    attributes=transcript.hashExtraFields(pairs)
    changes=getStructureChanges(transcript,attributes)
    return "mapped-transcript" in changes

def process(bySubstrate):
    substrates=bySubstrate.keys()
    for substrate in substrates:
        nextAlt=1
        array=bySubstrate[substrate]
        for transcript in array:
            if(isMapped(transcript)): continue
            id=transcript.getID()
            if(rex.find("ALT\d+_(ALT\d+\S+)",id)):
                id=rex[1]
            if(rex.find("ALT\d+_(\S+)",id)):
                id="ALT"+str(nextAlt)+"_"+rex[1]
                transcript.setTranscriptId(id)
                nextAlt+=1
                gff=transcript.toGff()
                print(gff+"\n")

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)<2):
    exit(ProgramName.get()+" <in1.gff> <in2.gff> ...  >  out.gff\n")
filenames=sys.argv[1:]

bySubstrate={}
for filename in filenames:
    reader=GffTranscriptReader()
    reader.exonsAreCDS=True
    reader.hashBySubstrateInto(filename,bySubstrate)
process(bySubstrate)

