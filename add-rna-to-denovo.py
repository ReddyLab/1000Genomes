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

THOUSAND="/home/bmajoros/1000G/assembly"
COMBINED=THOUSAND+"/combined"
DENOVO_IN=THOUSAND+"/rna150/denovo"
OUT_DIR=THOUSAND+"/rna150/denovo-rna"
MIN_COUNT=3
MIN_SUM=30
#MIN_COUNT=1
#MIN_SUM=1

def storeDenovo(byGene,geneID,score,rec):
    prevRec=byGene.get(geneID,None)
    if(prevRec is None or score>float(prevRec[8])):
        byGene[geneID]=rec

def loadDenovo(filename):
    byGene={}
    IN=open(filename,"rt")
    for line in IN:
        fields=line.rstrip().split()
        if(len(fields)==13):
            (event,siteType,geneID,hap,geneType,transID,altID,strand,
             score,sitePos,seqLen,fate,variantID)=fields
            fields=[event,siteType,geneID,hap,geneType,transID,altID,strand,
                    score,sitePos,seqLen,fate,".",variantID]
            storeDenovo(byGene,geneID,float(score),fields)
        elif(len(fields)==14):
            (event,siteType,geneID,hap,geneType,transID,altID,strand,
             score,sitePos,seqLen,fate,identity,variantID)=fields
            storeDenovo(byGene,geneID,float(score),fields)
    IN.close()
    return byGene

def loadJunctions(filename,wantHap):
    byGene={}
    IN=open(filename,"rt")
    for line in IN:
        fields=line.rstrip().split()
        if(len(fields)!=6): continue
        (geneID,hap,begin,end,count,strand)=fields
        if(hap!=wantHap): continue
        array=byGene.get(geneID,None)
        if(array is None): array=byGene[geneID]=[]
        begin=int(begin); end=int(end); count=int(count)
        array.append([begin,end,count])
    IN.close()
    return byGene

def processJunctions(table,junctions):
    geneIDs=table.keys()
    for geneID in geneIDs:
        rec=table[geneID]
        (event,siteType,geneID,hap,geneType,transID,altID,strand,
         score,sitePos,seqLen,fate,identity,variantID)=rec
        if(sitePos=="."): continue
        sitePos=int(sitePos)
        juncs=junctions.get(geneID,[])
        for junc in juncs:
            (juncBegin,juncEnd,count)=junc
            if(juncBegin==sitePos): processBegin(rec,juncs)
            elif(juncEnd==sitePos): processEnd(rec,juncs)

def processBegin(rec,juncs):
    (event,siteType,geneID,hap,geneType,transID,altID,strand,
     score,sitePos,seqLen,fate,identity,variantID)=rec
    sitePos=int(sitePos)
    alts=getAllBeginning(juncs,sitePos)
    ends=set()
    for junc in alts: ends.add(junc[1])
    alts=[]
    for end in ends:
        alts.extend(getAllEnding(juncs,end))
    sum=0; this=0
    for alt in alts:
        (juncBegin,juncEnd,count)=alt
        if(juncBegin==sitePos): this+=count
        sum+=count
    if(sum<MIN_SUM): return
    if(this<MIN_COUNT): return
    ratio=float(this)/float(sum)
    print(event,siteType,geneID,hap,geneType,transID,altID,strand,
          score,str(sitePos),seqLen,fate,identity,variantID,ratio,
          str(this),str(sum),sep="\t")

def processEnd(rec,juncs):
    (event,siteType,geneID,hap,geneType,transID,altID,strand,
     score,sitePos,seqLen,fate,identity,variantID)=rec
    sitePos=int(sitePos)
    alts=getAllEnding(juncs,sitePos)
    begins=set()
    for junc in alts: begins.add(junc[0])
    alts=[]
    for begin in begins:
        alts.extend(getAllBeginning(juncs,begin))
    sum=0; this=0
    for alt in alts:
        (juncBegin,juncEnd,count)=alt
        if(juncEnd==sitePos): this+=count
        sum+=count
    if(sum<MIN_SUM): return
    if(this<MIN_COUNT): return
    ratio=float(this)/float(sum)
    print(event,siteType,geneID,hap,geneType,transID,altID,strand,
          score,str(sitePos),seqLen,fate,identity,variantID,ratio,
          str(this),str(sum),sep="\t")

def getAllBeginning(juncs,pos):
    array=[]
    for junc in juncs:
        (juncBegin,juncEnd,count)=junc
        if(juncBegin==pos): array.append(junc)
    return array

def getAllEnding(juncs,pos):
    array=[]
    for junc in juncs:
        (juncBegin,juncEnd,count)=junc
        if(juncEnd==pos): array.append(junc)
    return array

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=3):
    exit(ProgramName.get()+" <indiv> <hap>\n")
(indiv,hap)=sys.argv[1:]

denovoFile=DENOVO_IN+"/"+indiv+"."+hap+".denovo"
table=loadDenovo(denovoFile)
junctionsFile=COMBINED+"/"+indiv+"/RNA6/junctions.txt"
junctions=loadJunctions(junctionsFile,hap)
processJunctions(table,junctions)

