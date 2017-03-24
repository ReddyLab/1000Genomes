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
if(len(sys.argv)!=2):
    exit(ProgramName.get()+" <in.gff>\n")
(infile,)=sys.argv[1:]

reader=GffTranscriptReader()
transcripts=reader.loadGFF(infile)
for transcript in transcripts:
    introns=transcript.getIntrons()
    transId=transcript.getTranscriptId()
    geneId=transcript.getGeneId()
    extra=transcript.hashExtraFields(transcript.parseExtraFields())
    change=extra.get("structure_change","")
    hap="?"
    if(rex.find("(\S+)_(\d+)",geneId)):
        geneId=rex[1]; hap=rex[2]
    if(rex.find("(\S+)_(\d+)",transId)):
        transId=rex[1]; hap=rex[2]
    for intron in introns:
        print(geneId,hap,transId,intron.begin,intron.end,
              transcript.getStrand(),change,sep="\t")


