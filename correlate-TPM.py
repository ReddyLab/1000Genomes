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
import os
from Rex import Rex
rex=Rex()
THOUSAND="/home/bmajoros/1000G/assembly"
COMBINED=THOUSAND+"/combined"

def loadSalmon(dir):
    hash={}
    infile=dir+"/salmon/salmonoutput/quant.sf"
    with open(infile,"rt") as fh:
        for line in fh:
            fields=line.split()
            if(len(fields)<5): continue
            (transcript,length,effectiveLen,tpm,reads)=fields
            if(transcript=="Name"): continue
            if(not rex.find("ALT",transcript)): continue
            hash[transcript]=tpm
    return hash

def loadKallisto(dir):
    hash={}
    infile=dir+"/salmon/kallistooutdir/abundance.tsv"
    with open(infile,"rt") as fh:
        for line in fh:
            fields=line.split()
            if(len(fields)<5): continue
            (transcript,length,effectiveLen,reads,tpm)=fields
            if(transcript=="target_id"): continue
            if(not rex.find("ALT",transcript)): continue
            hash[transcript]=tpm
    return hash

def updateStringtie(hash,indiv,hap,transcript,tpm):
    subhash=hash.get(indiv,None)
    if(not subhash): subhash=hash[indiv]={}
    subhash[transcript+"_"+hap]=tpm

def loadStringtie():
    hash={}
    infile=THOUSAND+"/rna.txt"
    with open(infile,"rt") as fh:
        for line in fh:
            fields=line.split()
            if(len(fields)<7): continue
            if(fields[0]=="indiv"): continue
            (indiv,hap,gene,transcript,cov,fpkm,tpm)=fields
            if(not rex.find("ALT",transcript)): continue
            updateStringtie(hash,indiv,hap,transcript,tpm)
    return hash

def getKeys(hash1,hash2,hash3):
    uniq=set()
    for key in hash1.keys(): uniq.add(key)
    for key in hash2.keys(): uniq.add(key)
    for key in hash3.keys(): uniq.add(key)
    return uniq

#=============================== main() =================================
allStringtie=loadStringtie()
dirs=os.listdir(COMBINED)
for indiv in dirs:
    indiv=indiv.rstrip()
    if(not rex.find("^HG\d+$",indiv) and not rex.find("^NA\d+$",indiv)):
        continue
    if(not os.path.exists(COMBINED+"/"+indiv+"/RNA/stringtie.gff")):
        continue
    dir=COMBINED+"/"+indiv
    salmon=loadSalmon(dir)
    kallisto=loadKallisto(dir)
    stringtie=allStringtie[indiv]
    keys=getKeys(stringtie,salmon,kallisto)
    #for transcript in stringtie.keys():
    for transcript in keys:
        salmonTPM=salmon.get(transcript,0)
        kallistoTPM=kallisto.get(transcript,0)
        stringtieTPM=stringtie.get(transcript,0)
        print(stringtieTPM,salmonTPM,kallistoTPM,sep="\t")

