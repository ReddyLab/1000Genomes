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

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=3):
    exit(ProgramName.get()+" <in.gff> <min-score>\n")
(gffFile,minScore)=sys.argv[1:]
minScore=float(minScore)

counts={}
reader=GffTranscriptReader()
genes=reader.loadGenes(gffFile)
for gene in genes:
    N=gene.numTranscripts()
    for i in range(N):
        transcript=gene.getIthTranscript(i)
        ID=transcript.getID()
        if(not rex.find("ALT(\d+)_(\S+)",ID)): continue
        alt=int(rex[1]); baseID=rex[2]
        if(transcript.getScore()<minScore): continue
        extraArray=transcript.parseExtraFields()
        hash=transcript.hashExtraFields(extraArray)
        if(hash.get("structure_change",None) is None): continue
        if("denovo-site" not in hash["structure_change"]): continue
        if(rex.find("ALT\d+_(\S+)",baseID)): baseID=rex[1]
        if(counts.get(baseID,None) is None): counts[baseID]=set()
        counts[baseID].add(alt)
baseIDs=counts.keys()
for baseID in baseIDs:
    numAlts=len(counts[baseID])
    print(numAlts)



