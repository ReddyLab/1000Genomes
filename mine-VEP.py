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

INFILE="/home/bmajoros/1000G/assembly/rna150/VEP.txt"

#=========================================================================
# main()
#=========================================================================
#if(len(sys.argv)!=2):
#    exit(ProgramName.get()+" <>\n")
#()=sys.argv[1:]

hash={}
with open(INFILE,"rt") as IN:
    IN.readline()
    for line in IN:
        fields=line.rstrip().split()
        if(len(fields)<5): continue
        (variant,pos,allele,effect,impact)=fields[:5]
        if(hash.get(variant,None) is None): hash[variant]=set()
        effects=effect.split(",")
        #print(variant,effects)
        for effect in effects:
            hash[variant].add(effect)

variants=hash.keys()
for variant in variants:
    print(variant,end="")
    effects=hash[variant]
    for effect in effects:
        print("\t"+effect,end="")
    print()






