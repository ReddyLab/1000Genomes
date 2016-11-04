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
import os

COMBINED="/home/bmajoros/1000G/assembly/combined"

def readBrokenSitesFile(infile,hash):
    with open(infile,"rt") as IN:
        while(True):
            line=IN.readline()
            if(line==""): break
            fields=line.split()
            if(len(fields)<10): continue
            (indiv,hap,geneID,transID,strand,exonNum,siteType,begin,
             pos,end)=fields
            hash[geneID]={"exon":exonNum,"type":siteType}

#============================= main() =================================

hash={}
subdirs=os.listdir(COMBINED)
for subdir in subdirs:
    if(not os.path.exists(COMBINED+"/"+subdir+"/1.broken-sites")): continue
    readBrokenSitesFile(COMBINED+"/"+subdir+"/1.broken-sites",hash)
    readBrokenSitesFile(COMBINED+"/"+subdir+"/2.broken-sites",hash)
keys=hash.keys()
for key in keys:
    rec=hash[key]
    print(key,rec["exon"],rec["type"],sep="\t")




