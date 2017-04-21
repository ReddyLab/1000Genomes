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

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=4):
    exit(ProgramName.get()+" <in.fasta> <in.gff> <out.fasta>\n")
(inFasta,inGff,outFasta)=sys.argv[1:]

# Get list of transcripts having alternate splice forms
reader=GffTranscriptReader()
bySubstrate=reader.hashBySubstrate(inGff)
substrates=bySubstrate.keys()
keep=set()
for substrate in substrates:
    transcripts=bySubstrate[substrate]
    for transcript in transcripts:
        if(rex.find("ALT\d+_",transcript.getID())):
            keep.add(substrate)
            break

# Iterate over sequences in fasta file
reader=FastaReader(inFasta)
writer=FastaWriter()
OUT=open(outFasta,"wt")
while(True):
    (defline,sequence)=reader.nextSequence()
    if(defline is None): break
    if(not rex.find("^>(\S+)",defline)): raise Exception("can't parse "+defline)
    substrate=rex[1]
    if(substrate in keep): writer.addToFasta(defline,sequence,OUT)
OUT.close()

