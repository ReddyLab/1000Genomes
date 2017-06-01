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

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=4):
    exit(ProgramName.get()+" <in-introns.fasta> <in-exons.fasta> <out.fasta>\n")
(intronsFasta,exonsFasta,outFasta)=sys.argv[1:]

lengths=[]
reader=FastaReader(exonsFasta)
while(True):
    (defline,seq)=reader.nextSequence()
    if(defline is None): break
    lengths.append(len(seq))
reader=FastaReader(intronsFasta)
writer=FastaWriter()
OUT=open(outFasta,"wt")
nextIndex=0;
while(True):
    (defline,seq)=reader.nextSequence()
    if(defline is None): break
    L=len(seq)
    newL=lengths[nextIndex]
    if(L>newL):
        #seq=seq[:newL]
        diff=L-newL
        begin=int(diff/2)
        end=begin+newL
        seq=seq[begin:end]
    writer.addToFasta(defline,seq,OUT)
    nextIndex+=1
    if(nextIndex>=len(lengths)): break
OUT.close()
