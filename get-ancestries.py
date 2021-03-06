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

ANCESTRIES="/home/bmajoros/1000G/vcf/ancestries.txt"

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=2):
    exit(ProgramName.get()+" <IDs.txt>\n")
(infile,)=sys.argv[1:]

keep=set()
IN=open(infile,"rt")
for line in IN: keep.add(line.rstrip())
IN.close()

IN=open(ANCESTRIES,"rt")
IN.readline()
for line in IN:
    fields=line.rstrip().split()
    if(len(fields)!=2): continue
    (id,ancestry)=fields
    if(id in keep): print(ancestry)
IN.close()


