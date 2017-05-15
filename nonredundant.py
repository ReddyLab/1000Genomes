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
from Rex import Rex
rex=Rex()

MIN_IDENT=0.8

def loadHits(filename):
    hits={}
    lengths={}
    with open(filename,"rt") as IN:
        for line in IN:
            fields=line.rstrip().split()
            if(len(fields)!=12): continue
            (qseqid,sseqid,pident,length,mismatch,gapopen,qstart,qend,
             sstart,send,evalue,bitscore)=fields
            pident=float(pident); length=int(length)
            if(qseqid==sseqid): lengths[qseqid]=length
            elif(pident>=MIN_IDENT):
                if(hits.get(qseqid,None) is None or
                   hits[qseqid]<length): hits[qseqid]=length
    return (hits,lengths)

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=5):
    exit(ProgramName.get()+" <test-vs-train.out> <test-vs-test.out> <test.fasta> <out.fasta>\n")
(testTrainFile,testTestFile,inFasta,outFasta)=sys.argv[1:]

testLengths={}
(testHits,lengths)=loadHits(testTestFile)
(trainHits,junk)=loadHits(testTrainFile)
discard=set()
for hit in testHits.keys(): discard.add(hit)
for hit in trainHits.keys(): discard.add(hit)
reader=FastaReader(inFasta)
writer=FastaWriter()
OUT=open(outFasta,"wt")
while(True):
    (defline,seq)=reader.nextSequence()
    if(not defline): break
    if(not rex.find(">\s*(\S+)",defline)):
        raise Exception("Can't parse defline"+defline)
    id=rex[1]
    if(id not in discard): writer.addToFasta(defline,seq,OUT)
OUT.close()

