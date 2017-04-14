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
from SlurmWriter import SlurmWriter

THOUSAND="/home/bmajoros/1000G/assembly"
GEUVADIS=THOUSAND+"/geuvadis.txt"
SLURM_DIR=THOUSAND+"/novel-slurms"
JOB_NAME="NOVEL"
MAX_PARALLEL=1000
NICE=500
MEMORY=0
THREADS=0

#=========================================================================
# main()
#=========================================================================

dirs=[]
with open(GEUVADIS,"rt") as IN:
    for line in IN:
        id=line.rstrip()
        dir=THOUSAND+"/combined/"+id
        dirs.append(dir)

writer=SlurmWriter()
for dir in dirs:
    writer.addCommand("cd "+dir+"\n"+
                      THOUSAND+"/src/get-novel-features.py "+
                      "1.aceplus.gff > 1.novel-features\n"+
                      THOUSAND+"/src/get-novel-features.py "+
                      "2.aceplus.gff > 2.novel-features\n"
                      )
writer.setQueue("new,all")
writer.nice(NICE)
if(MEMORY): writer.mem(MEMORY)
if(THREADS): writer.threads(THREADS)
writer.writeArrayScript(SLURM_DIR,JOB_NAME,MAX_PARALLEL)


