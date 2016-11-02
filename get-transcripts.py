#!/usr/bin/env python
#=========================================================================
# This is OPEN SOURCE SOFTWARE governed by the Gnu General Public
# License (GPL) version 3, as described at www.opensource.org.
# Copyright (C)2016 William H. Majoros (martiandna@gmail.com).
#=========================================================================
from __future__ import (absolute_import, division, print_function, 
   unicode_literals, generators, nested_scopes, with_statement)
from builtins import (bytes, dict, int, list, object, range, str, ascii,
   chr, hex, input, next, oct, open, pow, round, super, filter, map, zip)
# The above imports should allow this program to run in both Python 2 and
# Python 3.  You might need to update your version of module "future".
import sys
from FastaReader import FastaReader
from FastaWriter import FastaWriter
from GffTranscriptReader import GffTranscriptReader
from Rex import Rex
rex=Rex()

# Process command line
if(len(sys.argv)!=4): exit(sys.argv[0]+" <in.fasta> <in.gff> <out.fasta>")
(fastaFile,gffFile,outFile)=sys.argv[1:]

# Read GFF
reader=GffTranscriptReader()
hash=reader.hashBySubstrate(gffFile)

# Open output file
OUT=open(outFile,"wt")
writer=FastaWriter()

# Process each substrate in the FASTA file
reader=FastaReader(fastaFile)
while(True):
    [defline,seq]=reader.nextSequence()
    if(not defline): break
    if(not rex.find("^\s*>\s*(\S+)",defline)): 
        exit("Can't parse defline: "+defline)
    id=rex[1]
    transcripts=hash.get(id,None)
    if(not transcripts): continue
    for transcript in transcripts:
        transSeq=transcript.loadTranscriptSeq(seq)
        writer.addToFasta(">"+transcript.getID(),transSeq,OUT)
reader.close()
OUT.close()

