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
import os
import math
import ProgramName
from Pipe import Pipe
from FastaReader import FastaReader
MUMMIE=os.environ["MUMMIE"]

BASE="/home/bmajoros/1000G/assembly/ace"
#HMM_HEX=BASE+"/exons-trained-hex-exp.hmm"
HMM_HEX=BASE+"/exons-trained-hex-exp-notrans.hmm"
#HMM_NONCODING=BASE+"/exons-noncoding.hmm"
HMM_CODING=BASE+"/exons-coding-notrans.hmm"
HMM_NONCODING=BASE+"/exons-noncoding-notrans.hmm"
#HMM_LLR=BASE+"/exons-trained-LLR.hmm"
#HMM_LLR=BASE+"/exons-trained-LLR-trans.hmm"
HMM_LLR=BASE+"/exons-trained-LLR-notrans.hmm"
HMM_INTRON_HEX=BASE+"/introns-trained-hex-exp.hmm"
HMM_INTRON_LLR=BASE+"/introns-trained-LLR-notrans.hmm"
HMM_INTRON_CODING=BASE+"/introns-coding.hmm"
HMM_INTRON_NONCODING=BASE+"/introns-noncoding.hmm"
#EXONS=BASE+"/coding-exons-test"
#INTRONS=BASE+"/coding-introns-test"
EXONS=BASE+"/minigenes1"
INTRONS=BASE+"/minigenes0"
SHENDURE=BASE+"/shendure.txt"
#LOGISTIC=BASE+"/coefficients-cv-binomial.txt"
LOGISTIC=BASE+"/coefficients-cv.txt"
FREQUENCIES="/home/bmajoros/splicing/shendure/trained5.txt"


def scoreHexamers(seq,hexHash):
    L=len(seq)
    end=L-5
    total=0
    for i in range(end):
        hex=seq[i:i+6]
        hexScore=hexHash[hex]
        total+=hexScore
    mean=float(total)/float(end)
    return mean

def scoreHMM(hmm,length,filename):
    cmd=MUMMIE+"/get-likelihood "+hmm+" "+filename
    pipe=Pipe(cmd)
    line=pipe.readline();
    LL=float(line.rstrip())
    #LL=LL/float(length)
    #LL=math.exp(LL)
    return LL

def scoreDirectory(directory,label):
    array=[]
    files=os.listdir(directory)
    files.sort()
    for file in files:
        fullPath=directory+"/"+file
        (defline,seq)=FastaReader.firstSequence(fullPath)
        length=len(seq)
        if(length<6): continue
        hexScore=scoreHexamers(seq,hexHash)
        logisticScore=scoreHexamers(seq,logisticHash)
        frequenciesScore=scoreHexamers(seq,frequenciesHash)

        #hmmIntronHexScore=scoreHMM(HMM_INTRON_HEX,length,fullPath)
        #hmmIntronLLRScore=scoreHMM(HMM_INTRON_LLR,length,fullPath)
        #hmmIntronCodingScore=scoreHMM(HMM_INTRON_CODING,length,fullPath)
        #hmmIntronNoncodingScore=scoreHMM(HMM_INTRON_NONCODING,length,fullPath)

        #hmmHexScore=scoreHMM(HMM_HEX,length,fullPath)
        #hmmNoncodingScore=scoreHMM(HMM_NONCODING,length,fullPath)
        #hmmCodingScore=scoreHMM(HMM_CODING,length,fullPath)
        #hmmLLRScore=scoreHMM(HMM_LLR,length,fullPath)

        #hmmHexScore-=hmmIntronHexScore ###
        #hmmNoncodingScore-=hmmIntronNoncodingScore ###
        #hmmCodingScore-=hmmIntronCodingScore ###
        #hmmLLRScore-=hmmIntronLLRScore ###

        #rec=[label,hexScore,hmmHexScore,hmmCodingScore,hmmNoncodingScore,
        #     hmmLLRScore,logisticHash]
        rec=[label,hexScore,logisticScore,frequenciesScore]
        array.append(rec)
    return array

def addRecords(records,index,OUT):
    for rec in records:
        feature=rec[index]
        label=rec[0]
        OUT.write(str(feature)+"\t"+str(label)+"\n")

def writeROC(exons,introns,index,outfile):
    OUT=open(outfile,"wt")
    addRecords(exons,index,OUT)
    addRecords(introns,index,OUT)
    OUT.close()

#=========================================================================
# main()
#=========================================================================
hexHash={}
with open(SHENDURE,"rt") as IN:
    for line in IN:
        fields=line.rstrip().split()
        if(len(fields)!=2): continue
        (hex,score)=fields
        hexHash[hex]=float(score)
logisticHash={}
with open(LOGISTIC,"rt") as IN:
    for i in range(3): IN.readline()
    for line in IN:
        fields=line.rstrip().split()
        if(len(fields)!=2): continue
        (hex,score)=fields
        if(score=="."): score=0.0
        logisticHash[hex]=float(score)
frequenciesHash={}
with open(FREQUENCIES,"rt") as IN:
    for line in IN:
        fields=line.rstrip().split()
        if(len(fields)!=2): continue
        (hex,score)=fields
        frequenciesHash[hex]=float(score)
exonScores=scoreDirectory(EXONS,1)
intronScores=scoreDirectory(INTRONS,0)
writeROC(exonScores,intronScores,1,"shendure.roc")
#writeROC(exonScores,intronScores,2,"hexProbs-ratio.roc")
#writeROC(exonScores,intronScores,3,"coding-ratio.roc")
#writeROC(exonScores,intronScores,4,"noncoding-ratio.roc")
#writeROC(exonScores,intronScores,5,"LLR-ratio.roc")
writeROC(exonScores,intronScores,2,"logistic.roc")
writeROC(exonScores,intronScores,3,"frequencies.roc")

