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
COMBINED="/home/bmajoros/1000G/assembly/combined"
OUTDIR="/home/bmajoros/1000G/assembly/cryptic"
MIN_COUNT=1
EXPRESSED="/home/bmajoros/1000G/assembly/expressed.txt"

def loadExpressed(filename):
    hash={}
    with open(filename,"rt") as fh:
        for line in fh:
            fields=line.split()
            (gene,transcript,fpkm,SS)=fields
            hash[transcript]=True
    return hash

def loadStruct(filename,hash):
    with open(filename,"rt") as fh:
        for line in fh:
            fields=line.split()
            if(len(fields)!=5): continue
            (indiv,hap,gene,trans,type)=fields
            hash[trans]=type

def loadStructureChanges(dir):
    hash={}
    loadStruct(dir+"/1.structure-changes",hash)
    loadStruct(dir+"/2.structure-changes",hash)
    return hash

def loadCounts(indiv,filename,changes,hash):
    transcripts=changes.keys()
    for transcript in transcripts:
        if(changes[transcript]=="cryptic-site"):
            if(not rex.find("ALT\d+_(\S+)_(\d+)",transcript)):
                raise Exception(transcript)
            if(not expressed.get(rex[1],False)): continue
            baseTrans=rex[1]+"_"+rex[2]
            rec=hash.get(indiv+baseTrans,None)
            if(not rec): 
                rec=hash[indiv+baseTrans]={}
                rec["numSites"]=0
                rec["supported"]=0
            rec["numSites"]+=1
    with open(filename,"rt") as fh:
        for line in fh:
            fields=line.split()
            if(len(fields)!=8): continue
            (indiv,hap,baseTrans,trans,dot1,count,dot2,fate)=fields
            type=changes[trans]
            if(type!="cryptic-site"): continue
            if(int(count)>=MIN_COUNT):
                hash[indiv+"_"+hap+baseTrans]["supported"]+=1

def loadCrypskipCounts(indiv,dir,changes,hash):
    loadCounts(indiv+"_1",dir+"/1.crypskip-counts",changes,hash)
    loadCounts(indiv+"_2",dir+"/2.crypskip-counts",changes,hash)

def tabulate(hash):
    tabulated={}
    for transcript in hash.keys():
        rec=hash[transcript]
        numCryptic=rec["numSites"]
        supported=rec["supported"]
        array=tabulated.get(numCryptic,None)
        if(array is None): array=tabulated[numCryptic]=[]
        array.append(rec)
    return tabulated

#=============================== main() =================================
expressed=loadExpressed(EXPRESSED)
counts={}
dirs=os.listdir(COMBINED)
for indiv in dirs:
    indiv=indiv.rstrip()
    if(not rex.find("^HG\d+$",indiv) and not rex.find("^NA\d+$",indiv)):
        continue
    if(not os.path.exists(COMBINED+"/"+indiv+"/RNA/stringtie.gff")):
        continue
    dir=COMBINED+"/"+indiv
    changes=loadStructureChanges(dir)
    loadCrypskipCounts(indiv,dir,changes,counts)
tabulated=tabulate(counts)
keys=tabulated.keys()
for key in keys:
    array=tabulated[key]
    filename=OUTDIR+"/"+str(key)+".txt"
    with open(filename,"wt") as fh:
        for rec in array:
            supported=rec["supported"]
            fh.write(str(supported)+"\n")
        
