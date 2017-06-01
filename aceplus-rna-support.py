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

MIN_IR_COVERAGE=0.5
MIN_READS=3 # 3
MIN_FPKM=3 #3 # 1
seenPredictions=set()

def setSupport(firstHash,substrate,key,support):
    secondHash=firstHash.get(substrate,None)
    if(secondHash is None): secondHash=firstHash[substrate]={}
    secondHash[key]=support

def loadJunctions(filename):
    junctions={}
    with open(filename,"rt") as IN:
        for line in IN:
            fields=line.rstrip().split()
            if(len(fields)<6): continue
            (gene,hap,begin,end,reads,strand)=fields
            substrate=gene+"_"+hap
            key=begin+"-"+end
            setSupport(junctions,substrate,key,int(reads))
    return junctions

def loadIR(filename):
    IR={}
    with open(filename,"rt") as IN:
        for line in IN:
            fields=line.rstrip().split()
            if(len(fields)<6): continue
            (substrate,begin,end,covered,L,cov)=fields
            cov=float(cov)
            if(cov<MIN_IR_COVERAGE): continue
            key=begin+"-"+end
            setSupport(IR,substrate,key,cov)
    return IR

def loadPredictions(filename):
    seen={}
    with open(filename,"rt") as IN:
        for line in IN:
            fields=line.rstrip().split("\t")
            if(len(fields)!=9): exit(line)
            fields[4]=float(fields[4])
            (substrate,altID,featureType,interval,score,strand,essexFeatures,
             fate,broken)=fields
            if(BROKEN_ONLY and broken=="false"): continue
            if(fate=="NMD" or fate=="nonstop-decay"): continue
            if(not rex.find("ALT\d+_(\S+)_\d+",altID)): raise Exception(altID)
            transID=rex[1]
            if(transID not in expressed): continue
            key=substrate+" "+interval
            oldRec=seen.get(key,None)
            if(oldRec is not None and oldRec[4]>score): continue
            seen[key]=fields
    predictions={}

    for rec in seen.values():
        (substrate,altID,featureType,interval,score,strand,essexFeatures,
         fate,broken)=rec
        array=predictions.get(altID,None)
        if(array is None): array=predictions[altID]=[]
        array.append([substrate,featureType,interval,score,essexFeatures,
                      fate,broken])
    return predictions

def processPredictions(filename,junctions,IR):
    predictions=loadPredictions(filename)
    for altID in predictions.keys():
        if(not rex.find("ALT\d+_(\S+)_\d+",altID)): raise Exception(altID)
        transID=rex[1]
        if(transID not in expressed): continue
        features=predictions[altID]
        for feature in features:
            (substrate,featureType,interval,score,essex,fate,broken)=feature
            key=substrate+" "+interval
            if(key in seenPredictions): continue
            seenPredictions.add(key)
            support=None
            if(featureType=="junction"):
                support=checkJunction(feature,junctions)
            #elif(featureType=="intron-retention"):
            #    support=checkIR(feature,IR)
            else: raiseException(featureType)
            print(featureType,support,score,substrate,interval,essex,fate,
                  broken,sep="\t")

def checkJunction(feature,junctions):
    (substrate,featureType,interval,score,essex,fate,broken)=feature
    secondHash=junctions.get(substrate,None)
    if(secondHash is None): return 0
    support=secondHash.get(interval,None)
    if(support is None): return 0
    return support

def checkIR(feature,IR):
    (substrate,featureType,interval,score,essex,fate,broken)=feature
    secondHash=IR.get(substrate,None)
    if(secondHash is None): return 0
    support=secondHash.get(interval,None)
    if(support is None): return 0
    return support

def loadExpressed(filename):
    expressed=set()
    with open(filename,"rt") as IN:
        for line in IN:
            fields=line.rstrip().split()
            (geneID,transcriptID,meanFPKM,sampleSize)=fields
            if(float(meanFPKM)>=MIN_FPKM): expressed.add(transcriptID)
    return expressed

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=5):
    exit(ProgramName.get()+" </path/to/indiv> <RNA-subdir> <expressed.txt> <broken-only:0|1>\n")
(baseDir,subdir,expressedFile,brokenOnly)=sys.argv[1:]
BROKEN_ONLY=int(brokenOnly)

# Form paths to needed files
RNA=baseDir+"/"+subdir
IRfile=RNA+"/IR.txt"
junctionsFile=RNA+"/junctions.txt"

# Load data
expressed=loadExpressed(expressedFile)
junctions=loadJunctions(junctionsFile)
IR=None #loadIR(IRfile);

# Score predictions by evidence
#processPredictions(baseDir+"/1.novel-features",junctions,IR)
#processPredictions(baseDir+"/2.novel-features",junctions,IR)
#processPredictions(baseDir+"/1.uniform.novel",junctions,IR)
#processPredictions(baseDir+"/2.uniform.novel",junctions,IR)
processPredictions(baseDir+"/subsets/novel.txt",junctions,IR)



