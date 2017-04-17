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

MIN_IR_COVERAGE=0.5
MIN_READS=3

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
    predictions={}
    with open(filename,"rt") as IN:
        for line in IN:
            fields=line.rstrip().split()
            if(len(fields)<7): continue
            (substrate,altID,featureType,interval,score,strand,essexFeatures)=\
                fields
            array=predictions.get(altID,None)
            if(array is None): array=predictions[altID]=[]
            array.append([substrate,featureType,interval,score,essexFeatures])
    return predictions

def processPredictions(filename,junctions,IR):
    predictions=loadPredictions(filename)
    numPred=0
    numSupported=0
    for altID in predictions.keys():
        numPred+=1
        supported=True
        features=predictions[altID]
        for feature in features:
            (substrate,featureType,interval,score,essex)=feature
            if(featureType=="junction"):
                supported=supported and checkJunction(feature,junctions)
            elif(featureType=="intron-retention"):
                supported=supported and checkIR(feature,IR)
            else: raiseException(featureType)
        supportFlag=1 if supported else 0
        print(score,supportFlag,sep="\t")
        if(supported): numSupported+=1
    proportionSupported=float(numSupported)/float(numPred)
    print(proportionSupported)

def checkJunction(feature,junctions):
    (substrate,featureType,interval,score,essex)=feature
    secondHash=junctions.get(substrate,None)
    if(secondHash is None): return False
    support=secondHash.get(interval,None)
    if(support is None): return False
    return support>=MIN_READS

def checkIR(feature,IR):
    (substrate,featureType,interval,score,essex)=feature
    secondHash=IR.get(substrate,None)
    if(secondHash is None): return False
    support=secondHash.get(interval,None)
    if(support is None): return False
    return support>=MIN_IR_COVERAGE

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=3):
    exit(ProgramName.get()+" </path/to/indiv> <RNA-subdir>\n")
(baseDir,subdir)=sys.argv[1:]

# Form paths to needed files
RNA=baseDir+"/"+subdir
IRfile=RNA+"/IR.txt"
junctionsFile=RNA+"/junctions.txt"

# Load RNA evidence
junctions=loadJunctions(junctionsFile)
IR=loadIR(IRfile);

# Score predictions by evidence
processPredictions(baseDir+"/1.novel-features",junctions,IR)
processPredictions(baseDir+"/2.novel-features",junctions,IR)



