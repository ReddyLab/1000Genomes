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
import gzip
#from Pipe import Pipe
from FastaReader import FastaReader
from CodonIterator import CodonIterator
from Translation import Translation
from GffTranscriptReader import GffTranscriptReader
from Rex import Rex
rex=Rex()

INTRON_ONLY=False
MIN_TOTAL=50 # at least this many SNPs to estimate a substitution matrix
MIN_INTRON_LEN=5000
MAX_FREQ=0.1 # maximum alt allele frequency
TWO_BIT="/data/reddylab/Reference_Data/hg19.2bit"

nucs=("A","C","G","T")
alphabet=set()
for nuc in nucs: alphabet.add(nuc)

def clear(subst):
    for a in alphabet:
        second=subst[a]={}
        for b in alphabet:
            second[b]=0

def emit(ID,subst):
    total=0
    for a in alphabet:
        second=subst[a]
        for b in alphabet:
            count=second[b]
            total+=count
    if(total<MIN_TOTAL):
        #print("total ",total)
        return
    print(ID,total,sep="\t",end="")
    for a in alphabet:
        second=subst[a]
        for b in alphabet:
            count=second[b]
            P=round(float(count)/float(total),3)
            print("\t"+a+"->"+b+"="+str(P),end="")
    print()

def inIntron(pos,introns):
    for intron in introns:
        if(intron.contains(pos)): return True
    return False

def getDegenerateSites(transcript,seq):
    sites=set()
    #print("getDegenerateSites("+transcript.getID()+")")
    if(transcript.startCodonAbsolute is None):
        #print("startCodonAbsolute==None")
        return sites
    strand=transcript.getStrand()
    iterator=CodonIterator(transcript,seq,transcript.stopCodons)
    codons=iterator.getAllCodons()
    for codon in codons:
        if(codon.isInterrupted): continue
        pos=codon.absoluteCoord
        if(strand=="-"): pos-=3
        triple=seq[pos:pos+3]
        if(strand=="-"): triple=Translation.reverseComplement(triple)
        if(triple not in degenerateCodons): continue
        sites.add(pos+2 if strand=="+" else pos)
    return sites

def loadGeneSeq(transcript):
    cmd="twoBitToFa -seq="+transcript.substrate+" -start="+\
        str(transcript.getBegin())+" -end="+str(transcript.getEnd())+\
        " "+TWO_BIT+" -"
    #print(cmd)
    seq=Pipe.run(cmd)
    return seq

def getIntrons(transcript):
    introns=[]
    for intron in transcript.getIntrons():
        if(intron.getLength()>=MIN_INTRON_LEN): introns.append(intron)
    return introns

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=4):
    exit(ProgramName.get()+" <annotations.gff> <one-chromosome.vcf.gz> <chrom.fasta>\n")
(gffFile,vcfFile,fastaFile)=sys.argv[1:]

#(defline,seq)=FastaReader.firstSequence(fastaFile)
#degenerateCodons=Translation.getFourfoldDegenerateCodons()
#print(len(degenerateCodons),"degenerate codons")
gffReader=GffTranscriptReader()
genes=gffReader.loadGenes(gffFile)
#genes.sort(key=lambda x: x.getBegin())
if(len(genes)<1): raise Exception("no genes in GFF file")

subst={}
clear(subst)
nextGene=0
#while(nextGene<len(genes) and
#      genes[nextGene].longestTranscript().numExons()==0): nextGene+=1
if(nextGene>=len(genes)): raise Exception("nextGene>=len(genes)")
transcript=genes[nextGene].longestTranscript()
transcript.sortExons()
#(begin,end)=transcript.getCDSbeginEnd()
begin=transcript.getBegin()
end=transcript.getEnd()
introns=getIntrons(transcript)
#seq=loadGeneSeq(transcript)
#degenerateSites=getDegenerateSites(transcript,seq)
#print(transcript.getID(),len(degenerateSites),"degenerate sites")
#print(seq[:100])
with gzip.open(vcfFile,"rt") as IN:
    for line in IN:
        if(len(line)<10): continue
        if(line[0]=="#" or line[:5]=="CHROM"): continue
        fields=line.rstrip().split()
        (chr,pos,variant,ref,alt,qual,filter,info,format)=fields[:9]
        pos=int(pos)
        if(pos<begin): continue
        if(pos>end):
            emit(genes[nextGene].getID(),subst)
            clear(subst)
            while(pos>end):
                nextGene+=1
                #while(nextGene<len(genes) and
                #      genes[nextGene].longestTranscript().numExons()==0):
                #    nextGene+=1
                if(nextGene>=len(genes)): exit()
                transcript=genes[nextGene].longestTranscript()
                transcript.sortExons()
                #(begin,end)=transcript.getCDSbeginEnd()
                begin=transcript.getBegin()
                end=transcript.getEnd()
                introns=getIntrons(transcript)
                if(len(introns)<1): continue
                #seq=loadGeneSeq(transcript)
                #if(len(seq)==0): continue
                #print(seq[:100])
                #degenerateSites=getDegenerateSites(transcript,seq)
                #if(transcript.numExons()>0):
                #    print(transcript.getID(),len(degenerateSites),
                #          "degenerate sites")
        if(INTRON_ONLY and not inIntron(pos,introns)): continue
        #if(pos not in degenerateSites): continue 
        if(format!="GT" or filter!="PASS"): continue
        if(len(ref)!=1 or len(alt)!=1): continue
        if(not rex.find("AF=([^;]+)",info)): raise Exception(info)
        altFreq=float(rex[1])
        if(altFreq>MAX_FREQ): continue
        subst[ref][alt]+=1

