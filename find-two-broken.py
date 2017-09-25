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
from EssexParser import EssexParser

BASE="/home/bmajoros/1000G/assembly/combined"

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=3):
    exit(ProgramName.get()+" <indiv> <hap>\n")
(indiv,hap)=sys.argv[1:]

#infile=BASE+"/"+indiv+"/"+hap+".logreg.essex"
infile=BASE+"/"+indiv+"/"+hap+"-filtered-fixed.essex"
parser=EssexParser(infile)
while(True):
    root=parser.nextElem()
    if(root is None): break
    status=root.findChild("status")
    if(status is None): break
    array=status.findChildren("broken-donor")
    array.extend(status.findChildren("broken-acceptor"))
    numBroken=len(array)
    if(numBroken<2): continue
    print(numBroken,indiv,hap,root.getAttribute("gene-ID"),
          root.getAttribute("transcript-ID"),sep="\t")
    

