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
from Rex import Rex
rex=Rex()

BASE="/home/bmajoros/1000G/assembly"
KEEP=BASE+"/combined/splice-site-variants-rs.txt"
VCF="/home/bmajoros/1000G/vcf"

keep=set()
with open(KEEP) as IN:
    for line in IN:
        fields=line.rstrip().split(";")
        for field in fields: keep.add(field)
files=os.listdir(VCF)
for file in files:
    if(not rex.find(".headers",file)): continue
    with open(VCF+"/"+file) as IN:
        for line in IN:
            fields=line.rstrip().split()
            if(len(fields)!=2): continue
            #if(fields[0] not in keep): continue
            if(not rex.find("AF=([^;]+)",fields[1])): exit(fields[1])
            AF=None
            subfields=rex[1].split(",")
            if(len(subfields)>1):
                #print("XXX",line)
                #AF=float(subfields[0])
                #for f in subfields:
                #    if(abs(float(f)-0.5)<abs(AF-0.5)): AF=float(f)
                continue
            else: AF=float(rex[1])
            specific=""
            if(rex.find("(EAS_AF=.*SAS_AF=[^;]+)",fields[1])):
                specific=rex[1]
                subfields=specific.split(";")
                specific="\t".join(subfields)
            print(fields[0],AF,specific,sep="\t")




