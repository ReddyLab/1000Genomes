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

DBSNP="/home/bmajoros/1000G/assembly/dbSNP/snp147Common.txt"

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=2):
    exit(ProgramName.get()+" <combined.txt>\n")
(infile,)=sys.argv[1:]

variants=set()
with open(infile,"rt") as IN:
    for line in IN:
        fields=line.rstrip().split()
        if(len(fields)<10): continue
        (denovo,spliceType,gene,hap,geneType,transID,altID,strand,score,\
             begin,length,fate,identity,variantID,spliceActivity,reads1,\
             reads2)=fields
        if(denovo!="denovo"): continue
        variants.add(variantID)

with open(DBSNP,"rt") as IN:
    for line in IN:
        fields=line.rstrip().split("\t")
        if(len(fields)<10): continue
        variant=fields[4]
        effect=fields[15]
        if(variant not in variants): continue
        print(variant,effect)

