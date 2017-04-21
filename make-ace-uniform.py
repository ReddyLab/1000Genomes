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
import random
import sys
import ProgramName
from GffTranscriptReader import GffTranscriptReader
from Rex import Rex
rex=Rex()

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=3):
    exit(ProgramName.get()+" <ace.gff> <aceplus.gff>\n")
(aceGFF,aceplusGFF,)=sys.argv[1:]

reader=GffTranscriptReader()
transcripts=reader.loadGFF(aceGFF)
counts={}
hasAlts=set()
for transcript in transcripts:
    id=transcript.getTranscriptId()
    if(rex.find("ALT\d+_(\S+)",id)):
        baseID=rex[1]
        hasAlts.add(baseID)
    else: baseID=id
    transcript.baseID=baseID
    counts[baseID]=counts.get(baseID,0)+1
for transcript in transcripts:
    n=counts[transcript.baseID]
    transcript.score=1.0/float(n)
    print(transcript.toGff())

exit ###

transcripts=reader.loadGFF(aceplusGFF)
seen=set()
for transcript in transcripts:
    id=transcript.getTranscriptId()
    if(rex.find("ALT\d+_(\S+)",id)):
        baseID=rex[1]
        #if(baseID in hasAlts or baseID in seen): continue
        if(baseID in hasAlts): continue
        transcript.score=0.0
        print(transcript.toGff())
        seen.add(baseID)
for transcript in transcripts:
    id=transcript.getTranscriptId()
    if(rex.find("ALT\d+_(\S+)",id)): continue
    if(id not in seen): continue
    transcript.score=0.0
    print(transcript.toGff())
    seen.add(baseID)

