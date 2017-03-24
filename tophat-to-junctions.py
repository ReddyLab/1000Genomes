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
import sys
import ProgramName
from Rex import Rex
rex=Rex()

if(len(sys.argv)!=2): exit(ProgramName.get()+" <junctions.bed> ")
(junctionsFile,)=sys.argv[1:]

#============================= main() =================================


# Read junctions file
junctions={}
with open(junctionsFile) as IN:
    for line in IN:
        fields=line.split()
        if(len(fields)<12): continue
        (substrate,begin,end,juncID,count,strand,begin2,end2,color,two,
         offsets,last)=fields
        begin=int(begin); end=int(end)
        (left,right)=offsets.split(",")
        left=int(left); right=int(right)
        if(not rex.find("(\S+)_(\d+)",substrate)):
            raise Exception("can't parse substrate"+substrate)
        substrate=rex[1]
        hap=rex[2]
        print(substrate,hap,begin+left,end-right,count,strand,sep="\t")


