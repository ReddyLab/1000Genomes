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
from EssexParser import EssexParser
import sys
import glob

BASE="/home/bmajoros/1000G/assembly/combined"

FILES=glob.glob(BASE+"/*/*.ice9")
for file in FILES:
    print(file)
    parser=EssexParser(file)
    while(True):
        root=parser.nextElem()
        if(not root): break
        alts=root.pathQuery("report/status/alternate-structures")
        if(not alts): continue
        #print("alt structs found",flush=True)
        transcripts=alts.findChildren("transcript")
        #print(len(transcripts),"alt transcripts found",flush=True)
        scores={}
        for transcript in transcripts:
            change=transcript.getAttribute("structure-change")
            score=transcript.getAttribute("score")
            if(change not in scores): scores[change]=0.0
            scores[change]+=float(score)
        if(len(scores)!=2): continue
        skippingScore=scores["exon-skipping"]
        crypticScore=scores["cryptic-site"]
        print(root.getAttribute("substrate"),
              root.getAttribute("transcript-ID"),
              skippingScore,
              crypticScore,flush=True)
    parser.close()



