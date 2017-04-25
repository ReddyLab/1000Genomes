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
from FastaReader import FastaReader
from NgramIterator import NgramIterator
from Rex import Rex
rex=Rex()

PSEUDOCOUNT=1

def codonsFromIntrons(transcript):
    codons=[]
    introns=transcript.getIntrons()
    intronSeq=""
    for intron in introns:
        intronSeq+=seq[intron.begin:intron.end]
    L=int(len(intronSeq)/N)*N
    for i in range(int(L/N)):
        codons.append(intronSeq[i*N:(i+1)*N])
    return codons

def codonsFromExons_nonphased(transcript):
    codons=[]
    exonSeq=""
    for exon in transcript.exons:
        exonSeq+=exon.sequence
    L=len(exonSeq)
    for i in range(L-(N-1)):
        codons.append(exonSeq[i:i+N])
    return codons

def codonsFromExons(transcript,phased):
    if(not phased): return codonsFromExons_nonphased(transcript)
    codons=[]
    exonSeq=""
    for exon in transcript.exons:
        exonSeq+=exon.sequence
    L=int(len(exonSeq)/N)*N
    if(N==3):
        firstCodon=exonSeq[:N]
        if(firstCodon!="ATG"): return None
    for i in range(int(L/N)):
        codons.append(exonSeq[i*N:(i+1)*N])
    return codons

def getNgrams():
    ngrams=[]
    ngramIterator=NgramIterator("ACGT",N)
    while(True):
        ngram=ngramIterator.nextString()
        if(ngram is None): break
        ngrams.append(ngram)
    return ngrams
    
def emit(codons,category):
    print(str(category)+"\t",end="")
    counts={}
    total=0.0
    for codon in codons:
        counts[codon]=counts.get(codon,PSEUDOCOUNT)+1
        total+=1.0
    numCodons=len(allCodons)
    for i in range(numCodons):
        codon=allCodons[i]
        count=counts.get(codon,0)
        freq=float(count)/float(total)
        freq=round(freq,N)
        print(str(freq),end="")
        if(i+1<numCodons): print("\t",end="")
    print()

def printHeader():
    print("category\t",end="")
    numCodons=len(allCodons)
    for i in range(numCodons):
        codon=allCodons[i]
        print(codon,end="")
        if(i+1<numCodons): print("\t",end="")
    print()

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=6):
    exit(ProgramName.get()+
         " <in.gff> <in.fasta> <max-cases> <phased:YES|NO> <N>\n")
(gffFile,fastaFile,maxCases,wantPhased,N)=sys.argv[1:]
maxCases=int(maxCases); N=int(N)
phased=None
if(wantPhased=="YES"): phased=True
elif(wantPhased=="NO"): phased=False
else: exit("phased must be YES or NO")

allCodons=getNgrams()
printHeader()
stops={}; stops["TGA"]=stops["TAG"]=stops["TAA"]=True
reader=GffTranscriptReader()
genesBySubstrate=reader.hashGenesBySubstrate(gffFile)
reader=FastaReader(fastaFile)
cases=0
while(True):
    (defline,seq)=reader.nextSequence()
    if(defline is None): break
    (id,attributes)=FastaReader.parseDefline(defline)
    genes=genesBySubstrate.get(id,[])
    for gene in genes:
        transcript=gene.longestTranscript()
        if(len(transcript.getIntrons())==0): continue
        transcript.loadExonSequences(seq,transcript.exons)
        exonCodons=codonsFromExons(transcript,phased)
        if(exonCodons is None): continue
        intronCodons=codonsFromIntrons(transcript)
        emit(exonCodons,1)
        emit(intronCodons,0)
        cases+=1
        if(cases>=maxCases): break
reader.close()


