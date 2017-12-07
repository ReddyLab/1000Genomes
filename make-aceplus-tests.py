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
from Rex import Rex
rex=Rex()
from GffTranscriptReader import GffTranscriptReader
from Pipe import Pipe
from FastaWriter import FastaWriter
from Translation import Translation

CONFIG="/home/bmajoros/1000G/ACEPLUS/model/aceplus.config"
GENOME_FILE="/data/reddylab/Reference_Data/hg19.2bit"
LEFT_CONTEXT=10
MARGIN=100

def removeSlash(seq):
    if(rex.find("(\S*)/(\S*)",seq)):
        seq=rex[1]+rex[2]
    return seq

def makeRefAndAlt(dbass,geneSeq,strand):
    if(not rex.find("(\S+)\((\S+)>(\S+)\)(\S+)",dbass)):
        raise Exception("Can't find variant in DBASS sequence")
    refAllele=rex[2]; altAllele=rex[3]
    left=rex[1]; right=rex[4]
    if(strand=="-"):
        refAllele=Translation.reverseComplement(refAllele)
        altAllele=Translation.reverseComplement(altAllele)
        left=Translation.reverseComplement(left)
        right=Translation.reverseComplement(right)
        temp=left
        left=right
        right=temp
    if(len(left)<LEFT_CONTEXT): raise Exception("not enough left context")
    leftLen=len(left)
    context=left[leftLen-LEFT_CONTEXT:leftLen]
    refAllele=context+refAllele
    altAllele=context+altAllele
    if(not rex.find("(\S+)"+refAllele+"(\S+)",geneSeq)):
        raise Exception(refAllele+" not found in gene sequence")
    variantOffset=len(rex[1])
    ref=geneSeq
    alt=rex[1]+altAllele+rex[2]
    if(strand=="-"):
        ref=Translation.reverseComplement(ref)
        alt=Translation.reverseComplement(alt)
        variantOffset=len(ref)-variantOffset-1
    return (ref,alt,variantOffset)

def loadGeneSeq(gene):
    chrom=gene.getSubstrate()
    begin=gene.getBegin()-MARGIN
    end=gene.getEnd()+MARGIN
    cmd="twoBitToFa -seq="+chrom+" -start="+str(begin)+" -end="+str(end)+" "+GENOME_FILE+" tmp.fasta ; cat tmp.fasta"
    pipe=Pipe(cmd)
    defline=pipe.readline()
    seq=""
    while(True):
        line=pipe.readline()
        if(line is None or line==""): break
        seq+=line.rstrip()
    return seq

def writeGFF(gff,filename):
    with open(filename,"wt") as OUT:
        print(gff,file=OUT)

def runACE(configFile,refGffFile,refFasta,altFasta,outGFF,outEssex):
    cmd="$ACEPLUS/aceplus "+configFile+" "+refGffFile+" "+refFasta+" "+\
        altFasta+" "+outGFF+" "+outEssex
    print(cmd)
    #pipe=Pipe(cmd)
    #while(True):
        #line=pipe.readline()
        #if(line is None): break
        

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=5):
    exit(ProgramName.get()+" <*.gff> <ref-out.fasta> <alt-out.fasta> <DBASS-sequence>\n")
(gffFile,refFile,altFile,dbassSeq)=sys.argv[1:]

dbassSeq=dbassSeq.upper()

# Load GFF
gffReader=GffTranscriptReader()
genes=gffReader.loadGenes(gffFile)
if(len(genes)!=1): raise Exception("error loading genes from GFF")
gene=genes[0]

# Load gene sequence from two-bit file
geneSeq=loadGeneSeq(gene)
strand=gene.getStrand()

# Process DBASS sequence
dbassSeq=removeSlash(dbassSeq)
(ref,alt,variantOffset)=makeRefAndAlt(dbassSeq,geneSeq,strand)
print("variant offset: ",variantOffset)
L=len(ref)
if(len(alt)!=L): raise Exception("Unequal lengths: can't handle indels")
cigar="/cigar="+str(L)+"M"

# Write out the ref and alt fasta files
fastaWriter=FastaWriter()
fastaWriter.writeFasta(">ref "+cigar,ref.upper(),refFile)
fastaWriter.writeFasta(">alt "+cigar,alt.upper(),altFile)

# Do prediction
transcript=gene.longestTranscript()
transcript.shiftCoords(-gene.getBegin()+MARGIN)
if(strand=="-"): transcript.reverseComplement(L)
gff=transcript.toGff()
writeGFF(gff,"tmp.gff")
runACE(CONFIG,"tmp.gff",refFile,altFile,"out.gff","out.essex")

