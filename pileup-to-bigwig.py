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
import gzip
from Rex import Rex
rex=Rex()
import TempFilename
from GffTranscriptReader import GffTranscriptReader

MAX_LINES=100000

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=4):
    exit(ProgramName.get()+" <in.pileup.gz> <in.gff> <out.gz>\n")
(infile,gffFile,outfile)=sys.argv[1:]

# Allocate temp files
wigFile=TempFilename.generate("wig")
sizeFile=TempFilename.generate("sizes")

# Get gene lengths from GFF file
reader=GffTranscriptReader()
genes=reader.loadGenes(gffFile)
OUT=open(sizeFile,"wt")
for gene in genes:
    L=gene.getEnd()-gene.getBegin()
    print(gene.getID(),L,sep="\t",file=OUT)
OUT.close()

# Read pileup file and convert to wig
prevPos=-1
print("writing temp file",wigFile)
OUT=open(wigFile,"wt")
chrom=None
numLines=0
with gzip.open(infile,"rt") as IN:
    for line in IN:
        fields=line.split()
        if(len(fields)<3): continue
        (substrate,pos,reads)=fields[:3]
        pos=int(pos)
        #if(not rex.find("(\S+)_(\d)",substrate)): raise Exception(substrate)
        #gene=rex[1]; hap=int(rex[2])
        if(substrate!=chrom or pos!=prevPos+1):
            print("fixedStep chrom="+substrate+" start="+str(pos)+" step=1",
                  file=OUT)
            chrom=substrate
        print(reads,file=OUT)
        prevPos=int(pos)
        numLines+=1
        if(numLines>=MAX_LINES): break
OUT.close()

# Convert wig file to bigWig
os.system("wigToBigWig "+wigFile+" "+sizeFile+" "+outfile)

# Clean up
os.remove(wigFile)
os.remove(sizeFile)

