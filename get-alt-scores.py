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
from EssexNode import EssexNode

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=2):
    exit(ProgramName.get()+" <in.essex>\n")
(infile,)=sys.argv[1:]

byChange={}
parser=EssexParser(infile)
while(True):
    elem=parser.nextElem()
    if(not elem): break
    alts=elem.findDescendent("alternate-structures")
    if(not alts): continue
    alts=alts.findChildren("transcript")
    for alt in alts:
        score=float(alt.getAttribute("score"))
        changeNode=alt.findChild("structure-change")
        changes=set()
        numElems=changeNode.numElements()
        for i in range(numElems):
            change=changeNode.getIthElem(i)
            if(EssexNode.isaNode(change)): continue
            changes.add(change)
        changeList=[]
        for change in changes: changeList.append(change)
        changeList.sort()
        key="_".join(changeList)
        if(byChange.get(key,None)==None): byChange[key]=[]
        byChange[key].append(score)
        break
keys=byChange.keys()
for key in keys:
    array=byChange[key]
    filename="scores."+key
    with open(filename,"wt") as OUT:
        for score in array:
            print(score,file=OUT)
