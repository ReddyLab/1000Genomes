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

PREDICTORS=("logreg","shendure","MC","splice-only","arab")
BASE="/home/bmajoros/1000G/assembly/combined/"
SRC="/home/bmajoros/1000G/src/"
SUBDIR="/RNA6"

def System(cmd):
    print("COMMAND: "+cmd)
    os.system(cmd)

def getNovel(predictor,hap):
    print("Processing",predictor,hap)
    #System("grep ALT ../../"+hap+"."+predictor+".gff > "+hap+".tmp ; cat "+hap+".anno.gff "+hap+".tmp > "+hap+"."+predictor+".gff ; rm "+hap+".tmp")
    System(SRC+"get-novel-features.py "+hap+"."+predictor+".gff"+" | grep -v intron-retention > "+hap+"."+predictor+".novel.tmp")

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

def rnaSupport(predictor):
        #System("cat "+hap+".novel.tmp novel-zero.txt > novel.txt")
    #System("~/1000G/src/aceplus-rna-support.py ~/1000G/assembly/combined/HG00096 RNA6 ~/1000G/assembly/expressed.txt 0 > support.txt")
    #System(cat support.txt | cut -f2,3 | perl -ne 'chomp;@f=split;($sup,$score)=@f;$cat=$sup>0 ? 1 : 0;print "$score\t$cat\n"' > roc.tmp ; roc.pl roc.tmp > tmp.roc ; area-under-ROC.pl tmp.roc ")
    #System("~/1000G/src/aceplus-roc-distribution.py support.txt 1000 > scores.txt")
    #System("cat scores.txt | summary-stats")


#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=3):
    exit(ProgramName.get()+" <individual> <haplotype>\n")
(indiv,HAP)=sys.argv[1:]

RNA=BASE+indiv+SUBDIR
os.chdir(RNA)
if(not os.path.exists("temp")): System("mkdir temp")
System("grep -v ALT ../"+HAP+".aceplus.gff > temp/"+HAP+".anno.gff")
os.chdir("temp")
for predictor in PREDICTORS:
    getNovel(predictor,HAP)
makeNovelZero(HAP)



