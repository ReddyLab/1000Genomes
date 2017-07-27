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
import os
import sys
import ProgramName
from Rex import Rex
rex=Rex()

PREDICTORS=("logreg","shendure","MC","splice-only","arab")
BASE="/home/bmajoros/1000G/assembly/combined/"
SRC="/home/bmajoros/1000G/src/"
SUBDIR="RNA6"
EXPRESSED="/home/bmajoros/1000G/assembly/expressed.txt"

def System(cmd):
    print("COMMAND: "+cmd)
    os.system(cmd)

def getNovel(predictor,hap):
    System("grep ALT ../../"+hap+"."+predictor+".gff > "+hap+".tmp")
    removeDuplicateALT(hap+".tmp",hap+".tmp2")
    System("mv "+hap+".tmp2 "+hap+".tmp")
    System("cat "+hap+".anno.gff "+hap+".tmp > "+hap+"."+predictor+".gff")
    System("rm "+hap+".tmp")
    System(SRC+"get-novel-features.py "+hap+"."+predictor+".gff"+" | grep -v intron-retention > "+hap+"."+predictor+".novel.tmp")
    System("rm "+hap+"."+predictor+".gff")

def removeDuplicateALT(infile,outfile):
    IN=open(infile,"rt")
    OUT=open(outfile,"wt")
    for line in IN:
        if(rex.find("(.*)ALT\d+_(ALT.*)",line)):
            print(rex[1]+rex[2],file=OUT)
    OUT.close()
    IN.close()

def makeNovelZero(hap):
    outfile=hap+".novel.zero"
    OUT=open(outfile,"wt")
    for predictor in PREDICTORS:
        with open(hap+"."+predictor+".novel.tmp","rt") as IN:
            for line in IN:
                fields=line.rstrip().split()
                if(fields[6]==""): continue
                fields[4]="0.0"
                line="\t".join(fields)
                print(line,file=OUT)
    OUT.close()

def rnaSupport(predictor,hap,indiv):
    System("cat "+hap+"."+predictor+".novel.tmp "+hap+".novel.zero > "+hap+"."+predictor+".novel")
    System("rm "+hap+"."+predictor+".novel.tmp")
    System(SRC+"aceplus-rna-support.py "+BASE+"/"+indiv+" "+SUBDIR+" "+EXPRESSED+" 0 "+hap+"."+predictor+".novel > "+hap+"."+predictor+".support")

def ROC(predictor,hap):
    print(predictor,hap)
    System("cat "+hap+"."+predictor+".support | cut -f2,3 | perl -ne 'chomp;@f=split;($sup,$score)=@f;$cat=$sup>0 ? 1 : 0;print \"$score\t$cat\n\"' > roc.tmp ; roc.pl roc.tmp > tmp.roc ; rm roc.tmp ; area-under-ROC.pl tmp.roc ; mv tmp.roc "+hap+"."+predictor+".roc")
    System(SRC+"aceplus-roc-distribution.py "+hap+"."+predictor+".support 1000 > "+hap+"."+predictor+".auc")
    System("cat "+hap+"."+predictor+".auc | summary-stats > "+hap+".tmp")
    with open(hap+".tmp","rt") as IN:
        line=IN.readline()
        print("AUC_DISTRIBUTION",predictor,hap,line,sep="\t")

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=2):
    exit(ProgramName.get()+" <individual>\n")
(indiv,)=sys.argv[1:]

RNA=BASE+indiv+"/"+SUBDIR
os.chdir(RNA)
System(SRC+"tophat-to-junctions.py junctions.bed > junctions.txt")
if(not os.path.exists("temp")): System("mkdir temp")
for hap in (1,2):
    HAP=str(hap)
    System("grep -v ALT ../"+HAP+".aceplus.gff > temp/"+HAP+".anno.gff")
    os.chdir("temp")
    for predictor in PREDICTORS: getNovel(predictor,HAP)
    makeNovelZero(HAP)
    for predictor in PREDICTORS:
        rnaSupport(predictor,HAP,indiv)
        ROC(predictor,HAP)


