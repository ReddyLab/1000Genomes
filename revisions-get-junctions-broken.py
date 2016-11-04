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
from Transcript import Transcript
from Interval import Interval
if(len(sys.argv)!=3): exit(sys.argv[0]+" <in.broken-sites> <junctions.bed>")
(infile,junctionsFile)=sys.argv[1:]

#============================= main() =================================

# Read broken-sites file
sites={}
with open(infile,"rt") as IN:
    while(True):
        line=IN.readline()
        if(line==""): break
        fields=line.split()
        if(len(fields)<10): continue
        (indiv,hap,geneID,transID,strand,exonNum,siteType,begin,pos,end)=fields
        substrate=geneID+"_"+hap
        sites[substrate]=fields
junctions={}
keys=sites.keys()

# Read junctions file
with open(junctionsFile,"rt") as IN:
    while(True):
        line=IN.readline()
        if(line==""): break;
        fields=line.split()
        if(len(fields)<12): continue
        (substrate,begin,end,juncID,count,strand,begin2,end2,color,two,
         offsets,last)=fields
        begin=int(begin); end=int(end)
        array=junctions.get(substrate,None)
        if(array is None): array=junctions[substrate]=[]
        (left,right)=offsets.split(",")
        left=int(left); right=int(right)
        array.append([substrate,begin+left,end-right,count])

# Process each site
for substrate in keys:
    site=sites[substrate]
    (indiv,hap,geneID,transID,strand,exonNum,siteType,begin,pos,end)=site
    begin=int(begin); pos=int(pos); end=int(end)
    interval=Interval(pos-70,pos+70)
    if(interval.begin<begin): interval.begin=begin
    if(interval.end>end): interval.end=end
    juncs=junctions.get(substrate,[])
    sum=0
    for junc in juncs:
        (substrate,begin,end,count)=junc
        if(interval.contains(begin) or interval.contains(end)): sum+=int(count)
    print(indiv,hap,geneID,transID,strand,exonNum,siteType,begin,pos,end,
          count,sep="\t",flush=True)


