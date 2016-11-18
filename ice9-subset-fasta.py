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

if(len(sys.argv)!=4):
    exit(sys.argv[0]+" <in.fasta> <in.gff> <out.fasta>")
(fastaFile,gffFile,outFile)=sys.argv[1:]

reader=GffTranscriptReader()
transcripts=reader.loadGFF(gffFile)
keep=set()
for transcript in transcripts:
    if(transcript.getID()[:3]!="ALT"): continue
    keep.add(transcript.getSubstrate())

reader=FastaReader(fastaFile)
writer=FastaWriter()
fh=open(outFile,"wt")
while(True):
    (defline,seq)=reader.nextSequence()
    if(not defline): break
    (id,attr)=FastaReader.parseDefline(defline)
    if(id not in keep): continue
    writer.addToFasta(defline,seq,fh)
fh.close()
print("[done]",file=sys.stderr)

